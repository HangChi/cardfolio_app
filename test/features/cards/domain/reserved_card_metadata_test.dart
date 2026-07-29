import 'package:cardfolio_app/features/cards/domain/reserved_card_metadata.dart';
import 'package:cardfolio_app/features/organization/domain/organization_models.dart';
import 'package:test/test.dart';

void main() {
  test('reads reserved collection fields from organization details', () {
    final metadata = ReservedCardMetadata.fromDetails(
      const <CustomFieldValueDetail>[
        CustomFieldValueDetail(
          fieldId: 'condition',
          fieldName: conditionFieldName,
          value: CustomFieldValueInput.text(fieldId: 'condition', value: '近全新'),
        ),
        CustomFieldValueDetail(
          fieldId: 'quantity',
          fieldName: issueQuantityFieldName,
          value: CustomFieldValueInput.number(fieldId: 'quantity', value: 5000),
        ),
        CustomFieldValueDetail(
          fieldId: 'price',
          fieldName: issuePriceFieldName,
          value: CustomFieldValueInput.number(fieldId: 'price', value: 20),
        ),
      ],
    );

    expect(metadata.condition, '近全新');
    expect(metadata.issueQuantity, 5000);
    expect(metadata.issuePrice, 20);
  });
}
