import 'dart:async';

import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/core/id/id_generator.dart';
import 'package:cardfolio_app/features/cards/data/card_providers.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:cardfolio_app/features/cards/domain/card_repository.dart';
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
  FakeGalleryPicker({this.selection, this.lost, this.error});

  final SelectedGalleryImage? selection;
  final SelectedGalleryImage? lost;
  final AppFailure? error;

  int pickCalls = 0;
  int recoverCalls = 0;

  @override
  Future<SelectedGalleryImage?> pickOne() async {
    pickCalls++;
    if (error != null) throw error!;
    return selection;
  }

  @override
  Future<SelectedGalleryImage?> recoverLost() async {
    recoverCalls++;
    return lost;
  }
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
  late SequenceIdGenerator ids;
  late ProviderContainer container;

  ProviderContainer buildContainer() {
    return ProviderContainer.test(
      overrides: [
        galleryPickerProvider.overrideWithValue(picker),
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
    repository = FakeCardRepository();
    ids = SequenceIdGenerator();
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

    test('a blank name shows 名称不能为空 and skips the repository', () async {
      container = buildContainer();
      await pickAndName('   ');

      expect(await controller().save(), isNull);
      expect(state().fieldErrors[CardField.name], '名称不能为空');
      expect(state().phase, CreateCardPhase.editing);
      expect(repository.createCalls, 0);
    });

    test('saving without an image is rejected', () async {
      container = buildContainer();
      controller().updateName('樱花纪念卡');

      expect(await controller().save(), isNull);
      expect(repository.createCalls, 0);
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
      await pickAndName('   ');
      await controller().save();
      expect(state().fieldErrors[CardField.name], isNotNull);

      controller().updateName('樱花纪念卡');

      expect(state().fieldErrors[CardField.name], isNull);
    });
  });
}
