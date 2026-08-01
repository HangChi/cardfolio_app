import 'package:flutter/material.dart';

import 'card_condition_field.dart';

class ReservedCardMetadataFields extends StatelessWidget {
  const ReservedCardMetadataFields({
    required this.conditionController,
    required this.itemNotesController,
    required this.issueQuantityController,
    required this.issuePriceController,
    this.enabled = true,
    super.key,
  });

  final TextEditingController conditionController;
  final TextEditingController itemNotesController;
  final TextEditingController issueQuantityController;
  final TextEditingController issuePriceController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CardConditionField(controller: conditionController, enabled: enabled),
        const SizedBox(height: 12),
        TextField(
          controller: itemNotesController,
          enabled: enabled,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: '藏品实例备注（可选）'),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: issueQuantityController,
                enabled: enabled,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '发行数量（可选）'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: issuePriceController,
                enabled: enabled,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: '发售价/元（可选）'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

ReservedMetadataInput parseReservedMetadataInput({
  required TextEditingController condition,
  required TextEditingController itemNotes,
  required TextEditingController issueQuantity,
  required TextEditingController issuePrice,
}) {
  final quantityText = issueQuantity.text.trim();
  final priceText = issuePrice.text.trim();
  final quantity = quantityText.isEmpty ? null : int.tryParse(quantityText);
  final price = priceText.isEmpty ? null : double.tryParse(priceText);
  if (quantityText.isNotEmpty && (quantity == null || quantity <= 0)) {
    throw const FormatException('发行数量请输入大于 0 的整数。');
  }
  if (priceText.isNotEmpty && (price == null || price < 0)) {
    throw const FormatException('发售价请输入大于或等于 0 的数字。');
  }
  return ReservedMetadataInput(
    condition: condition.text,
    itemNotes: itemNotes.text,
    issueQuantity: quantity,
    issuePrice: price,
  );
}

final class ReservedMetadataInput {
  const ReservedMetadataInput({
    required this.condition,
    required this.itemNotes,
    this.issueQuantity,
    this.issuePrice,
  });

  final String condition;
  final String itemNotes;
  final int? issueQuantity;
  final double? issuePrice;
}
