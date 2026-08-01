import '../../../core/errors/app_failure.dart';
import '../../../core/time/clock.dart';
import '../../cards/data/local/card_database.dart';
import '../../purchases/domain/purchase_models.dart';
import '../domain/dashboard_models.dart';
import '../domain/dashboard_repository.dart';
import 'local/dashboard_database.dart';

final class DashboardRepositoryImpl
    implements DashboardRepository, SpendingCalendarRepository {
  const DashboardRepositoryImpl({
    required AppDatabase database,
    required this.clock,
  }) : _db = database;

  final AppDatabase _db;
  final Clock clock;

  @override
  Stream<HomeDashboard> watchHome(CostDisplayOptions options) {
    return _read(
      () => _db.watchHomeDashboard(nowUtc: clock.nowUtc(), options: options),
    );
  }

  @override
  Stream<StatisticsSnapshot> watchStatistics(CostDisplayOptions options) {
    return _read(() => _db.watchStatisticsSnapshot(options));
  }

  @override
  Stream<SpendingCalendarMonth> watchSpendingMonth(
    DateTime month,
    CostDisplayOptions options,
  ) {
    return _read(
      () => _db.watchSpendingCalendarMonth(month: month, options: options),
    );
  }

  Stream<T> _read<T>(Stream<T> Function() createStream) {
    try {
      return createStream().handleError((Object error) {
        if (error is AppFailure) throw error;
        throw DatabaseUnavailableFailure('首页与统计暂时无法读取，请重试。', error);
      });
    } on AppFailure {
      rethrow;
    } catch (error) {
      return Stream<T>.error(
        DatabaseUnavailableFailure('首页与统计暂时无法读取，请重试。', error),
      );
    }
  }
}
