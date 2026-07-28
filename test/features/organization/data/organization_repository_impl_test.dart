import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/core/time/clock.dart';
import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:cardfolio_app/features/organization/data/organization_repository_impl.dart';
import 'package:cardfolio_app/features/organization/domain/organization_models.dart';
import 'package:cardfolio_app/features/organization/domain/organization_repository.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late OrganizationRepository repository;
  final now = DateTime.utc(2026, 7, 28, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = OrganizationRepositoryImpl(
      database: db,
      clock: FixedClock(now),
    );
  });

  tearDown(() => db.close());

  Future<void> insertCard() {
    return db.insertCardGraph(
      CardRowGraph(
        definition: CardDefinitionsCompanion.insert(
          id: 'definition-1',
          name: '樱花纪念卡',
          city: const Value('东京'),
          issuedAt: const Value('2026-03'),
          createdAt: now,
          updatedAt: now,
        ),
        item: CardItemsCompanion.insert(
          id: 'item-1',
          definitionId: 'definition-1',
          createdAt: now,
          updatedAt: now,
        ),
        images: <CardImagesCompanion>[
          CardImagesCompanion.insert(
            id: 'image-1',
            cardItemId: 'item-1',
            kind: CardImageKind.front,
            relativePath: 'originals/item-1/image-1.jpg',
            checksum: 'sha256-1',
            isCover: const Value(true),
            createdAt: now,
          ),
        ],
      ),
    );
  }

  test('creates tags idempotently and maps duplicate names safely', () async {
    const request = CreateTagRequest(id: ' tag-1 ', name: ' 限定 ');

    expect(await repository.createTag(request), 'tag-1');
    expect(await repository.createTag(request), 'tag-1');
    final tags = await repository.watchTags().first;
    expect(tags, hasLength(1));
    expect(tags.single.name, '限定');
    expect(tags.single.cardCount, 0);

    await expectLater(
      repository.createTag(const CreateTagRequest(id: 'tag-2', name: '限定')),
      throwsA(
        isA<OrganizationValidationFailure>().having(
          (failure) => failure.field,
          'field',
          OrganizationField.name,
        ),
      ),
    );
  });

  test('saves and observes one card organization snapshot', () async {
    await insertCard();
    await repository.createTag(const CreateTagRequest(id: 'tag-1', name: '限定'));
    await repository.createField(
      const CreateCustomFieldRequest(
        id: 'field-1',
        name: '品相说明',
        fieldType: CustomFieldType.text,
      ),
    );
    await repository.saveSeries(
      const SaveSeriesRequest(id: 'series-1', name: '世博会'),
    );

    await repository.saveCardOrganization(
      SaveCardOrganizationRequest(
        cardItemId: 'item-1',
        cardType: '纪念卡',
        needsCompletion: true,
        tagIds: const <String>['tag-1'],
        seriesIds: const <String>['series-1'],
        fieldValues: const <CustomFieldValueInput>[
          CustomFieldValueInput.text(fieldId: 'field-1', value: '票面完好'),
        ],
      ),
    );

    final detail = await repository.watchCardOrganization('item-1').first;
    expect(detail, isNotNull);
    expect(detail!.cardType, '纪念卡');
    expect(detail.needsCompletion, isTrue);
    expect(detail.tags.single.name, '限定');
    expect(detail.series.single.name, '世博会');
    expect(detail.fieldValues.single.value.textValue, '票面完好');

    final cards = await repository
        .watchCards(const CardLibraryQuery(tagIds: <String>['tag-1']))
        .first;
    expect(cards.single.cardItemId, 'item-1');
  });

  test('observes series detail and typed field deletion impacts', () async {
    await insertCard();
    await repository.saveSeries(
      const SaveSeriesRequest(
        id: 'series-1',
        name: '东京系列',
        definitionIds: <String>['definition-1'],
      ),
    );
    await repository.createField(
      const CreateCustomFieldRequest(
        id: 'field-1',
        name: '发行日',
        fieldType: CustomFieldType.date,
      ),
    );
    await repository.saveCardOrganization(
      SaveCardOrganizationRequest(
        cardItemId: 'item-1',
        seriesIds: const <String>['series-1'],
        fieldValues: <CustomFieldValueInput>[
          CustomFieldValueInput.date(
            fieldId: 'field-1',
            value: DateTime.utc(2026, 3, 1),
          ),
        ],
      ),
    );

    final series = await repository.watchSeriesDetail('series-1').first;
    expect(series?.cards.single.name, '樱花纪念卡');
    expect(series?.sets, isEmpty);
    final impact = await repository.previewFieldDeletion('field-1');
    expect(impact.valueCount, 1);

    await repository.deleteField('field-1');
    expect(await repository.watchFieldDefinitions().first, isEmpty);
    expect(await db.select(db.organizationFieldValues).get(), hasLength(1));
  });

  test('maps a field type mismatch to a value-scoped failure', () async {
    await insertCard();
    await repository.createField(
      const CreateCustomFieldRequest(
        id: 'field-1',
        name: '数量',
        fieldType: CustomFieldType.number,
      ),
    );

    await expectLater(
      repository.saveCardOrganization(
        const SaveCardOrganizationRequest(
          cardItemId: 'item-1',
          fieldValues: <CustomFieldValueInput>[
            CustomFieldValueInput.text(fieldId: 'field-1', value: '不是数字'),
          ],
        ),
      ),
      throwsA(
        isA<OrganizationValidationFailure>().having(
          (failure) => failure.field,
          'field',
          OrganizationField.value,
        ),
      ),
    );
  });
}
