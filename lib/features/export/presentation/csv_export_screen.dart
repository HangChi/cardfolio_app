import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../card_sets/data/card_set_providers.dart';
import '../../cards/data/card_providers.dart';
import '../../cards/domain/reserved_card_metadata.dart';
import '../../organization/data/organization_providers.dart';
import '../../organization/domain/organization_models.dart';
import '../../purchases/data/purchase_providers.dart';
import '../../purchases/domain/purchase_models.dart';
import '../data/csv_export_providers.dart';
import '../domain/csv_export.dart';

class CsvExportScreen extends ConsumerStatefulWidget {
  const CsvExportScreen({super.key});

  @override
  ConsumerState<CsvExportScreen> createState() => _CsvExportScreenState();
}

class _CsvExportScreenState extends ConsumerState<CsvExportScreen> {
  bool _exporting = false;

  Future<void> _export() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final cards = await ref
          .read(organizationRepositoryProvider)
          .watchCards(const CardLibraryQuery())
          .first;
      final sets = await ref.read(cardSetRepositoryProvider).watchSets().first;
      final setNames = <String, String>{
        for (final set in sets) set.id: set.name,
      };
      final rows = <CardCsvRow>[];
      for (final summary in cards) {
        final card = await ref
            .read(cardRepositoryProvider)
            .watchCard(summary.cardItemId)
            .first;
        final organization = await ref
            .read(organizationRepositoryProvider)
            .watchCardOrganization(summary.cardItemId)
            .first;
        if (card == null || organization == null) continue;
        final memberships = await ref
            .read(cardSetRepositoryProvider)
            .watchMemberships(organization.definitionId)
            .first;
        final cost = await ref
            .read(purchaseRepositoryProvider)
            .watchCardEntryCost(summary.cardItemId)
            .first;
        final metadata = ReservedCardMetadata.fromDetails(
          organization.fieldValues,
        );
        rows.add(
          CardCsvRow(
            name: card.name,
            city: card.city,
            issuer: card.issuer,
            issuedAt: card.issuedAt?.toIsoString(),
            code: card.code,
            quantity: card.quantity,
            condition: metadata.condition,
            itemNotes: metadata.itemNotes,
            issueQuantity: metadata.issueQuantity,
            issuePrice: metadata.issuePrice?.toStringAsFixed(2),
            cardType: organization.cardType,
            acquiredAt: organization.acquiredAt == null
                ? null
                : _date(organization.acquiredAt!),
            tags: organization.tags.map((value) => value.name).toList(),
            albums: organization.series.map((value) => value.name).toList(),
            cardSets: memberships
                .map((value) => setNames[value.setId])
                .whereType<String>()
                .toList(),
            amount: _money(cost.amountMinor),
            shipping: _money(cost.shippingMinor),
            notes: card.notes,
          ),
        );
      }
      final now = DateTime.now();
      final suggested =
          'cardfolio-${now.year}${now.month.toString().padLeft(2, '0')}'
          '${now.day.toString().padLeft(2, '0')}.csv';
      final publisher = ref.read(csvFilePublisherProvider);
      final path = await publisher.choosePath(suggested);
      if (path == null) return;
      await File(path).writeAsString(encodeCardCsv(rows), flush: true);
      final published = await publisher.publish(path);
      if (mounted && published) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('已导出 ${rows.length} 张卡片。')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('CSV 导出失败，请重试。')));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CSV 导出')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Icon(Icons.table_view_outlined, size: 72),
            const SizedBox(height: 24),
            Text(
              '导出全部未删除卡片',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              '包含基础资料、持有数量、品相、发行信息、标签、套卡、集卡册与入手成本。'
              '文件使用 UTF-8 编码，可直接用 Excel 打开。',
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _exporting ? null : _export,
              icon: const Icon(Icons.download_outlined),
              label: Text(_exporting ? '正在导出…' : '选择位置并导出'),
            ),
          ],
        ),
      ),
    );
  }
}

String? _money(int minor) => minor == 0
    ? null
    : CurrencyAmount(minorUnits: minor, currency: 'CNY').formatted;

String _date(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
