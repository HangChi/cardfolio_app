import 'package:flutter/material.dart';

/// Cardfolio 的固定品牌色。
///
/// 页面应优先读取 [ColorScheme] 或 `context.palette`，这些常量只用于必须
/// 保持品牌色的第三方控件和兼容尚未迁移的旧组件。
abstract final class AppColors {
  static const Color primary = Color(0xFF1F574A);
  static const Color onPrimary = Color(0xFFFFFEFA);
  static const Color primaryContainer = Color(0xFFE8EDDE);
  static const Color background = Color(0xFFF6F2E8);
  static const Color surface = Color(0xFFFFFEFA);
  static const Color outline = Color(0xFFDBD4BF);
  static const Color textPrimary = Color(0xFF1A1F1C);
  static const Color textSecondary = Color(0xFF65695F);
  static const Color accent = Color(0xFFDE6E38);
  static const Color warning = Color(0xFF9B6A12);
  static const Color error = Color(0xFFB8382E);
}

/// Material 颜色之外的 Cardfolio 语义颜色。
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.outline,
    required this.accent,
    required this.warning,
    required this.success,
    required this.shadow,
  });

  static const AppPalette light = AppPalette(
    background: Color(0xFFF6F2E8),
    surface: Color(0xFFFFFEFA),
    surfaceElevated: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFECEEDF),
    textPrimary: Color(0xFF1A1F1C),
    textSecondary: Color(0xFF65695F),
    outline: Color(0xFFD7D0BC),
    accent: Color(0xFFCF5E2C),
    warning: Color(0xFF8A5A00),
    success: Color(0xFF2F6D50),
    shadow: Color(0x241D2C25),
  );

  static const AppPalette dark = AppPalette(
    background: Color(0xFF101612),
    surface: Color(0xFF18211C),
    surfaceElevated: Color(0xFF202B25),
    surfaceMuted: Color(0xFF263129),
    textPrimary: Color(0xFFF4F1E8),
    textSecondary: Color(0xFFB8BDB5),
    outline: Color(0xFF47534B),
    accent: Color(0xFFFF9A67),
    warning: Color(0xFFF0C76B),
    success: Color(0xFF8FD4AD),
    shadow: Color(0x66000000),
  );

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color outline;
  final Color accent;
  final Color warning;
  final Color success;
  final Color shadow;

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? outline,
    Color? accent,
    Color? warning,
    Color? success,
    Color? shadow,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      outline: outline ?? this.outline,
      accent: accent ?? this.accent,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

/// Cardfolio 的空间、形状、图标和动效令牌。
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.spaceXs,
    required this.spaceSm,
    required this.spaceMd,
    required this.spaceLg,
    required this.spaceXl,
    required this.space2xl,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusPill,
    required this.minTapTarget,
    required this.iconSm,
    required this.iconMd,
    required this.iconLg,
    required this.motionFast,
    required this.motionStandard,
    required this.contentMaxWidth,
  });

  static const AppTokens standard = AppTokens(
    spaceXs: 4,
    spaceSm: 8,
    spaceMd: 16,
    spaceLg: 24,
    spaceXl: 32,
    space2xl: 48,
    radiusSm: 8,
    radiusMd: 12,
    radiusLg: 18,
    radiusPill: 999,
    minTapTarget: 48,
    iconSm: 18,
    iconMd: 24,
    iconLg: 32,
    motionFast: Duration(milliseconds: 180),
    motionStandard: Duration(milliseconds: 240),
    contentMaxWidth: 1040,
  );

  final double spaceXs;
  final double spaceSm;
  final double spaceMd;
  final double spaceLg;
  final double spaceXl;
  final double space2xl;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusPill;
  final double minTapTarget;
  final double iconSm;
  final double iconMd;
  final double iconLg;
  final Duration motionFast;
  final Duration motionStandard;
  final double contentMaxWidth;

  @override
  AppTokens copyWith({
    double? spaceXs,
    double? spaceSm,
    double? spaceMd,
    double? spaceLg,
    double? spaceXl,
    double? space2xl,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusPill,
    double? minTapTarget,
    double? iconSm,
    double? iconMd,
    double? iconLg,
    Duration? motionFast,
    Duration? motionStandard,
    double? contentMaxWidth,
  }) {
    return AppTokens(
      spaceXs: spaceXs ?? this.spaceXs,
      spaceSm: spaceSm ?? this.spaceSm,
      spaceMd: spaceMd ?? this.spaceMd,
      spaceLg: spaceLg ?? this.spaceLg,
      spaceXl: spaceXl ?? this.spaceXl,
      space2xl: space2xl ?? this.space2xl,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusPill: radiusPill ?? this.radiusPill,
      minTapTarget: minTapTarget ?? this.minTapTarget,
      iconSm: iconSm ?? this.iconSm,
      iconMd: iconMd ?? this.iconMd,
      iconLg: iconLg ?? this.iconLg,
      motionFast: motionFast ?? this.motionFast,
      motionStandard: motionStandard ?? this.motionStandard,
      contentMaxWidth: contentMaxWidth ?? this.contentMaxWidth,
    );
  }

  @override
  AppTokens lerp(covariant AppTokens? other, double t) {
    if (other == null) return this;
    return AppTokens(
      spaceXs: _lerp(spaceXs, other.spaceXs, t),
      spaceSm: _lerp(spaceSm, other.spaceSm, t),
      spaceMd: _lerp(spaceMd, other.spaceMd, t),
      spaceLg: _lerp(spaceLg, other.spaceLg, t),
      spaceXl: _lerp(spaceXl, other.spaceXl, t),
      space2xl: _lerp(space2xl, other.space2xl, t),
      radiusSm: _lerp(radiusSm, other.radiusSm, t),
      radiusMd: _lerp(radiusMd, other.radiusMd, t),
      radiusLg: _lerp(radiusLg, other.radiusLg, t),
      radiusPill: _lerp(radiusPill, other.radiusPill, t),
      minTapTarget: _lerp(minTapTarget, other.minTapTarget, t),
      iconSm: _lerp(iconSm, other.iconSm, t),
      iconMd: _lerp(iconMd, other.iconMd, t),
      iconLg: _lerp(iconLg, other.iconLg, t),
      motionFast: _lerpDuration(motionFast, other.motionFast, t),
      motionStandard: _lerpDuration(motionStandard, other.motionStandard, t),
      contentMaxWidth: _lerp(contentMaxWidth, other.contentMaxWidth, t),
    );
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  static Duration _lerpDuration(Duration a, Duration b, double t) => Duration(
    microseconds: _lerp(
      a.inMicroseconds.toDouble(),
      b.inMicroseconds.toDouble(),
      t,
    ).round(),
  );
}

extension AppTokensAccess on BuildContext {
  AppTokens get tokens =>
      Theme.of(this).extension<AppTokens>() ?? AppTokens.standard;
}

extension AppPaletteAccess on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? AppPalette.dark
          : AppPalette.light);
}

/// 构建 Cardfolio 主题；默认保持亮色以兼容现有调用。
ThemeData buildCardfolioTheme([Brightness brightness = Brightness.light]) {
  const tokens = AppTokens.standard;
  final palette = brightness == Brightness.dark
      ? AppPalette.dark
      : AppPalette.light;
  final colorScheme = brightness == Brightness.dark
      ? const ColorScheme.dark(
          primary: Color(0xFF93D7B1),
          onPrimary: Color(0xFF073826),
          primaryContainer: Color(0xFF214B37),
          onPrimaryContainer: Color(0xFFCCF5DD),
          secondary: Color(0xFFFF9A67),
          onSecondary: Color(0xFF4B1700),
          tertiary: Color(0xFFF0C76B),
          onTertiary: Color(0xFF3E2E00),
          surface: Color(0xFF18211C),
          onSurface: Color(0xFFF4F1E8),
          onSurfaceVariant: Color(0xFFB8BDB5),
          outline: Color(0xFF748078),
          outlineVariant: Color(0xFF47534B),
          error: Color(0xFFFFB4AB),
          onError: Color(0xFF690005),
          errorContainer: Color(0xFF93000A),
          onErrorContainer: Color(0xFFFFDAD6),
        )
      : const ColorScheme.light(
          primary: Color(0xFF1F574A),
          onPrimary: Color(0xFFFFFEFA),
          primaryContainer: Color(0xFFE1EBDD),
          onPrimaryContainer: Color(0xFF173D33),
          secondary: Color(0xFFB84E20),
          onSecondary: Color(0xFFFFFFFF),
          secondaryContainer: Color(0xFFFFDBCB),
          onSecondaryContainer: Color(0xFF4A1704),
          tertiary: Color(0xFF7B5D10),
          onTertiary: Color(0xFFFFFFFF),
          surface: Color(0xFFFFFEFA),
          onSurface: Color(0xFF1A1F1C),
          onSurfaceVariant: Color(0xFF565C55),
          outline: Color(0xFF777D75),
          outlineVariant: Color(0xFFD7D0BC),
          error: Color(0xFFB3261E),
          onError: Color(0xFFFFFFFF),
          errorContainer: Color(0xFFF9DEDC),
          onErrorContainer: Color(0xFF410E0B),
        );

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: palette.background,
    fontFamilyFallback: const <String>[
      'Noto Sans SC',
      'Microsoft YaHei',
      'PingFang SC',
    ],
    visualDensity: VisualDensity.standard,
  );
  final textTheme = base.textTheme.apply(
    bodyColor: palette.textPrimary,
    displayColor: palette.textPrimary,
  );

  final roundedMedium = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(tokens.radiusMd),
  );
  final roundedLarge = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(tokens.radiusLg),
  );

  return base.copyWith(
    extensions: <ThemeExtension<dynamic>>[tokens, palette],
    textTheme: textTheme.copyWith(
      displaySmall: textTheme.displaySmall?.copyWith(
        fontSize: 36,
        height: 1.15,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.7,
      ),
      headlineMedium: textTheme.headlineMedium?.copyWith(
        fontSize: 28,
        height: 1.2,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.35,
      ),
      headlineSmall: textTheme.headlineSmall?.copyWith(
        fontSize: 23,
        height: 1.25,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        fontSize: 19,
        height: 1.35,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: textTheme.titleSmall?.copyWith(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.6),
      bodyMedium: textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.55),
      bodySmall: textTheme.bodySmall?.copyWith(
        fontSize: 12,
        height: 1.5,
        color: palette.textSecondary,
      ),
      labelLarge: textTheme.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: palette.background,
      foregroundColor: palette.textPrimary,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: palette.textPrimary,
        fontWeight: FontWeight.w800,
      ),
    ),
    cardTheme: CardThemeData(
      color: palette.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: palette.shadow,
      elevation: brightness == Brightness.dark ? 0 : 1,
      margin: EdgeInsets.zero,
      shape: roundedLarge.copyWith(
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: palette.surfaceElevated,
      surfaceTintColor: Colors.transparent,
      indicatorColor: colorScheme.primaryContainer,
      elevation: 0,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return textTheme.labelSmall?.copyWith(
          color: states.contains(WidgetState.selected)
              ? colorScheme.primary
              : palette.textSecondary,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
        );
      }),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: palette.surfaceElevated,
      indicatorColor: colorScheme.primaryContainer,
      selectedIconTheme: IconThemeData(color: colorScheme.primary),
      unselectedIconTheme: IconThemeData(color: palette.textSecondary),
      selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
        color: palette.textSecondary,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: roundedMedium,
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        side: BorderSide(color: colorScheme.outline),
        shape: roundedMedium,
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: roundedMedium,
        textStyle: textTheme.labelLarge,
      ),
    ),
    iconButtonTheme: const IconButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll<Size>(Size.square(48)),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 2,
      focusElevation: 3,
      hoverElevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusLg),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: palette.surface,
      selectedColor: colorScheme.primaryContainer,
      disabledColor: palette.surfaceMuted.withValues(alpha: 0.6),
      side: BorderSide(color: colorScheme.outlineVariant),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusPill),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      labelStyle: textTheme.labelMedium,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: palette.textSecondary,
      textColor: palette.textPrimary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      minVerticalPadding: 12,
      shape: roundedMedium,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      labelStyle: TextStyle(color: palette.textSecondary),
      hintStyle: TextStyle(color: palette.textSecondary),
      helperStyle: TextStyle(color: palette.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.surfaceElevated,
      surfaceTintColor: Colors.transparent,
      shape: roundedLarge,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: palette.surfaceElevated,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(tokens.radiusLg),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: brightness == Brightness.dark
          ? const Color(0xFF2C3831)
          : const Color(0xFF26342D),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: const Color(0xFFFDFBF4),
      ),
      shape: roundedMedium,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colorScheme.primary,
      linearTrackColor: palette.surfaceMuted,
      circularTrackColor: palette.surfaceMuted,
    ),
  );
}
