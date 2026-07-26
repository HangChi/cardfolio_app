import 'package:flutter/material.dart';

/// Cardfolio 语义颜色令牌。
///
/// 取值来源：`docs/design/figma/卡迹 Cardfolio · 核心流程高保真原型.svg` 导出件中的
/// 实际填充色。字号层级尚未从 Figma Dev Mode 取得，当前排版沿用 Material 3
/// 默认层级，待设计交付字号表后再校准（见 `docs/design/figma-handoff.md` §4）。
abstract final class AppColors {
  /// 品牌深绿：主按钮、选中态、进度条。
  static const Color primary = Color(0xFF1F574A);

  /// 主色之上的文字与图标。
  static const Color onPrimary = Color(0xFFFFFEFA);

  /// 浅绿容器：提示块、标签底、次级强调区域。
  static const Color primaryContainer = Color(0xFFE8EDDE);

  /// 米色页面底。
  static const Color background = Color(0xFFF6F2E8);

  /// 卡片与输入面。
  static const Color surface = Color(0xFFFFFEFA);

  /// 分隔线与描边。
  static const Color outline = Color(0xFFDBD4BF);

  /// 正文与标题。
  static const Color textPrimary = Color(0xFF1A1F1C);

  /// 辅助说明与占位。
  static const Color textSecondary = Color(0xFF6B6E63);

  /// 橙色强调：封面色带、次要状态。
  static const Color accent = Color(0xFFDE6E38);

  /// 金色提示：待补全、进行中。
  static const Color warning = Color(0xFFC79C40);

  /// 错误与危险操作。
  static const Color error = Color(0xFFB8382E);
}

/// 间距与圆角令牌。页面禁止直接书写数值，一律通过 `context.tokens` 取用。
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.spaceXs,
    required this.spaceSm,
    required this.spaceMd,
    required this.spaceLg,
    required this.spaceXl,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusPill,
    required this.minTapTarget,
  });

  /// 圆角取自原型 SVG 的 `rx` 分布：6 / 11 / 16 / 28。
  static const AppTokens standard = AppTokens(
    spaceXs: 4,
    spaceSm: 8,
    spaceMd: 16,
    spaceLg: 24,
    spaceXl: 32,
    radiusSm: 6,
    radiusMd: 11,
    radiusLg: 16,
    radiusPill: 28,
    minTapTarget: 48,
  );

  final double spaceXs;
  final double spaceSm;
  final double spaceMd;
  final double spaceLg;
  final double spaceXl;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusPill;
  final double minTapTarget;

  @override
  AppTokens copyWith({
    double? spaceXs,
    double? spaceSm,
    double? spaceMd,
    double? spaceLg,
    double? spaceXl,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusPill,
    double? minTapTarget,
  }) {
    return AppTokens(
      spaceXs: spaceXs ?? this.spaceXs,
      spaceSm: spaceSm ?? this.spaceSm,
      spaceMd: spaceMd ?? this.spaceMd,
      spaceLg: spaceLg ?? this.spaceLg,
      spaceXl: spaceXl ?? this.spaceXl,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusPill: radiusPill ?? this.radiusPill,
      minTapTarget: minTapTarget ?? this.minTapTarget,
    );
  }

  @override
  AppTokens lerp(covariant AppTokens? other, double t) {
    if (other == null) return this;
    return AppTokens(
      spaceXs: lerpDouble(spaceXs, other.spaceXs, t),
      spaceSm: lerpDouble(spaceSm, other.spaceSm, t),
      spaceMd: lerpDouble(spaceMd, other.spaceMd, t),
      spaceLg: lerpDouble(spaceLg, other.spaceLg, t),
      spaceXl: lerpDouble(spaceXl, other.spaceXl, t),
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t),
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t),
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t),
      radiusPill: lerpDouble(radiusPill, other.radiusPill, t),
      minTapTarget: lerpDouble(minTapTarget, other.minTapTarget, t),
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

extension AppTokensAccess on BuildContext {
  AppTokens get tokens =>
      Theme.of(this).extension<AppTokens>() ?? AppTokens.standard;
}

/// 构建 Cardfolio 亮色主题。暗色模式在 M0 不交付，但令牌保持语义命名。
ThemeData buildCardfolioTheme() {
  const tokens = AppTokens.standard;
  const colorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.textPrimary,
    secondary: AppColors.accent,
    onSecondary: AppColors.onPrimary,
    tertiary: AppColors.warning,
    onTertiary: AppColors.textPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.outline,
    outlineVariant: AppColors.outline,
    error: AppColors.error,
    onError: AppColors.onPrimary,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamilyFallback: const <String>['Noto Sans SC', 'Microsoft YaHei'],
  );

  return base.copyWith(
    extensions: const <ThemeExtension<dynamic>>[tokens],
    textTheme: base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      bodySmall: base.textTheme.bodySmall?.copyWith(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primaryContainer,
      elevation: 0,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.outline,
      thickness: 1,
      space: 1,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: Size.fromHeight(tokens.minTapTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
  );
}
