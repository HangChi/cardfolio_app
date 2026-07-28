import '../../../core/errors/app_failure.dart';
import '../../../core/time/clock.dart';
import '../../cards/data/local/card_database.dart';
import '../domain/purchase_models.dart';
import '../domain/purchase_repository.dart';
import 'local/purchase_database.dart';

final class PurchaseRepositoryImpl implements PurchaseRepository {
  const PurchaseRepositoryImpl({
    required AppDatabase database,
    required this.clock,
  }) : _db = database;

  final AppDatabase _db;
  final Clock clock;

  @override
  Stream<List<PurchaseRecord>> watchPurchases() =>
      _read(_db.watchPurchaseRecords());

  @override
  Stream<CostSummary> watchCostSummary(CostDisplayOptions options) =>
      _read(_db.watchPurchaseCostSummary(options));

  @override
  Stream<List<PurchaseTargetOption>> watchTargetOptions() =>
      _read(_db.watchPurchaseTargetOptions());

  @override
  Future<String> createPurchase(CreatePurchaseRequest request) async {
    final normalized = request.normalized();
    await _write(
      action: () =>
          _db.createPurchase(request: normalized, now: clock.nowUtc()),
      field: PurchaseField.target,
      failureMessage: '保存购买记录失败，请重试。',
    );
    return normalized.id;
  }

  @override
  Future<String> createAdjustment(CreateAdjustmentRequest request) async {
    final normalized = request.normalized();
    await _write(
      action: () => _db.createPurchaseAdjustment(
        request: normalized,
        now: clock.nowUtc(),
      ),
      field: PurchaseField.adjustment,
      failureMessage: '保存退款记录失败，原购买记录未改变。',
    );
    return normalized.id;
  }

  @override
  Future<void> saveExchangeRate(ExchangeRateInput rate) {
    final normalized = rate.normalized();
    return _write(
      action: () => _db.savePurchaseExchangeRate(normalized),
      field: PurchaseField.exchangeRate,
      failureMessage: '保存汇率失败，请重试。',
    );
  }

  Stream<T> _read<T>(Stream<T> stream) {
    return stream.handleError((Object error) {
      if (error is AppFailure) throw error;
      throw DatabaseUnavailableFailure('购买记录暂时无法读取，请重试。', error);
    });
  }

  Future<void> _write({
    required Future<void> Function() action,
    required PurchaseField field,
    required String failureMessage,
  }) async {
    try {
      await action();
    } on AppFailure {
      rethrow;
    } on StateError catch (error) {
      throw PurchaseValidationFailure(field, error.message);
    } catch (error) {
      throw PersistenceFailure(failureMessage, error);
    }
  }
}
