import 'package:meta/meta.dart';

/// 图片中的归一化坐标，左上角为 (0, 0)，右下角为 (1, 1)。
@immutable
final class NormalizedPoint {
  factory NormalizedPoint(double x, double y) {
    if (!x.isFinite || x < 0 || x > 1) {
      throw RangeError.range(x, 0, 1, 'x');
    }
    if (!y.isFinite || y < 0 || y > 1) {
      throw RangeError.range(y, 0, 1, 'y');
    }
    return NormalizedPoint._(x, y);
  }

  const NormalizedPoint._(this.x, this.y);

  final double x;
  final double y;

  @override
  bool operator ==(Object other) =>
      other is NormalizedPoint && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}

/// 按左上、右上、右下、左下排列的凸四边形。
@immutable
final class ImageCorners {
  factory ImageCorners({
    required NormalizedPoint topLeft,
    required NormalizedPoint topRight,
    required NormalizedPoint bottomRight,
    required NormalizedPoint bottomLeft,
  }) {
    final points = <NormalizedPoint>[
      topLeft,
      topRight,
      bottomRight,
      bottomLeft,
    ];
    final crosses = <double>[
      for (var index = 0; index < points.length; index++)
        _cross(
          points[index],
          points[(index + 1) % points.length],
          points[(index + 2) % points.length],
        ),
    ];
    const epsilon = 0.000001;
    final allPositive = crosses.every((value) => value > epsilon);
    final allNegative = crosses.every((value) => value < -epsilon);
    if (!allPositive && !allNegative) {
      throw ArgumentError.value(points, 'corners', '四角必须形成非退化凸四边形。');
    }
    return ImageCorners._(topLeft, topRight, bottomRight, bottomLeft);
  }

  const ImageCorners._(
    this.topLeft,
    this.topRight,
    this.bottomRight,
    this.bottomLeft,
  );

  static final ImageCorners safeInset = ImageCorners(
    topLeft: NormalizedPoint(0.04, 0.04),
    topRight: NormalizedPoint(0.96, 0.04),
    bottomRight: NormalizedPoint(0.96, 0.96),
    bottomLeft: NormalizedPoint(0.04, 0.96),
  );

  static final ImageCorners full = ImageCorners(
    topLeft: NormalizedPoint(0, 0),
    topRight: NormalizedPoint(1, 0),
    bottomRight: NormalizedPoint(1, 1),
    bottomLeft: NormalizedPoint(0, 1),
  );

  final NormalizedPoint topLeft;
  final NormalizedPoint topRight;
  final NormalizedPoint bottomRight;
  final NormalizedPoint bottomLeft;

  static double _cross(
    NormalizedPoint first,
    NormalizedPoint second,
    NormalizedPoint third,
  ) {
    return (second.x - first.x) * (third.y - second.y) -
        (second.y - first.y) * (third.x - second.x);
  }

  @override
  bool operator ==(Object other) =>
      other is ImageCorners &&
      other.topLeft == topLeft &&
      other.topRight == topRight &&
      other.bottomRight == bottomRight &&
      other.bottomLeft == bottomLeft;

  @override
  int get hashCode => Object.hash(topLeft, topRight, bottomRight, bottomLeft);
}

@immutable
final class ImageAdjustments {
  factory ImageAdjustments({
    double brightness = 0,
    double contrast = 0,
    double sharpness = 0,
  }) {
    _checkUnitRange(brightness, 'brightness');
    _checkUnitRange(contrast, 'contrast');
    if (!sharpness.isFinite || sharpness < 0 || sharpness > 1) {
      throw RangeError.range(sharpness, 0, 1, 'sharpness');
    }
    return ImageAdjustments._(brightness, contrast, sharpness);
  }

  const ImageAdjustments._(this.brightness, this.contrast, this.sharpness);

  static const ImageAdjustments none = ImageAdjustments._(0, 0, 0);

  final double brightness;
  final double contrast;
  final double sharpness;

  static void _checkUnitRange(double value, String name) {
    if (!value.isFinite || value < -1 || value > 1) {
      throw RangeError.range(value, -1, 1, name);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is ImageAdjustments &&
      other.brightness == brightness &&
      other.contrast == contrast &&
      other.sharpness == sharpness;

  @override
  int get hashCode => Object.hash(brightness, contrast, sharpness);
}

enum ImageOutputTemplate { original, standardCard, squareLight, squareDark }

@immutable
final class ImageEditSettings {
  factory ImageEditSettings.initial({ImageCorners? corners}) {
    return ImageEditSettings._(
      corners: corners ?? ImageCorners.full,
      quarterTurns: 0,
      adjustments: ImageAdjustments.none,
      template: ImageOutputTemplate.original,
    );
  }

  const ImageEditSettings._({
    required this.corners,
    required this.quarterTurns,
    required this.adjustments,
    required this.template,
  });

  final ImageCorners corners;
  final int quarterTurns;
  final ImageAdjustments adjustments;
  final ImageOutputTemplate template;

  ImageEditSettings copyWith({
    ImageCorners? corners,
    int? quarterTurns,
    ImageAdjustments? adjustments,
    ImageOutputTemplate? template,
  }) {
    final turns = quarterTurns ?? this.quarterTurns;
    return ImageEditSettings._(
      corners: corners ?? this.corners,
      quarterTurns: ((turns % 4) + 4) % 4,
      adjustments: adjustments ?? this.adjustments,
      template: template ?? this.template,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ImageEditSettings &&
      other.corners == corners &&
      other.quarterTurns == quarterTurns &&
      other.adjustments == adjustments &&
      other.template == template;

  @override
  int get hashCode => Object.hash(corners, quarterTurns, adjustments, template);
}

@immutable
final class EdgeDetectionResult {
  EdgeDetectionResult({required this.corners, required double confidence})
    : confidence = _validConfidence(confidence);

  static const double manualThreshold = 0.55;

  final ImageCorners corners;
  final double confidence;

  bool get requiresManualAdjustment => confidence < manualThreshold;

  static double _validConfidence(double value) {
    if (!value.isFinite || value < 0 || value > 1) {
      throw RangeError.range(value, 0, 1, 'confidence');
    }
    return value;
  }
}

@immutable
final class ImageProcessingRequest {
  const ImageProcessingRequest({
    required this.sourcePath,
    required this.outputId,
    required this.settings,
  });

  final String sourcePath;
  final String outputId;
  final ImageEditSettings settings;
}

@immutable
final class ProcessedImage {
  const ProcessedImage({
    required this.path,
    required this.width,
    required this.height,
    required this.byteSize,
    required this.elapsed,
  });

  final String path;
  final int width;
  final int height;
  final int byteSize;
  final Duration elapsed;
}

abstract interface class ImageProcessor {
  Future<EdgeDetectionResult> detectEdges(String sourcePath);

  Future<ProcessedImage> process(ImageProcessingRequest request);
}
