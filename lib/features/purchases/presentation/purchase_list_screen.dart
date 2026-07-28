import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../app/app_theme.dart';
import '../../../core/errors/app_failure.dart';
import '../../cards/data/card_providers.dart';
import '../data/purchase_providers.dart';
import '../domain/purchase_models.dart';

class PurchaseListScreen extends ConsumerWidget {
  const PurchaseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(purchaseListProvider);
    final summary = ref.watch(purchaseCostSummaryProvider);
    final options = ref.watch(purchaseCostDisplayOptionsProvider);
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(title: const Text('购买记录')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('create-purchase'),
        onPressed: () => context.push(createPurchasePath),
        icon: const Icon(Icons.add),
        label: const Text('记录购买'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(purchaseListProvider);
          ref.invalidate(purchaseCostSummaryProvider);
        },
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            tokens.spaceLg,
            tokens.spaceMd,
            tokens.spaceLg,
            tokens.spaceXl + 72,
          ),
          children: <Widget>[
            Text('累计花费', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: tokens.spaceSm),
            summary.when(
              loading: () => const _Loading(label: '正在加载累计花费'),
              error: (error, stackTrace) => _InlineError(
                message: '累计花费暂时无法读取',
                onRetry: () => ref.invalidate(purchaseCostSummaryProvider),
              ),
              data: (value) => _CostLedger(summary: value),
            ),
            SizedBox(height: tokens.spaceMd),
            Card(
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    key: const Key('include-shipping'),
                    title: const Text('累计包含运费'),
                    value: options.includeShipping,
                    onChanged: ref
                        .read(purchaseCostDisplayOptionsProvider.notifier)
                        .setIncludeShipping,
                  ),
                  const Divider(),
                  SwitchListTile(
                    key: const Key('include-fees'),
                    title: const Text('累计包含手续费'),
                    value: options.includeFees,
                    onChanged: ref
                        .read(purchaseCostDisplayOptionsProvider.notifier)
                        .setIncludeFees,
                  ),
                ],
              ),
            ),
            SizedBox(height: tokens.spaceXl),
            Text('历史', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: tokens.spaceSm),
            records.when(
              loading: () => const _Loading(label: '正在加载购买历史'),
              error: (error, stackTrace) => _InlineError(
                message: '购买历史暂时无法读取',
                onRetry: () => ref.invalidate(purchaseListProvider),
              ),
              data: (items) => items.isEmpty
                  ? const _EmptyPurchases()
                  : Column(
                      children: <Widget>[
                        for (var index = 0; index < items.length; index++) ...[
                          _PurchaseTile(record: items[index]),
                          if (index != items.length - 1)
                            SizedBox(height: tokens.spaceSm),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CostLedger extends StatelessWidget {
  const _CostLedger({required this.summary});

  final CostSummary summary;

  @override
  Widget build(BuildContext context) {
    if (summary.totals.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('保存第一笔购买后，这里会按币种显示累计花费。'),
        ),
      );
    }
    return Card(
      color: AppColors.primaryContainer,
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceMd),
        child: Wrap(
          spacing: context.tokens.spaceLg,
          runSpacing: context.tokens.spaceSm,
          children: <Widget>[
            for (final total in summary.totals)
              Semantics(
                label: '${total.currency} 累计花费',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '${total.currency} '
                      '${CurrencyAmount(minorUnits: total.minorUnits, currency: total.currency).formatted}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text('${total.purchaseCount} 条账本记录'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PurchaseTile extends ConsumerWidget {
  const _PurchaseTile({required this.record});

  final PurchaseRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amount = CurrencyAmount(
      minorUnits: record.ledgerMinor(),
      currency: record.currency,
    );
    final source = <String>[?record.channel, ?record.seller].join(' · ');
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        record.isAdjustment ? '退款调整' : '购买',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        '${record.currency} ${amount.formatted}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: record.isAdjustment
                              ? AppColors.error
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!record.isAdjustment)
                  IconButton(
                    key: Key('refund-${record.id}'),
                    tooltip: '记录退款',
                    onPressed: () => _showRefundDialog(context, ref, record),
                    icon: const Icon(Icons.undo_outlined),
                  ),
              ],
            ),
            SizedBox(height: context.tokens.spaceXs),
            Text(_dateLabel(record.purchasedAt)),
            if (source.isNotEmpty) Text(source),
            if (record.targets.isNotEmpty) ...<Widget>[
              SizedBox(height: context.tokens.spaceSm),
              Wrap(
                spacing: context.tokens.spaceSm,
                runSpacing: context.tokens.spaceXs,
                children: <Widget>[
                  for (final target in record.targets)
                    Chip(
                      avatar: Icon(
                        target.targetType == PurchaseTargetType.card
                            ? Icons.credit_card
                            : Icons.collections_bookmark_outlined,
                        size: 16,
                      ),
                      label: Text(target.targetName),
                    ),
                ],
              ),
            ],
            if (record.notes != null) ...<Widget>[
              SizedBox(height: context.tokens.spaceSm),
              Text(record.notes!),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> _showRefundDialog(
  BuildContext context,
  WidgetRef ref,
  PurchaseRecord original,
) async {
  final amountController = TextEditingController();
  final notesController = TextEditingController();
  String? errorText;
  var saving = false;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('记录退款'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                key: const Key('refund-amount'),
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: '退款金额（${original.currency}）',
                  errorText: errorText,
                ),
              ),
              SizedBox(height: context.tokens.spaceMd),
              TextField(
                controller: notesController,
                maxLength: 2000,
                decoration: const InputDecoration(labelText: '备注（可选）'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: saving ? null : () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: saving
                ? null
                : () async {
                    setState(() {
                      saving = true;
                      errorText = null;
                    });
                    try {
                      final refund = CurrencyAmount.parse(
                        amountController.text,
                        original.currency,
                      );
                      await ref
                          .read(purchaseRepositoryProvider)
                          .createAdjustment(
                            CreateAdjustmentRequest(
                              id: ref.read(idGeneratorProvider).newId(),
                              adjustmentOfId: original.id,
                              adjustedAt: ref.read(clockProvider).nowUtc(),
                              refundMinor: refund.minorUnits,
                              notes: notesController.text,
                            ),
                          );
                      ref.invalidate(purchaseListProvider);
                      ref.invalidate(purchaseCostSummaryProvider);
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    } on AppFailure catch (failure) {
                      setState(() {
                        errorText = failure.userMessage;
                        saving = false;
                      });
                    }
                  },
            child: saving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存退款'),
          ),
        ],
      ),
    ),
  );
}

class _EmptyPurchases extends StatelessWidget {
  const _EmptyPurchases();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceLg),
        child: const Column(
          children: <Widget>[
            Icon(Icons.receipt_long_outlined, size: 44),
            SizedBox(height: 12),
            Text('还没有购买记录'),
            SizedBox(height: 4),
            Text('记录购买后，可按原币种查看累计花费。'),
          ],
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceLg),
        child: CircularProgressIndicator(semanticsLabel: label),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.error_outline, color: AppColors.error),
        title: Text(message),
        trailing: TextButton(onPressed: onRetry, child: const Text('重试')),
      ),
    );
  }
}

String _dateLabel(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}
