# Feature 005 Purchases and Costs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a local-first purchase ledger with exact money, allocations, refund adjustments, currency-grouped totals, and purchase UI.

**Architecture:** A new `purchases` feature owns domain contracts, Drift extension queries, repository mapping, providers, and screens. Shared `AppDatabase` advances to schema v5; purchase facts and items are atomic, target names are snapshotted, and the existing organization query only consumes attributable cost for sorting.

**Tech Stack:** Flutter, Dart, flutter_riverpod, Drift/SQLite, go_router, build_runner, flutter_test.

## Global Constraints

- Work directly on the current `main`; do not create a branch or worktree.
- Do not use subagents.
- Do not launch an Android/iOS simulator; run host unit, database, repository, Widget, analysis, and build-time generation only.
- Persist money as integer minor units plus an uppercase three-letter ISO code.
- Default ledger total equals goods amount + shipping + fees; allocations never enter totals.
- Missing exchange rates produce currency groups, never a fabricated combined total.

---

### Task 1: Domain and repository contract

**Files:**
- Create: `lib/features/purchases/domain/purchase_models.dart`
- Create: `lib/features/purchases/domain/purchase_repository.dart`
- Create: `test/features/purchases/domain/purchase_models_test.dart`
- Modify: `lib/core/errors/app_failure.dart`

**Interfaces:**
- Produces: `CurrencyAmount`, `CostDisplayOptions`, `PurchaseTargetType`, `PurchaseTargetInput`, `CreatePurchaseRequest`, `CreateAdjustmentRequest`, `ExchangeRateInput`, `PurchaseRecord`, `CostSummary`, and `PurchaseRepository`.

- [ ] Write failing tests for exact amount parsing/formatting, ISO normalization, non-negative purchases, target uniqueness, complete allocations summing to the default ledger total, refund positivity, and rational rate validation.
- [ ] Run `flutter test --no-pub test/features/purchases/domain/purchase_models_test.dart` and verify failure is caused by missing purchase types.
- [ ] Implement immutable models, normalization, hand-derived totals, and `PurchaseValidationFailure`.
- [ ] Re-run the domain test and keep production types independent of Flutter and Drift.

### Task 2: Schema v5 and purchase transactions

**Files:**
- Modify: `lib/features/cards/data/local/card_database.dart`
- Create: `lib/features/purchases/data/local/purchase_database.dart`
- Generate: `lib/features/cards/data/local/card_database.g.dart`
- Generate: `lib/features/cards/data/local/card_database.steps.dart`
- Create: `drift_schemas/app/drift_schema_v5.json`
- Modify: `test/drift/app/migration_test.dart`
- Create: `test/features/purchases/data/purchase_database_test.dart`

**Interfaces:**
- Consumes: normalized requests from Task 1.
- Produces: schema tables and `AppDatabase` extension methods for atomic purchase creation, adjustments, history, summaries, target options, and exchange rates.

- [ ] Write failing v4→v5 migration and real-SQLite tests for atomic/idempotent writes, target snapshots, total 500 allocation, fee options, negative adjustments, currency grouping, rate persistence, and target deletion retention.
- [ ] Run focused tests and verify expected missing schema/API failures.
- [ ] Add three tables, constraints, indexes, transactional extension methods, and responsive queries.
- [ ] Run `dart run build_runner build --delete-conflicting-outputs` and `dart run drift_dev make-migrations`.
- [ ] Re-run focused migration/database tests.

### Task 3: Repository and providers

**Files:**
- Create: `lib/features/purchases/data/purchase_repository_impl.dart`
- Create: `lib/features/purchases/data/purchase_providers.dart`
- Create: `test/features/purchases/data/purchase_repository_impl_test.dart`

**Interfaces:**
- Produces: safe repository reads/writes plus `purchaseListProvider`, `costSummaryProvider`, and `purchaseTargetOptionsProvider`.

- [ ] Write failing repository tests for normalization, UTC timestamps, idempotency, adjustment currency inheritance, validation mapping, and database failure mapping.
- [ ] Implement the repository and Riverpod providers using the shared database, clock, and ID boundary.
- [ ] Run focused repository tests.

### Task 4: Purchase history, form, refund, and navigation

**Files:**
- Create: `lib/features/purchases/presentation/purchase_list_screen.dart`
- Create: `lib/features/purchases/presentation/purchase_form_screen.dart`
- Modify: `lib/features/organization/presentation/management/organization_settings_screen.dart`
- Modify: `lib/app/app_router.dart`
- Create: `test/features/purchases/presentation/purchase_list_screen_test.dart`
- Create: `test/features/purchases/presentation/purchase_form_screen_test.dart`

**Interfaces:**
- Consumes: purchase providers and repository.
- Produces: `/purchases`, `/purchases/new`, currency-grouped ledger, fee toggles, target selection, allocations, and refund adjustments.

- [ ] Write failing Widget tests for loading/empty/error/list states, currency groups, fee toggles, target selection, allocation validation, duplicate-submit prevention, refund creation, and accessible labels.
- [ ] Implement the list and scrolling form with existing theme tokens and safe amount parsing.
- [ ] Add routes and the “我的 → 购买记录” entry.
- [ ] Run focused Widget tests without launching a simulator.

### Task 5: Cost sort and completion

**Files:**
- Modify: `lib/features/organization/domain/organization_models.dart`
- Modify: `lib/features/organization/data/local/card_search_database.dart`
- Modify: `lib/features/cards/presentation/library/card_library_screen.dart`
- Modify: `test/features/organization/data/card_search_database_test.dart`
- Modify: `test/features/organization/presentation/card_library_filter_test.dart`
- Modify: `docs/features/005-purchases-and-costs/*`
- Modify: architecture, traceability, feature index, and development log documents.

**Interfaces:**
- Produces: stable card cost sort grouped by currency and scoped completion evidence.

- [ ] Write failing query and Widget tests for original-currency cost sorting and stable ties.
- [ ] Implement attributable direct-card cost query and expose the sort option with explicit grouped-currency copy.
- [ ] Run targeted purchase, organization, migration, and regression tests.
- [ ] Run `dart format`, code generation consistency, `flutter analyze --no-pub`, and full `flutter test --no-pub`.
- [ ] Update automated evidence, manual device steps, architecture, traceability, task checkboxes, feature index, and development log.
- [ ] Review `git diff`, stage only scoped files, and commit with `Complete purchases and cost ledger`.
