import 'dart:io';
import 'dart:typed_data';

import 'package:cardfolio_app/app/bootstrap/app_bootstrap.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;

final Uint8List _jpegBytes = Uint8List.fromList(<int>[
  0xFF,
  0xD8,
  0xFF,
  0xE0,
  ...List<int>.filled(64, 0x2A),
  0xFF,
  0xD9,
]);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test(
    'card and managed image survive a complete dependency restart',
    () async {
      final supportDirectory = await Directory.systemTemp.createTemp(
        'cardfolio-persistence-',
      );
      addTearDown(() async {
        if (supportDirectory.existsSync()) {
          await supportDirectory.delete(recursive: true);
        }
      });

      final source = File(p.join(supportDirectory.path, 'selected-card.jpg'));
      await source.writeAsBytes(_jpegBytes, flush: true);

      final first = await CardfolioDependencies.initialize(
        supportDirectory: supportDirectory,
      );
      final cardItemId = await first.repository.createCard(
        CreateCardRequest(
          ids: const CardDraftIds(
            definitionId: 'definition-restart',
            cardItemId: 'item-restart',
            imageId: 'image-restart',
          ),
          sourceImagePath: source.path,
          name: '重启后仍存在的卡片',
          city: '上海',
        ),
      );
      final orphan = File(
        p.join(
          first.imageStore.root.path,
          'originals',
          'orphan-item',
          'orphan.jpg',
        ),
      );
      await orphan.parent.create(recursive: true);
      await orphan.writeAsBytes(_jpegBytes, flush: true);
      await first.close();

      final second = await CardfolioDependencies.initialize(
        supportDirectory: supportDirectory,
      );
      addTearDown(second.close);

      final cards = await second.repository.watchCards().first;
      final detail = await second.repository.watchCard(cardItemId).first;

      expect(cards.single.name, '重启后仍存在的卡片');
      expect(detail, isNotNull);
      expect(detail!.city, '上海');
      expect(detail.images, hasLength(1));
      expect(orphan.existsSync(), isFalse);
      expect(
        second.imageStore
            .resolve(detail.images.single.relativePath)
            .existsSync(),
        isTrue,
      );
    },
  );
}
