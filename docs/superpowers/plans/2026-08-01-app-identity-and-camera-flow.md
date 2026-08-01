# 卡迹应用标识与拍摄流程调整 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. The user explicitly prohibited subagents, branch creation, and test execution.

**Goal:** 将应用显示名和启动器图标统一为“卡迹”，删除重复成本入口，并让新建、已有卡片及批量建卡的相机图片都支持拍后裁剪与继续拍摄。

**Architecture:** 保留现有 `CameraCapture`、`ImageProcessor`、`ImageEditorScreen` 和 `CardRepository` 边界，在界面层统一图片来源选择和拍后编辑编排。原图与派生图继续通过 `PendingCardImage` 进入现有受管图片仓库，不修改数据库结构。

**Tech Stack:** Flutter、Riverpod、go_router、image_picker、现有本地图片处理管线，以及 Android/iOS/macOS/Windows/Linux/Web 平台工程资源。

## Global Constraints

- 不创建或切换分支。
- 不调用子智能体。
- 不运行测试、构建或格式化命令；只做静态差异和资源检查。
- 保留现有包名、Bundle Identifier、二进制名称、Dart package 名和数据库结构。
- 单卡图片上限继续使用 `CreateCardRequest.maxImages`（20 张）。
- 所有本次改动与文档在完成后统一提交一次。

---

### Task 1: 统一应用名称与启动器图标

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `ios/Runner/Info.plist`
- Modify: `macos/Runner/Configs/AppInfo.xcconfig`
- Modify: `windows/runner/main.cpp`
- Modify: `windows/runner/Runner.rc`
- Modify: `linux/runner/my_application.cc`
- Modify: `web/manifest.json`
- Modify: `web/index.html`
- Replace: `android/app/src/main/res/mipmap-*/ic_launcher.png`
- Replace: `ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png`
- Replace: `macos/Runner/Assets.xcassets/AppIcon.appiconset/*.png`
- Replace: `windows/runner/resources/app_icon.ico`
- Replace: `web/favicon.png`, `web/icons/*.png`

**Interfaces:**
- Consumes: existing platform launcher metadata and the repository’s dark-green “卡” visual identity.
- Produces: user-visible name `卡迹` and one consistent launcher icon family without changing application identifiers.

- [ ] Generate one square 1024×1024 opaque master icon: dark green rounded-square field, centered white “卡” mark, restrained cream/orange transit-card details, no Latin text, readable at 20 px.
- [ ] Inspect the master icon, then resize it to every size already declared by Android, iOS, macOS and Web; create the Windows `.ico` from 16/32/48/64/128/256 pixel variants.
- [ ] Change only user-visible title/name fields to `卡迹`; keep internal names such as `cardfolio_app`, application IDs and executable names unchanged.
- [ ] Compare the generated filenames with each platform’s existing manifest or asset catalog so no required slot is missing.

### Task 2: 单卡拍摄与新建页多图来源

**Files:**
- Modify: `lib/features/cards/presentation/capture/capture_entry_screen.dart`
- Modify: `lib/features/cards/presentation/create/create_card_controller.dart`
- Modify: `lib/features/cards/presentation/create/create_card_screen.dart`

**Interfaces:**
- Consumes: `CreateCardController.captureImage({bool append = false})`, `ImageEditorRouteArgs`, `ProcessedImage`.
- Produces: `CreateCardController.discardImage(String imageId)` for canceled/failed capture editing, and a shared UI flow that captures, crops, then keeps the new draft image.

- [ ] Remove the “单卡多图连拍” option and continuous-entry callback from the capture screen.
- [ ] After the first `captureImage()`, push `imageEditorPath` with the new draft’s source path and ID; apply `ProcessedImage.path` before opening `createCardPath`; if the editor is canceled, remove that captured draft image and stay on the capture screen.
- [ ] Add `discardImage(String imageId)` to remove an unsaved draft image without changing other draft fields or IDs.
- [ ] Replace create-page gallery-only add buttons with a bottom-sheet source chooser containing “拍摄” and “从相册选择”.
- [ ] For camera additions, append one captured draft, open the editor immediately, apply the derived path on completion, and discard only that new draft when editing is canceled.
- [ ] Keep gallery multi-select and the existing per-image manual editor unchanged.

### Task 3: 已有卡片与批量建卡的拍后裁剪

**Files:**
- Modify: `lib/features/cards/presentation/detail/card_detail_screen.dart`
- Modify: `lib/features/cards/presentation/batch/batch_card_entry_screen.dart`

**Interfaces:**
- Consumes: `cameraCaptureProvider`, `galleryPickerProvider`, `ImageEditorRouteArgs`, `AddCardImagesRequest`, `PendingCardImage(derivedSourcePath: ...)`.
- Produces: consistent source selection for existing cards and derived image paths for every newly captured existing/batch image.

- [ ] Change existing-card “添加图片” to choose camera or gallery.
- [ ] For camera, capture one source, push the image editor, and call `addImages` only after a processed image is returned, passing both `sourcePath` and `derivedSourcePath`.
- [ ] Preserve gallery multi-select and existing failure messages.
- [ ] Extend the batch draft with `frontDerivedPath` and `backDerivedPath`, include both fields in JSON persistence, and pass them through `CreateCardRequest.derivedSourceImagePath` / `PendingCardImage.derivedSourcePath`.
- [ ] In batch entry, after selecting the camera source, push the editor before assigning the front/back draft; retain the original source path and store the processed result in the matching derived-path field.
- [ ] Treat camera or editor cancellation as a no-op and retain all earlier draft data.

### Task 4: 删除重复入口并同步文档

**Files:**
- Modify: `lib/features/cards/presentation/detail/card_detail_screen.dart`
- Modify: `README.md`
- Modify: `docs/features/009-camera-and-image-processing/spec.md`
- Modify: `docs/features/009-camera-and-image-processing/ux-mapping.md`
- Modify: `docs/engineering/development-log.md`

**Interfaces:**
- Consumes: confirmed behavior in `docs/superpowers/specs/2026-08-01-app-identity-and-camera-flow-design.md`.
- Produces: one “编辑资料” route to cost editing and documentation matching the implemented camera/crop workflow.

- [ ] Remove only the duplicate “记录入手成本” button from card details; keep the cost fields, providers and save behavior in the edit screen.
- [ ] Replace “单张/连续拍摄” documentation with the single-card multi-image workflow and state that each camera image enters cropping before it is retained.
- [ ] Record the display-name/logo update and the camera-source additions in the development log.

### Task 5: 静态审阅并统一提交

**Files:**
- Review: all files changed by Tasks 1–4 plus pre-existing user changes shown by `git status`.

**Interfaces:**
- Consumes: repository diff and platform resource declarations.
- Produces: one commit containing only this feature’s files, while preserving and excluding unrelated pre-existing changes.

- [ ] Run `git diff --check` and targeted `rg` searches for stale user-visible strings; do not run tests, builds, analyzers or formatters.
- [ ] Review `git diff --stat`, image dimensions, icon filenames, and the exact staged-file list.
- [ ] Stage only this feature’s code, platform metadata/resources and documentation; exclude unrelated pre-existing changes.
- [ ] Commit once with message `Improve app identity and camera workflows`.
