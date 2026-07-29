import 'purchase_models.dart';

abstract interface class PurchaseRepository {
  Stream<CardEntryCost> watchCardEntryCost(String cardItemId);

  Future<void> saveCardEntryCost(SaveCardEntryCostRequest request);

  Stream<List<PurchaseRecord>> watchPurchases();

  Stream<CostSummary> watchCostSummary(CostDisplayOptions options);

  Stream<List<PurchaseTargetOption>> watchTargetOptions();

  Future<String> createPurchase(CreatePurchaseRequest request);

  Future<String> createAdjustment(CreateAdjustmentRequest request);

  Future<void> saveExchangeRate(ExchangeRateInput rate);
}
