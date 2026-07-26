import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_theme.dart';

/// 应用根组件。路由由外部注入，便于测试从任意入口启动。
class CardfolioApp extends StatelessWidget {
  const CardfolioApp({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '卡迹',
      debugShowCheckedModeBanner: false,
      theme: buildCardfolioTheme(),
      routerConfig: router,
    );
  }
}
