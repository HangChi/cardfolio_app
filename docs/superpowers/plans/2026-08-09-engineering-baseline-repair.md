# Engineering Baseline Repair Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restore a trustworthy engineering baseline where migrations, the full Flutter test suite, static analysis, CI checks, and the Android debug build all pass on the current product behavior.

**Architecture:** Preserve the documented product rules and fix defects at their source. Database schema v9 becomes a first-class Drift schema, staged upgrades honor the requested target version, backup export includes every managed cover type, and tests are updated only when they encode superseded product behavior or UI structure. CI executes the same commands used locally.

**Tech Stack:** Flutter 3.x, Dart 3.12, Riverpod, Drift/SQLite, flutter_test, GitHub Actions, Android Gradle.

## Global Constraints

- Card name and city remain required for new cards.
- Monthly additions use acquisition date, not row creation time.
- Soft-deleted collection targets remain auditable but are excluded from active collection totals.
- Database and images remain local-first; no new network dependency is introduced.
- Existing user data must migrate from schema versions 1 through 8 to schema version 9.

---

### Task 1: Repair Drift schema v9 and staged migrations

**Files:**
- Modify: `lib/features/cards/data/local/card_database.dart`
- Generate: `drift_schemas/app/drift_schema_v9.json`
- Generate: `test/drift/app/generated/schema_v9.dart`
- Modify: `test/drift/app/generated/schema.dart`
- Modify: `test/drift/app/migration_test.dart`
- Modify: `test/features/cards/data/card_database_migration_test.dart`

**Interfaces:**
- Produces: `CardSets.coverRelativePath` as a typed nullable Drift column.
- Preserves: `AppDatabase.schemaVersion == 9` and upgrade paths 1..8 -> 9.

- [x] Confirm the existing migration suite fails because `onUpgrade` migrates to 8/9 even when Drift asks for an intermediate target.
- [x] Add the typed v9 cover column and make `onCreate` create it exactly once.
- [x] Bound `stepByStep` by `to`, and execute the v9 migration only when `to >= 9`.
- [x] Dump schema v9 and regenerate Drift migration helpers.
- [x] Update the legacy migration assertion to compare the stored version with the database's current version.
- [x] Run `flutter test test/drift/app/migration_test.dart test/features/cards/data/card_database_migration_test.dart` and require zero failures.

### Task 2: Repair backup coverage for standalone card-set covers

**Files:**
- Modify: `lib/features/backup/data/backup_repository_impl.dart`
- Test: `test/features/backup/data/backup_repository_impl_test.dart`

**Interfaces:**
- Consumes: logical backup `cardSets[*].coverRelativePath`.
- Produces: exported ZIP entries and import validation for standalone card-set cover files.

- [x] Use the existing failing standalone-cover test as the RED case.
- [x] Collect non-empty `coverRelativePath` values from `cardSets`, alongside card images and series covers.
- [x] Run the focused backup repository tests and require zero failures.

### Task 3: Align non-UI tests with current product rules

**Files:**
- Modify: `test/features/cards/presentation/create_card_controller_test.dart`
- Modify: `test/features/dashboard/data/dashboard_database_test.dart`
- Modify: `test/features/purchases/data/purchase_database_test.dart`
- Modify: `test/features/cards/presentation/image_edit_controller_test.dart`

**Interfaces:**
- Preserves: required name/city validation, acquisition-date statistics, active-only cost totals, image-editor state contract.

- [x] Update create-card fixtures so successful paths provide both required fields; replace the obsolete unnamed-card success case with explicit required-field validation.
- [x] Seed `acquiredAt` explicitly where monthly dashboard counts are asserted.
- [x] Assert that soft-deleted target history remains while active totals exclude it.
- [x] Update image-editor initialization assertions to the current manual-crop-first behavior.
- [x] Run all four focused test files and require zero failures.

### Task 4: Repair UI behavior regressions and refresh stale widget tests

**Files:**
- Modify: `lib/features/cards/presentation/create/create_card_screen.dart`
- Modify only as required by reproduced UI defects: affected presentation widgets under `lib/app`, `lib/features/cards`, `lib/features/card_sets`, `lib/features/dashboard`, `lib/features/organization`, `lib/features/recycle_bin`, and `lib/features/sync`.
- Modify: the 13 failing widget test files listed by the 2026-08-09 baseline run.

**Interfaces:**
- Preserves: current five-destination navigation, current capture flow, current image management UI, responsive forms, and documented active-data semantics.

- [x] For each failing widget file, inspect the current widget tree and recent UI change before editing.
- [x] Update tests that reference removed navigation bars, labels, buttons, or optional-field behavior to assert current user-visible behavior.
- [x] Fix the reproduced 200% text-scale overflow in production UI, keeping controls reachable.
- [x] Scroll or size test surfaces explicitly when the target is legitimately below the fold; do not suppress missed taps.
- [x] Run each affected widget test file until it passes without Flutter exceptions.

### Task 5: Clear static analysis findings

**Files:**
- Modify: `lib/core/widgets/app_layout.dart`
- Modify: `lib/core/widgets/app_surface.dart`
- Modify: `lib/features/backup/data/backup_database.dart`
- Modify: `lib/features/cards/domain/card_autofill.dart`
- Modify: `lib/features/cards/presentation/detail/card_detail_screen.dart`
- Modify: `lib/features/cards/presentation/edit/image_editor_screen.dart`
- Modify: `lib/features/dashboard/presentation/home_screen.dart`
- Modify: `lib/features/dashboard/presentation/spending_calendar_screen.dart`
- Modify: `lib/features/dashboard/presentation/statistics_screen.dart`

- [x] Apply only analyzer-directed mechanical changes.
- [x] Run `dart format --output=none --set-exit-if-changed lib test integration_test`.
- [x] Run `flutter analyze --fatal-infos --fatal-warnings` and require `No issues found!`.

### Task 6: Add a reproducible CI quality gate

**Files:**
- Create: `.github/workflows/ci.yml`
- Create: `docs/engineering-baseline.md`

**Interfaces:**
- Produces: pull-request and main-branch checks for format, analyze, test, migration coverage, and Android debug build.

- [x] Add a pinned Flutter stable workflow with Java 21 and dependency caching.
- [x] Run format check, analyze, migration tests, full tests, and Android debug APK build in CI.
- [x] Document the local equivalent commands and migration snapshot policy.

### Task 7: Final verification and review

- [x] Run `dart format --output=none --set-exit-if-changed lib test integration_test`.
- [x] Run `flutter analyze --fatal-infos --fatal-warnings`.
- [x] Run `flutter test --concurrency=1`.
- [x] Run `flutter test` with default concurrency.
- [x] Run `flutter build apk --debug`.
- [x] Inspect `git diff --check`, `git status --short`, and the complete diff for unrelated changes.
- [x] Record the verified result in project memory before reporting completion.
