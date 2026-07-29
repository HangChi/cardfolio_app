import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/backup/presentation/backup_screen.dart';
import '../features/card_sets/presentation/detail/card_set_detail_screen.dart';
import '../features/card_sets/presentation/form/card_set_form_screen.dart';
import '../features/cards/presentation/capture/capture_entry_screen.dart';
import '../features/cards/presentation/create/create_card_screen.dart';
import '../features/cards/presentation/detail/card_detail_screen.dart';
import '../features/cards/presentation/library/card_library_screen.dart';
import '../features/dashboard/presentation/home_screen.dart';
import '../features/dashboard/presentation/statistics_screen.dart';
import '../features/organization/presentation/card/card_organization_screen.dart';
import '../features/organization/presentation/management/organization_settings_screen.dart';
import '../features/organization/presentation/series/series_detail_screen.dart';
import '../features/organization/presentation/series/series_form_screen.dart';
import '../features/purchases/presentation/purchase_form_screen.dart';
import '../features/purchases/presentation/purchase_list_screen.dart';
import '../features/recycle_bin/presentation/recycle_bin_screen.dart';
import 'navigation/app_shell.dart';

const String homePath = '/home';
const String libraryPath = '/library';
const String capturePath = '/capture';
const String statsPath = '/stats';
const String profilePath = '/profile';
const String createCardPath = '/cards/new';
const String createCardSetPath = '/sets/new';
const String createSeriesPath = '/series/new';
const String purchasesPath = '/purchases';
const String createPurchasePath = '/purchases/new';
const String recycleBinPath = '/recycle-bin';
const String backupPath = '/backup';

String cardDetailPath(String id) => '/cards/$id';
String cardOrganizationPath(String id) => '/cards/$id/organization';
String cardSetDetailPath(String id) => '/sets/$id';
String editCardSetPath(String id) => '/sets/$id/edit';
String seriesDetailPath(String id) => '/series/$id';
String editSeriesPath(String id) => '/series/$id/edit';

/// Cardfolio 的五入口路由骨架。
GoRouter createAppRouter({String initialLocation = libraryPath}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    initialLocation: initialLocation,
    navigatorKey: rootNavigatorKey,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          _branch(homePath, const HomeScreen()),
          _branch(libraryPath, const CardLibraryScreen()),
          _branch(capturePath, const CaptureEntryScreen()),
          _branch(statsPath, const StatisticsScreen()),
          _branch(profilePath, const OrganizationSettingsScreen()),
        ],
      ),
      GoRoute(
        path: createCardPath,
        builder: (context, state) => const CreateCardScreen(),
      ),
      GoRoute(
        path: '/cards/:id/organization',
        builder: (context, state) =>
            CardOrganizationScreen(cardItemId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/cards/:id',
        builder: (context, state) =>
            CardDetailScreen(cardItemId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: createCardSetPath,
        builder: (context, state) => const CardSetFormScreen(),
      ),
      GoRoute(
        path: '/sets/:id/edit',
        builder: (context, state) =>
            CardSetFormScreen(setId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/sets/:id',
        builder: (context, state) =>
            CardSetDetailScreen(setId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: createSeriesPath,
        builder: (context, state) => const SeriesFormScreen(),
      ),
      GoRoute(
        path: '/series/:id/edit',
        builder: (context, state) =>
            SeriesFormScreen(seriesId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/series/:id',
        builder: (context, state) =>
            SeriesDetailScreen(seriesId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: purchasesPath,
        builder: (context, state) => const PurchaseListScreen(),
      ),
      GoRoute(
        path: createPurchasePath,
        builder: (context, state) => const PurchaseFormScreen(),
      ),
      GoRoute(
        path: recycleBinPath,
        builder: (context, state) => const RecycleBinScreen(),
      ),
      GoRoute(
        path: backupPath,
        builder: (context, state) => const BackupScreen(),
      ),
    ],
  );
}

StatefulShellBranch _branch(String path, Widget child) {
  return StatefulShellBranch(
    routes: <RouteBase>[
      GoRoute(path: path, builder: (context, state) => child),
    ],
  );
}
