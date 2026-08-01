import 'package:cardfolio_app/features/card_sets/domain/card_set_models.dart';
import 'package:cardfolio_app/features/card_sets/data/local/card_set_database.dart';
import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:cardfolio_app/features/organization/data/local/organization_database.dart';
import 'package:cardfolio_app/features/organization/data/local/organization_query_database.dart';
import 'package:cardfolio_app/features/organization/domain/organization_models.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  final now = DateTime.utc(2026, 7, 28, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Future<void> insertCard(String suffix, {int quantity = 1}) {
    return db.insertCardGraph(
      CardRowGraph(
        definition: CardDefinitionsCompanion.insert(
          id: 'definition-$suffix',
          name: '卡片$suffix',
          city: const Value('上海'),
          createdAt: now,
          updatedAt: now,
        ),
        item: CardItemsCompanion.insert(
          id: 'item-$suffix',
          definitionId: 'definition-$suffix',
          quantity: Value(quantity),
          createdAt: now,
          updatedAt: now,
        ),
        images: <CardImagesCompanion>[
          CardImagesCompanion.insert(
            id: 'image-$suffix',
            cardItemId: 'item-$suffix',
            kind: CardImageKind.front,
            relativePath: 'originals/item-$suffix/image-$suffix.jpg',
            checksum: 'sha256-$suffix',
            isCover: const Value(true),
            createdAt: now,
          ),
        ],
      ),
    );
  }

  Future<void> insertSet(String suffix) {
    return db.createCardSet(
      request: CreateCardSetRequest(
        id: 'set-$suffix',
        name: '套卡$suffix',
        countKnown: false,
      ).normalized(),
      now: now,
    );
  }

  test('creates and renames active tags with normalized uniqueness', () async {
    await db.createOrganizationTag(
      request: const CreateTagRequest(
        id: 'tag-1',
        name: ' Metro ',
      ).normalized(),
      now: now,
    );

    await expectLater(
      db.createOrganizationTag(
        request: const CreateTagRequest(
          id: 'tag-2',
          name: 'metro',
        ).normalized(),
        now: now,
      ),
      throwsA(anything),
    );

    await db.renameOrganizationTag(
      request: const RenameTagRequest(id: 'tag-1', name: ' 地铁 ').normalized(),
      now: now.add(const Duration(minutes: 1)),
    );
    final tag = await db.select(db.tags).getSingle();
    expect(tag.name, '地铁');
    expect(tag.normalizedName, '地铁');
    expect(tag.version, 2);
  });

  test(
    'saves card metadata, relationships, and typed values atomically',
    () async {
      await insertCard('1');
      await db.createOrganizationTag(
        request: const CreateTagRequest(id: 'tag-1', name: '限定').normalized(),
        now: now,
      );
      await db.createOrganizationField(
        request: const CreateCustomFieldRequest(
          id: 'field-text',
          name: '品相说明',
          fieldType: CustomFieldType.text,
        ).normalized(),
        now: now,
      );
      await db.saveOrganizationSeries(
        request: const SaveSeriesRequest(
          id: 'series-1',
          name: '世博会',
        ).normalized(),
        now: now,
      );

      await db.saveCardOrganization(
        request: SaveCardOrganizationRequest(
          cardItemId: 'item-1',
          cardType: '纪念卡',
          needsCompletion: true,
          acquiredAt: DateTime.utc(2026, 6, 1),
          tagIds: const <String>['tag-1'],
          seriesIds: const <String>['series-1'],
          fieldValues: const <CustomFieldValueInput>[
            CustomFieldValueInput.text(fieldId: 'field-text', value: '票面完好'),
          ],
        ).normalized(),
        now: now.add(const Duration(minutes: 1)),
      );

      final definition = await db.select(db.cardDefinitions).getSingle();
      final item = await db.select(db.cardItems).getSingle();
      final tagLink = await db.select(db.cardTags).getSingle();
      final seriesLink = await db.select(db.seriesCards).getSingle();
      final fieldValue = await db
          .select(db.organizationFieldValues)
          .getSingle();
      expect(definition.cardType, '纪念卡');
      expect(definition.needsCompletion, isTrue);
      expect(item.acquiredAt?.toUtc(), DateTime.utc(2026, 6, 1));
      expect(tagLink.definitionId, 'definition-1');
      expect(seriesLink.seriesId, 'series-1');
      expect(fieldValue.textValue, '票面完好');
      expect(fieldValue.numberValue, isNull);
      expect(fieldValue.dateValue, isNull);
    },
  );

  test(
    'merge migrates unique relationships and rolls back on failure',
    () async {
      await insertCard('1');
      await insertCard('2');
      for (final id in <String>['source', 'target']) {
        await db.createOrganizationTag(
          request: CreateTagRequest(id: id, name: id).normalized(),
          now: now,
        );
      }
      await db.replaceCardTags(
        definitionId: 'definition-1',
        tagIds: const <String>['source', 'target'],
        now: now,
      );
      await db.replaceCardTags(
        definitionId: 'definition-2',
        tagIds: const <String>['source'],
        now: now,
      );

      await db.mergeOrganizationTags(
        request: const MergeTagsRequest(
          sourceTagId: 'source',
          targetTagId: 'target',
        ).normalized(),
        now: now,
      );

      final targetLinks = await (db.select(
        db.cardTags,
      )..where((link) => link.tagId.equals('target'))).get();
      expect(targetLinks.map((link) => link.definitionId).toSet(), <String>{
        'definition-1',
        'definition-2',
      });
      final source = await (db.select(
        db.tags,
      )..where((tag) => tag.id.equals('source'))).getSingle();
      expect(source.deletedAt?.toUtc(), now);

      await db.createOrganizationTag(
        request: const CreateTagRequest(
          id: 'rollback',
          name: 'rollback',
        ).normalized(),
        now: now,
      );
      await db.replaceCardTags(
        definitionId: 'definition-1',
        tagIds: const <String>['rollback', 'target'],
        now: now,
      );
      await db.customStatement(
        "CREATE TRIGGER abort_tag_delete BEFORE UPDATE OF deleted_at ON tags "
        "WHEN OLD.id = 'rollback' BEGIN SELECT RAISE(ABORT, 'stop'); END;",
      );

      await expectLater(
        db.mergeOrganizationTags(
          request: const MergeTagsRequest(
            sourceTagId: 'rollback',
            targetTagId: 'target',
          ).normalized(),
          now: now,
        ),
        throwsA(anything),
      );
      final rollback = await (db.select(
        db.tags,
      )..where((tag) => tag.id.equals('rollback'))).getSingle();
      expect(rollback.deletedAt, isNull);
      expect(
        await (db.select(
          db.cardTags,
        )..where((link) => link.tagId.equals('rollback'))).get(),
        hasLength(1),
      );
    },
  );

  test(
    'series can contain cards and sets and objects can be in many series',
    () async {
      await insertCard('1');
      await insertSet('1');

      for (final id in <String>['a', 'b']) {
        await db.saveOrganizationSeries(
          request: SaveSeriesRequest(
            id: 'series-$id',
            name: '系列$id',
            definitionIds: const <String>['definition-1'],
            setIds: const <String>['set-1'],
          ).normalized(),
          now: now,
        );
      }

      expect(await db.select(db.seriesRecords).get(), hasLength(2));
      expect(await db.select(db.seriesCards).get(), hasLength(2));
      expect(await db.select(db.seriesSets).get(), hasLength(2));
    },
  );

  test('series detail groups set members and exposes the set cover', () async {
    await insertCard('1');
    await insertSet('1');
    await db.addCardSetMember(
      request: const AddCardSetMemberRequest.existing(
        id: 'member-1',
        setId: 'set-1',
        definitionId: 'definition-1',
      ).normalized(),
      now: now,
    );
    await db.setCardSetStandaloneCover(
      setId: 'set-1',
      relativePath: 'originals/set-set-1/cover.jpg',
      now: now,
    );
    await db.saveOrganizationSeries(
      request: const SaveSeriesRequest(
        id: 'series-1',
        name: '系列 1',
        definitionIds: <String>['definition-1'],
        setIds: <String>['set-1'],
      ).normalized(),
      now: now,
    );

    final detail = await db.watchOrganizationSeriesDetail('series-1').first;

    expect(detail, isNotNull);
    expect(detail!.setGroups, hasLength(1));
    expect(detail.setGroups.single.set.id, 'set-1');
    expect(
      detail.setGroups.single.set.coverRelativePath,
      'originals/set-set-1/cover.jpg',
    );
    expect(detail.setGroups.single.cards.map((card) => card.id), <String>[
      'definition-1',
    ]);
    expect(detail.setGroups.single.cards.single.cardItemId, 'item-1');
  });

  test('field deletion reports impact and preserves hidden values', () async {
    await insertCard('1');
    await db.createOrganizationField(
      request: const CreateCustomFieldRequest(
        id: 'field-1',
        name: '票面日期',
        fieldType: CustomFieldType.date,
      ).normalized(),
      now: now,
    );
    await db.saveCardOrganization(
      request: SaveCardOrganizationRequest(
        cardItemId: 'item-1',
        fieldValues: <CustomFieldValueInput>[
          CustomFieldValueInput.date(
            fieldId: 'field-1',
            value: DateTime.utc(2026, 7, 1),
          ),
        ],
      ).normalized(),
      now: now,
    );

    final impact = await db.organizationFieldDeletionImpact('field-1');
    expect(impact.valueCount, 1);

    await db.deleteOrganizationField(fieldId: 'field-1', now: now);
    final definition = await db
        .select(db.organizationFieldDefinitions)
        .getSingle();
    expect(definition.deletedAt?.toUtc(), now);
    expect(await db.select(db.organizationFieldValues).get(), hasLength(1));
  });
}
