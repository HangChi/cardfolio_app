import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/cards/presentation/widgets/phase_placeholder_screen.dart';
import 'navigation/app_shell.dart';

const String homePath = '/home';
const String libraryPath = '/library';
const String capturePath = '/capture';
const String statsPath = '/stats';
const String profilePath = '/profile';
const String createCardPath = '/cards/new';

String cardDetailPath(String id) => '/cards/$id';

/// Feature 001 的路由骨架。
///
/// 收藏、拍摄、新建与详情在 Task 6 替换为真实页面；首页、统计、我的保留导航位置
/// 但显式标注为“后续开放”。
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
          _branch(
            homePath,
            const PhasePlaceholderScreen(
              title: '首页',
              description: '收藏总览与最近录入将在首页统计能力开放后可用。',
            ),
          ),
          _branch(
            libraryPath,
            const PhasePlaceholderScreen(
              title: '我的收藏',
              description: '卡片列表将在本迭代实现。',
            ),
          ),
          _branch(
            capturePath,
            const PhasePlaceholderScreen(
              title: '快速建档',
              description: '录入方式选择将在本迭代实现。',
            ),
          ),
          _branch(
            statsPath,
            const PhasePlaceholderScreen(
              title: '统计',
              description: '数量、花费与套卡统计将在购买与统计能力开放后可用。',
            ),
          ),
          _branch(
            profilePath,
            const PhasePlaceholderScreen(
              title: '我的',
              description: '导入导出、回收站与账号同步将在后续迭代开放。',
            ),
          ),
        ],
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
