# Feature 004 Tags, Series, and Filters Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add local-first tags, series, typed custom fields, and responsive card search/filter/sort to Cardfolio.

**Architecture:** A new `organization` feature owns domain contracts and presentation. Drift schema v4 remains in the shared `AppDatabase`; focused extension files implement organization writes and raw responsive search queries. Riverpod connects repository streams to existing card, set, and navigation surfaces.

**Tech Stack:** Flutter, Dart, flutter_riverpod, Drift/SQLite, go_router, build_runner, flutter_test.

## Global Constraints

- Work directly on the current `main`; do not create a branch or worktree.
- Do not use subagents.
- Do not launch an Android/iOS simulator; run host unit, database, repository, Widget, analysis, and build-time generation only.
- Search debounce is 250ms; the 10,000-definition query benchmark must be below 300ms.
- P1 saved filters and Feature 005 purchase-cost sorting are out of scope.

---

### Task 1: Domain and repository contract

**Files:**
- Create: `lib/features/organization/domain/organization_models.dart`
- Create: `lib/features/organization/domain/organization_repository.dart`
- Create: `test/features/organization/domain/organization_models_test.dart`
- Modify: `lib/core/errors/app_failure.dart`

**Interfaces:**
- Produces: `CardLibraryQuery.normalized()`, `TagMatchMode`, `SetMembershipFilter`, `CardSortField`, `TagSummary`, `SeriesSummary`, `SeriesDetail`, `CustomFieldDefinition`, `CustomFieldValueInput`, `CardOrganizationDetail`, `OrganizationRepository`.

- [ ] Write failing domain tests for normalized queries, OR/AND tag semantics inputs, typed field values, name limits, and invalid merge IDs.
- [ ] Run `flutter test --no-pub test/features/organization/domain/organization_models_test.dart` and verify failures are caused by missing organization types.
- [ ] Implement immutable domain requests/read models and `OrganizationValidationFailure`.
- [ ] Re-run the domain test and keep the API independent of Flutter and Drift.

### Task 2: Schema v4 and transaction behavior

**Files:**
- Modify: `lib/features/cards/data/local/card_database.dart`
- Modify: `lib/features/cards/data/local/card_database.steps.dart` (generated)
- Modify: `lib/features/cards/data/local/card_database.g.dart` (generated)
- Create: `lib/features/organization/data/local/organization_database.dart`
- Create: `drift_schemas/app/drift_schema_v4.json`
- Modify: `test/drift/app/migration_test.dart`
- Create: `test/features/organization/data/organization_database_test.dart`

**Interfaces:**
- Consumes: normalized requests from Task 1.
- Produces: schema tables/columns and `AppDatabase` extension methods for tag, series, field, impact, and card-organization transactions.

- [ ] Write a failing v3→v4 data migration test and failing real-SQLite tests for unique active names, idempotent relationships, complete tag merge, rollback, field type validation, deletion impacts, and multi-series membership.
- [ ] Run the focused migration/database tests and verify expected missing schema/API failures.
- [ ] Add v4 columns, seven organization tables, foreign keys, partial unique indexes, and transactional extension methods.
- [ ] Run `dart run build_runner build --delete-conflicting-outputs` and `dart run drift_dev make-migrations`.
- [ ] Re-run focused migration/database tests.

### Task 3: Responsive card discovery query and repository

**Files:**
- Create: `lib/features/organization/data/local/card_search_database.dart`
- Create: `lib/features/organization/data/organization_repository_impl.dart`
- Create: `lib/features/organization/data/organization_providers.dart`
- Create: `test/features/organization/data/card_search_database_test.dart`
- Create: `test/features/organization/data/organization_repository_impl_test.dart`

**Interfaces:**
- Produces: `watchCards(CardLibraryQuery)`, facets, organization detail, tag/series/field streams and repository error mapping.

- [ ] Write failing query tests for six searchable fields, Chinese text, cross-dimension AND, tag OR/AND, set membership, duplicate/needs-completion, all stable sorts, null-last behavior, and soft-delete exclusion.
- [ ] Write the 10,000-definition fixed benchmark and verify the API is missing.
- [ ] Implement parameterized responsive SQL with explicit `readsFrom`, literal wildcard escaping, indexed relation subqueries, null-last sort expressions, and ID tiebreakers.
- [ ] Implement repository normalization, UTC/version coordination, idempotency, and safe failure mapping.
- [ ] Run focused data/repository tests and record the benchmark duration.

### Task 4: Tag, custom-field, and card organization UI

**Files:**
- Create: `lib/features/organization/presentation/management/organization_settings_screen.dart`
- Create: `lib/features/organization/presentation/card/card_organization_screen.dart`
- Modify: `lib/features/cards/presentation/detail/card_detail_screen.dart`
- Modify: `lib/app/app_router.dart`
- Create: `test/features/organization/presentation/organization_settings_screen_test.dart`
- Create: `test/features/organization/presentation/card_organization_screen_test.dart`

**Interfaces:**
- Consumes: organization providers from Task 3.
- Produces: management and per-card edit routes with impact confirmation.

- [ ] Write failing Widget tests for tag create/rename/merge/delete, field create/delete impact, typed card values, full-set tag/series saves, loading/failure/empty states, and accessible action labels.
- [ ] Implement management sections and the card organization editor using existing theme tokens.
- [ ] Add the card-detail organization summary and route actions.
- [ ] Run focused Widget tests without launching a simulator.

### Task 5: Series UI

**Files:**
- Create: `lib/features/organization/presentation/series/series_collection_view.dart`
- Create: `lib/features/organization/presentation/series/series_form_screen.dart`
- Create: `lib/features/organization/presentation/series/series_detail_screen.dart`
- Modify: `lib/app/app_router.dart`
- Create: `test/features/organization/presentation/series_screens_test.dart`

**Interfaces:**
- Consumes: series streams and `SaveSeriesRequest`.
- Produces: collection third tab, create/edit form, and separate card/set member lists.

- [ ] Write failing Widget tests for empty/list/detail, multi-card/multi-set membership, multiple series, edit/delete, missing and failure states.
- [ ] Implement the series collection, form and detail screens with explicit “series has no completion” copy.
- [ ] Run focused Widget tests.

### Task 6: Library search/filter/sort integration and completion

**Files:**
- Modify: `lib/features/cards/presentation/library/card_library_screen.dart`
- Modify: `lib/app/app_router.dart`
- Create: `test/features/organization/presentation/card_library_filter_test.dart`
- Modify: `docs/features/004-tags-series-and-filters/*`
- Modify: `docs/architecture/database-schema.md`
- Modify: `docs/architecture/domain-model.md`
- Modify: `docs/quality/requirements-traceability.md`
- Modify: `docs/engineering/development-log.md`
- Modify: `docs/features/README.md`

**Interfaces:**
- Consumes: query/facet providers and `SeriesCollectionView`.
- Produces: session-preserved query state, 250ms debounce, filter sheet, active-filter summary, no-results reset, and three collection tabs.

- [ ] Write failing Widget tests for debounce, active filter text, tag mode, sorting, no-results reset, and 200% text/narrow layouts.
- [ ] Implement the library query controller and search/filter/sort UI.
- [ ] Run targeted organization and regression tests.
- [ ] Run `dart format`, `flutter analyze --no-pub`, and the full `flutter test --no-pub`.
- [ ] Update test evidence, manual Android/iOS steps, traceability, architecture, feature index, development log, and task checkboxes.
- [ ] Review `git diff`, stage only scoped files, and commit with `Complete tags series and collection filters`.
