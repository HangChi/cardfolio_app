# Image Editor, Location, and Autofill Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the forced custom crop flow with an album-style editor, add structured card location and condition inputs, make OCR reviewable and useful, default the app to Home, and improve front/back image presentation.

**Architecture:** Keep the existing single-string `city` and reserved-metadata storage formats for backward compatibility, while adding reusable presentation widgets that serialize structured choices into those strings. Use the platform-native `image_cropper` UI for crop/rotate/zoom, then apply brightness, contrast, and sharpness to the cropped image at its current dimensions. OCR returns candidates to a review sheet and never silently overwrites card fields.

**Tech Stack:** Flutter, Riverpod, GoRouter, `image_picker`, `image_cropper`, Dart `image`, Android ML Kit, iOS Vision.

## Global Constraints

- Work directly on the current branch; do not create a branch or worktree.
- Do not use subagents.
- Do not run tests; the user will debug the application.
- Do not upscale or constrain output to 4096 pixels; preserve the cropped/original pixel dimensions.
- Photography must enter the card edit/create screen immediately and must not force cropping.
- Commit all workspace changes after code and required documentation updates are complete.

---

### Task 1: Native crop and original-resolution adjustment pipeline

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/features/cards/data/image_processing/local_image_processor.dart`
- Modify: `lib/features/cards/presentation/edit/image_editor_screen.dart`
- Modify: `lib/features/cards/presentation/edit/image_edit_controller.dart`
- Modify: `lib/features/cards/presentation/capture/capture_entry_screen.dart`
- Modify: `lib/features/cards/presentation/create/create_card_screen.dart`
- Modify: `lib/features/cards/presentation/batch/batch_card_entry_screen.dart`
- Modify: `lib/features/cards/presentation/detail/card_detail_screen.dart`

**Interfaces:**
- Consumes: source image path and existing `ImageProcessor.process(ImageProcessingRequest)` pipeline.
- Produces: a cropped path from `ImageCropper.cropImage`, immediate adjustment previews, and a final `ProcessedImage` at the crop result's native dimensions.

- [ ] Add `image_cropper` and platform configuration required by its current Android/iOS implementation.
- [ ] Remove the 4096-pixel resize from decode and remove the template output selector from the image editor.
- [ ] Replace four-corner dragging with a “裁剪与旋转” action that launches the native cropper.
- [ ] Apply slider changes to a debounced preview and save only when the user taps “使用此图片”.
- [ ] Route camera captures directly into create/edit flows and leave cropping as an explicit image-edit action.

### Task 2: Structured location and condition fields

**Files:**
- Create: `lib/features/cards/presentation/widgets/card_location_field.dart`
- Create: `lib/features/cards/presentation/widgets/card_condition_field.dart`
- Create: `lib/features/cards/data/china_regions.dart`
- Modify: `lib/features/cards/presentation/create/create_card_screen.dart`
- Modify: `lib/features/cards/presentation/edit/edit_card_screen.dart`
- Modify: `lib/features/cards/presentation/batch/batch_card_entry_screen.dart`
- Modify: `lib/features/cards/presentation/widgets/reserved_card_metadata_fields.dart`

**Interfaces:**
- Produces: `CardLocationField(value, onChanged)` which stores `省 / 市 / 县区`, and `CardConditionField(controller)` which stores one supported label or custom text.

- [ ] Add offline province/city/district data and a searchable three-step bottom sheet for China.
- [ ] Add a China/overseas mode; overseas mode exposes manual text input.
- [ ] Preserve unrecognized legacy city strings until the user changes them.
- [ ] Replace condition free text with the agreed dropdown and an “其他” custom field.
- [ ] Use both reusable controls in create, edit, and batch entry.

### Task 3: Reviewable cross-platform card OCR

**Files:**
- Modify: `lib/features/cards/domain/card_autofill.dart`
- Modify: `lib/features/cards/data/card_autofill_providers.dart`
- Modify: `lib/features/cards/presentation/widgets/card_autofill_button.dart`
- Modify: `lib/features/cards/presentation/create/create_card_screen.dart`
- Modify: `lib/features/cards/presentation/edit/edit_card_screen.dart`
- Modify: `android/app/src/main/kotlin/com/songhangchi/cardfolio_app/MainActivity.kt`
- Modify: `ios/Runner/AppDelegate.swift`

**Interfaces:**
- Produces: recognized raw lines plus ranked candidate values for name, code, year, city, and issuer; UI returns only fields explicitly selected by the user.

- [ ] Stop treating the first OCR line as the card name.
- [ ] Rank OCR lines and catalog matches, normalize Chinese region aliases, and keep code/year regex extraction.
- [ ] Replace automatic application with a confirmation bottom sheet containing selectable/editable fields and raw OCR text.
- [ ] Add an iOS Vision method-channel implementation matching Android's `cardfolio/text_recognition` contract.
- [ ] Rename the action to “识别卡面文字” and apply only confirmed non-empty values.

### Task 4: Home routing and card image presentation

**Files:**
- Modify: `lib/app/app_router.dart`
- Modify: `lib/app/bootstrap/app_bootstrap.dart`
- Modify: `lib/features/settings/presentation/onboarding_screen.dart`
- Modify: `lib/features/cards/presentation/create/create_card_screen.dart`
- Modify: `lib/features/cards/presentation/detail/card_detail_screen.dart`
- Modify: `lib/features/cards/presentation/batch/batch_card_entry_screen.dart`

**Interfaces:**
- Produces: Home as the initial post-onboarding route and landscape card thumbnails with explicit side/status/action affordances.

- [ ] Change router and completed-onboarding startup destinations from Library to Home.
- [ ] Change onboarding completion destination to Home.
- [ ] Render card images at the standard 85.60:53.98 landscape ratio.
- [ ] Replace crowded overlays with readable front/back chips, cover badges, and text-labelled edit/replace actions.

### Task 5: Documentation and commit

**Files:**
- Modify: `docs/features/009-camera-and-image-processing/spec.md`
- Modify: `docs/features/009-camera-and-image-processing/contracts.md`
- Modify: `docs/engineering/development-log.md`
- Modify: other directly contradicted documents found during the final documentation scan.

**Interfaces:**
- Produces: documentation matching the new optional crop flow, original-resolution processing, structured locations/conditions, and reviewable OCR.

- [ ] Search documentation for forced crop, 4096-pixel output, automatic autofill, city free text, and default Library routing.
- [ ] Update only documents contradicted by the implemented behavior.
- [ ] Review `git diff` and `git status` without running tests.
- [ ] Stage every workspace change and create one implementation commit.
