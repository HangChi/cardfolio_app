import 'package:cardfolio_app/features/cards/domain/image_processing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NormalizedPoint', () {
    test('rejects coordinates outside the normalized image bounds', () {
      expect(() => NormalizedPoint(-0.01, 0.5), throwsRangeError);
      expect(() => NormalizedPoint(0.5, 1.01), throwsRangeError);
    });
  });

  group('ImageCorners', () {
    test('accepts a clockwise convex quadrilateral', () {
      final corners = ImageCorners(
        topLeft: NormalizedPoint(0.04, 0.04),
        topRight: NormalizedPoint(0.96, 0.04),
        bottomRight: NormalizedPoint(0.96, 0.96),
        bottomLeft: NormalizedPoint(0.04, 0.96),
      );

      expect(corners, ImageCorners.safeInset);
    });

    test('rejects crossed or degenerate quadrilaterals', () {
      expect(
        () => ImageCorners(
          topLeft: NormalizedPoint(0.1, 0.1),
          topRight: NormalizedPoint(0.9, 0.9),
          bottomRight: NormalizedPoint(0.9, 0.1),
          bottomLeft: NormalizedPoint(0.1, 0.9),
        ),
        throwsArgumentError,
      );
      expect(
        () => ImageCorners(
          topLeft: NormalizedPoint(0.1, 0.1),
          topRight: NormalizedPoint(0.5, 0.1),
          bottomRight: NormalizedPoint(0.9, 0.1),
          bottomLeft: NormalizedPoint(0.2, 0.1),
        ),
        throwsArgumentError,
      );
    });
  });

  group('ImageAdjustments', () {
    test('enforces the documented parameter ranges', () {
      expect(() => ImageAdjustments(brightness: 1.01), throwsRangeError);
      expect(() => ImageAdjustments(contrast: -1.01), throwsRangeError);
      expect(() => ImageAdjustments(sharpness: -0.01), throwsRangeError);
    });
  });

  group('ImageEditSettings', () {
    test('normalizes quarter turns and preserves immutable edits', () {
      final original = ImageEditSettings.initial();
      final changed = original.copyWith(
        quarterTurns: 5,
        adjustments: ImageAdjustments(brightness: 0.25),
        template: ImageOutputTemplate.squareDark,
      );

      expect(original.quarterTurns, 0);
      expect(changed.quarterTurns, 1);
      expect(changed.adjustments.brightness, 0.25);
      expect(changed.template, ImageOutputTemplate.squareDark);
    });
  });

  test('low-confidence edge suggestions require manual adjustment', () {
    final result = EdgeDetectionResult(
      corners: ImageCorners.safeInset,
      confidence: 0.54,
    );

    expect(result.requiresManualAdjustment, isTrue);
  });
}
