import 'dart:io';

import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/features/cards/data/image_processing/local_image_processor.dart';
import 'package:cardfolio_app/features/cards/domain/image_processing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  late Directory root;
  late LocalImageProcessor processor;

  setUp(() {
    root = Directory.systemTemp.createTempSync('cardfolio-image-processing-');
    processor = LocalImageProcessor(root);
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  File writePng(String name, img.Image image) {
    final file = File('${root.path}/$name');
    file.writeAsBytesSync(img.encodePng(image));
    return file;
  }

  test('detects the bounding card edges on a contrasting image', () async {
    final image = img.Image(width: 100, height: 80);
    img.fill(image, color: img.ColorRgb8(245, 245, 245));
    img.fillRect(
      image,
      x1: 20,
      y1: 10,
      x2: 79,
      y2: 69,
      color: img.ColorRgb8(20, 20, 20),
    );
    final source = writePng('card.png', image);

    final result = await processor.detectEdges(source.path);

    expect(result.requiresManualAdjustment, isFalse);
    expect(result.corners.topLeft.x, closeTo(0.2, 0.03));
    expect(result.corners.topLeft.y, closeTo(0.125, 0.03));
    expect(result.corners.bottomRight.x, closeTo(0.8, 0.03));
    expect(result.corners.bottomRight.y, closeTo(0.875, 0.03));
  });

  test('falls back to safe manual corners for a flat image', () async {
    final image = img.Image(width: 40, height: 30);
    img.fill(image, color: img.ColorRgb8(120, 120, 120));
    final source = writePng('flat.png', image);

    final result = await processor.detectEdges(source.path);

    expect(result.corners, ImageCorners.safeInset);
    expect(result.requiresManualAdjustment, isTrue);
  });

  test(
    'processes on a worker and atomically publishes a JPEG template',
    () async {
      final image = img.Image(width: 120, height: 80);
      img.fill(image, color: img.ColorRgb8(220, 20, 20));
      final source = writePng('source.png', image);
      final originalBytes = source.readAsBytesSync();

      final result = await processor.process(
        ImageProcessingRequest(
          sourcePath: source.path,
          outputId: 'draft-image-1',
          settings:
              ImageEditSettings.initial(
                corners: ImageCorners(
                  topLeft: NormalizedPoint(0, 0),
                  topRight: NormalizedPoint(1, 0),
                  bottomRight: NormalizedPoint(1, 1),
                  bottomLeft: NormalizedPoint(0, 1),
                ),
              ).copyWith(
                quarterTurns: 1,
                adjustments: ImageAdjustments(
                  brightness: 0.1,
                  contrast: 0.2,
                  sharpness: 0.5,
                ),
                template: ImageOutputTemplate.squareLight,
              ),
        ),
      );

      expect(result.width, result.height);
      expect(result.byteSize, greaterThan(100));
      expect(File(result.path).readAsBytesSync().take(3), <int>[
        0xff,
        0xd8,
        0xff,
      ]);
      expect(source.readAsBytesSync(), originalBytes);
      expect(
        Directory(root.path)
            .listSync(recursive: true)
            .whereType<File>()
            .any((file) => file.path.endsWith('.tmp')),
        isFalse,
      );
    },
  );

  test('rejects malformed bytes and unsafe output identifiers', () async {
    final source = File('${root.path}/broken.jpg')..writeAsStringSync('broken');

    await expectLater(
      processor.detectEdges(source.path),
      throwsA(isA<ImageProcessingFailure>()),
    );
    await expectLater(
      processor.process(
        ImageProcessingRequest(
          sourcePath: source.path,
          outputId: '../escape',
          settings: ImageEditSettings.initial(),
        ),
      ),
      throwsA(isA<ImageProcessingFailure>()),
    );
  });
}
