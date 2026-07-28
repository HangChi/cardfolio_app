# Feature 003 Card Set Progress Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. This execution uses inline TDD and forbids subagents.

**Goal:** Let users create card sets, define and order required/optional members, associate owned styles, and see live missing, duplicate, and completion status.

**Architecture:** Add `CardSet` and `CardSetMember` tables to the shared Drift database, keep completion derived from active items, and expose a dedicated card-set repository through Riverpod. Missing members are definitions without items; UI lives in a separate `card_sets` feature and integrates into the collection route.

**Tech Stack:** Flutter, Dart 3.12, Riverpod 3, Drift/SQLite, go_router, flutter_test.

## Global Constraints

- Work directly on `main`; do not create a feature branch.
- Do not use subagents.
- Do not open or run a simulator.
- Use test-first red-green-refactor for every production behavior.
- Preserve schema-v2 data and never silently recreate a failed database.
- Do not persist derived completion percentages.

---

### Task 1: Domain and repository contracts

**Files:**
- Create: `lib/features/card_sets/domain/card_set_models.dart`
- Create: `lib/features/card_sets/domain/card_set_repository.dart`
- Modify: `lib/core/errors/app_failure.dart`
- Test: `test/features/card_sets/domain/card_set_models_test.dart`

**Interfaces:**
- Produces: `CreateCardSetRequest`, `UpdateCardSetRequest`, `AddCardSetMemberRequest`, `UpdateCardSetMemberRequest`, `CardSetProgress`, `CardSetSummary`, `CardSetDetail`, `CardSetCandidate`.
- Consumes: `IdGenerator`, `PartialDate`-independent text metadata, `AppFailure`.

- [ ] Write failing tests for normalization, known/unknown totals, 3/4 progress, duplicate quantity and zero-member completion.
- [ ] Run the domain test and confirm missing types fail compilation.
- [ ] Implement the minimal immutable models and pure progress calculation.
- [ ] Re-run the domain test.

### Task 2: Drift schema v3 and set transactions

**Files:**
- Modify: `lib/features/cards/data/local/card_database.dart`
- Create: `lib/features/card_sets/data/local/card_set_database.dart`
- Regenerate: `lib/features/cards/data/local/card_database.g.dart`
- Regenerate: `lib/features/cards/data/local/card_database.steps.dart`
- Create: `drift_schemas/app/drift_schema_v3.json`
- Modify: `test/drift/app/migration_test.dart`
- Create: `test/features/card_sets/data/card_set_database_test.dart`
- Modify: `test/features/cards/data/card_database_migration_test.dart`

**Interfaces:**
- Produces: schema-v3 tables plus create/update/member/cover transactions and responsive set/detail/candidate streams.
- Consumes: domain requests and generated Drift companions.

- [ ] Write failing database tests for create/edit, active uniqueness, missing member atomicity, ordering, cover ownership and AC-P0-005 aggregation.
- [ ] Add a v2 migration test and verify it fails before schema changes.
- [ ] Add the tables and extension queries/transactions, then regenerate Drift outputs and schema snapshots.
- [ ] Re-run database and migration tests.

### Task 3: Repository and providers

**Files:**
- Create: `lib/features/card_sets/data/card_set_repository_impl.dart`
- Create: `lib/features/card_sets/data/card_set_providers.dart`
- Test: `test/features/card_sets/data/card_set_repository_impl_test.dart`

**Interfaces:**
- Produces all `CardSetRepository` operations and Riverpod list/detail/candidate providers.
- Consumes `AppDatabase`, `Clock`, domain normalization and stable failure types.

- [ ] Write failing repository tests for normalized writes, version timestamps, conflict mapping and missing targets.
- [ ] Implement repository coordination and failure mapping.
- [ ] Re-run repository tests.

### Task 4: Collection integration and set form

**Files:**
- Modify: `lib/features/cards/presentation/library/card_library_screen.dart`
- Create: `lib/features/card_sets/presentation/library/card_set_collection_view.dart`
- Create: `lib/features/card_sets/presentation/form/card_set_form_screen.dart`
- Modify: `lib/app/app_router.dart`
- Test: `test/features/card_sets/presentation/card_set_collection_view_test.dart`
- Test: `test/features/card_sets/presentation/card_set_form_screen_test.dart`
- Modify: `test/features/cards/presentation/card_flow_test.dart`

**Interfaces:**
- Produces `/sets/new`, `/sets/:id/edit`, card/set collection switch and validated create/edit form.
- Consumes set providers, router path helpers and theme tokens.

- [ ] Write failing Widget tests for empty/list/error states, navigation and known/unknown form behavior.
- [ ] Implement the collection switch, set list and reusable form.
- [ ] Re-run collection, form and existing card-flow tests.

### Task 5: Set detail and member management

**Files:**
- Create: `lib/features/card_sets/presentation/detail/card_set_detail_screen.dart`
- Create: `lib/features/card_sets/presentation/widgets/card_set_progress_panel.dart`
- Modify: `lib/app/app_router.dart`
- Test: `test/features/card_sets/presentation/card_set_detail_screen_test.dart`

**Interfaces:**
- Produces `/sets/:id`, progress panel, member checklist track, add-existing/add-missing, member edit/move/remove and cover selection.
- Consumes detail/candidate providers, `IdGenerator`, repository mutations and AppFailure messages.

- [ ] Write failing Widget tests for 3/4, unknown total, missing/repeat labels, member actions and missing route state.
- [ ] Implement the responsive, semantic detail UI and mutation guards.
- [ ] Re-run detail and router tests.

### Task 6: Documentation, verification, and commit

**Files:**
- Modify: `docs/features/003-card-set-progress/tasks.md`
- Modify: `docs/features/003-card-set-progress/README.md`
- Modify: `docs/architecture/database-schema.md`
- Modify: `docs/architecture/domain-model.md`
- Modify: `docs/quality/requirements-traceability.md`
- Modify: `docs/engineering/development-log.md`

- [ ] Run `dart format --output=none --set-exit-if-changed lib test`.
- [ ] Run `flutter analyze --no-pub`.
- [ ] Run `flutter test --no-pub`.
- [ ] Review `git diff --check`, `git status --short`, and every Feature 003 acceptance item.
- [ ] Record simulator-free Android/iOS manual steps in the final handoff.
- [ ] Stage Feature 003 files and commit on `main`.
