import 'dart:io';

import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/core/id/id_generator.dart';
import 'package:cardfolio_app/features/cards/data/card_providers.dart';
import 'package:cardfolio_app/features/cards/data/files/managed_image_store.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:cardfolio_app/features/cards/domain/card_repository.dart';
import 'package:cardfolio_app/features/cards/domain/gallery_picker.dart';
import 'package:cardfolio_app/features/cards/presentation/detail/card_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final CardDetail detail = CardDetail(
  cardItemId: 'item-1',
  definitionId: 'definition-1',
  name: '樱花纪念卡',
  quantity: 1,
  createdAt: DateTime.utc(2026, 7, 28),
  updatedAt: DateTime.utc(2026, 7, 28),
  images: const <CardImageRef>[
    CardImageRef(
      id: 'image-1',
      relativePath: 'originals/item-1/image-1.jpg',
      kind: CardImageKind.front,
      sortOrder: 0,
      isCover: true,
    ),
    CardImageRef(
      id: 'image-2',
      relativePath: 'originals/item-1/image-2.jpg',
      kind: CardImageKind.back,
      sortOrder: 1,
    ),
    CardImageRef(
      id: 'image-3',
      relativePath: 'originals/item-1/image-3.jpg',
      kind: CardImageKind.packaging,
      sortOrder: 2,
    ),
  ],
);

class FakeDetailRepository implements CardRepository {
  String? coverImageId;
  String? deletedImageId;
  bool? keepOriginal;
  AddCardImagesRequest? addRequest;
  List<String>? orderedIds;
  CardImageKind? updatedKind;

  @override
  Stream<CardDetail?> watchCard(String cardItemId) =>
      Stream<CardDetail?>.value(detail);

  @override
  Stream<List<CardSummary>> watchCards() =>
      Stream<List<CardSummary>>.value(const <CardSummary>[]);

  @override
  Future<void> addImages(AddCardImagesRequest request) async {
    addRequest = request;
  }

  @override
  Future<String> createCard(CreateCardRequest request) async =>
      request.ids.cardItemId;

  @override
  Future<void> updateCard(UpdateCardRequest request) async {}

  @override
  Future<void> deleteImage({
    required String cardItemId,
    required String imageId,
    required bool keepOriginal,
  }) async {
    deletedImageId = imageId;
    this.keepOriginal = keepOriginal;
  }

  @override
  Future<ImageDeletionImpact> getImageDeletionImpact({
    required String cardItemId,
    required String imageId,
  }) async => ImageDeletionImpact(
    imageId: imageId,
    byteSize: 2048,
    isCover: imageId == 'image-1',
    remainingImageCount: 2,
  );

  @override
  Future<Set<String>> referencedImagePaths() async => const <String>{};

  @override
  Future<void> reorderImages({
    required String cardItemId,
    required List<String> orderedImageIds,
  }) async {
    orderedIds = orderedImageIds;
  }

  @override
  Future<void> setCover({
    required String cardItemId,
    required String imageId,
  }) async {
    coverImageId = imageId;
  }

  @override
  Future<void> updateImageKind({
    required String cardItemId,
    required String imageId,
    required CardImageKind kind,
  }) async {
    updatedKind = kind;
  }

  @override
  Future<void> updateImageEdit({
    required String cardItemId,
    required String imageId,
    required String derivedSourcePath,
  }) async {}
}

class FakeDetailPicker implements GalleryPicker {
  const FakeDetailPicker({this.failure});

  final AppFailure? failure;

  @override
  Future<List<SelectedGalleryImage>> pickMany({required int limit}) async {
    if (failure != null) throw failure!;
    return const <SelectedGalleryImage>[
      SelectedGalleryImage(path: 'C:/test/detail.jpg'),
    ];
  }

  @override
  Future<List<SelectedGalleryImage>> recoverLost() async =>
      const <SelectedGalleryImage>[];
}

class FixedIdGenerator implements IdGenerator {
  @override
  String newId() => 'image-4';
}

void main() {
  late FakeDetailRepository repository;
  late GalleryPicker picker;
  late Directory root;

  setUp(() async {
    repository = FakeDetailRepository();
    picker = const FakeDetailPicker();
    root = await Directory.systemTemp.createTemp('cardfolio-detail-');
  });

  tearDown(() async {
    if (root.existsSync()) await root.delete(recursive: true);
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cardRepositoryProvider.overrideWithValue(repository),
          galleryPickerProvider.overrideWithValue(picker),
          idGeneratorProvider.overrideWithValue(FixedIdGenerator()),
          managedImageStoreProvider.overrideWithValue(ManagedImageStore(root)),
        ],
        child: const MaterialApp(home: CardDetailScreen(cardItemId: 'item-1')),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> showSecondImage(WidgetTester tester) async {
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the ordered gallery with kind and cover semantics', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('正面 · 封面'), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.byKey(const Key('manage-image-image-1')), findsOneWidget);

    await showSecondImage(tester);

    expect(find.text('背面'), findsOneWidget);
    expect(find.text('2 / 3'), findsOneWidget);
    expect(find.byKey(const Key('manage-image-image-2')), findsOneWidget);
  });

  testWidgets('sets a different cover without reordering', (tester) async {
    await pump(tester);

    await showSecondImage(tester);
    await tester.tap(find.byKey(const Key('manage-image-image-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('设为封面'));
    await tester.pumpAndSettle();

    expect(repository.coverImageId, 'image-2');
    expect(repository.orderedIds, isNull);
  });

  testWidgets('delete confirmation defaults to retaining the original', (
    tester,
  ) async {
    await pump(tester);

    await showSecondImage(tester);
    await tester.tap(find.byKey(const Key('manage-image-image-2')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('移除图片'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('移除图片'));
    await tester.pumpAndSettle();

    expect(find.textContaining('2 KB'), findsOneWidget);
    await tester.tap(find.text('移除并保留原图'));
    await tester.pumpAndSettle();

    expect(repository.deletedImageId, 'image-2');
    expect(repository.keepOriginal, isTrue);
  });

  testWidgets('adds selected gallery images with generated ids', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.byTooltip('添加图片'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('从相册选择'));
    await tester.pumpAndSettle();

    expect(repository.addRequest?.cardItemId, 'item-1');
    expect(repository.addRequest?.images.single.id, 'image-4');
    expect(repository.addRequest?.images.single.kind, CardImageKind.other);
  });

  testWidgets('shows a stable failure when the gallery cannot open', (
    tester,
  ) async {
    picker = const FakeDetailPicker(failure: GalleryAccessFailure());
    await pump(tester);

    await tester.tap(find.byTooltip('添加图片'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('从相册选择'));
    await tester.pumpAndSettle();

    expect(find.text('无法访问相册，请检查权限后重试。'), findsOneWidget);
    expect(repository.addRequest, isNull);
  });
}
