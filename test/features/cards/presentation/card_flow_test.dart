import 'dart:async';
import 'dart:io';

import 'package:cardfolio_app/app/app_router.dart';
import 'package:cardfolio_app/app/cardfolio_app.dart';
import 'package:cardfolio_app/core/id/id_generator.dart';
import 'package:cardfolio_app/features/cards/data/card_providers.dart';
import 'package:cardfolio_app/features/cards/data/files/managed_image_store.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:cardfolio_app/features/cards/domain/card_repository.dart';
import 'package:cardfolio_app/features/cards/domain/camera_capture.dart';
import 'package:cardfolio_app/features/cards/domain/gallery_picker.dart';
import 'package:cardfolio_app/features/cards/presentation/create/create_card_controller.dart';
import 'package:cardfolio_app/features/organization/data/organization_providers.dart';
import 'package:cardfolio_app/features/organization/domain/organization_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const SelectedGalleryImage _selectedImage = SelectedGalleryImage(
  path: 'C:/test/card-front.jpg',
  displayName: 'card-front.jpg',
);

final CardSummary _summary = CardSummary(
  cardItemId: 'card-1',
  name: '东京 Metro 樱花纪念卡',
  quantity: 1,
  createdAt: DateTime.utc(2026, 7, 26),
  city: '东京',
  issuedAt: PartialDate.tryParse('2025'),
);

final CardDetail _detail = CardDetail(
  cardItemId: 'card-1',
  definitionId: 'definition-1',
  name: '东京 Metro 樱花纪念卡',
  quantity: 1,
  createdAt: DateTime.utc(2026, 7, 26),
  updatedAt: DateTime.utc(2026, 7, 26),
  images: const <CardImageRef>[],
  city: '东京',
  issuer: 'Tokyo Metro',
  issuedAt: PartialDate.tryParse('2025'),
);

class _FakeGalleryPicker implements GalleryPicker {
  const _FakeGalleryPicker(this.selections);

  final List<SelectedGalleryImage> selections;

  @override
  Future<List<SelectedGalleryImage>> pickMany({required int limit}) async =>
      selections.take(limit).toList(growable: false);

  @override
  Future<List<SelectedGalleryImage>> recoverLost() async =>
      const <SelectedGalleryImage>[];
}

class _FakeCameraCapture implements CameraCapture {
  _FakeCameraCapture(List<CapturedImage?> captures)
    : _captures = List<CapturedImage?>.of(captures);

  final List<CapturedImage?> _captures;

  @override
  Future<CapturedImage?> capture() async =>
      _captures.isEmpty ? null : _captures.removeAt(0);

  @override
  Future<List<CapturedImage>> recoverLost() async => const <CapturedImage>[];
}

class _SequenceIdGenerator implements IdGenerator {
  int _next = 0;

  @override
  String newId() => 'generated-${_next++}';
}

class _FakeCardRepository implements CardRepository {
  _FakeCardRepository({
    List<CardSummary> cards = const <CardSummary>[],
    Map<String, CardDetail> details = const <String, CardDetail>{},
    this.holdSave = false,
  }) : cards = List<CardSummary>.of(cards),
       details = Map<String, CardDetail>.of(details);

  final List<CardSummary> cards;
  final Map<String, CardDetail> details;
  final bool holdSave;
  final Completer<void> saveGate = Completer<void>();
  int createCalls = 0;

  @override
  Future<String> createCard(CreateCardRequest request) async {
    createCalls++;
    if (holdSave) await saveGate.future;

    final id = request.ids.cardItemId;
    final now = DateTime.utc(2026, 7, 26);
    cards.insert(
      0,
      CardSummary(
        cardItemId: id,
        name: request.name,
        quantity: request.quantity,
        createdAt: now,
        city: request.city,
        issuedAt: request.issuedAt,
      ),
    );
    details[id] = CardDetail(
      cardItemId: id,
      definitionId: request.ids.definitionId,
      name: request.name,
      quantity: request.quantity,
      createdAt: now,
      updatedAt: now,
      images: const <CardImageRef>[],
      city: request.city,
      issuer: request.issuer,
      issuedAt: request.issuedAt,
      code: request.code,
      notes: request.notes,
    );
    return id;
  }

  @override
  Future<void> updateCard(UpdateCardRequest request) async {}

  @override
  Future<void> addImages(AddCardImagesRequest request) async {}

  @override
  Future<void> deleteImage({
    required String cardItemId,
    required String imageId,
    required bool keepOriginal,
  }) async {}

  @override
  Future<ImageDeletionImpact> getImageDeletionImpact({
    required String cardItemId,
    required String imageId,
  }) async => const ImageDeletionImpact(
    imageId: 'image-1',
    byteSize: 0,
    isCover: true,
    remainingImageCount: 1,
  );

  @override
  Future<void> reorderImages({
    required String cardItemId,
    required List<String> orderedImageIds,
  }) async {}

  @override
  Future<void> setCover({
    required String cardItemId,
    required String imageId,
  }) async {}

  @override
  Future<void> updateImageKind({
    required String cardItemId,
    required String imageId,
    required CardImageKind kind,
  }) async {}

  @override
  Future<Set<String>> referencedImagePaths() async => const <String>{};

  @override
  Stream<List<CardSummary>> watchCards() =>
      Stream<List<CardSummary>>.value(List<CardSummary>.unmodifiable(cards));

  @override
  Stream<CardDetail?> watchCard(String cardItemId) =>
      Stream<CardDetail?>.value(details[cardItemId]);
}

class CardFlowHarness {
  CardFlowHarness._({
    required this._repository,
    required this.selections,
    required this.captures,
    required this.imageRoot,
  });

  factory CardFlowHarness.empty({
    SelectedGalleryImage? selection = _selectedImage,
    List<SelectedGalleryImage>? selections,
    bool holdSave = false,
    List<CapturedImage?> captures = const <CapturedImage?>[],
  }) {
    return CardFlowHarness._(
      repository: _FakeCardRepository(holdSave: holdSave),
      selections: selections ?? <SelectedGalleryImage>[?selection],
      captures: captures,
      imageRoot: Directory.systemTemp.createTempSync('cardfolio-flow-'),
    );
  }

  factory CardFlowHarness.withCards(List<CardSummary> cards) {
    return CardFlowHarness._(
      repository: _FakeCardRepository(
        cards: cards,
        details: <String, CardDetail>{_detail.cardItemId: _detail},
      ),
      selections: const <SelectedGalleryImage>[_selectedImage],
      captures: const <CapturedImage?>[],
      imageRoot: Directory.systemTemp.createTempSync('cardfolio-flow-'),
    );
  }

  factory CardFlowHarness.withMissingDetail() => CardFlowHarness._(
    repository: _FakeCardRepository(),
    selections: const <SelectedGalleryImage>[_selectedImage],
    captures: const <CapturedImage?>[],
    imageRoot: Directory.systemTemp.createTempSync('cardfolio-flow-'),
  );

  final _FakeCardRepository _repository;
  final List<SelectedGalleryImage> selections;
  final List<CapturedImage?> captures;
  final Directory imageRoot;
  ProviderContainer? _container;

  bool get hasDraft =>
      _container?.read(createCardControllerProvider).hasImage ?? false;

  int get createCalls => _repository.createCalls;

  void completeSave() => _repository.saveGate.complete();

  Future<void> pump(
    WidgetTester tester, {
    String initialLocation = libraryPath,
  }) async {
    _container = ProviderContainer(
      overrides: [
        galleryPickerProvider.overrideWithValue(_FakeGalleryPicker(selections)),
        cameraCaptureProvider.overrideWithValue(_FakeCameraCapture(captures)),
        cardRepositoryProvider.overrideWithValue(_repository),
        managedImageStoreProvider.overrideWithValue(
          ManagedImageStore(imageRoot),
        ),
        idGeneratorProvider.overrideWithValue(_SequenceIdGenerator()),
        organizedCardListProvider.overrideWith(
          (ref) =>
              Stream<List<OrganizedCardSummary>>.value(<OrganizedCardSummary>[
                for (final card in _repository.cards)
                  OrganizedCardSummary(
                    cardItemId: card.cardItemId,
                    definitionId:
                        _repository.details[card.cardItemId]?.definitionId ??
                        'definition-${card.cardItemId}',
                    name: card.name,
                    quantity: card.quantity,
                    createdAt: card.createdAt,
                    needsCompletion: false,
                    tags: const <OrganizationLabel>[],
                    coverRelativePath: card.coverRelativePath,
                    city: card.city,
                    issuedAt: card.issuedAt,
                  ),
              ]),
        ),
        cardFilterFacetsProvider.overrideWith(
          (ref) => Stream<CardFilterFacets>.value(
            const CardFilterFacets(
              cardTypes: <String>[],
              cities: <String>[],
              years: <int>[],
              tags: <TagSummary>[],
            ),
          ),
        ),
        organizationTagsProvider.overrideWith(
          (ref) => Stream<List<TagSummary>>.value(const <TagSummary>[]),
        ),
        organizationSeriesProvider.overrideWith(
          (ref) => Stream<List<SeriesSummary>>.value(const <SeriesSummary>[]),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: _container!,
        child: CardfolioApp(
          router: createAppRouter(initialLocation: initialLocation),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  void dispose() {
    _container?.dispose();
    if (imageRoot.existsSync()) {
      imageRoot.deleteSync(recursive: true);
    }
  }
}

void main() {
  testWidgets('empty library starts gallery import', (tester) async {
    final harness = CardFlowHarness.empty();
    addTearDown(harness.dispose);
    await harness.pump(tester);

    await tester.tap(find.text('从相册导入'));
    await tester.pumpAndSettle();

    expect(find.text('新建卡片'), findsOneWidget);
  });

  testWidgets('single and continuous capture are available', (tester) async {
    final harness = CardFlowHarness.empty();
    addTearDown(harness.dispose);
    await harness.pump(tester, initialLocation: capturePath);

    expect(find.text('拍摄单张卡'), findsOneWidget);
    expect(find.text('单卡多图连拍'), findsOneWidget);
    expect(find.text('批量建卡 / 创建套卡'), findsOneWidget);
  });

  testWidgets('single capture opens the existing card draft', (tester) async {
    final harness = CardFlowHarness.empty(
      captures: const <CapturedImage?>[
        CapturedImage(path: 'C:/test/camera-front.jpg'),
      ],
    );
    addTearDown(harness.dispose);
    await harness.pump(tester, initialLocation: capturePath);

    await tester.tap(find.text('拍摄单张卡'));
    await tester.pumpAndSettle();

    expect(find.text('新建卡片'), findsOneWidget);
    expect(find.text('正反面与其他图片（1 张，可选）'), findsOneWidget);
  });

  testWidgets('continuous capture keeps confirmed images and stops on cancel', (
    tester,
  ) async {
    final harness = CardFlowHarness.empty(
      captures: const <CapturedImage?>[
        CapturedImage(path: 'C:/test/camera-front.jpg'),
        CapturedImage(path: 'C:/test/camera-back.jpg'),
        null,
      ],
    );
    addTearDown(harness.dispose);
    await harness.pump(tester, initialLocation: capturePath);

    await tester.tap(find.text('单卡多图连拍'));
    await tester.pumpAndSettle();

    expect(find.text('新建卡片'), findsOneWidget);
    expect(find.text('正反面与其他图片（2 张，可选）'), findsOneWidget);
  });

  testWidgets('blank card name saves as 未命名卡片', (tester) async {
    final harness = CardFlowHarness.empty();
    addTearDown(harness.dispose);
    await harness.pump(tester, initialLocation: capturePath);
    await tester.tap(find.text('从相册导入'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('未命名卡片'), findsOneWidget);
    expect(harness.createCalls, 1);
  });

  testWidgets('batch entry starts with an empty optional card draft', (
    tester,
  ) async {
    final harness = CardFlowHarness.empty();
    addTearDown(harness.dispose);
    await harness.pump(tester, initialLocation: batchCardEntryPath);

    expect(find.text('批量录入卡片'), findsOneWidget);
    expect(find.text('正面（可选）'), findsOneWidget);
    expect(find.text('背面（可选）'), findsOneWidget);
    expect(find.text('名称（可选）'), findsOneWidget);
    expect(find.text('加入卡册（本批次共用，可多选）'), findsOneWidget);
    expect(find.text('已确认此卡资料'), findsOneWidget);
  });

  testWidgets('saving disables repeated submission', (tester) async {
    final harness = CardFlowHarness.empty(holdSave: true);
    addTearDown(harness.dispose);
    await harness.pump(tester, initialLocation: capturePath);
    await tester.tap(find.text('从相册导入'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('card-name-field')), '樱花纪念卡');

    await tester.tap(find.text('保存'));
    await tester.pump();
    await tester.tap(find.text('保存'), warnIfMissed: false);
    await tester.pump();

    expect(harness.createCalls, 1);
    harness.completeSave();
    await tester.pumpAndSettle();
  });

  testWidgets('successful creation opens card detail', (tester) async {
    final harness = CardFlowHarness.empty();
    addTearDown(harness.dispose);
    await harness.pump(tester, initialLocation: capturePath);
    await tester.tap(find.text('从相册导入'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('card-name-field')), '樱花纪念卡');

    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('卡片详情'), findsOneWidget);
    expect(find.text('樱花纪念卡'), findsOneWidget);
  });

  testWidgets('library renders a persisted card summary', (tester) async {
    final harness = CardFlowHarness.withCards(<CardSummary>[_summary]);
    addTearDown(harness.dispose);
    await harness.pump(tester);

    expect(find.text('东京 Metro 樱花纪念卡'), findsOneWidget);
  });

  testWidgets('missing detail returns to the library', (tester) async {
    final harness = CardFlowHarness.withMissingDetail();
    addTearDown(harness.dispose);
    await harness.pump(tester, initialLocation: '/cards/missing');

    expect(find.text('这张卡片不存在'), findsOneWidget);
    await tester.tap(find.text('返回收藏'));
    await tester.pumpAndSettle();

    expect(find.text('我的收藏'), findsOneWidget);
  });
}
