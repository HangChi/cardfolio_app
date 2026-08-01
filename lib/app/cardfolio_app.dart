import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/preferences/local_app_state.dart';
import '../core/preferences/local_app_state_providers.dart';
import 'app_theme.dart';

/// 应用根组件。路由由外部注入，便于测试从任意入口启动。
class CardfolioApp extends ConsumerWidget {
  const CardfolioApp({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference =
        ref.watch(localAppStateProvider).value?.themePreference ??
        AppThemePreference.system;
    return MaterialApp.router(
      title: '卡迹',
      debugShowCheckedModeBanner: false,
      theme: buildCardfolioTheme(Brightness.light),
      darkTheme: buildCardfolioTheme(Brightness.dark),
      themeAnimationDuration: const Duration(milliseconds: 240),
      themeAnimationCurve: Curves.easeOutCubic,
      themeMode: switch (preference) {
        AppThemePreference.light => ThemeMode.light,
        AppThemePreference.dark => ThemeMode.dark,
        AppThemePreference.system => ThemeMode.system,
      },
      locale: const Locale('zh', 'CN'),
      supportedLocales: const <Locale>[Locale('zh', 'CN'), Locale('en')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
