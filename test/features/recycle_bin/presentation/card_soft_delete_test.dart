import 'dart:io';

import 'package:cardfolio_app/features/cards/data/card_providers.dart';
import 'package:cardfolio_app/features/cards/data/files/managed_image_store.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:cardfolio_app/features/cards/domain/card_repository.dart';
import 'package:cardfolio_app/features/cards/presentation/detail/card_detail_screen.dart';
import 'package:cardfolio_app/features/recycle_bin/data/recycle_bin_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/fake_recycle_bin_repository.dart';

void main() {
  testWidgets('card detail asks before moving a card to recycle bin', (
    tester,
  ) async {
    final recycleRepository = FakeRecycleBinRepository();
    final imageRoot = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('cardfolio-soft-delete-'),
    ))!;
    final router = GoRouter(
      initialLocation: '/cards/item-1',
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('收藏页')),
        ),
        GoRoute(
          path: '/library',
          builder: (context, state) => const Scaffold(body: Text('收藏页')),
        ),
        GoRoute(
          path: '/cards/:id',
          builder: (context, state) =>
              CardDetailScreen(cardItemId: state.pathParameters['id']!),
        ),
      ],
    );
    addTearDown(() async {
      router.dispose();
      if (imageRoot.existsSync()) {
        await imageRoot.delete(recursive: true);
      }
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cardRepositoryProvider.overrideWithValue(_DetailRepository()),
          recycleBinRepositoryProvider.overrideWithValue(recycleRepository),
          managedImageStoreProvider.overrideWithValue(
            ManagedImageStore(imageRoot),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const Key('delete-card')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('移入回收站？'), findsOneWidget);
    expect(find.textContaining('可以在回收站恢复'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '移入回收站'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(recycleRepository.deletedCardId, 'item-1');
    expect(find.text('收藏页'), findsOneWidget);
  });
}

final class _DetailRepository implements CardRepository {
  final CardDetail _detail = CardDetail(
    cardItemId: 'item-1',
    definitionId: 'definition-1',
    name: '樱花纪念卡',
    quantity: 1,
    createdAt: DateTime.utc(2026, 7, 29),
    updatedAt: DateTime.utc(2026, 7, 29),
    images: const <CardImageRef>[],
  );

  @override
  Stream<CardDetail?> watchCard(String cardItemId) =>
      Stream<CardDetail?>.value(_detail);

  @override
  Stream<List<CardSummary>> watchCards() =>
      Stream<List<CardSummary>>.value(const <CardSummary>[]);

  @override
  Future<void> addImages(AddCardImagesRequest request) async {}

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
  }) async {}

  @override
  Future<ImageDeletionImpact> getImageDeletionImpact({
    required String cardItemId,
    required String imageId,
  }) async => const ImageDeletionImpact(
    imageId: 'image-1',
    byteSize: 0,
    isCover: false,
    remainingImageCount: 0,
  );

  @override
  Future<Set<String>> referencedImagePaths() async => const <String>{};

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
  Future<void> updateImageEdit({
    required String cardItemId,
    required String imageId,
    required String derivedSourcePath,
  }) async {}
}
