import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cards/data/card_providers.dart';
import '../domain/purchase_models.dart';
import '../domain/purchase_repository.dart';
import 'purchase_repository_impl.dart';

final Provider<PurchaseRepository> purchaseRepositoryProvider =
    Provider<PurchaseRepository>((ref) {
      return PurchaseRepositoryImpl(
        database: ref.watch(appDatabaseProvider),
        clock: ref.watch(clockProvider),
      );
    });

final cardEntryCostProvider = StreamProvider.family<CardEntryCost, String>((
  ref,
  cardItemId,
) {
  return ref.watch(purchaseRepositoryProvider).watchCardEntryCost(cardItemId);
});

final NotifierProvider<CostDisplayOptionsController, CostDisplayOptions>
purchaseCostDisplayOptionsProvider =
    NotifierProvider<CostDisplayOptionsController, CostDisplayOptions>(
      CostDisplayOptionsController.new,
    );

final class CostDisplayOptionsController extends Notifier<CostDisplayOptions> {
  @override
  CostDisplayOptions build() => const CostDisplayOptions();

  void setIncludeShipping(bool value) {
    state = CostDisplayOptions(
      includeShipping: value,
      includeFees: state.includeFees,
    );
  }

  void setIncludeFees(bool value) {
    state = CostDisplayOptions(
      includeShipping: state.includeShipping,
      includeFees: value,
    );
  }
}

final StreamProvider<List<PurchaseRecord>> purchaseListProvider =
    StreamProvider<List<PurchaseRecord>>((ref) {
      return ref.watch(purchaseRepositoryProvider).watchPurchases();
    });

final StreamProvider<CostSummary> purchaseCostSummaryProvider =
    StreamProvider<CostSummary>((ref) {
      final options = ref.watch(purchaseCostDisplayOptionsProvider);
      return ref.watch(purchaseRepositoryProvider).watchCostSummary(options);
    });

final StreamProvider<List<PurchaseTargetOption>> purchaseTargetOptionsProvider =
    StreamProvider<List<PurchaseTargetOption>>((ref) {
      return ref.watch(purchaseRepositoryProvider).watchTargetOptions();
    });
