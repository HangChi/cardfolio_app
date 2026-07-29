import 'dart:async';
import 'dart:io';

import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/features/cards/domain/image_processing.dart';
import 'package:cardfolio_app/features/cards/presentation/edit/image_edit_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_image_processor.dart';

final class DelayedImageProcessor implements ImageProcessor {
  final Completer<ProcessedImage> completer = Completer<ProcessedImage>();

  @override
  Future<EdgeDetectionResult> detectEdges(String sourcePath) async =>
      EdgeDetectionResult(corners: ImageCorners.safeInset, confidence: 0.9);

  @override
  Future<ProcessedImage> process(ImageProcessingRequest request) =>
      completer.future;
}

void main() {
  test(
    'initializes with an automatic suggestion and manual fallback state',
    () async {
      final controller = ImageEditController(
        processor: FakeImageProcessor(),
        sourcePath: '/tmp/original.jpg',
        outputId: 'image-1',
      );

      await controller.initialize();

      expect(controller.state.phase, ImageEditPhase.ready);
      expect(controller.state.requiresManualAdjustment, isTrue);
      expect(controller.state.settings.corners, ImageCorners.safeInset);
    },
  );

  test(
    'records edits, supports undo, and resets to detected settings',
    () async {
      final controller = ImageEditController(
        processor: FakeImageProcessor(),
        sourcePath: '/tmp/original.jpg',
        outputId: 'image-1',
      );
      await controller.initialize();

      controller
        ..setBrightness(0.4)
        ..rotateClockwise()
        ..setTemplate(ImageOutputTemplate.squareDark);
      expect(controller.state.canUndo, isTrue);
      expect(controller.state.settings.quarterTurns, 1);

      controller.undo();
      expect(controller.state.settings.template, ImageOutputTemplate.original);
      controller.reset();
      expect(controller.state.settings.adjustments, ImageAdjustments.none);
      expect(controller.state.settings.quarterTurns, 0);
    },
  );

  test(
    'renders the current immutable settings and exposes the output',
    () async {
      final processor = FakeImageProcessor();
      final controller = ImageEditController(
        processor: processor,
        sourcePath: '/tmp/original.jpg',
        outputId: 'image-1',
      );
      await controller.initialize();
      controller.setContrast(0.25);

      final result = await controller.render();

      expect(result?.path, '/tmp/processed.jpg');
      expect(processor.requests.single.settings.adjustments.contrast, 0.25);
      expect(controller.state.phase, ImageEditPhase.completed);
    },
  );

  test('keeps settings and exposes a safe processing failure', () async {
    final controller = ImageEditController(
      processor: FakeImageProcessor(
        failure: const ImageProcessingFailure('无法生成展示图。'),
      ),
      sourcePath: '/tmp/original.jpg',
      outputId: 'image-1',
    );
    await controller.initialize();
    controller.setSharpness(0.5);

    expect(await controller.render(), isNull);

    expect(controller.state.phase, ImageEditPhase.failure);
    expect(controller.state.settings.adjustments.sharpness, 0.5);
    expect(controller.state.failure, isA<ImageProcessingFailure>());
  });

  test('cancelling an active render removes its unpublished output', () async {
    final directory = await Directory.systemTemp.createTemp(
      'cardfolio-cancelled-edit-',
    );
    addTearDown(() async {
      if (directory.existsSync()) await directory.delete(recursive: true);
    });
    final output = File('${directory.path}/processed.jpg')
      ..writeAsBytesSync(<int>[0xff, 0xd8, 0xff]);
    final processor = DelayedImageProcessor();
    final controller = ImageEditController(
      processor: processor,
      sourcePath: '/tmp/original.jpg',
      outputId: 'image-1',
    );
    await controller.initialize();

    final rendering = controller.render();
    controller.cancelPending();
    processor.completer.complete(
      ProcessedImage(
        path: output.path,
        width: 1,
        height: 1,
        byteSize: 3,
        elapsed: Duration.zero,
      ),
    );

    expect(await rendering, isNull);
    expect(output.existsSync(), isFalse);
  });
}
