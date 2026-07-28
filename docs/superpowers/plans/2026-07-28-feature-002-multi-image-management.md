# Feature 002 Multi-image Management Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. This repository's current execution explicitly forbids subagents.

**Goal:** Let one local card own, order, classify, cover-select, add, and remove up to 20 managed images.

**Architecture:** Extend the existing domain/repository boundary, migrate Drift from schema 1 to 2, keep files immutable under `ManagedImageStore`, and expose operations through Riverpod controllers. Cover and order are independent; retained originals use soft-deleted image rows.

**Tech Stack:** Flutter, Dart 3.12, Riverpod 3, Drift/SQLite, image_picker, flutter_test.

## Global Constraints

- Do not open or run a simulator.
- Do not use subagents.
- Keep camera and image processing out of scope.
- Use test-first red-green-refactor for every production behavior.
- Preserve schema-v1 user data and never silently recreate a failed database.

---

### Task 1: Domain and gallery contracts

**Files:**
- Modify: `lib/features/cards/domain/card_models.dart`
- Modify: `lib/features/cards/domain/card_repository.dart`
- Modify: `lib/features/cards/domain/gallery_picker.dart`
- Modify: `lib/features/cards/data/platform/image_picker_gallery.dart`
- Test: `test/features/cards/domain/card_models_test.dart`

**Interfaces:**
- Produces: `PendingCardImage`, `AddCardImagesRequest`, `ImageDeletionImpact`, six-value `CardImageKind`, `GalleryPicker.pickMany(int limit)`.
- Consumes: `IdGenerator`, existing failure types.

- [ ] Write tests that reject empty/over-20 image lists and preserve all six kinds.
- [ ] Run `flutter test test/features/cards/domain/card_models_test.dart` and observe missing API failures.
- [ ] Implement the types and multi-select adapter.
- [ ] Re-run the target test and keep existing domain tests green.

### Task 2: Drift schema v2 and mutation transactions

**Files:**
- Modify: `lib/features/cards/data/local/card_database.dart`
- Regenerate: `lib/features/cards/data/local/card_database.g.dart`
- Create: `drift_schemas/app/drift_schema_v2.json`
- Test: `test/features/cards/data/card_database_test.dart`
- Create: `test/features/cards/data/card_database_migration_test.dart`

**Interfaces:**
- Produces: `insertImages`, `updateImageKind`, `reorderImages`, `setCover`, `deleteImage`, `imageDeletionRecord`.
- Consumes: `CardImagesCompanion`, ordered image IDs.

- [ ] Add failing tests for ordered images, independent cover, unique cover, six kinds, soft/hard delete, last-image guard and v1 migration.
- [ ] Run both database tests and confirm schema/method failures.
- [ ] Add v2 columns, partial unique index, migration and transaction methods.
- [ ] Run `dart run build_runner build --delete-conflicting-outputs` and `dart run drift_dev make-migrations`.
- [ ] Re-run both database tests.

### Task 3: Repository batch coordination

**Files:**
- Modify: `lib/features/cards/data/card_repository_impl.dart`
- Test: `test/features/cards/data/card_repository_impl_test.dart`

**Interfaces:**
- Produces all Feature 002 `CardRepository` methods.
- Consumes `ManagedImageStore.importImage/delete/resolve` and database mutations.

- [ ] Add failing tests for multi-create, append, compensation, capacity, cover/order/kind and both delete policies.
- [ ] Run the repository test and confirm missing behavior failures.
- [ ] Implement batch import with a list of successfully imported paths and compensation in reverse order.
- [ ] Implement mutation mapping and deletion byte impact from the real managed file.
- [ ] Re-run repository tests.

### Task 4: Multi-image creation state

**Files:**
- Modify: `lib/features/cards/presentation/create/create_card_state.dart`
- Modify: `lib/features/cards/presentation/create/create_card_controller.dart`
- Modify: `lib/features/cards/presentation/create/create_card_screen.dart`
- Test: `test/features/cards/presentation/create_card_controller_test.dart`
- Test: `test/features/cards/presentation/create_card_screen_test.dart`

**Interfaces:**
- Produces ordered draft images with stable IDs and kind updates.
- Consumes `GalleryPicker.pickMany`, `CreateCardRequest.images`.

- [ ] Add failing controller tests for multi-select, stable per-image IDs, reordering, kind changes and 20-image capacity.
- [ ] Add failing Widget tests for ordered previews, kind labels and cover semantics.
- [ ] Implement minimal state/controller/UI behavior.
- [ ] Re-run both creation tests.

### Task 5: Detail gallery management

**Files:**
- Modify: `lib/features/cards/presentation/detail/card_detail_screen.dart`
- Create: `lib/features/cards/presentation/widgets/card_image_kind_label.dart`
- Test: `test/features/cards/presentation/card_detail_screen_test.dart`

**Interfaces:**
- Produces screen-local add, kind, move, cover and delete operations with busy/failure state.
- Consumes `CardRepository`, `GalleryPicker`, `IdGenerator`, `CardDetail`.

- [ ] Add failing Widget/controller tests for gallery order, cover selection, add, kind, movement and delete confirmation.
- [ ] Run the target test and observe missing controls.
- [ ] Implement the controller and accessible management sheet.
- [ ] Re-run target tests.

### Task 6: Verification and handoff

**Files:**
- Modify: `docs/features/002-multi-image-management/tasks.md`
- Modify: `docs/quality/requirements-traceability.md`
- Modify: `docs/开发日志.md`

- [ ] Run `dart format --output=none --set-exit-if-changed lib test integration_test`.
- [ ] Run `flutter analyze`.
- [ ] Run `flutter test`.
- [ ] Review `git diff --check`, `git status --short`, and the Feature 002 acceptance checklist.
- [ ] Record simulator-free manual Android/iOS steps in the final handoff.
- [ ] Stage only Feature 002 files and commit with `Complete multi-image and cover management`.
