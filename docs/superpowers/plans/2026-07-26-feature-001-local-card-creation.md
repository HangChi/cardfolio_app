# Feature 001 Local Card Creation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an offline Android-first vertical slice that imports one gallery image, creates a locally persisted card, displays it in the collection and detail screens, and restores it after restart.

**Architecture:** Use a feature-first UI/domain/data split. Riverpod injects dependencies and owns presentation state, Drift is the relational source of truth, a repository coordinates managed image files with database transactions, and go_router connects the Figma-derived screen flow.

**Tech Stack:** Flutter, Dart, flutter_riverpod, Drift/SQLite, drift_flutter, go_router, image_picker, path_provider, uuid, crypto, build_runner, flutter_test.

## Global Constraints

- First acceptance target: Android emulator or physical device.
- Keep production Dart and plugin usage compatible with iOS; defer iOS build and device verification until macOS is available.
- Gallery selection navigates directly to card creation; do not implement crop or enhancement.
- Do not implement camera capture, multi-image capture, sets, tags, purchases, statistics, recycle bin, export, accounts, or sync.
- Store images in the application support directory and persist only relative paths.
- Generate all entity IDs locally as UUIDs.
- Never silently recreate or delete a database after an open or migration failure.
- Run every production change through a failing test, minimal implementation, passing test, and refactor cycle.

---

## File Map

### App and shared infrastructure

- `lib/main.dart`: starts Flutter and renders the bootstrap gate.
- `lib/app/cardfolio_app.dart`: root `MaterialApp.router`.
- `lib/app/app_router.dart`: shell and card routes.
- `lib/app/app_theme.dart`: Cardfolio Material theme.
- `lib/app/bootstrap/app_bootstrap.dart`: initializes database and managed image storage; exposes retryable failure UI.
- `lib/app/navigation/app_shell.dart`: five-destination navigation shell.
- `lib/core/errors/app_failure.dart`: stable failure hierarchy exposed above the data layer.
- `lib/core/id/id_generator.dart`: UUID abstraction.
- `lib/core/time/clock.dart`: current-time abstraction.

### Cards domain

- `lib/features/cards/domain/card_models.dart`: `PartialDate`, `CardDraftIds`, `CreateCardRequest`, `CardSummary`, and `CardDetail`.
- `lib/features/cards/domain/card_repository.dart`: card write/query contract.
- `lib/features/cards/domain/gallery_picker.dart`: gallery selection contract.

### Cards data

- `lib/features/cards/data/local/card_database.dart`: Drift tables, database and schema version.
- `lib/features/cards/data/local/card_database.g.dart`: generated Drift code.
- `lib/features/cards/data/local/card_queries.dart`: Drift query mapping for summary/detail.
- `lib/features/cards/data/files/managed_image_store.dart`: private file import, checksum, resolution and orphan cleanup.
- `lib/features/cards/data/platform/image_picker_gallery.dart`: `image_picker` adapter and lost-data recovery.
- `lib/features/cards/data/card_repository_impl.dart`: file/database orchestration and compensation.
- `lib/features/cards/data/card_providers.dart`: Riverpod dependency bindings.

### Cards presentation

- `lib/features/cards/presentation/create/create_card_state.dart`: immutable draft/save state.
- `lib/features/cards/presentation/create/create_card_controller.dart`: pick, edit, validate and save actions.
- `lib/features/cards/presentation/create/create_card_screen.dart`: Figma “06 新建卡片”.
- `lib/features/cards/presentation/capture/capture_entry_screen.dart`: Figma “04 拍摄入口”.
- `lib/features/cards/presentation/library/card_library_screen.dart`: collection list and empty state.
- `lib/features/cards/presentation/detail/card_detail_screen.dart`: Figma “07 卡片详情”.
- `lib/features/cards/presentation/widgets/card_image.dart`: managed/local preview image widget.
- `lib/features/cards/presentation/widgets/phase_placeholder_screen.dart`: explicit inactive-tab state.

### Tests

- `test/app/cardfolio_app_test.dart`
- `test/features/cards/domain/card_models_test.dart`
- `test/features/cards/data/card_database_test.dart`
- `test/features/cards/data/managed_image_store_test.dart`
- `test/features/cards/data/card_repository_impl_test.dart`
- `test/features/cards/presentation/create_card_controller_test.dart`
- `test/features/cards/presentation/create_card_screen_test.dart`
- `test/features/cards/presentation/card_flow_test.dart`
- `integration_test/card_persistence_test.dart`

---

### Task 1: Establish the runnable app shell

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/main.dart`
- Create: `lib/app/cardfolio_app.dart`
- Create: `lib/app/app_router.dart`
- Create: `lib/app/app_theme.dart`
- Create: `lib/app/navigation/app_shell.dart`
- Create: `lib/features/cards/presentation/widgets/phase_placeholder_screen.dart`
- Modify: `test/widget_test.dart`
- Create: `test/app/cardfolio_app_test.dart`

**Interfaces:**
- Produces: `CardfolioApp({required GoRouter router})`, `createAppRouter({String initialLocation = libraryPath})`, `AppShell`.
- Consumes: Flutter SDK only in the first failing test; package dependencies are added in the implementation step.

- [ ] **Step 1: Replace the counter smoke test with a failing app-title test**

```dart
testWidgets('renders the Cardfolio application shell', (tester) async {
  await tester.pumpWidget(CardfolioApp(router: createAppRouter()));
  await tester.pumpAndSettle();
  expect(find.text('收藏'), findsOneWidget);
  expect(find.text('卡迹'), findsWidgets);
});
```

- [ ] **Step 2: Run the target test and observe the missing app/router failure**

Run: `flutter test test/app/cardfolio_app_test.dart`

Expected: FAIL because `CardfolioApp` and `createAppRouter` do not exist.

- [ ] **Step 3: Add dependencies and the minimal five-tab shell**

Add runtime dependencies for `flutter_riverpod`, `drift`, `drift_flutter`, `go_router`, `image_picker`, `path_provider`, `uuid`, `crypto`, and `path`. Add development dependencies for `drift_dev`, `build_runner`, and `integration_test` from the Flutter SDK.

Use these routes:

```dart
const homePath = '/home';
const libraryPath = '/library';
const capturePath = '/capture';
const statsPath = '/stats';
const profilePath = '/profile';
const createCardPath = '/cards/new';
String cardDetailPath(String id) => '/cards/$id';
```

Set the initial location to `/library`. Render the five labels `首页`, `收藏`, `拍摄`, `统计`, `我的`; use `PhasePlaceholderScreen` for non-card tabs.

- [ ] **Step 4: Run formatting, analysis and shell tests**

Run:

```powershell
dart format lib test
flutter analyze
flutter test test/app/cardfolio_app_test.dart
```

Expected: all commands exit 0 and the shell test passes.

- [ ] **Step 5: Commit the shell**

```powershell
git add -- pubspec.yaml pubspec.lock lib/main.dart lib/app lib/features/cards/presentation/widgets test/widget_test.dart test/app/cardfolio_app_test.dart
git commit -m "Build Cardfolio app shell"
```

### Task 2: Define card domain values and repository contracts

**Files:**
- Create: `lib/core/errors/app_failure.dart`
- Create: `lib/core/id/id_generator.dart`
- Create: `lib/core/time/clock.dart`
- Create: `lib/features/cards/domain/card_models.dart`
- Create: `lib/features/cards/domain/card_repository.dart`
- Create: `lib/features/cards/domain/gallery_picker.dart`
- Create: `test/features/cards/domain/card_models_test.dart`

**Interfaces:**
- Produces:
  - `PartialDate.tryParse(String): PartialDate?`
  - `CardDraftIds.create(IdGenerator): CardDraftIds`
  - `CreateCardRequest.normalized(): CreateCardRequest`
  - `abstract interface class CardRepository`
  - `abstract interface class GalleryPicker`
- Consumes: none from Task 1.

- [ ] **Step 1: Write failing domain tests**

Cover these exact behaviors:

```dart
test('trims the required name and optional text fields', () {
  final normalized = request(name: '  樱花纪念卡  ', city: ' 东京 ').normalized();
  expect(normalized.name, '樱花纪念卡');
  expect(normalized.city, '东京');
});

test('rejects a blank name', () {
  expect(() => request(name: '  ').normalized(), throwsA(isA<ValidationFailure>()));
});

test('supports year, year-month, and full partial dates', () {
  expect(PartialDate.tryParse('2025')?.toIsoString(), '2025');
  expect(PartialDate.tryParse('2025-07')?.toIsoString(), '2025-07');
  expect(PartialDate.tryParse('2025-07-26')?.toIsoString(), '2025-07-26');
  expect(PartialDate.tryParse('2025-13'), isNull);
});
```

- [ ] **Step 2: Run the domain test and observe missing types**

Run: `flutter test test/features/cards/domain/card_models_test.dart`

Expected: FAIL because the domain files and types do not exist.

- [ ] **Step 3: Implement immutable domain models and stable failures**

Define:

```dart
sealed class AppFailure implements Exception {
  const AppFailure(this.userMessage, [this.cause]);
  final String userMessage;
  final Object? cause;
}

abstract interface class CardRepository {
  Stream<List<CardSummary>> watchCards();
  Stream<CardDetail?> watchCard(String cardItemId);
  Future<String> createCard(CreateCardRequest request);
  Future<Set<String>> referencedImagePaths();
}

abstract interface class GalleryPicker {
  Future<SelectedGalleryImage?> pickOne();
  Future<SelectedGalleryImage?> recoverLost();
}
```

Keep `CardSummary` and `CardDetail` free of Flutter, Drift and `dart:io` types.

- [ ] **Step 4: Run domain tests**

Run: `flutter test test/features/cards/domain/card_models_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit domain contracts**

```powershell
git add -- lib/core lib/features/cards/domain test/features/cards/domain
git commit -m "Define card domain contracts"
```

### Task 3: Create the Drift schema and reactive card queries

**Files:**
- Create: `lib/features/cards/data/local/card_database.dart`
- Generate: `lib/features/cards/data/local/card_database.g.dart`
- Create: `lib/features/cards/data/local/card_queries.dart`
- Create: `test/features/cards/data/card_database_test.dart`
- Create: `drift_schemas/`
- Create: `build.yaml`

**Interfaces:**
- Produces:
  - `AppDatabase(QueryExecutor executor)`
  - `AppDatabase.defaults()`
  - `Future<void> insertCardGraph(CreateCardRowGraph graph)`
  - `Stream<List<CardSummary>> watchCardSummaries()`
  - `Stream<CardDetail?> watchCardDetail(String cardItemId)`
  - `Future<bool> cardItemExists(String id)`
  - `Future<Set<String>> referencedImagePaths()`
- Consumes: domain models from Task 2.

- [ ] **Step 1: Write failing in-memory database tests**

Test:

```dart
late AppDatabase db;

setUp(() {
  db = AppDatabase(NativeDatabase.memory());
});

tearDown(() => db.close());

test('inserts and watches a complete card graph', () async {
  await db.insertCardGraph(exampleGraph());
  final summaries = await db.watchCardSummaries().first;
  expect(summaries.single.name, '樱花纪念卡');
  expect(summaries.single.quantity, 1);
});

test('rolls back all rows when image insertion fails', () async {
  await expectLater(db.insertCardGraph(graphWithInvalidImageForeignKey()), throwsA(anything));
  expect(await db.countDefinitions(), 0);
  expect(await db.countItems(), 0);
  expect(await db.countImages(), 0);
});
```

- [ ] **Step 2: Run the database test and observe missing database failures**

Run: `flutter test test/features/cards/data/card_database_test.dart`

Expected: FAIL because `AppDatabase` and the schema do not exist.

- [ ] **Step 3: Implement schema version 1**

Create Drift tables named `CardDefinitions`, `CardItems`, and `CardImages`. Use text primary keys, required timestamps, nullable text for optional fields, an integer quantity with a `CHECK quantity > 0`, foreign keys with explicit indexes, and a unique `relativePath` for images. Enable SQLite foreign keys in `beforeOpen`.

Use one Drift `transaction` for all three inserts. Put summary/detail joins in `card_queries.dart` and map database rows into domain read models.

- [ ] **Step 4: Generate code and the schema baseline**

Run:

```powershell
dart run build_runner build --delete-conflicting-outputs
dart run drift_dev make-migrations
```

Expected: `card_database.g.dart` and schema-v1 artifacts are generated without diagnostics.

- [ ] **Step 5: Run database tests and analysis**

Run:

```powershell
flutter test test/features/cards/data/card_database_test.dart
flutter analyze
```

Expected: PASS and exit 0.

- [ ] **Step 6: Commit the database**

```powershell
git add -- lib/features/cards/data/local test/features/cards/data/card_database_test.dart drift_schemas build.yaml
git commit -m "Add local card database"
```

### Task 4: Coordinate managed images and transactional card creation

**Files:**
- Create: `lib/features/cards/data/files/managed_image_store.dart`
- Create: `lib/features/cards/data/card_repository_impl.dart`
- Create: `test/features/cards/data/managed_image_store_test.dart`
- Create: `test/features/cards/data/card_repository_impl_test.dart`

**Interfaces:**
- Produces:
  - `ManagedImageStore(Directory root)`
  - `Future<ManagedImage> importImage(String sourcePath, String imageId)`
  - `Future<void> delete(String relativePath)`
  - `Future<void> removeOrphans(Set<String> referencedPaths)`
  - `File resolve(String relativePath)`
  - `CardRepositoryImpl(AppDatabase, ManagedImageStore, Clock)`
- Consumes: `CreateCardRequest`, `CardRepository`, and `AppDatabase`.

- [ ] **Step 1: Write failing managed-image tests**

Test that importing copies bytes under `cards/<imageId>.<extension>`, returns a SHA-256 checksum, resolves the relative path, rejects unreadable sources, and deletes only files absent from the referenced-path set.

- [ ] **Step 2: Run the image-store tests and observe missing implementation**

Run: `flutter test test/features/cards/data/managed_image_store_test.dart`

Expected: FAIL because `ManagedImageStore` does not exist.

- [ ] **Step 3: Implement the minimal managed image store**

Use `Directory.create(recursive: true)`, streamed SHA-256 hashing, extension normalization to `.jpg`, `.jpeg`, `.png`, `.webp`, or `.heic`, and path containment checks before every delete. Throw `ImageImportFailure` for unreadable or unsupported input.

- [ ] **Step 4: Run image-store tests**

Run: `flutter test test/features/cards/data/managed_image_store_test.dart`

Expected: PASS.

- [ ] **Step 5: Write failing repository compensation and idempotency tests**

Test:

```dart
test('deletes the copied image when the database transaction fails', () async {
  await expectLater(repository.createCard(validRequest), throwsA(isA<PersistenceFailure>()));
  expect(await managedFile.exists(), isFalse);
});

test('returns the existing item for a repeated draft id', () async {
  final first = await repository.createCard(validRequest);
  final second = await repository.createCard(validRequest);
  expect(second, first);
  expect(await db.countItems(), 1);
});
```

- [ ] **Step 6: Implement repository orchestration**

Normalize and validate the request, check `cardItemExists` before copying, import the image to its deterministic final path, insert the graph in one transaction, and delete the copied file on non-idempotent database failure. Map filesystem and Drift exceptions into `AppFailure` subclasses.

- [ ] **Step 7: Run repository and database tests**

Run:

```powershell
flutter test test/features/cards/data/card_repository_impl_test.dart
flutter test test/features/cards/data/card_database_test.dart
```

Expected: PASS.

- [ ] **Step 8: Commit repository and image storage**

```powershell
git add -- lib/features/cards/data/files lib/features/cards/data/card_repository_impl.dart test/features/cards/data
git commit -m "Persist card images and records atomically"
```

### Task 5: Add gallery selection and create-card state

**Files:**
- Create: `lib/features/cards/data/platform/image_picker_gallery.dart`
- Create: `lib/features/cards/data/card_providers.dart`
- Create: `lib/features/cards/presentation/create/create_card_state.dart`
- Create: `lib/features/cards/presentation/create/create_card_controller.dart`
- Create: `test/features/cards/presentation/create_card_controller_test.dart`

**Interfaces:**
- Produces:
  - `ImagePickerGallery(ImagePicker picker)`
  - Riverpod providers for database, repository, image store, picker, ID generator, clock and card streams.
  - `CreateCardController.pickImage()`
  - `CreateCardController.recoverLostImage()`
  - `CreateCardController.updateName(String)`
  - optional-field update methods
  - `CreateCardController.save(): Future<String?>`
- Consumes: Task 2 contracts and Task 4 repository.

- [ ] **Step 1: Write failing controller tests with fakes**

Cover:

- cancelled picker leaves the draft empty;
- selected image creates stable IDs exactly once;
- blank name exposes `名称不能为空` and does not call the repository;
- a second `save` call during an active save does not call the repository twice;
- successful save returns the item ID and clears the failure;
- repository failure preserves draft input and exposes the stable user message;
- recovered Android lost data follows the same selected-image path.

- [ ] **Step 2: Run controller tests and observe missing state/controller failures**

Run: `flutter test test/features/cards/presentation/create_card_controller_test.dart`

Expected: FAIL because the controller and providers do not exist.

- [ ] **Step 3: Implement the image-picker adapter**

Use `ImagePicker.pickImage(source: ImageSource.gallery)` and `retrieveLostData()`. Return `null` for cancellation and no lost file. Convert `PlatformException` and picker errors to `GalleryAccessFailure`.

- [ ] **Step 4: Implement immutable create state and Riverpod controller**

Use these phases: `idle`, `selecting`, `editing`, `saving`, `saved`, `failure`. Store `SelectedGalleryImage`, `CardDraftIds`, input fields, field errors and an optional `AppFailure`. Keep the save guard in the controller, not the widget.

- [ ] **Step 5: Run controller tests**

Run: `flutter test test/features/cards/presentation/create_card_controller_test.dart`

Expected: PASS.

- [ ] **Step 6: Commit selection and state**

```powershell
git add -- lib/features/cards/data/platform lib/features/cards/data/card_providers.dart lib/features/cards/presentation/create test/features/cards/presentation/create_card_controller_test.dart
git commit -m "Add gallery card creation state"
```

### Task 6: Implement the Figma-derived card screens

**Files:**
- Create: `lib/features/cards/presentation/widgets/card_image.dart`
- Create: `lib/features/cards/presentation/capture/capture_entry_screen.dart`
- Create: `lib/features/cards/presentation/create/create_card_screen.dart`
- Create: `lib/features/cards/presentation/library/card_library_screen.dart`
- Create: `lib/features/cards/presentation/detail/card_detail_screen.dart`
- Modify: `lib/app/app_router.dart`
- Modify: `lib/app/app_theme.dart`
- Create: `test/features/cards/presentation/create_card_screen_test.dart`
- Create: `test/features/cards/presentation/card_flow_test.dart`

**Interfaces:**
- Produces: functional `/library`, `/capture`, `/cards/new`, and `/cards/:id` screens.
- Consumes: card providers, controller and routes from earlier tasks.

- [ ] **Step 1: Load Figma design-to-code context before UI work**

Use file `AIiGFgVmQYrd8WqTPxHy0S` and nodes `3:71`, `3:137`, `3:211`, and `3:253`. Extract layout, typography, colors, spacing, corner radii and component states. If visual context remains unavailable, implement from the already retrieved node dimensions and text hierarchy, record that limitation, and do not invent additional screens.

- [ ] **Step 2: Write failing widget tests**

Cover:

```dart
testWidgets('empty library starts gallery import', (tester) async {
  final harness = CardFlowHarness.empty(selection: selectedImage);
  await harness.pump(tester);
  await tester.tap(find.text('从相册导入'));
  await tester.pumpAndSettle();
  expect(find.text('新建卡片'), findsOneWidget);
});

testWidgets('disabled capture modes announce 后续开放', (tester) async {
  final harness = CardFlowHarness.empty();
  await harness.pump(tester, initialLocation: '/capture');
  expect(find.text('后续开放'), findsNWidgets(3));
});

testWidgets('blank card name shows 名称不能为空', (tester) async {
  final harness = CardFlowHarness.editing(selectedImage);
  await harness.pump(tester, initialLocation: '/cards/new');
  await tester.tap(find.text('保存'));
  await tester.pump();
  expect(find.text('名称不能为空'), findsOneWidget);
  expect(harness.repository.createCalls, 0);
});

testWidgets('saving disables repeated submission', (tester) async {
  final harness = CardFlowHarness.editing(selectedImage, holdSave: true);
  await harness.pump(tester, initialLocation: '/cards/new');
  await tester.enterText(find.byKey(const Key('card-name-field')), '樱花纪念卡');
  await tester.tap(find.text('保存'));
  await tester.tap(find.text('保存'), warnIfMissed: false);
  expect(harness.repository.createCalls, 1);
});

testWidgets('successful creation opens card detail', (tester) async {
  final harness = CardFlowHarness.editing(selectedImage);
  await harness.pump(tester, initialLocation: '/cards/new');
  await tester.enterText(find.byKey(const Key('card-name-field')), '樱花纪念卡');
  await tester.tap(find.text('保存'));
  await tester.pumpAndSettle();
  expect(find.text('卡片详情'), findsOneWidget);
  expect(find.text('樱花纪念卡'), findsOneWidget);
});

testWidgets('library renders the persisted card summary', (tester) async {
  final harness = CardFlowHarness.withCards([cardSummary]);
  await harness.pump(tester, initialLocation: '/library');
  await tester.pump();
  expect(find.text('樱花纪念卡'), findsOneWidget);
});

testWidgets('missing detail returns to the library', (tester) async {
  final harness = CardFlowHarness.withMissingDetail();
  await harness.pump(tester, initialLocation: '/cards/missing');
  await tester.pumpAndSettle();
  expect(find.text('这张卡片不存在'), findsOneWidget);
  await tester.tap(find.text('返回收藏'));
  await tester.pumpAndSettle();
  expect(find.text('我的收藏'), findsOneWidget);
});
```

Create `CardFlowHarness` inside `card_flow_test.dart`. It must build a `ProviderScope` with overrides for the picker, repository, managed image resolver and query streams, then wrap `CardfolioApp(router: createAppRouter(initialLocation: initialLocation))`. Do not invoke platform plugins in widget tests.

- [ ] **Step 3: Run widget tests and observe missing screen failures**

Run:

```powershell
flutter test test/features/cards/presentation/create_card_screen_test.dart
flutter test test/features/cards/presentation/card_flow_test.dart
```

Expected: FAIL because the functional card screens are not implemented.

- [ ] **Step 4: Implement capture and create screens**

Match the 393×852 Figma layout responsively rather than hard-coding device dimensions. Preserve the visual hierarchy and Chinese copy. Only “从相册导入” is active. On selection success navigate to `/cards/new`; on save success replace the route with `/cards/<id>`.

- [ ] **Step 5: Implement library and detail screens**

Render loading, empty, data and failure states. Resolve managed image paths through `ManagedImageStore`; provide a semantic fallback when a file is unavailable. Exclude soft-deleted rows through the database query.

- [ ] **Step 6: Run widget tests, gold-free layout checks and analysis**

Run:

```powershell
dart format lib test
flutter test test/features/cards/presentation
flutter analyze
```

Expected: PASS with no overflow exceptions in widget tests.

- [ ] **Step 7: Commit the card UI**

```powershell
git add -- lib/app lib/features/cards/presentation test/features/cards/presentation
git commit -m "Build local card creation flow"
```

### Task 7: Bootstrap, persistence restart and final verification

**Files:**
- Create: `lib/app/bootstrap/app_bootstrap.dart`
- Modify: `lib/main.dart`
- Modify: `lib/features/cards/data/card_providers.dart`
- Create: `integration_test/card_persistence_test.dart`
- Modify: `README.md`
- Modify: `docs/superpowers/specs/2026-07-26-feature-001-local-card-creation-design.md`

**Interfaces:**
- Produces: retryable startup, orphan cleanup, persistent dependency scope and Android acceptance test.
- Consumes: all preceding tasks.

- [ ] **Step 1: Write a failing bootstrap/restart integration test**

The test must:

1. create a temporary on-disk Drift database and managed image directory;
2. create one card through `CardRepository`;
3. close the database;
4. construct a new database and repository using the same paths;
5. assert that `watchCards().first` returns the card and the managed image still exists.

- [ ] **Step 2: Run the persistence test and observe the missing bootstrap behavior**

Run: `flutter test integration_test/card_persistence_test.dart`

Expected: FAIL until dependency initialization and restart-safe paths are implemented.

- [ ] **Step 3: Implement retryable bootstrap**

Initialize bindings, application support directory, image root and Drift database before rendering `CardfolioApp`. Query referenced image paths and call orphan cleanup. On failure, keep the original files untouched and show a full-screen `重试` action that reruns initialization.

- [ ] **Step 4: Update README with exact local commands**

Document:

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run
```

Also document Android-first acceptance and the deferred macOS/iOS verification.

- [ ] **Step 5: Run the complete verification suite**

Run:

```powershell
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
flutter test integration_test/card_persistence_test.dart
flutter build apk --debug
git diff --check
```

Expected: every command exits 0; all tests report zero failures; the debug APK builds successfully.

- [ ] **Step 6: Perform Android manual acceptance**

On an Android emulator or device:

1. launch with an empty database;
2. open 拍摄 and choose 从相册导入;
3. cancel once and verify no card is created;
4. select a valid image;
5. attempt blank-name save and verify inline validation;
6. enter a name and rapidly tap save twice;
7. verify one detail record and one collection row;
8. force-stop and relaunch;
9. verify the card and image remain available.

- [ ] **Step 7: Commit the completed vertical slice**

```powershell
git add -- lib test integration_test README.md docs pubspec.yaml pubspec.lock drift_schemas build.yaml
git commit -m "Complete local card creation slice"
```
