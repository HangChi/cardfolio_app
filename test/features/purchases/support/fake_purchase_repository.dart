import 'dart:async';

import 'package:cardfolio_app/features/purchases/domain/purchase_models.dart';
import 'package:cardfolio_app/features/purchases/domain/purchase_repository.dart';

final class FakePurchaseRepository implements PurchaseRepository {
  FakePurchaseRepository({
    this.records = const <PurchaseRecord>[],
    this.targets = const <PurchaseTargetOption>[],
  });

  List<PurchaseRecord> records;
  List<PurchaseTargetOption> targets;
  CardEntryCost cardEntryCost = const CardEntryCost.empty();
  final List<SaveCardEntryCostRequest> savedCardEntryCosts =
      <SaveCardEntryCostRequest>[];
  final List<CreatePurchaseRequest> created = <CreatePurchaseRequest>[];
  final List<CreateAdjustmentRequest> adjustments = <CreateAdjustmentRequest>[];
  final List<ExchangeRateInput> rates = <ExchangeRateInput>[];
  Completer<String>? createCompleter;

  @override
  Stream<CardEntryCost> watchCardEntryCost(String cardItemId) =>
      Stream<CardEntryCost>.value(cardEntryCost);

  @override
  Future<void> saveCardEntryCost(SaveCardEntryCostRequest request) async {
    final normalized = request.normalized();
    savedCardEntryCosts.add(normalized);
    cardEntryCost = CardEntryCost(
      amountMinor: normalized.amountMinor,
      shippingMinor: normalized.shippingMinor,
    );
  }

  @override
  Future<String> createPurchase(CreatePurchaseRequest request) async {
    final normalized = request.normalized();
    created.add(normalized);
    final completer = createCompleter;
    if (completer != null) return completer.future;
    return normalized.id;
  }

  @override
  Future<String> createAdjustment(CreateAdjustmentRequest request) async {
    final normalized = request.normalized();
    adjustments.add(normalized);
    return normalized.id;
  }

  @override
  Future<void> saveExchangeRate(ExchangeRateInput rate) async {
    rates.add(rate.normalized());
  }

  @override
  Stream<List<PurchaseRecord>> watchPurchases() =>
      Stream<List<PurchaseRecord>>.value(records);

  @override
  Stream<List<PurchaseTargetOption>> watchTargetOptions() =>
      Stream<List<PurchaseTargetOption>>.value(targets);

  @override
  Stream<CostSummary> watchCostSummary(CostDisplayOptions options) {
    final totals = <String, int>{};
    final counts = <String, int>{};
    for (final record in records) {
      totals.update(
        record.currency,
        (value) => value + record.ledgerMinor(options),
        ifAbsent: () => record.ledgerMinor(options),
      );
      counts.update(record.currency, (value) => value + 1, ifAbsent: () => 1);
    }
    final currencies = totals.keys.toList()..sort();
    return Stream<CostSummary>.value(
      CostSummary(
        options: options,
        totals: <CostTotal>[
          for (final currency in currencies)
            CostTotal(
              currency: currency,
              minorUnits: totals[currency]!,
              purchaseCount: counts[currency]!,
            ),
        ],
      ),
    );
  }
}
