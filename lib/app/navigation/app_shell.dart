import 'package:flutter/material.dart';
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
    icon: Icons.camera_outlined,
    activeIcon: Icons.camera,
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
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: <Widget>[
          for (final destination in appDestinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.activeIcon),
              label: destination.label,
              tooltip: destination.label,
            ),
        ],
      ),
    );
  }
}
