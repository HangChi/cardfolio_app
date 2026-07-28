import 'package:cardfolio_app/features/dashboard/domain/dashboard_models.dart';
import 'package:cardfolio_app/features/dashboard/domain/dashboard_repository.dart';
import 'package:cardfolio_app/features/purchases/domain/purchase_models.dart';

final class FakeDashboardRepository implements DashboardRepository {
  FakeDashboardRepository({
    this.home = const HomeDashboard.empty(),
    this.statistics = const StatisticsSnapshot.empty(),
    this.homeStream,
    this.statisticsStream,
  });

  final HomeDashboard home;
  final StatisticsSnapshot statistics;
  final Stream<HomeDashboard> Function()? homeStream;
  final Stream<StatisticsSnapshot> Function()? statisticsStream;

  int homeWatchCount = 0;
  int statisticsWatchCount = 0;

  @override
  Stream<HomeDashboard> watchHome(CostDisplayOptions options) {
    homeWatchCount++;
    return homeStream?.call() ?? Stream<HomeDashboard>.value(home);
  }

  @override
  Stream<StatisticsSnapshot> watchStatistics(CostDisplayOptions options) {
    statisticsWatchCount++;
    return statisticsStream?.call() ??
        Stream<StatisticsSnapshot>.value(statistics);
  }
}
