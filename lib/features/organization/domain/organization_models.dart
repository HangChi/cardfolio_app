import 'package:meta/meta.dart';

import '../../../core/errors/app_failure.dart';
import '../../cards/domain/card_models.dart';

enum TagMatchMode { any, all }

enum SetMembershipFilter { any, inSet, notInSet }

enum CardSortField { createdAt, issuedAt, acquiredAt, name, acquisitionCost }

enum SortDirection { ascending, descending }

enum CustomFieldType { text, number, date }

@immutable
final class CardLibraryQuery {
  const CardLibraryQuery({
    this.searchText,
    this.cardType,
    this.city,
    this.year,
    this.tagIds = const <String>[],
    this.tagMatchMode = TagMatchMode.any,
    this.setMembership = SetMembershipFilter.any,
    this.duplicate,
    this.needsCompletion,
    this.sortField = CardSortField.createdAt,
    this.sortDirection = SortDirection.descending,
    this.isNormalized = false,
  });

  final String? searchText;
  final String? cardType;
  final String? city;
  final int? year;
  final List<String> tagIds;
  final TagMatchMode tagMatchMode;
  final SetMembershipFilter setMembership;
  final bool? duplicate;
  final bool? needsCompletion;
  final CardSortField sortField;
  final SortDirection sortDirection;
  final bool isNormalized;

  bool get isFiltering =>
      searchText != null ||
      cardType != null ||
      city != null ||
      year != null ||
      tagIds.isNotEmpty ||
      setMembership != SetMembershipFilter.any ||
      duplicate != null ||
      needsCompletion != null;

  CardLibraryQuery normalized() {
    if (isNormalized) return this;
    if (year != null && (year! < 1000 || year! > 9999)) {
      throw const OrganizationValidationFailure(
        OrganizationField.filter,
        '发行年份必须是四位年份。',
      );
    }
    return CardLibraryQuery(
      searchText: _optional(searchText),
      cardType: _optional(cardType),
      city: _optional(city),
      year: year,
      tagIds: List<String>.unmodifiable(_normalizedIds(tagIds)),
      tagMatchMode: tagMatchMode,
      setMembership: setMembership,
      duplicate: duplicate,
      needsCompletion: needsCompletion,
      sortField: sortField,
      sortDirection: sortDirection,
      isNormalized: true,
    );
  }

  CardLibraryQuery copyWith({
    String? searchText,
    bool clearSearchText = false,
    String? cardType,
    bool clearCardType = false,
    String? city,
    bool clearCity = false,
    int? year,
    bool clearYear = false,
    List<String>? tagIds,
    TagMatchMode? tagMatchMode,
    SetMembershipFilter? setMembership,
    bool? duplicate,
    bool clearDuplicate = false,
    bool? needsCompletion,
    bool clearNeedsCompletion = false,
    CardSortField? sortField,
    SortDirection? sortDirection,
  }) {
    return CardLibraryQuery(
      searchText: clearSearchText ? null : searchText ?? this.searchText,
      cardType: clearCardType ? null : cardType ?? this.cardType,
      city: clearCity ? null : city ?? this.city,
      year: clearYear ? null : year ?? this.year,
      tagIds: tagIds ?? this.tagIds,
      tagMatchMode: tagMatchMode ?? this.tagMatchMode,
      setMembership: setMembership ?? this.setMembership,
      duplicate: clearDuplicate ? null : duplicate ?? this.duplicate,
      needsCompletion: clearNeedsCompletion
          ? null
          : needsCompletion ?? this.needsCompletion,
      sortField: sortField ?? this.sortField,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }
}

@immutable
final class CreateTagRequest {
  const CreateTagRequest({
    required this.id,
    required this.name,
    this.isNormalized = false,
  }) : normalizedName = null;

  const CreateTagRequest._normalized({
    required this.id,
    required this.name,
    required this.normalizedName,
  }) : isNormalized = true;

  final String id;
  final String name;
  final String? normalizedName;
  final bool isNormalized;

  CreateTagRequest normalized() {
    if (isNormalized) return this;
    final result = _normalizedNameRequest(id: id, name: name);
    return CreateTagRequest._normalized(
      id: result.id,
      name: result.name,
      normalizedName: result.normalizedName,
    );
  }
}

@immutable
final class RenameTagRequest {
  const RenameTagRequest({
    required this.id,
    required this.name,
    this.isNormalized = false,
  }) : normalizedName = null;

  const RenameTagRequest._normalized({
    required this.id,
    required this.name,
    required this.normalizedName,
  }) : isNormalized = true;

  final String id;
  final String name;
  final String? normalizedName;
  final bool isNormalized;

  RenameTagRequest normalized() {
    if (isNormalized) return this;
    final result = _normalizedNameRequest(id: id, name: name);
    return RenameTagRequest._normalized(
      id: result.id,
      name: result.name,
      normalizedName: result.normalizedName,
    );
  }
}

@immutable
final class MergeTagsRequest {
  const MergeTagsRequest({
    required this.sourceTagId,
    required this.targetTagId,
    this.isNormalized = false,
  });

  final String sourceTagId;
  final String targetTagId;
  final bool isNormalized;

  MergeTagsRequest normalized() {
    if (isNormalized) return this;
    final source = _requiredId(sourceTagId, OrganizationField.tag);
    final target = _requiredId(targetTagId, OrganizationField.tag);
    if (source == target) {
      throw const OrganizationValidationFailure(
        OrganizationField.tag,
        '请选择另一个目标标签。',
      );
    }
    return MergeTagsRequest(
      sourceTagId: source,
      targetTagId: target,
      isNormalized: true,
    );
  }
}

@immutable
final class SaveSeriesRequest {
  const SaveSeriesRequest({
    required this.id,
    required this.name,
    this.description,
    this.definitionIds = const <String>[],
    this.setIds = const <String>[],
    this.isNormalized = false,
  });

  static const int maxDescriptionLength = 1000;

  final String id;
  final String name;
  final String? description;
  final List<String> definitionIds;
  final List<String> setIds;
  final bool isNormalized;

  SaveSeriesRequest normalized() {
    if (isNormalized) return this;
    return SaveSeriesRequest(
      id: _requiredId(id, OrganizationField.series),
      name: _requiredName(name),
      description: _optional(
        description,
        maxLength: maxDescriptionLength,
        field: OrganizationField.series,
      ),
      definitionIds: List<String>.unmodifiable(
        _normalizedIds(definitionIds, field: OrganizationField.series),
      ),
      setIds: List<String>.unmodifiable(
        _normalizedIds(setIds, field: OrganizationField.series),
      ),
      isNormalized: true,
    );
  }
}

@immutable
final class CreateCustomFieldRequest {
  const CreateCustomFieldRequest({
    required this.id,
    required this.name,
    required this.fieldType,
    this.isNormalized = false,
  }) : normalizedName = null;

  const CreateCustomFieldRequest._normalized({
    required this.id,
    required this.name,
    required this.normalizedName,
    required this.fieldType,
  }) : isNormalized = true;

  final String id;
  final String name;
  final String? normalizedName;
  final CustomFieldType fieldType;
  final bool isNormalized;

  CreateCustomFieldRequest normalized() {
    if (isNormalized) return this;
    final result = _normalizedNameRequest(
      id: id,
      name: name,
      field: OrganizationField.customField,
    );
    return CreateCustomFieldRequest._normalized(
      id: result.id,
      name: result.name,
      normalizedName: result.normalizedName,
      fieldType: fieldType,
    );
  }
}

@immutable
final class RenameCustomFieldRequest {
  const RenameCustomFieldRequest({
    required this.id,
    required this.name,
    this.isNormalized = false,
  }) : normalizedName = null;

  const RenameCustomFieldRequest._normalized({
    required this.id,
    required this.name,
    required this.normalizedName,
  }) : isNormalized = true;

  final String id;
  final String name;
  final String? normalizedName;
  final bool isNormalized;

  RenameCustomFieldRequest normalized() {
    if (isNormalized) return this;
    final result = _normalizedNameRequest(
      id: id,
      name: name,
      field: OrganizationField.customField,
    );
    return RenameCustomFieldRequest._normalized(
      id: result.id,
      name: result.name,
      normalizedName: result.normalizedName,
    );
  }
}

@immutable
final class CustomFieldValueInput {
  const CustomFieldValueInput.text({
    required this.fieldId,
    required String value,
    this.isNormalized = false,
  }) : fieldType = CustomFieldType.text,
       textValue = value,
       numberValue = null,
       dateValue = null;

  const CustomFieldValueInput.number({
    required this.fieldId,
    required double value,
    this.isNormalized = false,
  }) : fieldType = CustomFieldType.number,
       textValue = null,
       numberValue = value,
       dateValue = null;

  const CustomFieldValueInput.date({
    required this.fieldId,
    required DateTime value,
    this.isNormalized = false,
  }) : fieldType = CustomFieldType.date,
       textValue = null,
       numberValue = null,
       dateValue = value;

  final String fieldId;
  final CustomFieldType fieldType;
  final String? textValue;
  final double? numberValue;
  final DateTime? dateValue;
  final bool isNormalized;

  Object get value => switch (fieldType) {
    CustomFieldType.text => textValue!,
    CustomFieldType.number => numberValue!,
    CustomFieldType.date => dateValue!,
  };

  CustomFieldValueInput normalized() {
    if (isNormalized) return this;
    final id = _requiredId(fieldId, OrganizationField.customField);
    return switch (fieldType) {
      CustomFieldType.text => CustomFieldValueInput.text(
        fieldId: id,
        value:
            _optional(
              textValue,
              maxLength: 1000,
              field: OrganizationField.value,
            ) ??
            (throw const OrganizationValidationFailure(
              OrganizationField.value,
              '文本字段值不能为空。',
            )),
        isNormalized: true,
      ),
      CustomFieldType.number =>
        numberValue == null || !numberValue!.isFinite
            ? throw const OrganizationValidationFailure(
                OrganizationField.value,
                '请输入有效数字。',
              )
            : CustomFieldValueInput.number(
                fieldId: id,
                value: numberValue!,
                isNormalized: true,
              ),
      CustomFieldType.date =>
        dateValue == null
            ? throw const OrganizationValidationFailure(
                OrganizationField.value,
                '请选择有效日期。',
              )
            : CustomFieldValueInput.date(
                fieldId: id,
                value: DateTime.utc(
                  dateValue!.year,
                  dateValue!.month,
                  dateValue!.day,
                ),
                isNormalized: true,
              ),
    };
  }
}

@immutable
final class SaveCardOrganizationRequest {
  const SaveCardOrganizationRequest({
    required this.cardItemId,
    this.cardType,
    this.needsCompletion = false,
    this.acquiredAt,
    this.tagIds = const <String>[],
    this.seriesIds = const <String>[],
    this.fieldValues = const <CustomFieldValueInput>[],
    this.isNormalized = false,
  });

  final String cardItemId;
  final String? cardType;
  final bool needsCompletion;
  final DateTime? acquiredAt;
  final List<String> tagIds;
  final List<String> seriesIds;
  final List<CustomFieldValueInput> fieldValues;
  final bool isNormalized;

  SaveCardOrganizationRequest normalized() {
    if (isNormalized) return this;
    final values = fieldValues
        .map((value) => value.normalized())
        .toList(growable: false);
    if (values.map((value) => value.fieldId).toSet().length != values.length) {
      throw const OrganizationValidationFailure(
        OrganizationField.value,
        '同一字段只能保存一个值。',
      );
    }
    return SaveCardOrganizationRequest(
      cardItemId: _requiredId(cardItemId, OrganizationField.target),
      cardType: _optional(
        cardType,
        maxLength: 100,
        field: OrganizationField.value,
      ),
      needsCompletion: needsCompletion,
      acquiredAt: acquiredAt?.toUtc(),
      tagIds: List<String>.unmodifiable(
        _normalizedIds(tagIds, field: OrganizationField.tag),
      ),
      seriesIds: List<String>.unmodifiable(
        _normalizedIds(seriesIds, field: OrganizationField.series),
      ),
      fieldValues: List<CustomFieldValueInput>.unmodifiable(values),
      isNormalized: true,
    );
  }
}

@immutable
final class TagSummary {
  const TagSummary({
    required this.id,
    required this.name,
    required this.cardCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final int cardCount;
  final DateTime createdAt;
  final DateTime updatedAt;
}

@immutable
final class OrganizationLabel {
  const OrganizationLabel({required this.id, required this.name});

  final String id;
  final String name;
}

@immutable
final class SeriesSummary {
  const SeriesSummary({
    required this.id,
    required this.name,
    required this.cardCount,
    required this.setCount,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  final String id;
  final String name;
  final String? description;
  final int cardCount;
  final int setCount;
  final DateTime createdAt;
  final DateTime updatedAt;
}

@immutable
final class SeriesMemberSummary {
  const SeriesMemberSummary({
    required this.id,
    required this.name,
    this.coverRelativePath,
  });

  final String id;
  final String name;
  final String? coverRelativePath;
}

@immutable
final class SeriesDetail {
  const SeriesDetail({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.cards,
    required this.sets,
    this.description,
  });

  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SeriesMemberSummary> cards;
  final List<SeriesMemberSummary> sets;
}

@immutable
final class CustomFieldDefinition {
  const CustomFieldDefinition({
    required this.id,
    required this.name,
    required this.fieldType,
    required this.valueCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final CustomFieldType fieldType;
  final int valueCount;
  final DateTime createdAt;
  final DateTime updatedAt;
}

@immutable
final class CustomFieldValueDetail {
  const CustomFieldValueDetail({
    required this.fieldId,
    required this.fieldName,
    required this.value,
  });

  final String fieldId;
  final String fieldName;
  final CustomFieldValueInput value;
}

@immutable
final class CardOrganizationDetail {
  const CardOrganizationDetail({
    required this.cardItemId,
    required this.definitionId,
    required this.name,
    required this.needsCompletion,
    required this.tags,
    required this.series,
    required this.fieldValues,
    this.cardType,
    this.acquiredAt,
  });

  final String cardItemId;
  final String definitionId;
  final String name;
  final String? cardType;
  final bool needsCompletion;
  final DateTime? acquiredAt;
  final List<TagSummary> tags;
  final List<SeriesSummary> series;
  final List<CustomFieldValueDetail> fieldValues;
}

@immutable
final class OrganizedCardSummary {
  const OrganizedCardSummary({
    required this.cardItemId,
    required this.definitionId,
    required this.name,
    required this.quantity,
    required this.createdAt,
    required this.needsCompletion,
    required this.tags,
    this.coverRelativePath,
    this.city,
    this.issuedAt,
    this.acquiredAt,
    this.cardType,
    this.acquisitionCostCurrency,
    this.acquisitionCostMinor,
  });

  final String cardItemId;
  final String definitionId;
  final String name;
  final int quantity;
  final DateTime createdAt;
  final bool needsCompletion;
  final List<OrganizationLabel> tags;
  final String? coverRelativePath;
  final String? city;
  final PartialDate? issuedAt;
  final DateTime? acquiredAt;
  final String? cardType;
  final String? acquisitionCostCurrency;
  final int? acquisitionCostMinor;
}

@immutable
final class CardFilterFacets {
  const CardFilterFacets({
    required this.cardTypes,
    required this.cities,
    required this.years,
    required this.tags,
  });

  final List<String> cardTypes;
  final List<String> cities;
  final List<int> years;
  final List<TagSummary> tags;
}

@immutable
final class ChangeImpact {
  const ChangeImpact({
    required this.targetId,
    required this.associationCount,
    this.valueCount = 0,
  });

  final String targetId;
  final int associationCount;
  final int valueCount;
}

final class _NormalizedNameRequest {
  const _NormalizedNameRequest({
    required this.id,
    required this.name,
    required this.normalizedName,
  });

  final String id;
  final String name;
  final String normalizedName;
}

_NormalizedNameRequest _normalizedNameRequest({
  required String id,
  required String name,
  OrganizationField field = OrganizationField.tag,
}) {
  final normalizedId = _requiredId(id, field);
  final normalizedName = _requiredName(name);
  return _NormalizedNameRequest(
    id: normalizedId,
    name: normalizedName,
    normalizedName: normalizedName.toLowerCase(),
  );
}

String _requiredId(String value, OrganizationField field) {
  final result = value.trim();
  if (result.isEmpty) {
    throw OrganizationValidationFailure(field, '目标不存在，请刷新后重试。');
  }
  return result;
}

String _requiredName(String value) {
  final result = value.trim();
  if (result.isEmpty) {
    throw const OrganizationValidationFailure(
      OrganizationField.name,
      '名称不能为空。',
    );
  }
  if (result.length > 100) {
    throw const OrganizationValidationFailure(
      OrganizationField.name,
      '名称最多 100 个字符。',
    );
  }
  return result;
}

String? _optional(
  String? value, {
  int? maxLength,
  OrganizationField field = OrganizationField.value,
}) {
  final result = value?.trim() ?? '';
  if (result.isEmpty) return null;
  if (maxLength != null && result.length > maxLength) {
    throw OrganizationValidationFailure(field, '内容最多 $maxLength 个字符。');
  }
  return result;
}

List<String> _normalizedIds(
  Iterable<String> values, {
  OrganizationField field = OrganizationField.filter,
}) {
  final seen = <String>{};
  final result = <String>[];
  for (final value in values) {
    final normalized = value.trim();
    if (normalized.isEmpty) continue;
    if (seen.add(normalized)) result.add(normalized);
  }
  return result;
}
