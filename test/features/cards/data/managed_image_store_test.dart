import 'dart:io';
import 'dart:typed_data';

import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/features/cards/data/files/managed_image_store.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// 各格式的魔数头部。存储层按内容而非文件名判断媒体类型。
final Uint8List jpegBytes = Uint8List.fromList(<int>[
  0xFF, 0xD8, 0xFF, 0xE0, //
  ...List<int>.filled(64, 0x11),
  0xFF, 0xD9,
]);

final Uint8List pngBytes = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  ...List<int>.filled(64, 0x22),
]);

final Uint8List webpBytes = Uint8List.fromList(<int>[
  ...'RIFF'.codeUnits, //
  0x40, 0x00, 0x00, 0x00,
  ...'WEBP'.codeUnits,
  ...List<int>.filled(48, 0x33),
]);

final Uint8List heicBytes = Uint8List.fromList(<int>[
  0x00, 0x00, 0x00, 0x18, //
  ...'ftypheic'.codeUnits,
  ...List<int>.filled(48, 0x44),
]);

void main() {
  late Directory root;
  late Directory sourceDir;
  late ManagedImageStore store;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('cardfolio-root-');
    sourceDir = await Directory.systemTemp.createTemp('cardfolio-src-');
    store = ManagedImageStore(root);
  });

  tearDown(() async {
    for (final dir in <Directory>[root, sourceDir]) {
      if (dir.existsSync()) await dir.delete(recursive: true);
    }
  });

  Future<String> writeSource(String name, List<int> bytes) async {
    final file = File(p.join(sourceDir.path, name));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  group('importImage', () {
    test('copies bytes under originals/<cardItemId>/<imageId>.<ext>', () async {
      final source = await writeSource('IMG_0001.jpg', jpegBytes);

      final imported = await store.importImage(
        sourcePath: source,
        cardItemId: 'item-1',
        imageId: 'image-1',
      );

      expect(imported.relativePath, 'originals/item-1/image-1.jpg');
      expect(imported.byteSize, jpegBytes.length);
      expect(store.resolve(imported.relativePath).existsSync(), isTrue);
      expect(
        await store.resolve(imported.relativePath).readAsBytes(),
        jpegBytes,
      );
    });

    test('returns the SHA-256 of the source bytes', () async {
      final source = await writeSource('IMG_0002.jpg', jpegBytes);

      final imported = await store.importImage(
        sourcePath: source,
        cardItemId: 'item-1',
        imageId: 'image-1',
      );

      expect(imported.checksum, sha256.convert(jpegBytes).toString());
    });

    test(
      'derives the extension from content, not from the file name',
      () async {
        final source = await writeSource('misnamed.jpg', pngBytes);

        final imported = await store.importImage(
          sourcePath: source,
          cardItemId: 'item-1',
          imageId: 'image-1',
        );

        expect(imported.relativePath, endsWith('.png'));
      },
    );

    test('supports webp and heic', () async {
      final webp = await store.importImage(
        sourcePath: await writeSource('a.bin', webpBytes),
        cardItemId: 'item-1',
        imageId: 'image-1',
      );
      final heic = await store.importImage(
        sourcePath: await writeSource('b.bin', heicBytes),
        cardItemId: 'item-2',
        imageId: 'image-2',
      );

      expect(webp.relativePath, endsWith('.webp'));
      expect(heic.relativePath, endsWith('.heic'));
    });

    test('rejects a missing source file', () async {
      expect(
        () => store.importImage(
          sourcePath: p.join(sourceDir.path, 'nope.jpg'),
          cardItemId: 'item-1',
          imageId: 'image-1',
        ),
        throwsA(isA<ImageImportFailure>()),
      );
    });

    test('rejects an unsupported media type', () async {
      final source = await writeSource('notes.txt', 'hello'.codeUnits);

      expect(
        () => store.importImage(
          sourcePath: source,
          cardItemId: 'item-1',
          imageId: 'image-1',
        ),
        throwsA(isA<ImageImportFailure>()),
      );
    });

    test('rejects an empty file', () async {
      final source = await writeSource('empty.jpg', const <int>[]);

      expect(
        () => store.importImage(
          sourcePath: source,
          cardItemId: 'item-1',
          imageId: 'image-1',
        ),
        throwsA(isA<ImageImportFailure>()),
      );
    });

    test('leaves no staging residue after a successful import', () async {
      final source = await writeSource('IMG_0003.jpg', jpegBytes);

      await store.importImage(
        sourcePath: source,
        cardItemId: 'item-1',
        imageId: 'image-1',
      );

      final staging = Directory(p.join(root.path, 'staging'));
      final residue = staging.existsSync()
          ? staging.listSync(recursive: true).whereType<File>().toList()
          : <File>[];
      expect(residue, isEmpty);
    });

    test(
      'never leaves a partial file in originals when import fails',
      () async {
        final source = await writeSource('bad.jpg', 'not an image'.codeUnits);

        await expectLater(
          store.importImage(
            sourcePath: source,
            cardItemId: 'item-1',
            imageId: 'image-1',
          ),
          throwsA(isA<ImageImportFailure>()),
        );

        final originals = Directory(p.join(root.path, 'originals'));
        final leftovers = originals.existsSync()
            ? originals.listSync(recursive: true).whereType<File>().toList()
            : <File>[];
        expect(leftovers, isEmpty);
      },
    );
  });

  group('importDerivedImage', () {
    test(
      'stores only JPEG bytes under derived and keeps source unchanged',
      () async {
        final source = await writeSource('processed.jpg', jpegBytes);

        final imported = await store.importDerivedImage(
          sourcePath: source,
          cardItemId: 'item-1',
          imageId: 'image-1',
        );

        expect(imported.relativePath, 'derived/item-1/image-1.jpg');
        expect(
          await store.resolve(imported.relativePath).readAsBytes(),
          jpegBytes,
        );
        expect(await File(source).readAsBytes(), jpegBytes);
      },
    );

    test('rejects a non-JPEG derived file without leaving residue', () async {
      final source = await writeSource('processed.png', pngBytes);

      await expectLater(
        store.importDerivedImage(
          sourcePath: source,
          cardItemId: 'item-1',
          imageId: 'image-1',
        ),
        throwsA(isA<ImageImportFailure>()),
      );

      expect(Directory(p.join(root.path, 'derived')).existsSync(), isFalse);
    });
  });

  group('resolve', () {
    test('rejects a path that escapes the managed root', () {
      expect(
        () => store.resolve('../../etc/passwd'),
        throwsA(isA<ImageImportFailure>()),
      );
      expect(
        () => store.resolve('originals/../../outside.jpg'),
        throwsA(isA<ImageImportFailure>()),
      );
    });

    test('rejects an absolute path', () {
      expect(
        () => store.resolve(p.join(sourceDir.path, 'anything.jpg')),
        throwsA(isA<ImageImportFailure>()),
      );
    });
  });

  group('delete', () {
    test('removes a managed file', () async {
      final imported = await store.importImage(
        sourcePath: await writeSource('IMG_0004.jpg', jpegBytes),
        cardItemId: 'item-1',
        imageId: 'image-1',
      );

      await store.delete(imported.relativePath);

      expect(store.resolve(imported.relativePath).existsSync(), isFalse);
    });

    test('is a no-op for an already deleted file', () async {
      await store.delete('originals/item-1/never-existed.jpg');
    });

    test('refuses to delete outside the managed root', () async {
      final outside = File(p.join(sourceDir.path, 'keep.jpg'));
      await outside.writeAsBytes(jpegBytes, flush: true);

      await expectLater(
        store.delete(p.relative(outside.path, from: root.path)),
        throwsA(isA<ImageImportFailure>()),
      );
      expect(outside.existsSync(), isTrue);
    });
  });

  group('removeOrphans', () {
    test('deletes only files absent from the referenced set', () async {
      final kept = await store.importImage(
        sourcePath: await writeSource('a.jpg', jpegBytes),
        cardItemId: 'item-1',
        imageId: 'image-1',
      );
      final orphan = await store.importImage(
        sourcePath: await writeSource('b.png', pngBytes),
        cardItemId: 'item-2',
        imageId: 'image-2',
      );

      await store.removeOrphans(<String>{kept.relativePath});

      expect(store.resolve(kept.relativePath).existsSync(), isTrue);
      expect(store.resolve(orphan.relativePath).existsSync(), isFalse);
    });

    test('applies orphan cleanup to derived files', () async {
      final kept = await store.importDerivedImage(
        sourcePath: await writeSource('kept.jpg', jpegBytes),
        cardItemId: 'item-1',
        imageId: 'image-1',
      );
      final orphan = await store.importDerivedImage(
        sourcePath: await writeSource('orphan.jpg', jpegBytes),
        cardItemId: 'item-2',
        imageId: 'image-2',
      );

      await store.removeOrphans(<String>{kept.relativePath});

      expect(store.resolve(kept.relativePath).existsSync(), isTrue);
      expect(store.resolve(orphan.relativePath).existsSync(), isFalse);
    });

    test('clears stale staging files', () async {
      final staged = File(p.join(root.path, 'staging', 'op-1', 'partial.jpg'));
      await staged.parent.create(recursive: true);
      await staged.writeAsBytes(jpegBytes, flush: true);

      await store.removeOrphans(const <String>{});

      expect(staged.existsSync(), isFalse);
    });

    test('tolerates a missing root directory', () async {
      await root.delete(recursive: true);

      await store.removeOrphans(const <String>{});
    });
  });
}
