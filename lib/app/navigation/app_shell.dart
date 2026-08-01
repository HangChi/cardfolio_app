import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// 五个固定主入口，顺序与 Figma 底部导航一致：首页、收藏、拍摄、统计、我的。
const List<AppDestination> appDestinations = <AppDestination>[
  AppDestination(
    label: '首页',
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
  ),
  AppDestination(
    label: '收藏',
    icon: Icons.grid_view_outlined,
    activeIcon: Icons.grid_view,
  ),
  AppDestination(
    label: '拍摄',
    icon: Icons.photo_camera_outlined,
    activeIcon: Icons.photo_camera,
  ),
  AppDestination(
    label: '统计',
    icon: Icons.donut_small_outlined,
    activeIcon: Icons.donut_small,
  ),
  AppDestination(
    label: '我的',
    icon: Icons.person_outline,
    activeIcon: Icons.person,
  ),
];

@immutable
class AppDestination {
  const AppDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// 承载五入口分支的导航壳。每个分支保留自己的导航栈。
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) SystemNavigator.pop();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useRail = constraints.maxWidth >= 720;
          if (useRail) {
            return Scaffold(
              body: SafeArea(
                child: Row(
                  children: <Widget>[
                    NavigationRail(
                      selectedIndex: navigationShell.currentIndex,
                      labelType: NavigationRailLabelType.all,
                      groupAlignment: -0.72,
                      leading: const Padding(
                        padding: EdgeInsets.fromLTRB(12, 12, 12, 24),
                        child: _BrandMark(),
                      ),
                      onDestinationSelected: _goToBranch,
                      destinations: <NavigationRailDestination>[
                        for (final destination in appDestinations)
                          NavigationRailDestination(
                            icon: Icon(destination.icon),
                            selectedIcon: Icon(destination.activeIcon),
                            label: Text(destination.label),
                          ),
                      ],
                    ),
                    VerticalDivider(
                      width: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    Expanded(child: navigationShell),
                  ],
                ),
              ),
            );
          }
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: SafeArea(
              top: false,
              child: NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _goToBranch,
                destinations: <Widget>[
                  for (var index = 0; index < appDestinations.length; index++)
                    NavigationDestination(
                      icon: Icon(appDestinations[index].icon),
                      selectedIcon: Icon(appDestinations[index].activeIcon),
                      label: appDestinations[index].label,
                      tooltip: appDestinations[index].label,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _goToBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: '卡迹 Cardfolio',
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '卡',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: scheme.onPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
