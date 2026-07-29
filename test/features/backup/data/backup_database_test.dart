import 'dart:convert';

import 'package:cardfolio_app/features/backup/data/backup_database.dart';
import 'package:cardfolio_app/features/backup/domain/backup_models.dart';
import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:cardfolio_app/features/organization/domain/organization_models.dart';
import 'package:cardfolio_app/features/purchases/domain/purchase_models.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase source;
  late AppDatabase target;

  setUp(() {
    source = AppDatabase(NativeDatabase.memory());
    target = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await source.close();
    await target.close();
  });

  test(
    'all logical entities round-trip with stable UTC and exact money',
    () async {
      await _seedAllEntities(source);

      final snapshot = await source.exportLogicalBackup();

      expect(snapshot.entityCounts, <String, int>{
        for (final name in BackupSnapshot.entityNames) name: 1,
      });
      final json = snapshot.toJson();
      final entities = json['entities']! as Map<String, Object?>;
      final definitions =
          entities['cardDefinitions']! as List<Map<String, Object?>>;
      final purchases = entities['purchases']! as List<Map<String, Object?>>;
      expect(definitions.single['createdAt'], '2026-07-01T08:00:00.000Z');
      expect(purchases.single['amountMinor'], 50000);

      final result = await target.importLogicalBackup(
        snapshot,
        mode: BackupMode.emptyLibrary,
      );

      expect(result.addedCount, 17);
      expect(result.skippedCount, 0);
      expect(
        jsonEncode((await target.exportLogicalBackup()).toJson()),
        jsonEncode(snapshot.toJson()),
      );
    },
  );

  test('broken relationships fail without modifying the target', () async {
    await _seedAllEntities(source);
    final raw =
        jsonDecode(jsonEncode((await source.exportLogicalBackup()).toJson()))
            as Map<String, Object?>;
    final entities = raw['entities']! as Map<String, Object?>;
    final items = entities['cardItems']! as List<Object?>;
    (items.single! as Map<String, Object?>)['definitionId'] =
        '00000000-0000-4000-8000-000000000099';
    final broken = BackupSnapshot.fromJson(raw);

    await expectLater(
      target.importLogicalBackup(broken, mode: BackupMode.emptyLibrary),
      throwsA(isA<BackupValidationFailure>()),
    );

    expect((await target.exportLogicalBackup()).totalEntityCount, 0);
  });

  test('non-UUID entity identifiers fail validation', () async {
    await _seedAllEntities(source);
    final raw =
        jsonDecode(jsonEncode((await source.exportLogicalBackup()).toJson()))
            as Map<String, Object?>;
    final entities = raw['entities']! as Map<String, Object?>;
    final tags = entities['tags']! as List<Object?>;
    final cardTags = entities['cardTags']! as List<Object?>;
    (tags.single! as Map<String, Object?>)['id'] = 'not-a-uuid';
    (cardTags.single! as Map<String, Object?>)['tagId'] = 'not-a-uuid';
    final malformed = BackupSnapshot.fromJson(raw);

    await expectLater(
      target.importLogicalBackup(malformed, mode: BackupMode.emptyLibrary),
      throwsA(isA<BackupValidationFailure>()),
    );
    expect((await target.exportLogicalBackup()).totalEntityCount, 0);
  });

  test(
    'merge skips identical rows and blocks same-key different content',
    () async {
      await _seedAllEntities(source);
      final snapshot = await source.exportLogicalBackup();
      await target.importLogicalBackup(snapshot, mode: BackupMode.emptyLibrary);

      final identical = await target.previewLogicalImport(
        snapshot,
        mode: BackupMode.mergeAddOnly,
      );
      expect(identical.addedCount, 0);
      expect(identical.skippedCount, 17);
      expect(identical.conflicts, isEmpty);

      final raw =
          jsonDecode(jsonEncode(snapshot.toJson())) as Map<String, Object?>;
      final entities = raw['entities']! as Map<String, Object?>;
      final definitions = entities['cardDefinitions']! as List<Object?>;
      (definitions.single! as Map<String, Object?>)['name'] = '冲突名称';
      final conflicting = BackupSnapshot.fromJson(raw);

      final preview = await target.previewLogicalImport(
        conflicting,
        mode: BackupMode.mergeAddOnly,
      );
      expect(preview.conflicts, hasLength(1));
      expect(preview.conflicts.single.entity, 'cardDefinitions');
      await expectLater(
        target.importLogicalBackup(conflicting, mode: BackupMode.mergeAddOnly),
        throwsA(isA<BackupValidationFailure>()),
      );
      expect(
        (await target.select(target.cardDefinitions).getSingle()).name,
        '樱花纪念卡',
      );
    },
  );
}

const String _definitionId = '00000000-0000-4000-8000-000000000001';
const String _itemId = '00000000-0000-4000-8000-000000000002';
const String _imageId = '00000000-0000-4000-8000-000000000003';
const String _setId = '00000000-0000-4000-8000-000000000004';
const String _memberId = '00000000-0000-4000-8000-000000000005';
const String _tagId = '00000000-0000-4000-8000-000000000006';
const String _seriesId = '00000000-0000-4000-8000-000000000007';
const String _fieldId = '00000000-0000-4000-8000-000000000008';
const String _purchaseId = '00000000-0000-4000-8000-000000000009';

Future<void> _seedAllEntities(AppDatabase db) async {
  final createdAt = DateTime.utc(2026, 7, 1, 8);
  await db
      .into(db.cardDefinitions)
      .insert(
        CardDefinitionsCompanion.insert(
          id: _definitionId,
          name: '樱花纪念卡',
          city: const Value('上海'),
          version: const Value(2),
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );
  await db
      .into(db.cardItems)
      .insert(
        CardItemsCompanion.insert(
          id: _itemId,
          definitionId: _definitionId,
          quantity: const Value(2),
          acquiredAt: Value(createdAt),
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );
  await db
      .into(db.cardImages)
      .insert(
        CardImagesCompanion.insert(
          id: _imageId,
          cardItemId: _itemId,
          kind: CardImageKind.front,
          relativePath: 'originals/$_itemId/$_imageId.jpg',
          derivedRelativePath: Value('derived/$_itemId/$_imageId.webp'),
          isCover: const Value(true),
          checksum:
              'ca978112ca1bbdcafac231b39a23dc4d'
              'a786eff8147c4e72b9807785afee48bb',
          createdAt: createdAt,
        ),
      );
  await db
      .into(db.cardSets)
      .insert(
        CardSetsCompanion.insert(
          id: _setId,
          name: '春日套卡',
          countKnown: true,
          expectedCount: const Value(1),
          coverImageId: const Value(_imageId),
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );
  await db
      .into(db.cardSetMembers)
      .insert(
        CardSetMembersCompanion.insert(
          id: _memberId,
          setId: _setId,
          definitionId: _definitionId,
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );
  await db
      .into(db.tags)
      .insert(
        TagsCompanion.insert(
          id: _tagId,
          name: '樱花',
          normalizedName: '樱花',
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );
  await db
      .into(db.cardTags)
      .insert(
        CardTagsCompanion.insert(
          tagId: _tagId,
          definitionId: _definitionId,
          createdAt: createdAt,
        ),
      );
  await db
      .into(db.seriesRecords)
      .insert(
        SeriesRecordsCompanion.insert(
          id: _seriesId,
          name: '城市纪念系列',
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );
  await db
      .into(db.seriesCards)
      .insert(
        SeriesCardsCompanion.insert(
          seriesId: _seriesId,
          definitionId: _definitionId,
          createdAt: createdAt,
        ),
      );
  await db
      .into(db.seriesSets)
      .insert(
        SeriesSetsCompanion.insert(
          seriesId: _seriesId,
          setId: _setId,
          createdAt: createdAt,
        ),
      );
  await db
      .into(db.organizationFieldDefinitions)
      .insert(
        OrganizationFieldDefinitionsCompanion.insert(
          id: _fieldId,
          name: '票价',
          normalizedName: '票价',
          fieldType: CustomFieldType.number,
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );
  await db
      .into(db.organizationFieldValues)
      .insert(
        OrganizationFieldValuesCompanion.insert(
          fieldId: _fieldId,
          definitionId: _definitionId,
          numberValue: const Value(18.5),
          updatedAt: createdAt,
        ),
      );
  await db
      .into(db.purchases)
      .insert(
        PurchasesCompanion.insert(
          id: _purchaseId,
          purchasedAt: createdAt,
          amountMinor: 50000,
          currency: 'CNY',
          shippingMinor: const Value(1200),
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );
  await db
      .into(db.purchaseItems)
      .insert(
        PurchaseItemsCompanion.insert(
          purchaseId: _purchaseId,
          targetType: PurchaseTargetType.card,
          targetId: _itemId,
          targetName: '樱花纪念卡',
          allocatedMinor: const Value(50000),
          createdAt: createdAt,
        ),
      );
  await db
      .into(db.exchangeRates)
      .insert(
        ExchangeRatesCompanion.insert(
          baseCurrency: 'USD',
          quoteCurrency: 'CNY',
          rateDate: createdAt,
          numerator: 725,
          denominator: 100,
          source: 'manual',
          capturedAt: createdAt,
        ),
      );
  await db
      .into(db.recycleBinSettingsRows)
      .insert(
        RecycleBinSettingsRowsCompanion.insert(
          id: const Value(1),
          retentionDays: const Value(30),
          updatedAt: createdAt,
        ),
      );
  await db
      .into(db.fileCleanupQueueEntries)
      .insert(
        FileCleanupQueueEntriesCompanion.insert(
          relativePath: 'originals/removed/file.jpg',
          createdAt: createdAt,
          attemptCount: const Value(1),
          lastAttemptAt: Value(createdAt),
        ),
      );
}
