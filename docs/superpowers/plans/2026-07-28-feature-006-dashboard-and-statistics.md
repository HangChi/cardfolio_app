# Feature 006 Dashboard and Statistics Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. The user explicitly requires inline execution without subagents, branches, or approval checkpoints.

**Goal:** Build reactive home summaries, multidimensional statistics, cost trends, and statistics-to-library drill-down on existing local facts.

**Architecture:** Add a read-only dashboard feature with immutable domain snapshots, a Drift query extension, repository boundary, Riverpod providers, and two routed screens. Extend `CardLibraryQuery` with issuer and set-status predicates so statistics and drill-down use one condition model.

**Tech Stack:** Flutter, Dart 3.12, Riverpod 3, Drift 2.34, SQLite, go_router, flutter_test.

## Global Constraints

- No subagents, no new branch, and no implementation approval pause.
- Run only unit, database/API-boundary, widget, analyzer, and build-time checks; do not open a simulator.
- Statistics are read-only derived data and exclude soft-deleted facts by default.
- Costs remain grouped by original ISO currency; shipping and fees follow existing display options.
- Set completion follows BR-SET-001..005.

---

### Task 1: Feature contract and shared drill-down query

**Files:**
- Create: `docs/features/006-dashboard-and-statistics/spec.md`
- Create: `docs/features/006-dashboard-and-statistics/data-model.md`
- Create: `docs/features/006-dashboard-and-statistics/contracts.md`
- Create: `docs/features/006-dashboard-and-statistics/acceptance.md`
- Create: `docs/features/006-dashboard-and-statistics/error-cases.md`
- Create: `docs/features/006-dashboard-and-statistics/ux-mapping.md`
- Create: `docs/features/006-dashboard-and-statistics/test-matrix.md`
- Create: `docs/features/006-dashboard-and-statistics/tasks.md`
- Create: `docs/features/006-dashboard-and-statistics/plan.md`
- Modify: `lib/features/organization/domain/organization_models.dart`
- Modify: `lib/features/organization/data/local/card_search_database.dart`
- Test: `test/features/organization/domain/organization_models_test.dart`
- Test: `test/features/organization/data/card_search_database_test.dart`

**Interfaces:**
- Produces: `CardLibraryQuery.issuer` and `CardLibraryQuery.setStatus`, with normalized exact-match semantics.
- Produces: `CardSetStatusFilter { complete, nearlyComplete, incomplete, unknown }`.

- [ ] **Step 1: Write failing domain and database tests**

Add literal assertions that issuer text is trimmed, copied, and recognized as filtering; create four sets and assert each set-status query returns only cards belonging to a matching active set.

- [ ] **Step 2: Run tests to verify RED**

Run: `flutter test test/features/organization/domain/organization_models_test.dart test/features/organization/data/card_search_database_test.dart`

Expected: compile failures because `issuer`, `setStatus`, and `CardSetStatusFilter` do not exist.

- [ ] **Step 3: Implement minimal shared query support**

Add the fields to constructor, normalization, `copyWith`, `isFiltering`, and SQL predicates. The set predicate must use active sets, active required members, and summed active item quantity; unknown sets match only `count_known = 0`, complete sets require all required members owned, nearly complete requires exactly one missing, and incomplete excludes both complete and nearly complete known sets.

- [ ] **Step 4: Run tests to verify GREEN**

Run the same targeted command and require exit code 0.

### Task 2: Dashboard domain and reactive database aggregation

**Files:**
- Create: `lib/features/dashboard/domain/dashboard_models.dart`
- Create: `lib/features/dashboard/domain/dashboard_repository.dart`
- Create: `lib/features/dashboard/data/local/dashboard_database.dart`
- Test: `test/features/dashboard/domain/dashboard_models_test.dart`
- Test: `test/features/dashboard/data/dashboard_database_test.dart`

**Interfaces:**
- Produces: `HomeDashboard`, `StatisticsSnapshot`, `StatisticBucket`, `CostTrendPoint`, `DashboardCard`, `DashboardSet`, and `StatisticDimension`.
- Produces: `DashboardRepository.watchHome(nowUtc, options)` and `watchStatistics(options)`.

- [ ] **Step 1: Write failing model tests**

Assert each statistics bucket creates the literal expected `CardLibraryQuery`, set status labels are stable Chinese copy, and month labels are `YYYY-MM`.

- [ ] **Step 2: Run model tests to verify RED**

Run: `flutter test test/features/dashboard/domain/dashboard_models_test.dart`

Expected: compile failure because dashboard models do not exist.

- [ ] **Step 3: Implement immutable models**

Keep constructors const where possible; make list fields unmodifiable at the data boundary. No framework or Drift types may enter the domain.

- [ ] **Step 4: Write failing database tests**

Seed active and deleted cards, duplicate quantities, complete/nearly/unknown sets, tags, two currencies, shipping, fees, and refund adjustments. Assert exact totals, stable recent ordering, non-exclusive tag counts, per-currency cost totals, per-month trends, and recomputation after a source row changes.

- [ ] **Step 5: Run database tests to verify RED**

Run: `flutter test test/features/dashboard/data/dashboard_database_test.dart`

Expected: compile failure because `watchHomeDashboard` and `watchStatisticsSnapshot` do not exist.

- [ ] **Step 6: Implement read-only Drift aggregation**

Use custom selects with explicit `readsFrom`; exclude deleted cards, definitions, sets, members, and tags. Calculate month start from the supplied UTC instant via local calendar boundaries, reuse existing cost options, and stable-sort equal buckets by label.

- [ ] **Step 7: Run database tests to verify GREEN**

Run both dashboard domain and database test files and require exit code 0.

### Task 3: Repository and providers

**Files:**
- Create: `lib/features/dashboard/data/dashboard_repository_impl.dart`
- Create: `lib/features/dashboard/data/dashboard_providers.dart`
- Test: `test/features/dashboard/data/dashboard_repository_impl_test.dart`

**Interfaces:**
- Consumes: `AppDatabase`, `Clock`, and `purchaseCostDisplayOptionsProvider`.
- Produces: `dashboardRepositoryProvider`, `homeDashboardProvider`, and `statisticsProvider`.

- [ ] **Step 1: Write failing repository tests**

Assert a real in-memory database snapshot is returned and a closed database error becomes `DatabaseUnavailableFailure` with user-safe copy.

- [ ] **Step 2: Run test to verify RED**

Run: `flutter test test/features/dashboard/data/dashboard_repository_impl_test.dart`

Expected: compile failure because the implementation does not exist.

- [ ] **Step 3: Implement repository and providers**

Delegate reads to the database extension, obtain `nowUtc()` from the injected clock, and map non-domain read errors without exposing their source text.

- [ ] **Step 4: Run test to verify GREEN**

Run the repository test and require exit code 0.

### Task 4: Home and statistics UI

**Files:**
- Create: `lib/features/dashboard/presentation/home_screen.dart`
- Create: `lib/features/dashboard/presentation/statistics_screen.dart`
- Modify: `lib/app/app_router.dart`
- Test: `test/features/dashboard/presentation/home_screen_test.dart`
- Test: `test/features/dashboard/presentation/statistics_screen_test.dart`
- Modify: `test/app/cardfolio_app_test.dart`

**Interfaces:**
- Consumes: dashboard providers and `cardLibraryQueryProvider`.
- Produces: real `/home` and `/stats` branch roots; bucket taps replace the shared library query and navigate to `/library`.

- [ ] **Step 1: Write failing widget tests**

Use a fake dashboard repository. Assert summary values and currency separation, actionable empty state, error retry, dimension switching, trend rendering, and a bucket tap that changes `CardLibraryQuery` before showing the collection branch.

- [ ] **Step 2: Run tests to verify RED**

Run: `flutter test test/features/dashboard/presentation test/app/cardfolio_app_test.dart`

Expected: compile or finder failures because both routed screens are absent.

- [ ] **Step 3: Implement minimal responsive screens and routes**

Use Material theme values, scrolling layouts, semantic text labels, `AsyncValue` loading/error/data branches, and no fixed screen width. Replace both placeholders in `createAppRouter`.

- [ ] **Step 4: Run tests to verify GREEN**

Run the same widget test command and require exit code 0.

### Task 5: Traceability, verification, and commit

**Files:**
- Modify: `docs/features/006-dashboard-and-statistics/README.md`
- Modify: `docs/features/README.md`
- Modify: `docs/quality/requirements-traceability.md`
- Modify: `docs/engineering/development-log.md`

**Interfaces:**
- Produces: honest automated evidence and explicit unexecuted device steps.

- [ ] **Step 1: Update documentation**

Mark only commands actually executed as passing. Keep simulator/device checks listed as pending manual verification.

- [ ] **Step 2: Run format and targeted verification**

Run: `dart format lib test`

Run: `flutter test test/features/dashboard test/features/organization/domain/organization_models_test.dart test/features/organization/data/card_search_database_test.dart test/app/cardfolio_app_test.dart`

- [ ] **Step 3: Run full non-device verification**

Run: `flutter analyze`

Run: `flutter test`

Expected: all commands exit 0 with zero analyzer issues and zero test failures.

- [ ] **Step 4: Review changes and commit**

Inspect `git diff --check`, `git status --short`, and the final diff. Stage only Feature 006 and required shared-query/documentation files, then commit with `Complete dashboard and statistics`.
