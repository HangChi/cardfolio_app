// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart' hide isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated/schema.dart';
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test('v2 card data survives the v3 card-set migration', () async {
    final schema = await verifier.schemaAt(2);
    final oldDb = v2.DatabaseAtV2(schema.newConnection());
    final createdAt =
        DateTime.utc(2026, 7, 27).millisecondsSinceEpoch ~/
        Duration.millisecondsPerSecond;
    await oldDb
        .into(oldDb.cardDefinitions)
        .insert(
          v2.CardDefinitionsCompanion.insert(
            id: 'definition-1',
            name: '樱花纪念卡',
            createdAt: createdAt,
            updatedAt: createdAt,
          ),
        );
    await oldDb
        .into(oldDb.cardItems)
        .insert(
          v2.CardItemsCompanion.insert(
            id: 'item-1',
            definitionId: 'definition-1',
            createdAt: createdAt,
            updatedAt: createdAt,
          ),
        );
    await oldDb
        .into(oldDb.cardImages)
        .insert(
          v2.CardImagesCompanion.insert(
            id: 'image-1',
            cardItemId: 'item-1',
            kind: 'front',
            relativePath: 'originals/item-1/image-1.jpg',
            isCover: const Value(1),
            checksum: 'sha256-abc',
            createdAt: createdAt,
          ),
        );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 4);

    final card = await db.watchCardDetail('item-1').first;
    expect(card?.name, '樱花纪念卡');
    expect(card?.cover?.id, 'image-1');
    expect(await db.select(db.cardSets).get(), isEmpty);
    await db.close();
  });

  test('v3 card and set data survive the v4 organization migration', () async {
    final schema = await verifier.schemaAt(3);
    final oldDb = v3.DatabaseAtV3(schema.newConnection());
    final createdAt =
        DateTime.utc(2026, 7, 28).millisecondsSinceEpoch ~/
        Duration.millisecondsPerSecond;
    await oldDb
        .into(oldDb.cardDefinitions)
        .insert(
          v3.CardDefinitionsCompanion.insert(
            id: 'definition-v3',
            name: '迁移前卡片',
            city: const Value('上海'),
            createdAt: createdAt,
            updatedAt: createdAt,
          ),
        );
    await oldDb
        .into(oldDb.cardItems)
        .insert(
          v3.CardItemsCompanion.insert(
            id: 'item-v3',
            definitionId: 'definition-v3',
            createdAt: createdAt,
            updatedAt: createdAt,
          ),
        );
    await oldDb
        .into(oldDb.cardImages)
        .insert(
          v3.CardImagesCompanion.insert(
            id: 'image-v3',
            cardItemId: 'item-v3',
            kind: 'front',
            relativePath: 'originals/item-v3/image-v3.jpg',
            isCover: const Value(1),
            checksum: 'sha256-v3',
            createdAt: createdAt,
          ),
        );
    await oldDb
        .into(oldDb.cardSets)
        .insert(
          v3.CardSetsCompanion.insert(
            id: 'set-v3',
            name: '迁移前套卡',
            countKnown: 0,
            createdAt: createdAt,
            updatedAt: createdAt,
          ),
        );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 4);

    final card = await db.watchCardDetail('item-v3').first;
    expect(card?.name, '迁移前卡片');
    expect(card?.city, '上海');
    final definition = await db.select(db.cardDefinitions).getSingle();
    expect(definition.cardType, isNull);
    expect(definition.needsCompletion, isFalse);
    final item = await db.select(db.cardItems).getSingle();
    expect(item.acquiredAt, isNull);
    expect(await db.select(db.tags).get(), isEmpty);
    expect(await db.select(db.seriesRecords).get(), isEmpty);
    expect(await db.select(db.organizationFieldDefinitions).get(), isEmpty);
    await db.close();
  });
}
