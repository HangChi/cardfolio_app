import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cards/data/card_providers.dart';
import '../../purchases/data/purchase_providers.dart';
import '../domain/dashboard_models.dart';
import '../domain/dashboard_repository.dart';
import 'dashboard_repository_impl.dart';

final Provider<DashboardRepository> dashboardRepositoryProvider =
    Provider<DashboardRepository>((ref) {
      return DashboardRepositoryImpl(
        database: ref.watch(appDatabaseProvider),
        clock: ref.watch(clockProvider),
      );
    });

final StreamProvider<HomeDashboard> homeDashboardProvider =
    StreamProvider<HomeDashboard>((ref) {
      final options = ref.watch(purchaseCostDisplayOptionsProvider);
      return ref.watch(dashboardRepositoryProvider).watchHome(options);
    });

final StreamProvider<StatisticsSnapshot> statisticsProvider =
    StreamProvider<StatisticsSnapshot>((ref) {
      final options = ref.watch(purchaseCostDisplayOptionsProvider);
      return ref.watch(dashboardRepositoryProvider).watchStatistics(options);
    });
