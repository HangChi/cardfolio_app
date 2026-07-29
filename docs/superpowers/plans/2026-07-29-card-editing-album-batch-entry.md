# Card Editing, Album, and Batch Entry Implementation Plan

> 按任务顺序实现；本次明确不使用子智能体或额外分支。

**Goal:** Deliver optional-field card editing, front/back batch entry, and album folder semantics without changing the persisted Series schema.

**Architecture:** Extend the existing card repository with an update command and zero-image creation. Reuse Series as the album persistence model while changing user-facing language. Add focused edit and batch-entry screens that compose existing card and organization repositories.

**Tech Stack:** Flutter, Riverpod, go_router, Drift/SQLite, image_picker.

## Global Constraints

- Do not create or switch branches.
- Do not use subagents.
- Do not launch an emulator or simulator.
- Every card field, including front, back, name, tags, and dates, is optional.
- Keep existing Series table/type names for backup and sync compatibility.
- Run only host-side tests, formatting, and static analysis.
- Commit all implementation and documentation once, after verification.

---

### Task 1: Optional card creation and update contract

**Files:**
- Modify: `lib/features/cards/domain/card_models.dart`
- Modify: `lib/features/cards/domain/card_repository.dart`
- Modify: `lib/features/cards/data/card_repository_impl.dart`
- Modify: `lib/features/cards/data/local/card_database.dart`
- Test: `test/features/cards/domain/card_models_test.dart`
- Test: `test/features/cards/data/card_repository_impl_test.dart`

**Interfaces:**
- Produces: `UpdateCardRequest`
- Produces: `CardRepository.updateCard(UpdateCardRequest request)`
- Changes: `CreateCardRequest` accepts zero images and normalizes blank names to `未命名卡片`

- [x] Add failing host tests for blank-name/zero-image creation and card updates.
- [x] Run the focused tests and confirm the missing behavior fails.
- [x] Implement normalization, database update, repository failure mapping, and no-image creation.
- [x] Run the focused tests and confirm the new behavior passes.

### Task 2: Single-card create and edit UI

**Files:**
- Modify: `lib/app/app_router.dart`
- Modify: `lib/features/cards/presentation/create/create_card_controller.dart`
- Modify: `lib/features/cards/presentation/create/create_card_state.dart`
- Modify: `lib/features/cards/presentation/create/create_card_screen.dart`
- Create: `lib/features/cards/presentation/edit/edit_card_screen.dart`
- Modify: `lib/features/cards/presentation/detail/card_detail_screen.dart`
- Test: `test/features/cards/presentation/create_card_controller_test.dart`
- Test: `test/features/cards/presentation/card_detail_screen_test.dart`

**Interfaces:**
- Produces: `editCardPath(String id)`
- Consumes: `CardRepository.updateCard`
- Consumes: `OrganizationRepository.saveCardOrganization`

- [x] Add failing host tests for blank creation and enabled edit navigation.
- [x] Run the focused tests and confirm the missing behavior fails.
- [x] Make the create form always available, add clearable date selection, and implement the edit screen.
- [x] Enable card-detail edit and purchase actions.
- [x] Run the focused tests and confirm the UI behavior passes.

### Task 3: Album terminology and folder behavior

**Files:**
- Modify: `lib/features/cards/presentation/library/card_library_screen.dart`
- Modify: `lib/features/organization/presentation/series/series_collection_view.dart`
- Modify: `lib/features/organization/presentation/series/series_form_screen.dart`
- Modify: `lib/features/organization/presentation/series/series_detail_screen.dart`
- Modify: `lib/features/organization/presentation/card/card_organization_screen.dart`
- Modify: `lib/features/organization/presentation/management/organization_settings_screen.dart`
- Modify: `lib/features/sync/presentation/profile_screen.dart`

**Interfaces:**
- Keeps: persisted `SeriesRecord`, `SeriesCard`, and `SeriesSet`
- Changes: all user-facing Series copy to 集卡册

- [x] Replace user-facing terminology while keeping persisted names unchanged.
- [x] Confirm album forms still select cards and sets and expose no tag controls.

### Task 4: Front/back batch entry

**Files:**
- Modify: `lib/app/app_router.dart`
- Create: `lib/features/cards/presentation/batch/batch_card_entry_screen.dart`
- Modify: `lib/features/cards/presentation/capture/capture_entry_screen.dart`
- Modify: `lib/features/cards/presentation/library/card_library_screen.dart`
- Test: `test/features/cards/presentation/card_flow_test.dart`

**Interfaces:**
- Produces: `batchCardEntryPath`
- Consumes: gallery/camera adapters, `CardRepository.createCard`, and `OrganizationRepository.saveCardOrganization`

- [x] Add a failing host Widget test for the batch route and empty front/back drafts.
- [x] Run the focused test and confirm the route/screen is missing.
- [x] Implement multiple stable drafts with optional front/back, date, tags, album, add/remove, and idempotent sequential save.
- [x] Connect capture and collection entry points.
- [x] Run the focused test and confirm the route and empty-state behavior pass.

### Task 5: Documentation and host verification

**Files:**
- Modify: `README.md`
- Modify: `docs/features/README.md`
- Modify: `docs/engineering/development-log.md`
- Modify: `docs/quality/requirements-traceability.md`

- [x] Update feature status, terminology, completed behavior, and manual-device steps.
- [x] Run Dart formatting.
- [x] Run focused host tests.
- [x] Run static analysis.
- [x] Run the full host `flutter test --no-pub` if focused verification is green.
- [ ] Review `git diff --check`, generated files, and `git status`.
- [ ] Commit all scoped files once.
