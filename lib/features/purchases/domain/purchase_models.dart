import 'package:meta/meta.dart';

import '../../../core/errors/app_failure.dart';

const int _maxStoredMinor = 9000000000000000;

enum PurchaseTargetType { card, cardSet }

@immutable
final class CurrencyAmount {
  const CurrencyAmount({required this.minorUnits, required this.currency});

  final int minorUnits;
  final String currency;

  static const Set<String> _zeroDecimalCurrencies = <String>{
    'BIF',
    'CLP',
    'DJF',
    'GNF',
    'ISK',
    'JPY',
    'KMF',
    'KRW',
    'PYG',
    'RWF',
    'UGX',
    'VND',
    'VUV',
    'XAF',
    'XOF',
    'XPF',
  };

  static const Set<String> _threeDecimalCurrencies = <String>{
    'BHD',
    'IQD',
    'JOD',
    'KWD',
    'LYD',
    'OMR',
    'TND',
  };

  static int minorDigitsFor(String currency) {
    final normalized = normalizeCurrency(currency);
    if (_zeroDecimalCurrencies.contains(normalized)) return 0;
    if (_threeDecimalCurrencies.contains(normalized)) return 3;
    return 2;
  }

  static CurrencyAmount parse(String input, String currency) {
    final normalizedCurrency = normalizeCurrency(currency);
    final digits = minorDigitsFor(normalizedCurrency);
    final normalizedInput = input.trim().replaceAll(',', '');
    final match = RegExp(
      r'^([+-]?)(\d+)(?:\.(\d+))?$',
    ).firstMatch(normalizedInput);
    if (match == null) {
      throw const PurchaseValidationFailure(PurchaseField.amount, '请输入有效金额。');
    }
    final fraction = match.group(3) ?? '';
    if (fraction.length > digits || (digits == 0 && fraction.isNotEmpty)) {
      throw PurchaseValidationFailure(
        PurchaseField.amount,
        '$normalizedCurrency 最多支持 $digits 位小数。',
      );
    }
    final scale = _pow10(digits);
    final major = int.parse(match.group(2)!);
    final fractionMinor = fraction.isEmpty
        ? 0
        : int.parse(fraction.padRight(digits, '0'));
    final sign = match.group(1) == '-' ? -1 : 1;
    final minor = sign * (major * scale + fractionMinor);
    _validateStoredMinor(minor, PurchaseField.amount);
    return CurrencyAmount(minorUnits: minor, currency: normalizedCurrency);
  }

  String get formatted {
    final digits = minorDigitsFor(currency);
    final sign = minorUnits < 0 ? '-' : '';
    final absolute = minorUnits.abs();
    if (digits == 0) return '$sign$absolute';
    final scale = _pow10(digits);
    final major = absolute ~/ scale;
    final fraction = (absolute % scale).toString().padLeft(digits, '0');
    return '$sign$major.$fraction';
  }
}

@immutable
final class CardEntryCost {
  const CardEntryCost({
    required this.amountMinor,
    required this.shippingMinor,
  });

  const CardEntryCost.empty() : amountMinor = 0, shippingMinor = 0;

  final int amountMinor;
  final int shippingMinor;

  bool get isEmpty => amountMinor == 0 && shippingMinor == 0;
}

@immutable
final class SaveCardEntryCostRequest {
  const SaveCardEntryCostRequest({
    required this.cardItemId,
    required this.amountMinor,
    required this.shippingMinor,
    this.isNormalized = false,
  });

  final String cardItemId;
  final int amountMinor;
  final int shippingMinor;
  final bool isNormalized;

  bool get isEmpty => amountMinor == 0 && shippingMinor == 0;

  SaveCardEntryCostRequest normalized() {
    if (isNormalized) return this;
    if (amountMinor < 0 || shippingMinor < 0) {
      throw const PurchaseValidationFailure(
        PurchaseField.amount,
        '卡片金额和运费不能为负数。',
      );
    }
    _validateStoredMinor(amountMinor, PurchaseField.amount);
    _validateStoredMinor(shippingMinor, PurchaseField.amount);
    _validateStoredMinor(amountMinor + shippingMinor, PurchaseField.amount);
    return SaveCardEntryCostRequest(
      cardItemId: _requiredId(cardItemId, PurchaseField.target),
      amountMinor: amountMinor,
      shippingMinor: shippingMinor,
      isNormalized: true,
    );
  }
}

String cardEntryCostPurchaseId(String cardItemId) =>
    'card-entry-cost:${cardItemId.trim()}';

@immutable
final class CostDisplayOptions {
  const CostDisplayOptions({
    this.includeShipping = true,
    this.includeFees = true,
  });

  final bool includeShipping;
  final bool includeFees;
}

@immutable
final class PurchaseTargetInput {
  const PurchaseTargetInput({
    required this.targetType,
    required this.targetId,
    this.allocatedMinor,
  });

  final PurchaseTargetType targetType;
  final String targetId;
  final int? allocatedMinor;

  PurchaseTargetInput normalized() {
    final id = _requiredId(targetId, PurchaseField.target);
    final allocation = allocatedMinor;
    if (allocation != null) {
      if (allocation < 0) {
        throw const PurchaseValidationFailure(
          PurchaseField.allocation,
          '分摊金额不能为负数。',
        );
      }
      _validateStoredMinor(allocation, PurchaseField.allocation);
    }
    return PurchaseTargetInput(
      targetType: targetType,
      targetId: id,
      allocatedMinor: allocation,
    );
  }
}

@immutable
final class CreatePurchaseRequest {
  const CreatePurchaseRequest({
    required this.id,
    required this.purchasedAt,
    required this.amountMinor,
    required this.currency,
    this.shippingMinor = 0,
    this.feesMinor = 0,
    this.channel,
    this.seller,
    this.notes,
    this.targets = const <PurchaseTargetInput>[],
    this.isNormalized = false,
  });

  final String id;
  final DateTime purchasedAt;
  final int amountMinor;
  final String currency;
  final int shippingMinor;
  final int feesMinor;
  final String? channel;
  final String? seller;
  final String? notes;
  final List<PurchaseTargetInput> targets;
  final bool isNormalized;

  int get defaultLedgerMinor => amountMinor + shippingMinor + feesMinor;

  bool get hasAllocations =>
      targets.any((target) => target.allocatedMinor != null);

  CreatePurchaseRequest normalized() {
    if (isNormalized) return this;
    final normalizedId = _requiredId(id, PurchaseField.target);
    if (amountMinor < 0 || shippingMinor < 0 || feesMinor < 0) {
      throw const PurchaseValidationFailure(
        PurchaseField.amount,
        '普通购买的商品金额、运费和手续费不能为负数。',
      );
    }
    _validateStoredMinor(amountMinor, PurchaseField.amount);
    _validateStoredMinor(shippingMinor, PurchaseField.amount);
    _validateStoredMinor(feesMinor, PurchaseField.amount);
    _validateStoredMinor(defaultLedgerMinor, PurchaseField.amount);
    final normalizedTargets = targets
        .map((target) => target.normalized())
        .toList(growable: false);
    if (normalizedTargets.isEmpty) {
      throw const PurchaseValidationFailure(
        PurchaseField.target,
        '请至少选择一张卡片或一个套卡。',
      );
    }
    final uniqueTargets = <String>{};
    for (final target in normalizedTargets) {
      final key = '${target.targetType.name}:${target.targetId}';
      if (!uniqueTargets.add(key)) {
        throw const PurchaseValidationFailure(
          PurchaseField.target,
          '同一购买目标不能重复选择。',
        );
      }
    }
    final hasAnyAllocation = normalizedTargets.any(
      (target) => target.allocatedMinor != null,
    );
    if (hasAnyAllocation) {
      if (normalizedTargets.any((target) => target.allocatedMinor == null)) {
        throw const PurchaseValidationFailure(
          PurchaseField.allocation,
          '启用分摊后，请为每个目标填写分摊金额。',
        );
      }
      final allocated = normalizedTargets.fold<int>(
        0,
        (total, target) => total + target.allocatedMinor!,
      );
      if (allocated != defaultLedgerMinor) {
        throw PurchaseValidationFailure(
          PurchaseField.allocation,
          '分摊合计必须等于默认累计金额 '
          '${CurrencyAmount(minorUnits: defaultLedgerMinor, currency: currency).formatted}。',
        );
      }
    }
    return CreatePurchaseRequest(
      id: normalizedId,
      purchasedAt: purchasedAt.toUtc(),
      amountMinor: amountMinor,
      currency: normalizeCurrency(currency),
      shippingMinor: shippingMinor,
      feesMinor: feesMinor,
      channel: _optionalText(
        channel,
        field: PurchaseField.channel,
        maxLength: 100,
      ),
      seller: _optionalText(
        seller,
        field: PurchaseField.seller,
        maxLength: 200,
      ),
      notes: _optionalText(notes, field: PurchaseField.notes, maxLength: 2000),
      targets: List<PurchaseTargetInput>.unmodifiable(normalizedTargets),
      isNormalized: true,
    );
  }
}

@immutable
final class CreateAdjustmentRequest {
  const CreateAdjustmentRequest({
    required this.id,
    required this.adjustmentOfId,
    required this.adjustedAt,
    required this.refundMinor,
    this.notes,
    this.isNormalized = false,
  });

  final String id;
  final String adjustmentOfId;
  final DateTime adjustedAt;
  final int refundMinor;
  final String? notes;
  final bool isNormalized;

  CreateAdjustmentRequest normalized() {
    if (isNormalized) return this;
    if (refundMinor <= 0) {
      throw const PurchaseValidationFailure(
        PurchaseField.adjustment,
        '退款金额必须大于零。',
      );
    }
    _validateStoredMinor(refundMinor, PurchaseField.adjustment);
    return CreateAdjustmentRequest(
      id: _requiredId(id, PurchaseField.adjustment),
      adjustmentOfId: _requiredId(adjustmentOfId, PurchaseField.adjustment),
      adjustedAt: adjustedAt.toUtc(),
      refundMinor: refundMinor,
      notes: _optionalText(notes, field: PurchaseField.notes, maxLength: 2000),
      isNormalized: true,
    );
  }
}

@immutable
final class ExchangeRateInput {
  const ExchangeRateInput({
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.rateDate,
    required this.numerator,
    required this.denominator,
    required this.source,
    required this.capturedAt,
    this.isNormalized = false,
  });

  final String baseCurrency;
  final String quoteCurrency;
  final DateTime rateDate;
  final int numerator;
  final int denominator;
  final String source;
  final DateTime capturedAt;
  final bool isNormalized;

  ExchangeRateInput normalized() {
    if (isNormalized) return this;
    final base = normalizeCurrency(baseCurrency);
    final quote = normalizeCurrency(quoteCurrency);
    if (base == quote) {
      throw const PurchaseValidationFailure(
        PurchaseField.exchangeRate,
        '汇率的原币种和目标币种不能相同。',
      );
    }
    if (numerator <= 0 || denominator <= 0) {
      throw const PurchaseValidationFailure(
        PurchaseField.exchangeRate,
        '汇率分子和分母必须是正整数。',
      );
    }
    _validateStoredMinor(numerator, PurchaseField.exchangeRate);
    _validateStoredMinor(denominator, PurchaseField.exchangeRate);
    final normalizedSource = _optionalText(
      source,
      field: PurchaseField.exchangeRate,
      maxLength: 200,
    );
    if (normalizedSource == null) {
      throw const PurchaseValidationFailure(
        PurchaseField.exchangeRate,
        '请填写汇率来源。',
      );
    }
    return ExchangeRateInput(
      baseCurrency: base,
      quoteCurrency: quote,
      rateDate: DateTime.utc(rateDate.year, rateDate.month, rateDate.day),
      numerator: numerator,
      denominator: denominator,
      source: normalizedSource,
      capturedAt: capturedAt.toUtc(),
      isNormalized: true,
    );
  }
}

@immutable
final class PurchaseTargetSnapshot {
  const PurchaseTargetSnapshot({
    required this.targetType,
    required this.targetId,
    required this.targetName,
    this.allocatedMinor,
  });

  final PurchaseTargetType targetType;
  final String targetId;
  final String targetName;
  final int? allocatedMinor;
}

@immutable
final class PurchaseTargetOption {
  const PurchaseTargetOption({
    required this.targetType,
    required this.targetId,
    required this.targetName,
  });

  final PurchaseTargetType targetType;
  final String targetId;
  final String targetName;
}

@immutable
final class PurchaseRecord {
  const PurchaseRecord({
    required this.id,
    required this.purchasedAt,
    required this.amountMinor,
    required this.currency,
    required this.shippingMinor,
    required this.feesMinor,
    required this.createdAt,
    required this.targets,
    this.channel,
    this.seller,
    this.notes,
    this.adjustmentOfId,
  });

  final String id;
  final DateTime purchasedAt;
  final int amountMinor;
  final String currency;
  final int shippingMinor;
  final int feesMinor;
  final String? channel;
  final String? seller;
  final String? notes;
  final String? adjustmentOfId;
  final DateTime createdAt;
  final List<PurchaseTargetSnapshot> targets;

  bool get isAdjustment => adjustmentOfId != null;

  int ledgerMinor([CostDisplayOptions options = const CostDisplayOptions()]) {
    return amountMinor +
        (options.includeShipping ? shippingMinor : 0) +
        (options.includeFees ? feesMinor : 0);
  }
}

@immutable
final class CostTotal {
  const CostTotal({
    required this.currency,
    required this.minorUnits,
    required this.purchaseCount,
  });

  final String currency;
  final int minorUnits;
  final int purchaseCount;
}

@immutable
final class CostSummary {
  const CostSummary({required this.totals, required this.options});

  final List<CostTotal> totals;
  final CostDisplayOptions options;
}

String normalizeCurrency(String value) {
  final normalized = value.trim().toUpperCase();
  if (!RegExp(r'^[A-Z]{3}$').hasMatch(normalized) || normalized == 'RMB') {
    throw const PurchaseValidationFailure(
      PurchaseField.currency,
      '币种必须使用三位 ISO 代码，例如 CNY、JPY 或 USD。',
    );
  }
  return normalized;
}

String _requiredId(String value, PurchaseField field) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw PurchaseValidationFailure(field, '目标不存在，请刷新后重试。');
  }
  return normalized;
}

String? _optionalText(
  String? value, {
  required PurchaseField field,
  required int maxLength,
}) {
  final normalized = value?.trim() ?? '';
  if (normalized.isEmpty) return null;
  if (normalized.length > maxLength) {
    throw PurchaseValidationFailure(field, '内容最多 $maxLength 个字符。');
  }
  return normalized;
}

void _validateStoredMinor(int value, PurchaseField field) {
  if (value.abs() > _maxStoredMinor) {
    throw PurchaseValidationFailure(field, '金额超出可保存范围。');
  }
}

int _pow10(int exponent) {
  var result = 1;
  for (var index = 0; index < exponent; index++) {
    result *= 10;
  }
  return result;
}
