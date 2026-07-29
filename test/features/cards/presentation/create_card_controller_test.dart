import 'dart:async';

import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/core/id/id_generator.dart';
import 'package:cardfolio_app/features/cards/data/card_providers.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:cardfolio_app/features/cards/domain/card_repository.dart';
import 'package:cardfolio_app/features/cards/domain/camera_capture.dart';
import 'package:cardfolio_app/features/cards/domain/gallery_picker.dart';
import 'package:cardfolio_app/features/cards/presentation/create/create_card_controller.dart';
import 'package:cardfolio_app/features/cards/presentation/create/create_card_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const SelectedGalleryImage selectedImage = SelectedGalleryImage(
  path: '/tmp/IMG_0001.jpg',
  displayName: 'IMG_0001.jpg',
);

class FakeGalleryPicker implements GalleryPicker {
  FakeGalleryPicker({
    SelectedGalleryImage? selection,
    List<SelectedGalleryImage>? selections,
    SelectedGalleryImage? lost,
    List<SelectedGalleryImage>? lostSelections,
    this.error,
    this.ignoreLimit = false,
  }) : selections = selections ?? <SelectedGalleryImage>[?selection],
       lostSelections = lostSelections ?? <SelectedGalleryImage>[?lost];

  final List<SelectedGalleryImage> selections;
  final List<SelectedGalleryImage> lostSelections;
  final AppFailure? error;
  final bool ignoreLimit;

  int pickCalls = 0;
  int recoverCalls = 0;

  @override
  Future<List<SelectedGalleryImage>> pickMany({required int limit}) async {
    pickCalls++;
    if (error != null) throw error!;
    return (ignoreLimit ? selections : selections.take(limit)).toList(
      growable: false,
    );
  }

  @override
  Future<List<SelectedGalleryImage>> recoverLost() async {
    recoverCalls++;
    return lostSelections;
  }
}

class FakeCameraCapture implements CameraCapture {
  FakeCameraCapture({
    List<CapturedImage?>? captures,
    List<CapturedImage>? lost,
    this.error,
  }) : captures = captures ?? <CapturedImage?>[],
       lost = lost ?? <CapturedImage>[];

  final List<CapturedImage?> captures;
  final List<CapturedImage> lost;
  final AppFailure? error;
  int captureCalls = 0;

  @override
  Future<CapturedImage?> capture() async {
    captureCalls++;
    if (error != null) throw error!;
    if (captures.isEmpty) return null;
    return captures.removeAt(0);
  }

  @override
  Future<List<CapturedImage>> recoverLost() async => lost;
}

class FakeCardRepository implements CardRepository {
  FakeCardRepository({this.failure, this.hold = false});

  final AppFailure? failure;
  final bool hold;

  final Completer<void> gate = Completer<void>();
  final List<CreateCardRequest> requests = <CreateCardRequest>[];

  int get createCalls => requests.length;

  @override
  Future<String> createCard(CreateCardRequest request) async {
    requests.add(request);
    if (hold) await gate.future;
    if (failure != null) throw failure!;
    return request.ids.cardItemId;
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
  Stream<List<CardSummary>> watchCards() =>
      Stream<List<CardSummary>>.value(const <CardSummary>[]);

  @override
  Stream<CardDetail?> watchCard(String cardItemId) =>
      Stream<CardDetail?>.value(null);

  @override
  Future<Set<String>> referencedImagePaths() async => const <String>{};
}

class SequenceIdGenerator implements IdGenerator {
  int _next = 0;
  int get issuedCount => _next;

  @override
  String newId() => 'id-${_next++}';
}

void main() {
  late FakeGalleryPicker picker;
  late FakeCardRepository repository;
  late FakeCameraCapture camera;
  late SequenceIdGenerator ids;
  late ProviderContainer container;

  ProviderContainer buildContainer() {
    return ProviderContainer.test(
      overrides: [
        galleryPickerProvider.overrideWithValue(picker),
        cameraCaptureProvider.overrideWithValue(camera),
        cardRepositoryProvider.overrideWithValue(repository),
        idGeneratorProvider.overrideWithValue(ids),
      ],
    );
  }

  CreateCardController controller() =>
      container.read(createCardControllerProvider.notifier);

  CreateCardState state() => container.read(createCardControllerProvider);

  setUp(() {
    picker = FakeGalleryPicker(selection: selectedImage);
    camera = FakeCameraCapture();
    repository = FakeCardRepository();
    ids = SequenceIdGenerator();
  });

  group('camera capture', () {
    const first = CapturedImage(
      path: '/tmp/CAMERA_0001.jpg',
      displayName: 'CAMERA_0001.jpg',
    );
    const second = CapturedImage(path: '/tmp/CAMERA_0002.jpg');

    test('single capture creates a front-image draft', () async {
      camera = FakeCameraCapture(captures: <CapturedImage?>[first]);
      container = buildContainer();

      expect(await controller().captureImage(), isTrue);

      expect(state().images.single.selection.path, first.path);
      expect(state().images.single.kind, CardImageKind.front);
      expect(state().phase, CreateCardPhase.editing);
    });

    test(
      'continuous capture stops on cancel and keeps confirmed images',
      () async {
        camera = FakeCameraCapture(
          captures: <CapturedImage?>[first, second, null],
        );
        container = buildContainer();

        expect(await controller().captureContinuously(), isTrue);

        expect(state().images.map((image) => image.selection.path), <String>[
          first.path,
          second.path,
        ]);
        expect(camera.captureCalls, 3);
        expect(state().failure, isNull);
      },
    );

    test('camera cancellation leaves an empty draft idle', () async {
      camera = FakeCameraCapture(captures: <CapturedImage?>[null]);
      container = buildContainer();

      expect(await controller().captureImage(), isFalse);

      expect(state().phase, CreateCardPhase.idle);
      expect(state().images, isEmpty);
    });

    test('camera failure is recoverable and keeps gallery available', () async {
      camera = FakeCameraCapture(error: const CameraAccessFailure());
      container = buildContainer();

      expect(await controller().captureImage(), isFalse);

      expect(state().failure, isA<CameraAccessFailure>());
      expect(state().phase, CreateCardPhase.failure);
    });

    test('recovers lost camera results into the current draft', () async {
      camera = FakeCameraCapture(lost: const <CapturedImage>[first, second]);
      container = buildContainer();

      expect(await controller().recoverLostCapture(), isTrue);

      expect(state().images, hasLength(2));
      expect(state().images.first.selection.path, first.path);
    });

    test('does not open camera after the 20-image limit', () async {
      picker = FakeGalleryPicker(
        selections: List<SelectedGalleryImage>.generate(
          CreateCardRequest.maxImages,
          (index) => SelectedGalleryImage(path: '/tmp/IMG_$index.jpg'),
        ),
      );
      camera = FakeCameraCapture(captures: <CapturedImage?>[first]);
      container = buildContainer();
      await controller().pickImage();

      expect(await controller().captureImage(append: true), isFalse);
      expect(camera.captureCalls, 0);
    });
  });

  group('pickImage', () {
    test('starts idle with an empty draft', () {
      container = buildContainer();

      expect(state().phase, CreateCardPhase.idle);
      expect(state().image, isNull);
      expect(state().ids, isNull);
    });

    test('a cancelled picker leaves the draft empty', () async {
      picker = FakeGalleryPicker();
      container = buildContainer();

      final picked = await controller().pickImage();

      expect(picked, isFalse);
      expect(state().phase, CreateCardPhase.idle);
      expect(state().image, isNull);
      expect(ids.issuedCount, 0);
    });

    test('a selected image generates draft ids exactly once', () async {
      container = buildContainer();

      expect(await controller().pickImage(), isTrue);

      expect(state().phase, CreateCardPhase.editing);
      expect(state().image, selectedImage);
      expect(ids.issuedCount, 3);

      final firstIds = state().ids;
      await controller().pickImage();

      // 重新选图只替换图片，草稿 ID 保持不变，幂等键才有意义。
      expect(state().ids, firstIds);
      expect(ids.issuedCount, 3);
    });

    test(
      'a multi-selection keeps order and generates one id per image',
      () async {
        picker = FakeGalleryPicker(
          selections: const <SelectedGalleryImage>[
            selectedImage,
            SelectedGalleryImage(path: '/tmp/IMG_0002.jpg'),
            SelectedGalleryImage(path: '/tmp/IMG_0003.jpg'),
          ],
        );
        container = buildContainer();

        expect(await controller().pickImage(), isTrue);

        expect(state().images.map((image) => image.selection.path), <String>[
          '/tmp/IMG_0001.jpg',
          '/tmp/IMG_0002.jpg',
          '/tmp/IMG_0003.jpg',
        ]);
        expect(state().images.map((image) => image.kind), <CardImageKind>[
          CardImageKind.front,
          CardImageKind.back,
          CardImageKind.other,
        ]);
        expect(ids.issuedCount, 5);
      },
    );

    test(
      'additional selection appends without changing existing ids',
      () async {
        container = buildContainer();
        await controller().pickImage();
        final firstId = state().images.single.id;
        picker = FakeGalleryPicker(
          selections: const <SelectedGalleryImage>[
            SelectedGalleryImage(path: '/tmp/IMG_0002.jpg'),
          ],
        );
        container.updateOverrides([
          galleryPickerProvider.overrideWithValue(picker),
          cameraCaptureProvider.overrideWithValue(camera),
          cardRepositoryProvider.overrideWithValue(repository),
          idGeneratorProvider.overrideWithValue(ids),
        ]);

        expect(await controller().addImages(), isTrue);

        expect(state().images, hasLength(2));
        expect(state().images.first.id, firstId);
        expect(state().images.last.selection.path, '/tmp/IMG_0002.jpg');
      },
    );

    test('caps results when a platform ignores the picker limit', () async {
      picker = FakeGalleryPicker(
        ignoreLimit: true,
        selections: List<SelectedGalleryImage>.generate(
          CreateCardRequest.maxImages + 1,
          (index) => SelectedGalleryImage(path: '/tmp/IMG_$index.jpg'),
        ),
      );
      container = buildContainer();

      expect(await controller().pickImage(), isTrue);

      expect(state().images, hasLength(CreateCardRequest.maxImages));
    });

    test('changes image kind and order in the draft', () async {
      picker = FakeGalleryPicker(
        selections: const <SelectedGalleryImage>[
          selectedImage,
          SelectedGalleryImage(path: '/tmp/IMG_0002.jpg'),
        ],
      );
      container = buildContainer();
      await controller().pickImage();
      final secondId = state().images.last.id;

      controller().updateImageKind(secondId, CardImageKind.back);
      controller().moveImage(secondId, -1);

      expect(state().images.first.id, secondId);
      expect(state().images.first.kind, CardImageKind.back);
    });

    test('exposes a stable failure when the picker throws', () async {
      picker = FakeGalleryPicker(error: const GalleryAccessFailure());
      container = buildContainer();

      expect(await controller().pickImage(), isFalse);
      expect(state().phase, CreateCardPhase.failure);
      expect(state().failure, isA<GalleryAccessFailure>());
    });

    test(
      'recovered Android lost data follows the selected-image path',
      () async {
        picker = FakeGalleryPicker(lost: selectedImage);
        container = buildContainer();

        expect(await controller().recoverLostImage(), isTrue);
        expect(state().phase, CreateCardPhase.editing);
        expect(state().image, selectedImage);
        expect(ids.issuedCount, 3);
      },
    );

    test('recoverLostImage is a no-op when nothing was lost', () async {
      picker = FakeGalleryPicker();
      container = buildContainer();

      expect(await controller().recoverLostImage(), isFalse);
      expect(state().phase, CreateCardPhase.idle);
    });
  });

  group('save', () {
    Future<void> pickAndName(String name) async {
      await controller().pickImage();
      controller().updateName(name);
    }

    test('a blank name saves as 未命名卡片', () async {
      container = buildContainer();
      await pickAndName('   ');

      expect(await controller().save(), isNotNull);
      expect(repository.requests.single.name, '未命名卡片');
    });

    test('saving without an image creates an empty card', () async {
      container = buildContainer();

      expect(await controller().save(), isNotNull);
      expect(repository.requests.single.images, isEmpty);
      expect(repository.requests.single.name, '未命名卡片');
    });

    test('a successful save returns the item id and clears failures', () async {
      container = buildContainer();
      await pickAndName('  樱花纪念卡  ');

      final id = await controller().save();

      expect(id, isNotNull);
      expect(state().phase, CreateCardPhase.saved);
      expect(state().savedCardItemId, id);
      expect(state().failure, isNull);
      expect(repository.requests.single.name, '樱花纪念卡');
    });

    test('passes every ordered draft image to the repository', () async {
      picker = FakeGalleryPicker(
        selections: const <SelectedGalleryImage>[
          selectedImage,
          SelectedGalleryImage(path: '/tmp/IMG_0002.jpg'),
          SelectedGalleryImage(path: '/tmp/IMG_0003.jpg'),
        ],
      );
      container = buildContainer();
      await pickAndName('樱花纪念卡');
      controller().updateImageKind(state().images[1].id, CardImageKind.back);

      await controller().save();

      final request = repository.requests.single;
      expect(request.images, hasLength(3));
      expect(request.images[1].kind, CardImageKind.back);
      expect(request.images.map((image) => image.sourcePath), <String>[
        '/tmp/IMG_0001.jpg',
        '/tmp/IMG_0002.jpg',
        '/tmp/IMG_0003.jpg',
      ]);
    });

    test(
      'passes a processed draft path without replacing its original',
      () async {
        container = buildContainer();
        await pickAndName('樱花纪念卡');
        final imageId = state().images.single.id;

        controller().applyProcessedImage(imageId, '/tmp/processed.jpg');
        await controller().save();

        final image = repository.requests.single.images.single;
        expect(image.sourcePath, selectedImage.path);
        expect(image.derivedSourcePath, '/tmp/processed.jpg');
        expect(state().images.single.displayPath, '/tmp/processed.jpg');
      },
    );

    test('passes optional fields through to the repository', () async {
      container = buildContainer();
      await pickAndName('樱花纪念卡');
      controller()
        ..updateCity('东京')
        ..updateIssuer('Tokyo Metro')
        ..updateIssuedAt('2025-03')
        ..updateCode('01 / 08')
        ..updateNotes('首发');

      await controller().save();

      final request = repository.requests.single;
      expect(request.city, '东京');
      expect(request.issuer, 'Tokyo Metro');
      expect(request.issuedAt, PartialDate.tryParse('2025-03'));
      expect(request.code, '01 / 08');
      expect(request.notes, '首发');
    });

    test('rejects an unparseable issue date before saving', () async {
      container = buildContainer();
      await pickAndName('樱花纪念卡');
      controller().updateIssuedAt('2025-13');

      expect(await controller().save(), isNull);
      expect(state().fieldErrors[CardField.issuedAt], isNotNull);
      expect(repository.createCalls, 0);
    });

    test('a second save during an active save does not call twice', () async {
      repository = FakeCardRepository(hold: true);
      container = buildContainer();
      await pickAndName('樱花纪念卡');

      final first = controller().save();
      final second = controller().save();

      expect(state().phase, CreateCardPhase.saving);
      expect(repository.createCalls, 1);

      repository.gate.complete();
      expect(await first, isNotNull);
      expect(await second, isNull);
      expect(repository.createCalls, 1);
    });

    test(
      'a repository failure preserves the draft and shows the message',
      () async {
        repository = FakeCardRepository(failure: const PersistenceFailure());
        container = buildContainer();
        await pickAndName('樱花纪念卡');
        controller().updateCity('东京');

        expect(await controller().save(), isNull);

        expect(state().phase, CreateCardPhase.failure);
        expect(state().failure, isA<PersistenceFailure>());
        expect(state().failure!.userMessage, '保存失败，请重试。');
        expect(state().name, '樱花纪念卡');
        expect(state().city, '东京');
        expect(state().image, selectedImage);
      },
    );

    test('retrying after a failure reuses the same draft ids', () async {
      repository = FakeCardRepository(failure: const PersistenceFailure());
      container = buildContainer();
      await pickAndName('樱花纪念卡');

      await controller().save();
      await controller().save();

      expect(repository.createCalls, 2);
      expect(
        repository.requests.first.ids.cardItemId,
        repository.requests.last.ids.cardItemId,
      );
    });

    test('editing a field clears that field error', () async {
      container = buildContainer();
      await pickAndName('');
      controller().updateIssuedAt('invalid');
      await controller().save();
      expect(state().fieldErrors[CardField.issuedAt], isNotNull);

      controller().updateIssuedAt('2026-07-29');

      expect(state().fieldErrors[CardField.issuedAt], isNull);
    });
  });
}
