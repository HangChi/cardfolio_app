import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/widgets/app_name_dialog.dart';
import '../../../card_sets/data/card_set_providers.dart';
import '../../../card_sets/domain/card_set_models.dart';
import '../../../organization/data/organization_providers.dart';
import '../../../organization/domain/organization_models.dart';
import '../../../purchases/domain/purchase_models.dart';
import '../../data/card_providers.dart';

class CardEntryMetadataFields extends StatelessWidget {
  const CardEntryMetadataFields({
    required this.tags,
    required this.cardSets,
    required this.albums,
    required this.selectedTagIds,
    required this.selectedSetIds,
    required this.selectedAlbumIds,
    required this.enabled,
    required this.onCreateTag,
    required this.onTagSelected,
    required this.onSetSelected,
    required this.onAlbumSelected,
    super.key,
  });

  final List<TagSummary> tags;
  final List<CardSetSummary> cardSets;
  final List<SeriesSummary> albums;
  final Set<String> selectedTagIds;
  final Set<String> selectedSetIds;
  final Set<String> selectedAlbumIds;
  final bool enabled;
  final VoidCallback onCreateTag;
  final void Function(String id, bool selected) onTagSelected;
  final void Function(String id, bool selected) onSetSelected;
  final void Function(String id, bool selected) onAlbumSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '卡片标签（可选）',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton.icon(
              key: const Key('create-tag-inline'),
              onPressed: enabled ? onCreateTag : null,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('新建标签'),
            ),
          ],
        ),
        if (tags.isEmpty)
          Text('暂无标签', style: Theme.of(context).textTheme.bodySmall)
        else
          _chips<TagSummary>(
            values: tags,
            selectedIds: selectedTagIds,
            enabled: enabled,
            idOf: (value) => value.id,
            nameOf: (value) => value.name,
            onSelected: onTagSelected,
          ),
        const SizedBox(height: 16),
        Text('加入套卡（可选）', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (cardSets.isEmpty)
          Text('暂无套卡', style: Theme.of(context).textTheme.bodySmall)
        else
          _chips<CardSetSummary>(
            values: cardSets,
            selectedIds: selectedSetIds,
            enabled: enabled,
            idOf: (value) => value.id,
            nameOf: (value) => value.name,
            onSelected: onSetSelected,
          ),
        const SizedBox(height: 16),
        Text('加入卡册（可选）', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (albums.isEmpty)
          Text('暂无卡册', style: Theme.of(context).textTheme.bodySmall)
        else
          _chips<SeriesSummary>(
            values: albums,
            selectedIds: selectedAlbumIds,
            enabled: enabled,
            idOf: (value) => value.id,
            nameOf: (value) => value.name,
            onSelected: onAlbumSelected,
          ),
      ],
    );
  }

  Widget _chips<T>({
    required List<T> values,
    required Set<String> selectedIds,
    required bool enabled,
    required String Function(T value) idOf,
    required String Function(T value) nameOf,
    required void Function(String id, bool selected) onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final value in values)
          FilterChip(
            label: Text(nameOf(value)),
            selected: selectedIds.contains(idOf(value)),
            onSelected: enabled
                ? (selected) => onSelected(idOf(value), selected)
                : null,
          ),
      ],
    );
  }
}

class CardEntryCostFields extends StatelessWidget {
  const CardEntryCostFields({
    required this.amountController,
    required this.shippingController,
    required this.enabled,
    this.onChanged,
    super.key,
  });

  final TextEditingController amountController;
  final TextEditingController shippingController;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: TextField(
            key: const Key('card-amount-field'),
            controller: amountController,
            enabled: enabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: onChanged,
            decoration: const InputDecoration(
              labelText: '卡片金额（元）',
              prefixText: '¥ ',
              hintText: '0.00',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            key: const Key('shipping-amount-field'),
            controller: shippingController,
            enabled: enabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: onChanged,
            decoration: const InputDecoration(
              labelText: '运费（元）',
              prefixText: '¥ ',
              hintText: '0.00',
            ),
          ),
        ),
      ],
    );
  }
}

int parseOptionalCnyMinor(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return 0;
  final amount = CurrencyAmount.parse(normalized, 'CNY');
  if (amount.minorUnits < 0) {
    throw const PurchaseValidationFailure(
      PurchaseField.amount,
      '卡片金额和运费不能为负数。',
    );
  }
  return amount.minorUnits;
}

String formatCnyInput(int minorUnits) => minorUnits == 0
    ? ''
    : CurrencyAmount(minorUnits: minorUnits, currency: 'CNY').formatted;

Future<String?> createTagInline(BuildContext context, WidgetRef ref) async {
  final name = await showAppNameDialog(
    context,
    title: '新建标签',
    fieldLabel: '标签名称',
  );
  if (name == null || name.isEmpty) return null;
  final id = ref.read(idGeneratorProvider).newId();
  return ref
      .read(organizationRepositoryProvider)
      .createTag(CreateTagRequest(id: id, name: name));
}

Future<void> saveCardSetSelections({
  required WidgetRef ref,
  required String definitionId,
  required Set<String> selectedSetIds,
}) async {
  final repository = ref.read(cardSetRepositoryProvider);
  final current = await repository.watchMemberships(definitionId).first;
  final currentBySet = <String, CardSetMembership>{
    for (final membership in current) membership.setId: membership,
  };

  for (final membership in current) {
    if (!selectedSetIds.contains(membership.setId)) {
      await repository.removeMember(
        setId: membership.setId,
        memberId: membership.memberId,
      );
    }
  }
  for (final setId in selectedSetIds) {
    if (!currentBySet.containsKey(setId)) {
      await repository.addMember(
        AddCardSetMemberRequest.existing(
          id: ref.read(idGeneratorProvider).newId(),
          setId: setId,
          definitionId: definitionId,
        ),
      );
    }
  }
}
