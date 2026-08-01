import '../../../core/errors/app_failure.dart';
import '../../../core/id/id_generator.dart';
import '../../organization/domain/organization_models.dart';
import '../../organization/domain/organization_repository.dart';

const String conditionFieldName = '品相';
const String itemNotesFieldName = '藏品实例备注';
const String issueQuantityFieldName = '发行数量';
const String issuePriceFieldName = '发售价（元）';

final class ReservedCardMetadata {
  const ReservedCardMetadata({
    this.condition,
    this.itemNotes,
    this.issueQuantity,
    this.issuePrice,
  });

  final String? condition;
  final String? itemNotes;
  final int? issueQuantity;
  final double? issuePrice;

  bool get isEmpty =>
      _blank(condition) &&
      _blank(itemNotes) &&
      issueQuantity == null &&
      issuePrice == null;

  factory ReservedCardMetadata.fromDetails(
    Iterable<CustomFieldValueDetail> values,
  ) {
    CustomFieldValueDetail? named(String name) {
      for (final value in values) {
        if (value.fieldName == name) return value;
      }
      return null;
    }

    return ReservedCardMetadata(
      condition: named(conditionFieldName)?.value.textValue,
      itemNotes: named(itemNotesFieldName)?.value.textValue,
      issueQuantity: named(issueQuantityFieldName)?.value.numberValue?.round(),
      issuePrice: named(issuePriceFieldName)?.value.numberValue,
    );
  }
}

Future<List<CustomFieldValueInput>> mergeReservedCardMetadata({
  required OrganizationRepository repository,
  required IdGenerator idGenerator,
  required List<CustomFieldDefinition> definitions,
  required List<CustomFieldValueInput> existingValues,
  required ReservedCardMetadata metadata,
}) async {
  final latestDefinitions = await repository.watchFieldDefinitions().first;
  final byName = <String, CustomFieldDefinition>{
    for (final definition in definitions) definition.name: definition,
    for (final definition in latestDefinitions) definition.name: definition,
  };
  final reservedIds = byName.values
      .where((definition) => _reservedNames.contains(definition.name))
      .map((definition) => definition.id)
      .toSet();
  final output = <CustomFieldValueInput>[
    for (final value in existingValues)
      if (!reservedIds.contains(value.fieldId)) value,
  ];
  Future<String> ensure(String name, CustomFieldType type) async {
    final existing = byName[name];
    if (existing != null) {
      if (existing.fieldType != type) {
        throw OrganizationValidationFailure(
          OrganizationField.customField,
          '“$name”字段类型不正确，请在整理设置中调整。',
        );
      }
      return existing.id;
    }
    final id = idGenerator.newId();
    await repository.createField(
      CreateCustomFieldRequest(id: id, name: name, fieldType: type),
    );
    return id;
  }

  final condition = metadata.condition?.trim();
  if (condition != null && condition.isNotEmpty) {
    output.add(
      CustomFieldValueInput.text(
        fieldId: await ensure(conditionFieldName, CustomFieldType.text),
        value: condition,
      ),
    );
  }
  final itemNotes = metadata.itemNotes?.trim();
  if (itemNotes != null && itemNotes.isNotEmpty) {
    output.add(
      CustomFieldValueInput.text(
        fieldId: await ensure(itemNotesFieldName, CustomFieldType.text),
        value: itemNotes,
      ),
    );
  }
  if (metadata.issueQuantity != null) {
    output.add(
      CustomFieldValueInput.number(
        fieldId: await ensure(issueQuantityFieldName, CustomFieldType.number),
        value: metadata.issueQuantity!.toDouble(),
      ),
    );
  }
  if (metadata.issuePrice != null) {
    output.add(
      CustomFieldValueInput.number(
        fieldId: await ensure(issuePriceFieldName, CustomFieldType.number),
        value: metadata.issuePrice!,
      ),
    );
  }
  return List<CustomFieldValueInput>.unmodifiable(output);
}

const _reservedNames = <String>{
  conditionFieldName,
  itemNotesFieldName,
  issueQuantityFieldName,
  issuePriceFieldName,
};

bool _blank(String? value) => value == null || value.trim().isEmpty;
