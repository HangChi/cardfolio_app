import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/preferences/local_app_state_providers.dart';
import '../features/backup/presentation/backup_screen.dart';
import '../features/card_sets/presentation/detail/card_set_detail_screen.dart';
import '../features/card_sets/presentation/form/card_set_form_screen.dart';
import '../features/cards/presentation/capture/capture_entry_screen.dart';
import '../features/cards/presentation/batch/batch_card_entry_screen.dart';
import '../features/cards/data/card_providers.dart';
import '../features/cards/presentation/create/create_card_screen.dart';
import '../features/cards/presentation/detail/card_detail_screen.dart';
import '../features/cards/presentation/edit/image_editor_screen.dart';
import '../features/cards/presentation/edit/edit_card_screen.dart';
import '../features/cards/presentation/library/card_library_screen.dart';
import '../features/dashboard/presentation/home_screen.dart';
import '../features/dashboard/presentation/spending_calendar_screen.dart';
import '../features/dashboard/presentation/statistics_screen.dart';
import '../features/export/presentation/csv_export_screen.dart';
import '../features/organization/presentation/card/card_organization_screen.dart';
import '../features/organization/presentation/management/organization_settings_screen.dart';
import '../features/organization/presentation/series/series_detail_screen.dart';
import '../features/organization/presentation/series/series_form_screen.dart';
import '../features/recycle_bin/presentation/recycle_bin_screen.dart';
import '../features/sync/presentation/account_screen.dart';
import '../features/sync/presentation/profile_screen.dart';
import '../features/settings/presentation/app_settings_screen.dart';
import '../features/settings/presentation/onboarding_screen.dart';
import 'navigation/app_shell.dart';
import 'app_theme.dart';

const String homePath = '/home';
const String libraryPath = '/library';
const String capturePath = '/capture';
const String statsPath = '/stats';
const String spendingCalendarPath = '/spending-calendar';
const String profilePath = '/profile';
const String accountPath = '/account';
const String createCardPath = '/cards/new';
const String batchCardEntryPath = '/cards/batch';
const String createCardSetPath = '/sets/new';
const String createSeriesPath = '/series/new';
const String recycleBinPath = '/recycle-bin';
const String backupPath = '/backup';
const String imageEditorPath = '/image-editor';
const String organizationSettingsPath = '/organization-settings';
const String onboardingPath = '/onboarding';
const String appSettingsPath = '/app-settings';
const String csvExportPath = '/csv-export';

String libraryTabPath(String tab) => '$libraryPath?tab=$tab';

String spendingCalendarMonthPath(DateTime month) =>
    '$spendingCalendarPath?year=${month.year}&month=${month.month}';

@immutable
final class ImageEditorRouteArgs {
  const ImageEditorRouteArgs({
    required this.sourcePath,
    required this.outputId,
  });

  final String sourcePath;
  final String outputId;
}

/// 动态路由的路径模式。helper 与对应 GoRoute 引用同一常量，避免两处字符串漂移。
const String cardDetailRoutePattern = '/cards/:id';
const String editCardRoutePattern = '/cards/:id/edit';
const String copyCardRoutePattern = '/cards/:id/copy';
const String cardOrganizationRoutePattern = '/cards/:id/organization';
const String cardSetDetailRoutePattern = '/sets/:id';
const String editCardSetRoutePattern = '/sets/:id/edit';
const String seriesDetailRoutePattern = '/series/:id';
const String editSeriesRoutePattern = '/series/:id/edit';

String _concrete(String pattern, String id) => pattern.replaceFirst(':id', id);

String cardDetailPath(String id) => _concrete(cardDetailRoutePattern, id);
String editCardPath(String id) => _concrete(editCardRoutePattern, id);
String copyCardPath(String id) => _concrete(copyCardRoutePattern, id);
String cardOrganizationPath(String id) =>
    _concrete(cardOrganizationRoutePattern, id);
String cardSetDetailPath(String id) => _concrete(cardSetDetailRoutePattern, id);
String editCardSetPath(String id) => _concrete(editCardSetRoutePattern, id);
String seriesDetailPath(String id) => _concrete(seriesDetailRoutePattern, id);
String editSeriesPath(String id) => _concrete(editSeriesRoutePattern, id);

/// Cardfolio 的五入口路由骨架。
GoRouter createAppRouter({
  String initialLocation = homePath,
  bool onboardingCompleted = true,
}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    initialLocation: initialLocation,
    navigatorKey: rootNavigatorKey,
    errorBuilder: (context, state) =>
        const _RouteFallbackScreen(message: '页面不存在或暂时无法打开。'),
    redirect: (context, state) {
      final currentOnboardingCompleted =
          onboardingCompleted ||
          (ProviderScope.containerOf(
                context,
              ).read(localAppStateProvider).value?.onboardingCompleted ??
              false);
      if (!currentOnboardingCompleted) {
        return state.matchedLocation == onboardingPath ? null : onboardingPath;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: onboardingPath,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          _branch(homePath, const HomeScreen()),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: libraryPath,
                builder: (context, state) => CardLibraryScreen(
                  initialTabIndex: switch (state.uri.queryParameters['tab']) {
                    'sets' => 1,
                    'series' => 2,
                    _ => 0,
                  },
                ),
              ),
            ],
          ),
          _branch(capturePath, const CaptureEntryScreen()),
          _branch(statsPath, const StatisticsScreen()),
          _branch(profilePath, const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: createCardPath,
        builder: (context, state) => const CreateCardScreen(),
      ),
      GoRoute(
        path: batchCardEntryPath,
        builder: (context, state) => const BatchCardEntryScreen(),
      ),
      GoRoute(
        path: editCardRoutePattern,
        builder: (context, state) =>
            EditCardScreen(cardItemId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: copyCardRoutePattern,
        builder: (context, state) =>
            CreateCardScreen(copyFromCardItemId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: cardOrganizationRoutePattern,
        builder: (context, state) =>
            CardOrganizationScreen(cardItemId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: cardDetailRoutePattern,
        builder: (context, state) =>
            CardDetailScreen(cardItemId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: createCardSetPath,
        builder: (context, state) => const CardSetFormScreen(),
      ),
      GoRoute(
        path: editCardSetRoutePattern,
        builder: (context, state) =>
            CardSetFormScreen(setId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: cardSetDetailRoutePattern,
        builder: (context, state) =>
            CardSetDetailScreen(setId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: createSeriesPath,
        builder: (context, state) => const SeriesFormScreen(),
      ),
      GoRoute(
        path: editSeriesRoutePattern,
        builder: (context, state) =>
            SeriesFormScreen(seriesId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: seriesDetailRoutePattern,
        builder: (context, state) =>
            SeriesDetailScreen(seriesId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: accountPath,
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: recycleBinPath,
        builder: (context, state) => const RecycleBinScreen(),
      ),
      GoRoute(
        path: backupPath,
        builder: (context, state) => const BackupScreen(),
      ),
      GoRoute(
        path: organizationSettingsPath,
        builder: (context, state) => const OrganizationSettingsScreen(),
      ),
      GoRoute(
        path: appSettingsPath,
        builder: (context, state) => const AppSettingsScreen(),
      ),
      GoRoute(
        path: csvExportPath,
        builder: (context, state) => const CsvExportScreen(),
      ),
      GoRoute(
        path: spendingCalendarPath,
        builder: (context, state) {
          final now = DateTime.now();
          final year = int.tryParse(state.uri.queryParameters['year'] ?? '');
          final month = int.tryParse(state.uri.queryParameters['month'] ?? '');
          final initialMonth =
              year != null && month != null && month >= 1 && month <= 12
              ? DateTime(year, month)
              : DateTime(now.year, now.month);
          return SpendingCalendarScreen(initialMonth: initialMonth);
        },
      ),
      GoRoute(
        path: imageEditorPath,
        builder: (context, state) {
          // extra 只在进程内导航时存在；深链接或状态恢复下可能缺失。
          final args = state.extra;
          if (args is! ImageEditorRouteArgs) {
            return const _RouteFallbackScreen(message: '图片编辑器无法从外部直接打开。');
          }
          return Consumer(
            builder: (context, ref, child) => ImageEditorScreen(
              sourcePath: args.sourcePath,
              outputId: args.outputId,
              processor: ref.watch(imageProcessorProvider),
            ),
          );
        },
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

/// 路由异常时的兜底页，保证任何导航失败都有可操作的出口。
class _RouteFallbackScreen extends StatelessWidget {
  const _RouteFallbackScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(tokens.spaceLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.map_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline,
                ),
                SizedBox(height: tokens.spaceMd),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: tokens.spaceLg),
                FilledButton.icon(
                  onPressed: () => context.go(homePath),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('回到首页'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
