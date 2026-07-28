import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/features/organization/domain/organization_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardLibraryQuery.normalized', () {
    test('trims text and facets while removing duplicate tag ids', () {
      const raw = CardLibraryQuery(
        searchText: ' 樱花 ',
        cardType: ' 纪念卡 ',
        city: ' 东京 ',
        issuer: ' Metro ',
        year: 2026,
        tagIds: <String>[' tag-2 ', 'tag-1', 'tag-2', ' '],
        tagMatchMode: TagMatchMode.all,
        setMembership: SetMembershipFilter.inSet,
        duplicate: true,
        needsCompletion: false,
        setStatus: CardSetStatusFilter.nearlyComplete,
        sortField: CardSortField.name,
        sortDirection: SortDirection.ascending,
      );

      final result = raw.normalized();

      expect(result.searchText, '樱花');
      expect(result.cardType, '纪念卡');
      expect(result.city, '东京');
      expect(result.issuer, 'Metro');
      expect(result.tagIds, <String>['tag-2', 'tag-1']);
      expect(result.tagMatchMode, TagMatchMode.all);
      expect(result.setMembership, SetMembershipFilter.inSet);
      expect(result.setStatus, CardSetStatusFilter.nearlyComplete);
      expect(result.sortField, CardSortField.name);
      expect(result.sortDirection, SortDirection.ascending);
      expect(result.isFiltering, isTrue);
    });

    test('turns blank optional filters into an empty default query', () {
      const raw = CardLibraryQuery(
        searchText: ' ',
        cardType: '',
        city: '  ',
        issuer: ' ',
        tagIds: <String>[' '],
      );

      final result = raw.normalized();

      expect(result.searchText, isNull);
      expect(result.cardType, isNull);
      expect(result.city, isNull);
      expect(result.issuer, isNull);
      expect(result.tagIds, isEmpty);
      expect(result.isFiltering, isFalse);
    });

    test('copies and clears dashboard drill-down filters', () {
      const query = CardLibraryQuery(
        issuer: 'Metro',
        setStatus: CardSetStatusFilter.complete,
      );

      final changed = query.copyWith(
        issuer: '申通地铁',
        setStatus: CardSetStatusFilter.unknown,
      );
      final cleared = changed.copyWith(clearIssuer: true, clearSetStatus: true);

      expect(changed.issuer, '申通地铁');
      expect(changed.setStatus, CardSetStatusFilter.unknown);
      expect(cleared.issuer, isNull);
      expect(cleared.setStatus, isNull);
      expect(cleared.isFiltering, isFalse);
    });

    test('rejects years outside the supported partial-date range', () {
      expect(
        () => const CardLibraryQuery(year: 999).normalized(),
        throwsA(
          isA<OrganizationValidationFailure>().having(
            (failure) => failure.field,
            'field',
            OrganizationField.filter,
          ),
        ),
      );
    });
  });

  group('organization write requests', () {
    test('normalizes tag and series names and full membership sets', () {
      const tag = CreateTagRequest(id: ' tag-1 ', name: ' 限定 ');
      const series = SaveSeriesRequest(
        id: ' series-1 ',
        name: ' 世博会 ',
        description: ' 主题收藏 ',
        definitionIds: <String>[
          ' definition-2 ',
          'definition-1',
          'definition-2',
        ],
        setIds: <String>[' set-1 ', 'set-1'],
      );

      final normalizedTag = tag.normalized();
      final normalizedSeries = series.normalized();

      expect(normalizedTag.id, 'tag-1');
      expect(normalizedTag.name, '限定');
      expect(normalizedTag.normalizedName, '限定');
      expect(normalizedSeries.id, 'series-1');
      expect(normalizedSeries.name, '世博会');
      expect(normalizedSeries.description, '主题收藏');
      expect(normalizedSeries.definitionIds, <String>[
        'definition-2',
        'definition-1',
      ]);
      expect(normalizedSeries.setIds, <String>['set-1']);
    });

    test('uses lowercase normalized names for latin duplicate detection', () {
      const request = CreateTagRequest(id: 'tag-1', name: ' Metro ');

      expect(request.normalized().normalizedName, 'metro');
    });

    test('rejects blank ids and names longer than 100 characters', () {
      expect(
        () => const CreateTagRequest(id: ' ', name: '限定').normalized(),
        throwsA(isA<OrganizationValidationFailure>()),
      );
      expect(
        () => CreateCustomFieldRequest(
          id: 'field-1',
          name: List<String>.filled(101, '字').join(),
          fieldType: CustomFieldType.text,
        ).normalized(),
        throwsA(
          isA<OrganizationValidationFailure>().having(
            (failure) => failure.field,
            'field',
            OrganizationField.name,
          ),
        ),
      );
    });
  });

  group('CustomFieldValueInput', () {
    test('normalizes text, number and UTC date values independently', () {
      final text = const CustomFieldValueInput.text(
        fieldId: ' field-text ',
        value: ' 票面完好 ',
      ).normalized();
      final number = const CustomFieldValueInput.number(
        fieldId: 'field-number',
        value: 12.5,
      ).normalized();
      final date = CustomFieldValueInput.date(
        fieldId: 'field-date',
        value: DateTime(2026, 7, 28, 18, 30),
      ).normalized();

      expect(text.fieldId, 'field-text');
      expect(text.textValue, '票面完好');
      expect(text.fieldType, CustomFieldType.text);
      expect(number.numberValue, 12.5);
      expect(number.fieldType, CustomFieldType.number);
      expect(date.dateValue?.isUtc, isTrue);
      expect(date.dateValue, DateTime.utc(2026, 7, 28));
    });

    test('rejects non-finite numbers and blank text as stored values', () {
      expect(
        () => const CustomFieldValueInput.number(
          fieldId: 'field-1',
          value: double.infinity,
        ).normalized(),
        throwsA(isA<OrganizationValidationFailure>()),
      );
      expect(
        () => const CustomFieldValueInput.text(
          fieldId: 'field-1',
          value: ' ',
        ).normalized(),
        throwsA(isA<OrganizationValidationFailure>()),
      );
    });
  });

  test('rejects merging a tag into itself after id normalization', () {
    expect(
      () => const MergeTagsRequest(
        sourceTagId: ' tag-1 ',
        targetTagId: 'tag-1',
      ).normalized(),
      throwsA(
        isA<OrganizationValidationFailure>().having(
          (failure) => failure.field,
          'field',
          OrganizationField.tag,
        ),
      ),
    );
  });
}
