import '../../purchases/domain/purchase_models.dart';
import 'dashboard_models.dart';

abstract interface class DashboardRepository {
  Stream<HomeDashboard> watchHome(CostDisplayOptions options);

  Stream<StatisticsSnapshot> watchStatistics(CostDisplayOptions options);
}
