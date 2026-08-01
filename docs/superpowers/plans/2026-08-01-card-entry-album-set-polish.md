# Card Entry, Album, and Set Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete image draft controls and OCR, align calendar-date semantics, add standalone set and preset album covers, render album contents as an album/set/card hierarchy, and make root back navigation and related spacing consistent.

**Architecture:** Keep existing feature-first boundaries and extend the Drift schema only for a standalone set cover path. Build album nesting in the organization read model, keep generated album presets as managed image files, and centralize root-exit handling in the app shell. UI changes reuse the existing theme tokens and card image pipeline.

**Tech Stack:** Flutter, Dart, Riverpod, go_router, Drift/SQLite, Android Kotlin MethodChannel, Google ML Kit Chinese text recognition.

**Execution status:** Completed inline on 2026-08-01. Per the user's validation constraint, verification is limited to Dart formatting and manual Git diff inspection.

## Global Constraints

- Do not use subagents.
- Do not create or switch branches.
- Do not add or modify tests and do not run tests, builds, or static analysis.
- Format only touched Dart sources, inspect the Git diff manually, and create one final commit.
- Update `docs/local/CHANGELOG.md` and `docs/local/TECHNICAL_IMPLEMENTATION.md` with the implementation.

---

### Task 1: Draft Image and Copy Isolation

**Files:**
- Modify: `lib/features/cards/presentation/create/create_card_controller.dart`
- Modify: `lib/features/cards/presentation/create/create_card_screen.dart`

**Interfaces:**
- Produces: `CreateCardController.startCopyDraft()` that clears images, draft IDs, transient failures, quantity, and form state before copy metadata is applied.
- Produces: a visible draft-image delete action that calls `discardImage(String imageId)` for every image, including the current cover.

- [ ] Add `startCopyDraft()` and invoke it before loading copied fields.
- [ ] Keep capture/import entry flows unchanged so their selected images survive navigation.
- [ ] Add a delete icon with clear semantics; after deleting index zero, the next image becomes cover by list order.
- [ ] Replace the large cover `Chip` with a compact translucent corner badge.
- [ ] Normalize image-card action spacing with existing design tokens.

### Task 2: OCR Availability and Feedback

**Files:**
- Modify: `android/app/src/main/kotlin/com/songhangchi/cardfolio/MainActivity.kt`
- Modify: `lib/features/cards/data/card_autofill_providers.dart`
- Modify: `lib/features/cards/presentation/widgets/card_autofill_button.dart`

**Interfaces:**
- Produces: stable MethodChannel recognition with one recognizer lifecycle and platform error codes surfaced as actionable Chinese messages.

- [ ] Keep bundled Chinese ML Kit recognition offline and validate that the supplied local path exists before recognition.
- [ ] Reuse and close the recognizer with the Activity lifecycle rather than constructing one per tap.
- [ ] Translate invalid path, invalid image, unavailable model, and recognition failure into distinct UI feedback.
- [ ] Continue showing the editable confirmation sheet before applying fields.

### Task 3: Calendar-Date and Quick-Cost Alignment

**Files:**
- Modify: `lib/features/organization/domain/organization_models.dart`
- Modify: `lib/features/purchases/domain/purchase_models.dart`
- Modify: `lib/features/purchases/data/local/purchase_database.dart`
- Modify: `lib/features/cards/presentation/create/create_card_screen.dart`
- Modify: `lib/features/cards/presentation/edit/edit_card_screen.dart`

**Interfaces:**
- Produces: date-only normalization as `DateTime.utc(year, month, day)`.
- Extends: `SaveCardEntryCostRequest` with optional `purchasedAt`, normalized as the same UTC calendar date.

- [ ] Replace local-midnight `.toUtc()` conversion for acquisition dates with UTC calendar-date construction.
- [ ] Add an optional quick-cost date and use the acquisition date when available.
- [ ] Preserve the existing purchase timestamp when no acquisition date is supplied during edits; use repository time only for a new undated quick cost.
- [ ] Ensure detail labels and spending-calendar grouping no longer shift by one day.

### Task 4: Standalone Set Covers and Schema Migration

**Files:**
- Modify: `lib/features/cards/data/local/card_database.dart`
- Modify: `lib/features/card_sets/domain/card_set_models.dart`
- Modify: `lib/features/card_sets/domain/card_set_repository.dart`
- Modify: `lib/features/card_sets/data/card_set_repository_impl.dart`
- Modify: `lib/features/card_sets/data/local/card_set_database.dart`
- Modify: `lib/features/backup/data/backup_database.dart`
- Modify: relevant sync serialization in `lib/features/sync/data/local/sync_local_store.dart` if the generated row map is not automatic.

**Interfaces:**
- Adds: nullable `card_sets.cover_relative_path` through an additive SQL migration in schema version 9; existing generated table APIs remain unchanged and raw SQL is isolated to cover-path reads/writes.
- Produces: `setStandaloneCover({required String setId, String? relativePath})` while retaining legacy member-image cover selection.

- [ ] Add the nullable column and a version 8→9 migration.
- [ ] Prefer standalone cover path over the legacy cover image path in set summary/detail reads.
- [ ] Clear the alternative cover source when a standalone or member cover is selected.
- [ ] Include the new path in backup snapshots/import and managed-file reference discovery.
- [ ] Preserve existing databases and old member-image covers.

### Task 5: Set Detail Visual and Cover Interaction

**Files:**
- Modify: `lib/features/card_sets/presentation/detail/card_set_detail_screen.dart`
- Modify: `lib/features/card_sets/presentation/widgets/card_set_progress_panel.dart`

**Interfaces:**
- Consumes: standalone set-cover repository API and existing camera/gallery/managed-image providers.

- [ ] Make the cover image itself the only persistent cover affordance.
- [ ] On tap, offer camera, gallery, member card face, and clear actions.
- [ ] Import captured/selected covers into managed storage with a set-scoped owner key.
- [ ] Render owned, missing, and duplicate counts as one three-column row.
- [ ] Replace the oversized add-member button with a compact icon action.
- [ ] Render issue information and notes as restrained labeled information surfaces.
- [ ] Standardize intra-card gaps to `spaceSm`/`spaceMd` and section gaps to `spaceLg`.

### Task 6: Album Preset Covers and Nested Detail

**Files:**
- Modify: `lib/features/organization/domain/organization_models.dart`
- Modify: `lib/features/organization/data/local/organization_query_database.dart`
- Modify: `lib/features/organization/presentation/series/series_form_screen.dart`
- Modify: `lib/features/organization/presentation/series/series_detail_screen.dart`
- Create: `lib/features/organization/presentation/series/series_cover_presets.dart`

**Interfaces:**
- Produces: `SeriesSetGroup` containing a set summary and its active member cards.
- Produces: managed PNG preset generation from album name, palette choice, and optional cover text.

- [ ] Extend the series detail read model with included-set member cards.
- [ ] Compute ungrouped cards by removing direct cards represented by an included set.
- [ ] Show every included set as an expandable directory with its member card rows.
- [ ] Show remaining direct cards under “其他卡片”.
- [ ] Add a small preset gallery to the album cover menu and generate a managed PNG on selection.
- [ ] Keep camera, gallery, member-image, and clear cover options.

### Task 7: Reliable Double-Back Exit

**Files:**
- Modify: `lib/app/navigation/app_shell.dart`

**Interfaces:**
- Produces: one root back handler shared by all five shell branches.

- [ ] Consume root back events exactly once per physical press.
- [ ] Reset the first-press window when switching branches.
- [ ] Show the exit prompt on the first root back and call `SystemNavigator.pop()` only on a distinct second press within two seconds.
- [ ] Leave nested route popping unchanged.

### Task 8: Documentation, Formatting, and Commit

**Files:**
- Modify: `docs/local/CHANGELOG.md`
- Modify: `docs/local/TECHNICAL_IMPLEMENTATION.md`

**Interfaces:**
- Documents: schema version 9, standalone/preset covers, nested album read model, OCR bridge lifecycle, UTC calendar-date semantics, draft copy isolation, and double-back behavior.

- [ ] Add a dated changelog entry describing all user-visible changes.
- [ ] Update the corresponding technical implementation sections and migration notes.
- [ ] Run `dart format` only on touched Dart files.
- [ ] Inspect `git diff --check`, `git status --short`, and the full diff without running tests, builds, or static analysis.
- [ ] Stage only this task's files and commit once with `feat: refine card entry albums and set experience`.
