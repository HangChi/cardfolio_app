import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/export/data/database_csv_export_repository.dart';
import 'package:cardfolio_app/features/organization/domain/organization_models.dart';
import 'package:cardfolio_app/features/purchases/domain/purchase_models.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('loads complete CSV rows with a fixed set of batch queries', () async {
    final now = DateTime.utc(2026, 8, 29, 8);
    const definitionId = 'definition-1';
    const itemId = 'item-1';
    const tagId = 'tag-1';
    const seriesId = 'series-1';
    const setId = 'set-1';

    await database
        .into(database.cardDefinitions)
        .insert(
          CardDefinitionsCompanion.insert(
            id: definitionId,
            name: '城市纪念卡',
            city: const Value('上海'),
            issuer: const Value('交通公司'),
            issuedAt: const Value('2026-08'),
            code: const Value('SH-001'),
            notes: const Value('测试备注'),
            cardType: const Value('交通卡'),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.cardItems)
        .insert(
          CardItemsCompanion.insert(
            id: itemId,
            definitionId: definitionId,
            quantity: const Value(2),
            acquiredAt: Value(DateTime.utc(2026, 8, 20)),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.tags)
        .insert(
          TagsCompanion.insert(
            id: tagId,
            name: '纪念卡',
            normalizedName: '纪念卡',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.cardTags)
        .insert(
          CardTagsCompanion.insert(
            tagId: tagId,
            definitionId: definitionId,
            createdAt: now,
          ),
        );
    await database
        .into(database.seriesRecords)
        .insert(
          SeriesRecordsCompanion.insert(
            id: seriesId,
            name: '上海集卡册',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.seriesCards)
        .insert(
          SeriesCardsCompanion.insert(
            seriesId: seriesId,
            definitionId: definitionId,
            createdAt: now,
          ),
        );
    await database
        .into(database.cardSets)
        .insert(
          CardSetsCompanion.insert(
            id: setId,
            name: '城市套卡',
            countKnown: false,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.cardSetMembers)
        .insert(
          CardSetMembersCompanion.insert(
            id: 'member-1',
            setId: setId,
            definitionId: definitionId,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await _insertTextField(
      database,
      id: 'condition-field',
      name: '品相',
      definitionId: definitionId,
      value: '全新',
      now: now,
    );
    await _insertNumberField(
      database,
      id: 'price-field',
      name: '发售价（元）',
      definitionId: definitionId,
      value: 20.5,
      now: now,
    );
    final purchaseId = cardEntryCostPurchaseId(itemId);
    await database
        .into(database.purchases)
        .insert(
          PurchasesCompanion.insert(
            id: purchaseId,
            purchasedAt: now,
            amountMinor: 1250,
            currency: 'CNY',
            shippingMinor: const Value(300),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.purchaseItems)
        .insert(
          PurchaseItemsCompanion.insert(
            purchaseId: purchaseId,
            targetType: PurchaseTargetType.card,
            targetId: itemId,
            targetName: '城市纪念卡',
            createdAt: now,
          ),
        );

    final rows = await DatabaseCsvExportRepository(database).loadRows();

    expect(rows, hasLength(1));
    final row = rows.single;
    expect(row.name, '城市纪念卡');
    expect(row.quantity, 2);
    expect(row.acquiredAt, '2026-08-20');
    expect(row.tags, <String>['纪念卡']);
    expect(row.albums, <String>['上海集卡册']);
    expect(row.cardSets, <String>['城市套卡']);
    expect(row.condition, '全新');
    expect(row.issuePrice, '20.50');
    expect(row.amount, '12.50');
    expect(row.shipping, '3.00');
  });
}

Future<void> _insertTextField(
  AppDatabase database, {
  required String id,
  required String name,
  required String definitionId,
  required String value,
  required DateTime now,
}) async {
  await database
      .into(database.organizationFieldDefinitions)
      .insert(
        OrganizationFieldDefinitionsCompanion.insert(
          id: id,
          name: name,
          normalizedName: name,
          fieldType: CustomFieldType.text,
          createdAt: now,
          updatedAt: now,
        ),
      );
  await database
      .into(database.organizationFieldValues)
      .insert(
        OrganizationFieldValuesCompanion.insert(
          fieldId: id,
          definitionId: definitionId,
          textValue: Value(value),
          updatedAt: now,
        ),
      );
}

Future<void> _insertNumberField(
  AppDatabase database, {
  required String id,
  required String name,
  required String definitionId,
  required double value,
  required DateTime now,
}) async {
  await database
      .into(database.organizationFieldDefinitions)
      .insert(
        OrganizationFieldDefinitionsCompanion.insert(
          id: id,
          name: name,
          normalizedName: name,
          fieldType: CustomFieldType.number,
          createdAt: now,
          updatedAt: now,
        ),
      );
  await database
      .into(database.organizationFieldValues)
      .insert(
        OrganizationFieldValuesCompanion.insert(
          fieldId: id,
          definitionId: definitionId,
          numberValue: Value(value),
          updatedAt: now,
        ),
      );
}
