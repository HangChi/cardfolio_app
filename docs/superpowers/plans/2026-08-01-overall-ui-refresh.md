# Cardfolio Overall UI Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Do not use subagents for this project. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver a coherent, accessible light/dark Cardfolio interface with shared visual components, adaptive navigation, and polished primary workflows while preserving all existing business behavior.

**Architecture:** Extend the existing Material 3 theme with semantic theme extensions and a persisted three-state theme preference. Put reusable presentation-only primitives in `lib/core/widgets/`, keep Riverpod and repository boundaries unchanged, and refactor primary screens to compose those primitives. Use `LayoutBuilder` in the application shell for phone versus wide navigation without changing routes.

**Tech Stack:** Flutter 3 / Dart 3.12, Material 3, Riverpod 3, go_router 17, flutter_test.

## Global Constraints

- Preserve the existing warm beige, deep green, and restrained orange brand identity.
- Deliver separate accessible light and dark palettes; dark mode must not be a mechanical inversion.
- All interactive targets must be at least 48×48 logical pixels.
- Use the 4/8 spacing rhythm and semantic theme tokens; do not add page-local business colors.
- Keep motion between 180–260ms and remove nonessential movement when accessibility navigation is enabled.
- Keep the existing database, repositories, synchronization protocol, routes, and business rules unchanged.
- Keep simplified Chinese UI copy and the existing system-font fallback; do not add network fonts.
- Do not use subagents.

## File Structure

- `lib/app/app_theme.dart`: light/dark color schemes, semantic palette, spacing, radius, elevation, icon, motion, and content-width tokens.
- `lib/app/cardfolio_app.dart`: reads persisted theme preference and maps it to Flutter `ThemeMode`.
- `lib/app/navigation/app_shell.dart`: adaptive `NavigationBar`/`NavigationRail` shell.
- `lib/core/preferences/local_app_state.dart`: serialized `AppThemePreference` state.
- `lib/core/preferences/local_app_state_providers.dart`: theme-preference mutation.
- `lib/core/widgets/app_layout.dart`: page width, header, section, and responsive content primitives.
- `lib/core/widgets/app_surface.dart`: cards, metric cards, action tiles, status badges, empty/error states.
- `lib/features/settings/presentation/app_settings_screen.dart`: system/light/dark theme selector and polished settings groups.
- `lib/features/dashboard/presentation/home_screen.dart`: overview hierarchy and shared cards.
- `lib/features/cards/presentation/capture/capture_entry_screen.dart`: focused capture hierarchy.
- `lib/features/cards/presentation/library/card_library_screen.dart`: toolbar, filters, list cards, and states.
- `lib/features/dashboard/presentation/statistics_screen.dart`: metric hierarchy and accessible data presentation.
- `lib/features/sync/presentation/profile_screen.dart`: grouped profile/settings navigation.
- High-frequency card and set presentation files: semantic theme migration and shared section/surface adoption without data-flow changes.
- Matching tests under `test/app/`, `test/core/`, and existing `test/features/**/presentation/` paths.

---

### Task 1: Persisted Theme Preference and Dual Theme Foundation

**Files:**
- Modify: `lib/core/preferences/local_app_state.dart`
- Modify: `lib/core/preferences/local_app_state_providers.dart`
- Modify: `lib/app/cardfolio_app.dart`
- Modify: `lib/app/app_theme.dart`
- Modify: `test/core/preferences/local_app_state_test.dart`
- Modify: `test/app/cardfolio_app_test.dart`
- Create: `test/app/app_theme_test.dart`

**Interfaces:**
- Produces: `enum AppThemePreference { system, light, dark }`.
- Produces: `LocalAppState.themePreference` and `LocalAppStateController.setThemePreference(AppThemePreference)`.
- Produces: `ThemeData buildCardfolioTheme(Brightness brightness)`.
- Produces: `AppPalette`, `AppTokens`, `AppPaletteAccess.palette`, and `AppTokensAccess.tokens` used by all later tasks.

- [ ] **Step 1: Write failing persistence and application-theme tests**

Add serialization coverage:

```dart
test('theme preference round-trips and defaults to system', () {
  expect(LocalAppState.fromJson(const {}).themePreference,
      AppThemePreference.system);
  final state = LocalAppState.fromJson(
    const {'themePreference': 'dark'},
  );
  expect(state.themePreference, AppThemePreference.dark);
  expect(state.toJson()['themePreference'], 'dark');
});
```

Add widget coverage that pumps `CardfolioApp` with a `MemoryLocalAppStateStore` set to dark and asserts `Theme.of(context).brightness == Brightness.dark`. Add theme assertions that both palettes expose distinct background/surface colors and that button/input minimum heights are 48.

- [ ] **Step 2: Run targeted tests and confirm failure**

Run:

```powershell
flutter test test/core/preferences/local_app_state_test.dart test/app/cardfolio_app_test.dart test/app/app_theme_test.dart
```

Expected: failures because `AppThemePreference`, dark theme construction, and theme selection are not defined.

- [ ] **Step 3: Implement the persisted theme state**

Add the enum and state field with tolerant decoding:

```dart
enum AppThemePreference { system, light, dark }

AppThemePreference _themePreferenceFromJson(Object? value) =>
    AppThemePreference.values.where((item) => item.name == value).firstOrNull ??
    AppThemePreference.system;
```

Include the field in `copyWith`, `toJson`, `fromJson`, equality, and hash code. Add:

```dart
Future<void> setThemePreference(AppThemePreference preference) =>
    _update((value) => value.copyWith(themePreference: preference));
```

- [ ] **Step 4: Implement semantic light and dark themes**

Replace the light-only builder with `buildCardfolioTheme(Brightness brightness)`. Keep existing light brand values and define a dark palette based on ink green surfaces rather than pure black. Expand `AppTokens` with `space2xl`, elevation/shadow definitions, icon sizes, `motionFast`, `motionStandard`, and `contentMaxWidth`. Configure consistent `TextTheme`, `AppBarTheme`, `CardTheme`, buttons, icon buttons, chips, navigation, inputs, dialogs, sheets, dividers, snack bars, and focus states.

Make `CardfolioApp` a `ConsumerWidget`, read `localAppStateProvider`, map the preference to `ThemeMode`, and provide both `theme` and `darkTheme`:

```dart
theme: buildCardfolioTheme(Brightness.light),
darkTheme: buildCardfolioTheme(Brightness.dark),
themeMode: switch (preference) {
  AppThemePreference.light => ThemeMode.light,
  AppThemePreference.dark => ThemeMode.dark,
  AppThemePreference.system => ThemeMode.system,
},
```

- [ ] **Step 5: Run targeted tests and analyze touched files**

Run the Step 2 command, then:

```powershell
flutter analyze lib/app lib/core/preferences test/app test/core/preferences
```

Expected: all tests pass and analyzer reports no issues.

- [ ] **Step 6: Commit the theme foundation**

```powershell
git add -- lib/app/app_theme.dart lib/app/cardfolio_app.dart lib/core/preferences/local_app_state.dart lib/core/preferences/local_app_state_providers.dart test/app/app_theme_test.dart test/app/cardfolio_app_test.dart test/core/preferences/local_app_state_test.dart
git commit -m "Add adaptive Cardfolio themes"
```

### Task 2: Shared Layout, Surface, and State Components

**Files:**
- Create: `lib/core/widgets/app_layout.dart`
- Create: `lib/core/widgets/app_surface.dart`
- Create: `test/core/widgets/app_layout_test.dart`
- Create: `test/core/widgets/app_surface_test.dart`

**Interfaces:**
- Consumes: `AppTokens`, `AppPalette`, and `context.tokens` from Task 1.
- Produces: `AppContentView`, `AppPageHeader`, `AppSectionHeader`, `AppSurfaceCard`, `AppMetricCard`, `AppActionTile`, `AppStatusBadge`, `AppEmptyState`, and `AppErrorState`.

- [ ] **Step 1: Write failing component tests**

Cover the following exact behaviors with concrete widget tests:

```dart
testWidgets('AppContentView caps wide content and keeps phone gutters',
    (tester) async {
  await tester.binding.setSurfaceSize(const Size(1200, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(MaterialApp(
    theme: buildCardfolioTheme(Brightness.light),
    home: const Scaffold(
      body: AppContentView(
        child: SizedBox(key: Key('content'), width: double.infinity),
      ),
    ),
  ));
  expect(
    tester.getSize(find.byKey(const Key('content'))).width,
    lessThanOrEqualTo(AppTokens.standard.contentMaxWidth),
  );
});

testWidgets('AppActionTile exposes a 48 pixel target and semantic label',
    (tester) async {
  var tapped = false;
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: AppActionTile(
        icon: Icons.settings_outlined,
        title: '应用设置',
        subtitle: '管理外观与权限',
        onTap: () => tapped = true,
      ),
    ),
  ));
  expect(tester.getSize(find.byType(AppActionTile)).height, greaterThanOrEqualTo(48));
  expect(find.text('应用设置'), findsOneWidget);
  await tester.tap(find.byType(AppActionTile));
  expect(tapped, isTrue);
});

testWidgets('AppErrorState renders recovery copy and invokes retry',
    (tester) async {
  var retried = false;
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: AppErrorState(
        icon: Icons.error_outline,
        title: '收藏暂时无法加载',
        description: '请检查本地存储后重试。',
        actionLabel: '重试',
        onAction: () => retried = true,
      ),
    ),
  ));
  expect(find.text('请检查本地存储后重试。'), findsOneWidget);
  await tester.tap(find.text('重试'));
  expect(retried, isTrue);
});
```

Also cover long titles, 2.0 text scaling, dark theme rendering, and status badges that include visible text.

- [ ] **Step 2: Run tests and confirm missing-component failures**

```powershell
flutter test test/core/widgets/app_layout_test.dart test/core/widgets/app_surface_test.dart
```

Expected: compilation fails because the shared widgets do not exist.

- [ ] **Step 3: Implement layout primitives**

`AppContentView` wraps content in `SafeArea`, centers it, caps it at `context.tokens.contentMaxWidth`, and applies adaptive horizontal gutters. `AppPageHeader` permits wrapping title/subtitle/actions. `AppSectionHeader` keeps section actions reachable without assuming a fixed row width.

- [ ] **Step 4: Implement surface and state primitives**

Use `Material` and `InkWell` for interactive cards, theme-derived borders and surface colors, 48-pixel minimum targets, and stable pressed feedback. `AppEmptyState` and `AppErrorState` must accept an icon, title, description, action label, and callback; error state uses error color plus visible explanatory text.

- [ ] **Step 5: Run component tests and analyzer**

```powershell
flutter test test/core/widgets/app_layout_test.dart test/core/widgets/app_surface_test.dart
flutter analyze lib/core/widgets test/core/widgets
```

Expected: tests pass at phone/wide widths and 2.0 text scale; analyzer is clean.

- [ ] **Step 6: Commit shared UI primitives**

```powershell
git add -- lib/core/widgets/app_layout.dart lib/core/widgets/app_surface.dart test/core/widgets/app_layout_test.dart test/core/widgets/app_surface_test.dart
git commit -m "Add shared Cardfolio UI primitives"
```

### Task 3: Adaptive Application Navigation

**Files:**
- Modify: `lib/app/navigation/app_shell.dart`
- Modify: `test/app/cardfolio_app_test.dart`
- Create: `test/app/app_shell_test.dart`

**Interfaces:**
- Consumes: Task 1 theme tokens and the existing `appDestinations` list.
- Produces: phone `NavigationBar` below 720 logical pixels and wide `NavigationRail` at or above 720 logical pixels.

- [ ] **Step 1: Write failing adaptive-shell tests**

Pump the shell at widths 393 and 1024. Assert that the phone layout contains one `NavigationBar` and no `NavigationRail`, while the wide layout contains one `NavigationRail` and no `NavigationBar`. Tap “统计” in each layout and verify `navigationShell.goBranch(3)` behavior through the existing router test harness.

- [ ] **Step 2: Run shell tests and confirm the wide-layout failure**

```powershell
flutter test test/app/app_shell_test.dart test/app/cardfolio_app_test.dart
```

Expected: the wide test fails because only `NavigationBar` exists.

- [ ] **Step 3: Implement the adaptive shell**

Use a `LayoutBuilder` threshold of 720. On wide layouts render a `Row` with a themed `NavigationRail`, vertical divider, and `Expanded(child: navigationShell)`. On phones retain `NavigationBar`. Preserve branch stacks and the current-branch reset behavior. Use `SafeArea`, tooltips, selected semantics, and at least 48-pixel destinations.

- [ ] **Step 4: Run shell and application tests**

```powershell
flutter test test/app/app_shell_test.dart test/app/cardfolio_app_test.dart
flutter analyze lib/app test/app
```

Expected: both layouts pass with the same route behavior.

- [ ] **Step 5: Commit adaptive navigation**

```powershell
git add -- lib/app/navigation/app_shell.dart test/app/app_shell_test.dart test/app/cardfolio_app_test.dart
git commit -m "Add adaptive app navigation"
```

### Task 4: Theme Controls and Profile Information Architecture

**Files:**
- Modify: `lib/features/settings/presentation/app_settings_screen.dart`
- Modify: `lib/features/sync/presentation/profile_screen.dart`
- Modify: `lib/features/sync/presentation/account_sync_panel.dart`
- Create: `test/features/settings/presentation/app_settings_screen_test.dart`
- Modify: `test/features/sync/presentation/profile_screen_test.dart`

**Interfaces:**
- Consumes: `AppThemePreference`, `LocalAppStateController.setThemePreference`, `AppContentView`, `AppSectionHeader`, and `AppActionTile`.
- Produces: an accessible system/light/dark selector and grouped profile navigation.

- [ ] **Step 1: Write failing settings and profile tests**

Assert that “跟随系统 / 浅色 / 深色” are visible, selecting “深色” updates the in-memory state, and the selector exposes selected semantics. Assert profile group headings “账号与同步 / 收藏整理 / 数据管理 / 应用” and existing route labels remain present.

- [ ] **Step 2: Run targeted tests and confirm failures**

```powershell
flutter test test/features/settings/presentation/app_settings_screen_test.dart test/features/sync/presentation/profile_screen_test.dart
```

Expected: theme controls and grouped headings are missing.

- [ ] **Step 3: Refactor settings and profile UI**

Add a theme section using `SegmentedButton<AppThemePreference>` and the controller method from Task 1. Convert raw `ListTile` sequences to `AppActionTile` inside labeled sections. Keep permission, storage, diagnostics, onboarding, account, backup, CSV, recycle-bin, and organization callbacks unchanged. Use current theme colors instead of `AppColors` physical constants.

- [ ] **Step 4: Run tests and analyzer**

```powershell
flutter test test/features/settings/presentation/app_settings_screen_test.dart test/features/sync/presentation/profile_screen_test.dart
flutter analyze lib/features/settings/presentation lib/features/sync/presentation test/features/settings test/features/sync/presentation
```

Expected: all existing navigation actions and new theme controls pass.

- [ ] **Step 5: Commit settings and profile polish**

```powershell
git add -- lib/features/settings/presentation/app_settings_screen.dart lib/features/sync/presentation/profile_screen.dart lib/features/sync/presentation/account_sync_panel.dart test/features/settings/presentation/app_settings_screen_test.dart test/features/sync/presentation/profile_screen_test.dart
git commit -m "Polish profile and theme settings"
```

### Task 5: Home and Capture Primary Journeys

**Files:**
- Modify: `lib/features/dashboard/presentation/home_screen.dart`
- Modify: `lib/features/cards/presentation/capture/capture_entry_screen.dart`
- Modify: `test/features/dashboard/presentation/home_screen_test.dart`
- Modify: `test/features/cards/presentation/card_flow_test.dart`

**Interfaces:**
- Consumes: shared components from Task 2 and existing dashboard/capture providers and callbacks.
- Produces: branded overview cards and a single-primary-action capture hierarchy.

- [ ] **Step 1: Add failing hierarchy and state tests**

Assert the home page exposes one primary overview region, “最近录入”, “即将集齐”, and “待补资料”; assert loading/error/empty content retains a recovery action. Assert capture presents camera as the primary filled action while continuous capture, set capture, gallery import, and blank creation remain reachable with their existing enablement and labels.

- [ ] **Step 2: Run the targeted tests and confirm hierarchy failures**

```powershell
flutter test test/features/dashboard/presentation/home_screen_test.dart test/features/cards/presentation/card_flow_test.dart
```

Expected: shared section/card expectations fail before refactoring.

- [ ] **Step 3: Refactor home with shared overview components**

Use `AppContentView`, `AppPageHeader`, `AppMetricCard`, `AppSectionHeader`, and `AppSurfaceCard`. Preserve repository reads, route callbacks, refresh behavior, and list keys used by current tests. Make numbers tabular and ensure recent-card rows wrap at 2.0 text scale.

- [ ] **Step 4: Refactor capture around one primary action**

Keep all existing capture/import flows and cancellation semantics. Use one visually dominant camera action, group alternate methods below it, show short helper copy, and use theme surfaces/icons without emoji. Keep every target at 48 pixels.

- [ ] **Step 5: Run tests and analyzer**

```powershell
flutter test test/features/dashboard/presentation/home_screen_test.dart test/features/cards/presentation/card_flow_test.dart
flutter analyze lib/features/dashboard/presentation/home_screen.dart lib/features/cards/presentation/capture/capture_entry_screen.dart
```

Expected: all business-flow tests still pass with the new hierarchy.

- [ ] **Step 6: Commit primary journey polish**

```powershell
git add -- lib/features/dashboard/presentation/home_screen.dart lib/features/cards/presentation/capture/capture_entry_screen.dart test/features/dashboard/presentation/home_screen_test.dart test/features/cards/presentation/card_flow_test.dart
git commit -m "Polish home and capture journeys"
```

### Task 6: Collection and Statistics Content Surfaces

**Files:**
- Modify: `lib/features/cards/presentation/library/card_library_screen.dart`
- Modify: `lib/features/dashboard/presentation/statistics_screen.dart`
- Modify: `lib/features/cards/presentation/widgets/card_image.dart`
- Modify: `test/features/organization/presentation/card_library_filter_test.dart`
- Modify: `test/features/dashboard/presentation/statistics_screen_test.dart`

**Interfaces:**
- Consumes: shared surfaces/states, semantic colors, and existing query/dashboard models.
- Produces: consistent collection toolbar/cards, theme-aware image placeholder, metric sections, and text-accessible data summaries.

- [ ] **Step 1: Add failing visual-behavior tests**

Assert collection search/filter/sort controls remain keyboard/touch reachable, active filters include visible text, empty/filter-empty/error states use the shared state components, and card metadata survives 2.0 text scale without overflow. Assert statistics keeps quantity, cost, city, type, tag, issuer, and set-progress sections in both themes and includes text values alongside visual bars.

- [ ] **Step 2: Run targeted tests and confirm failures**

```powershell
flutter test test/features/organization/presentation/card_library_filter_test.dart test/features/dashboard/presentation/statistics_screen_test.dart
```

Expected: new shared-state and theme assertions fail.

- [ ] **Step 3: Refactor collection surfaces**

Keep `CardLibraryQuery`, filter sheet, sort options, saved filters, routes, and keys unchanged. Replace physical colors and ad hoc cards with theme-derived shared surfaces. Improve toolbar wrapping, active-filter chip spacing, image ratio, metadata hierarchy, and missing-image treatment. Ensure the filter sheet respects keyboard and bottom safe-area insets.

- [ ] **Step 4: Refactor statistics surfaces**

Use metric cards and semantic section headers. Keep exact data calculations and navigation callbacks. Pair each bar or color mark with a visible label and value, use tabular numbers, and simplify layouts at narrow widths through wrapping instead of horizontal scrolling.

- [ ] **Step 5: Run tests and analyzer**

```powershell
flutter test test/features/organization/presentation/card_library_filter_test.dart test/features/dashboard/presentation/statistics_screen_test.dart
flutter analyze lib/features/cards/presentation/library lib/features/cards/presentation/widgets/card_image.dart lib/features/dashboard/presentation/statistics_screen.dart
```

Expected: query/data behavior is unchanged and UI tests pass in both themes.

- [ ] **Step 6: Commit collection and statistics polish**

```powershell
git add -- lib/features/cards/presentation/library/card_library_screen.dart lib/features/cards/presentation/widgets/card_image.dart lib/features/dashboard/presentation/statistics_screen.dart test/features/organization/presentation/card_library_filter_test.dart test/features/dashboard/presentation/statistics_screen_test.dart
git commit -m "Refine collection and statistics UI"
```

### Task 7: High-Frequency Detail and Form Consistency

**Files:**
- Modify: `lib/features/cards/presentation/create/create_card_screen.dart`
- Modify: `lib/features/cards/presentation/edit/edit_card_screen.dart`
- Modify: `lib/features/cards/presentation/detail/card_detail_screen.dart`
- Modify: `lib/features/cards/presentation/batch/batch_card_entry_screen.dart`
- Modify: `lib/features/cards/presentation/widgets/card_entry_metadata_fields.dart`
- Modify: `lib/features/cards/presentation/widgets/reserved_card_metadata_fields.dart`
- Modify: `lib/features/card_sets/presentation/detail/card_set_detail_screen.dart`
- Modify: `lib/features/card_sets/presentation/form/card_set_form_screen.dart`
- Modify: `lib/features/card_sets/presentation/widgets/card_set_progress_panel.dart`
- Modify: matching existing presentation tests under `test/features/cards/presentation/` and `test/features/card_sets/presentation/`

**Interfaces:**
- Consumes: semantic theme and shared section/surface components.
- Produces: consistent details, metadata sections, forms, save bars, progress panels, and destructive-action styling.

- [ ] **Step 1: Extend existing tests for theme and large-text behavior**

For create/edit/detail/batch/set screens, pump once in dark theme and once with `textScaler: const TextScaler.linear(2)`. Assert primary save actions, field labels, error copy, image controls, progress labels, and destructive actions remain visible and tappable. Preserve all existing test keys and business assertions.

- [ ] **Step 2: Run the focused presentation test groups and confirm failures or overflow**

```powershell
flutter test test/features/cards/presentation test/features/card_sets/presentation
```

Expected: new dark-theme/shared-layout or large-text expectations expose existing hardcoded colors and rigid rows.

- [ ] **Step 3: Migrate card workflows to semantic surfaces**

Replace `AppColors` and `Colors.*` presentation values with `Theme.of(context).colorScheme` or `context.palette`. Group image, basic metadata, organization, acquisition, and notes sections consistently. Keep controller methods, validation, dirty-state confirmation, double-submit protection, and navigation unchanged. Ensure fixed save bars account for `MediaQuery.viewInsetsOf(context).bottom` and safe-area padding.

- [ ] **Step 4: Migrate set workflows and progress panels**

Use the same section/surface hierarchy for set form/detail screens. Keep member queries, completion calculations, editing, deletion, and navigation unchanged. Provide text percentages and counts in addition to progress color.

- [ ] **Step 5: Run focused tests and analyzer**

```powershell
flutter test test/features/cards/presentation test/features/card_sets/presentation
flutter analyze lib/features/cards/presentation lib/features/card_sets/presentation
```

Expected: all existing behavior plus theme/large-text checks pass without overflow.

- [ ] **Step 6: Commit detail and form polish**

```powershell
git add -- lib/features/cards/presentation lib/features/card_sets/presentation test/features/cards/presentation test/features/card_sets/presentation
git commit -m "Unify card and set workflows"
```

### Task 8: Secondary Screens, Theme Audit, and Final Verification

**Files:**
- Modify: presentation files under `lib/features/organization/`, `lib/features/purchases/`, `lib/features/backup/`, `lib/features/export/`, `lib/features/recycle_bin/`, and `lib/features/sync/` only where physical colors, rigid layouts, or ungrouped surfaces remain.
- Modify: `docs/design/design-system.md`
- Modify: `README.md`
- Modify: relevant existing presentation tests in the same feature directories.

**Interfaces:**
- Consumes: all prior theme and component interfaces.
- Produces: a complete presentation-layer semantic-color audit and updated design documentation.

- [ ] **Step 1: Locate remaining UI inconsistencies**

Run:

```powershell
rg -n "AppColors\.|Color\(0x|Colors\.(white|black|grey|gray|red|green|orange|blue)" lib -g "*.dart"
rg -n "height:\s*[0-3][0-9](\.0)?[,)]|width:\s*[0-3][0-9](\.0)?[,)]" lib/features -g "*.dart"
```

Classify each result as semantic business meaning, acceptable illustration detail, or presentation hardcoding. Only migrate presentation hardcoding.

- [ ] **Step 2: Add or extend regression tests before each secondary-screen migration**

For every touched secondary screen, add a dark-theme pump and assert its primary title, recovery action, and destructive action remain visible. Reuse existing fakes and provider overrides; do not introduce repository changes.

- [ ] **Step 3: Migrate secondary presentation screens**

Apply semantic colors, shared headers/sections/surfaces, 48-pixel targets, wrapping rows, safe areas, and clear destructive separation. Keep routes, providers, repository calls, keys, and copy required by existing tests unchanged.

- [ ] **Step 4: Update design documentation**

Document the final light/dark semantic palette, token values, adaptive navigation breakpoint (720), component inventory, and reduced-motion behavior in `docs/design/design-system.md`. Update README feature summary to mention light/dark appearance and adaptive layouts.

- [ ] **Step 5: Run the UI/UX validation search required by ui-ux-pro-max**

```powershell
python "C:\Users\song\.codex\skills\ui-ux-pro-max\scripts\search.py" "animation accessibility z-index loading" --domain ux -n 10
```

Review findings against the implementation, especially visible focus, loading feedback, reduced motion, safe areas, and contrast.

- [ ] **Step 6: Run formatter, analyzer, and the full test suite**

```powershell
dart format lib test
flutter analyze
flutter test
```

Expected: formatter completes; analyzer reports no issues; all tests pass.

- [ ] **Step 7: Run target-platform build verification**

```powershell
flutter build windows --debug
```

Expected: the Windows debug build succeeds. If the local machine lacks a required platform component, record the exact external prerequisite and still require analyzer and tests to pass.

- [ ] **Step 8: Inspect final diff and commit**

```powershell
git diff --check
git status --short
git add -- lib test docs/design/design-system.md README.md
git commit -m "Polish Cardfolio UI across light and dark themes"
```

Expected: no whitespace errors, only scoped UI/docs/test changes are staged, and the final commit succeeds.
