import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme.dart';
import '../../../core/errors/app_failure.dart';
import '../../cards/data/card_providers.dart';
import '../data/purchase_providers.dart';
import '../domain/purchase_models.dart';

class PurchaseFormScreen extends ConsumerStatefulWidget {
  const PurchaseFormScreen({super.key});

  @override
  ConsumerState<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends ConsumerState<PurchaseFormScreen> {
  final _amountController = TextEditingController();
  final _shippingController = TextEditingController();
  final _feesController = TextEditingController();
  final _channelController = TextEditingController();
  final _sellerController = TextEditingController();
  final _notesController = TextEditingController();
  final Map<String, TextEditingController> _allocationControllers =
      <String, TextEditingController>{};
  final Set<String> _selectedTargetKeys = <String>{};

  String _currency = 'CNY';
  late DateTime _purchasedAt;
  bool _allocationsEnabled = false;
  bool _saving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _purchasedAt = ref.read(clockProvider).nowUtc();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _shippingController.dispose();
    _feesController.dispose();
    _channelController.dispose();
    _sellerController.dispose();
    _notesController.dispose();
    for (final controller in _allocationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targets = ref.watch(purchaseTargetOptionsProvider);
    final tokens = context.tokens;
    return Scaffold(
      appBar: AppBar(title: const Text('记录购买')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.spaceLg,
          tokens.spaceMd,
          tokens.spaceLg,
          tokens.spaceXl,
        ),
        children: <Widget>[
          const _SectionTitle('金额与日期'),
          TextField(
            key: const Key('purchase-amount'),
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '商品金额（$_currency）',
              errorText: _errorText,
            ),
          ),
          SizedBox(height: tokens.spaceMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: const Key('purchase-currency'),
                  initialValue: _currency,
                  decoration: const InputDecoration(labelText: '币种'),
                  items:
                      const <String>[
                            'CNY',
                            'JPY',
                            'USD',
                            'EUR',
                            'GBP',
                            'HKD',
                            'MOP',
                            'TWD',
                            'KRW',
                            'SGD',
                            'AUD',
                            'CAD',
                            'CHF',
                            'KWD',
                          ]
                          .map(
                            (currency) => DropdownMenuItem<String>(
                              value: currency,
                              child: Text(currency),
                            ),
                          )
                          .toList(),
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _currency = value!),
                ),
              ),
              SizedBox(width: tokens.spaceSm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving ? null : _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(_dateLabel(_purchasedAt)),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceMd),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  key: const Key('purchase-shipping'),
                  controller: _shippingController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: '运费（可选）'),
                ),
              ),
              SizedBox(width: tokens.spaceSm),
              Expanded(
                child: TextField(
                  key: const Key('purchase-fees'),
                  controller: _feesController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: '手续费（可选）'),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceXl),
          const _SectionTitle('来源（可选）'),
          TextField(
            key: const Key('purchase-channel'),
            controller: _channelController,
            maxLength: 100,
            decoration: const InputDecoration(labelText: '渠道'),
          ),
          SizedBox(height: tokens.spaceSm),
          TextField(
            key: const Key('purchase-seller'),
            controller: _sellerController,
            maxLength: 200,
            decoration: const InputDecoration(labelText: '卖家'),
          ),
          SizedBox(height: tokens.spaceSm),
          TextField(
            key: const Key('purchase-notes'),
            controller: _notesController,
            maxLength: 2000,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: '备注'),
          ),
          SizedBox(height: tokens.spaceXl),
          const _SectionTitle('关联卡片或套卡'),
          targets.when(
            loading: () => const Center(
              child: CircularProgressIndicator(semanticsLabel: '正在加载可选对象'),
            ),
            error: (error, stackTrace) => Card(
              child: ListTile(
                title: const Text('可选对象暂时无法读取'),
                trailing: TextButton(
                  onPressed: () =>
                      ref.invalidate(purchaseTargetOptionsProvider),
                  child: const Text('重试'),
                ),
              ),
            ),
            data: (items) => items.isEmpty
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('请先创建卡片或套卡，再记录购买。'),
                    ),
                  )
                : Column(
                    children: <Widget>[
                      for (final target in items) _targetTile(target),
                    ],
                  ),
          ),
          SizedBox(height: tokens.spaceMd),
          SwitchListTile(
            key: const Key('enable-allocations'),
            contentPadding: EdgeInsets.zero,
            title: const Text('为所选对象分摊金额'),
            subtitle: const Text('分摊合计需等于商品金额 + 运费 + 手续费，不会重复累计。'),
            value: _allocationsEnabled,
            onChanged: _selectedTargetKeys.isEmpty || _saving
                ? null
                : (value) => setState(() => _allocationsEnabled = value),
          ),
          if (_allocationsEnabled) ...<Widget>[
            SizedBox(height: tokens.spaceSm),
            for (final target
                in targets.value ?? const <PurchaseTargetOption>[])
              if (_selectedTargetKeys.contains(_targetKey(target)))
                Padding(
                  padding: EdgeInsets.only(bottom: tokens.spaceSm),
                  child: TextField(
                    key: Key(
                      'allocation-${target.targetType.name}-${target.targetId}',
                    ),
                    controller: _allocationController(target),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: '${target.targetName} 分摊（$_currency）',
                    ),
                  ),
                ),
          ],
          SizedBox(height: tokens.spaceLg),
          if (_errorText != null) ...<Widget>[
            Semantics(
              liveRegion: true,
              child: Text(
                _errorText!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
              ),
            ),
            SizedBox(height: tokens.spaceSm),
          ],
          FilledButton(
            key: const Key('save-purchase'),
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存购买'),
          ),
        ],
      ),
    );
  }

  Widget _targetTile(PurchaseTargetOption target) {
    final key = _targetKey(target);
    final selected = _selectedTargetKeys.contains(key);
    return CheckboxListTile(
      key: Key('target-${target.targetType.name}-${target.targetId}'),
      contentPadding: EdgeInsets.zero,
      value: selected,
      onChanged: _saving
          ? null
          : (value) => setState(() {
              if (value == true) {
                _selectedTargetKeys.add(key);
              } else {
                _selectedTargetKeys.remove(key);
              }
              if (_selectedTargetKeys.isEmpty) {
                _allocationsEnabled = false;
              }
            }),
      secondary: Icon(
        target.targetType == PurchaseTargetType.card
            ? Icons.credit_card
            : Icons.collections_bookmark_outlined,
      ),
      title: Text(target.targetName),
      subtitle: Text(
        target.targetType == PurchaseTargetType.card ? '卡片' : '套卡',
      ),
    );
  }

  TextEditingController _allocationController(PurchaseTargetOption target) {
    return _allocationControllers.putIfAbsent(
      _targetKey(target),
      TextEditingController.new,
    );
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _purchasedAt.toLocal(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (result != null && mounted) {
      setState(() {
        _purchasedAt = DateTime.utc(result.year, result.month, result.day);
      });
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _errorText = null;
    });
    try {
      final amount = CurrencyAmount.parse(_amountController.text, _currency);
      final shipping = _optionalAmount(_shippingController.text);
      final fees = _optionalAmount(_feesController.text);
      final options =
          ref.read(purchaseTargetOptionsProvider).value ??
          const <PurchaseTargetOption>[];
      final selected = options
          .where((target) => _selectedTargetKeys.contains(_targetKey(target)))
          .toList(growable: false);
      final targets = <PurchaseTargetInput>[
        for (final target in selected)
          PurchaseTargetInput(
            targetType: target.targetType,
            targetId: target.targetId,
            allocatedMinor: _allocationsEnabled
                ? CurrencyAmount.parse(
                    _allocationController(target).text,
                    _currency,
                  ).minorUnits
                : null,
          ),
      ];
      final request = CreatePurchaseRequest(
        id: ref.read(idGeneratorProvider).newId(),
        purchasedAt: _purchasedAt,
        amountMinor: amount.minorUnits,
        currency: _currency,
        shippingMinor: shipping,
        feesMinor: fees,
        channel: _channelController.text,
        seller: _sellerController.text,
        notes: _notesController.text,
        targets: targets,
      ).normalized();
      await ref.read(purchaseRepositoryProvider).createPurchase(request);
      ref.invalidate(purchaseListProvider);
      ref.invalidate(purchaseCostSummaryProvider);
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
    } on AppFailure catch (failure) {
      if (mounted) {
        setState(() {
          _errorText = failure.userMessage;
          _saving = false;
        });
      }
    } finally {
      if (mounted && _saving && !Navigator.canPop(context)) {
        setState(() => _saving = false);
      }
    }
  }

  int _optionalAmount(String value) {
    if (value.trim().isEmpty) return 0;
    return CurrencyAmount.parse(value, _currency).minorUnits;
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.tokens.spaceSm),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

String _targetKey(PurchaseTargetOption target) =>
    '${target.targetType.name}:${target.targetId}';

String _dateLabel(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}
