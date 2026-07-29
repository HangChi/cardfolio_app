import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import '../../../../core/errors/app_failure.dart';
import '../../domain/image_processing.dart';

/// 使用纯 Dart `image` 库的本地处理器。
///
/// 解码、像素遍历、透视与编码均在 worker isolate 执行，避免阻塞 UI isolate。
final class LocalImageProcessor implements ImageProcessor {
  const LocalImageProcessor(this.workingDirectory);

  final Directory workingDirectory;

  static const int maxDecodedPixels = 48 * 1000 * 1000;
  static const int maxLongEdge = 4096;
  static const int jpegQuality = 92;

  @override
  Future<EdgeDetectionResult> detectEdges(String sourcePath) async {
    try {
      final data = await Isolate.run(() => _detectEdges(sourcePath));
      return EdgeDetectionResult(
        corners: _cornersFromData(data),
        confidence: data.confidence,
      );
    } on ImageProcessingFailure {
      rethrow;
    } catch (error) {
      throw ImageProcessingFailure('无法识别卡片边缘，请手动调整四角。', error);
    }
  }

  @override
  Future<ProcessedImage> process(ImageProcessingRequest request) async {
    if (!RegExp(r'^[A-Za-z0-9_-]{1,100}$').hasMatch(request.outputId)) {
      throw const ImageProcessingFailure('图片处理标识无效，请重新打开编辑器。');
    }

    final outputDirectory = Directory(p.join(workingDirectory.path, 'outputs'));
    try {
      await outputDirectory.create(recursive: true);
      final data = _requestData(request, outputDirectory.path);
      final result = await Isolate.run(() => _processImage(data));
      return ProcessedImage(
        path: result.path,
        width: result.width,
        height: result.height,
        byteSize: result.byteSize,
        elapsed: Duration(microseconds: result.elapsedMicroseconds),
      );
    } on ImageProcessingFailure {
      rethrow;
    } catch (error) {
      throw ImageProcessingFailure('生成展示图失败，请检查存储空间后重试。', error);
    }
  }
}

_CornersData _detectEdges(String sourcePath) {
  final source = _decode(sourcePath);
  final scale = source.width > 512 ? 512 / source.width : 1.0;
  final sample = scale < 1
      ? img.copyResize(
          source,
          width: 512,
          interpolation: img.Interpolation.linear,
        )
      : source;

  double luminanceAt(int x, int y) {
    final pixel = sample.getPixel(x, y);
    return 0.2126 * pixel.r + 0.7152 * pixel.g + 0.0722 * pixel.b;
  }

  var borderSum = 0.0;
  var borderCount = 0;
  for (var x = 0; x < sample.width; x++) {
    borderSum += luminanceAt(x, 0);
    borderSum += luminanceAt(x, sample.height - 1);
    borderCount += 2;
  }
  for (var y = 1; y < sample.height - 1; y++) {
    borderSum += luminanceAt(0, y);
    borderSum += luminanceAt(sample.width - 1, y);
    borderCount += 2;
  }
  final borderLuminance = borderSum / borderCount;

  var minX = sample.width;
  var minY = sample.height;
  var maxX = -1;
  var maxY = -1;
  var contrasting = 0;
  for (var y = 0; y < sample.height; y++) {
    for (var x = 0; x < sample.width; x++) {
      if ((luminanceAt(x, y) - borderLuminance).abs() < 35) continue;
      contrasting++;
      minX = math.min(minX, x);
      minY = math.min(minY, y);
      maxX = math.max(maxX, x);
      maxY = math.max(maxY, y);
    }
  }

  final coverage = contrasting / (sample.width * sample.height);
  final widthCoverage = maxX < minX ? 0 : (maxX - minX + 1) / sample.width;
  final heightCoverage = maxY < minY ? 0 : (maxY - minY + 1) / sample.height;
  if (coverage < 0.05 || widthCoverage < 0.2 || heightCoverage < 0.2) {
    return const _CornersData(
      left: 0.04,
      top: 0.04,
      right: 0.96,
      bottom: 0.96,
      confidence: 0.2,
    );
  }

  final confidence = math.min(0.95, 0.55 + coverage);
  return _CornersData(
    left: minX / (sample.width - 1),
    top: minY / (sample.height - 1),
    right: maxX / (sample.width - 1),
    bottom: maxY / (sample.height - 1),
    confidence: confidence,
  );
}

_ProcessResultData _processImage(_RequestData request) {
  final stopwatch = Stopwatch()..start();
  var image = _decode(request.sourcePath);
  final corners = request.corners;

  image = img.copyRectify(
    image,
    topLeft: img.Point(
      _pixel(corners[0], image.width),
      _pixel(corners[1], image.height),
    ),
    topRight: img.Point(
      _pixel(corners[2], image.width),
      _pixel(corners[3], image.height),
    ),
    bottomRight: img.Point(
      _pixel(corners[4], image.width),
      _pixel(corners[5], image.height),
    ),
    bottomLeft: img.Point(
      _pixel(corners[6], image.width),
      _pixel(corners[7], image.height),
    ),
    interpolation: img.Interpolation.linear,
  );

  if (request.quarterTurns != 0) {
    image = img.copyRotate(
      image,
      angle: request.quarterTurns * 90,
      interpolation: img.Interpolation.linear,
    );
  }

  if (request.brightness != 0 || request.contrast != 0) {
    image = img.adjustColor(
      image,
      brightness: 1 + request.brightness * 0.5,
      contrast: 1 + request.contrast * 0.5,
    );
  }
  if (request.sharpness > 0) {
    image = img.convolution(
      image,
      filter: const <num>[0, -1, 0, -1, 5, -1, 0, -1, 0],
      amount: request.sharpness,
    );
  }

  image = _applyTemplate(image, request.template);
  final bytes = img.encodeJpg(image, quality: LocalImageProcessor.jpegQuality);
  final destination = File(
    p.join(request.outputDirectory, '${request.outputId}.jpg'),
  );
  final staged = File('${destination.path}.tmp');
  try {
    staged.writeAsBytesSync(bytes, flush: true);
    if (destination.existsSync()) destination.deleteSync();
    staged.renameSync(destination.path);
  } on FileSystemException {
    if (staged.existsSync()) staged.deleteSync();
    rethrow;
  }
  stopwatch.stop();

  return _ProcessResultData(
    path: destination.path,
    width: image.width,
    height: image.height,
    byteSize: bytes.length,
    elapsedMicroseconds: stopwatch.elapsedMicroseconds,
  );
}

img.Image _decode(String sourcePath) {
  final source = File(sourcePath);
  if (!source.existsSync()) {
    throw const ImageProcessingFailure('找不到原图，请重新拍摄或选择。');
  }
  final bytes = source.readAsBytesSync();
  if (bytes.isEmpty) {
    throw const ImageProcessingFailure('原图是空文件，请重新拍摄或选择。');
  }
  var image = img.decodeImage(bytes);
  if (image == null) {
    throw const ImageProcessingFailure('当前图片格式无法处理，请改用 JPEG 或 PNG。');
  }
  image = img.bakeOrientation(image);
  if (image.width * image.height > LocalImageProcessor.maxDecodedPixels) {
    throw const ImageProcessingFailure('图片分辨率过高，请使用不超过 48MP 的图片。');
  }
  final longEdge = math.max(image.width, image.height);
  if (longEdge > LocalImageProcessor.maxLongEdge) {
    final scale = LocalImageProcessor.maxLongEdge / longEdge;
    image = img.copyResize(
      image,
      width: math.max(1, (image.width * scale).round()),
      height: math.max(1, (image.height * scale).round()),
      interpolation: img.Interpolation.linear,
    );
  }
  return image;
}

int _pixel(double normalized, int size) =>
    (normalized * (size - 1)).round().clamp(0, size - 1);

img.Image _applyTemplate(img.Image source, int template) {
  if (template == ImageOutputTemplate.original.index) return source;

  final isSquare =
      template == ImageOutputTemplate.squareLight.index ||
      template == ImageOutputTemplate.squareDark.index;
  const standardCardAspect = 85.60 / 53.98;
  final targetAspect = isSquare ? 1.0 : standardCardAspect;
  final sourceAspect = source.width / source.height;
  final width = sourceAspect >= targetAspect
      ? source.width
      : math.max(1, (source.height * targetAspect).round());
  final height = sourceAspect >= targetAspect
      ? math.max(1, (source.width / targetAspect).round())
      : source.height;
  final dark = template == ImageOutputTemplate.squareDark.index;
  return img.copyResize(
    source,
    width: width,
    height: height,
    maintainAspect: true,
    backgroundColor: dark
        ? img.ColorRgb8(24, 27, 26)
        : img.ColorRgb8(255, 255, 255),
    interpolation: img.Interpolation.linear,
  );
}

ImageCorners _cornersFromData(_CornersData data) {
  return ImageCorners(
    topLeft: NormalizedPoint(data.left, data.top),
    topRight: NormalizedPoint(data.right, data.top),
    bottomRight: NormalizedPoint(data.right, data.bottom),
    bottomLeft: NormalizedPoint(data.left, data.bottom),
  );
}

_RequestData _requestData(
  ImageProcessingRequest request,
  String outputDirectory,
) {
  final corners = request.settings.corners;
  return _RequestData(
    sourcePath: request.sourcePath,
    outputDirectory: outputDirectory,
    outputId: request.outputId,
    corners: <double>[
      corners.topLeft.x,
      corners.topLeft.y,
      corners.topRight.x,
      corners.topRight.y,
      corners.bottomRight.x,
      corners.bottomRight.y,
      corners.bottomLeft.x,
      corners.bottomLeft.y,
    ],
    quarterTurns: request.settings.quarterTurns,
    brightness: request.settings.adjustments.brightness,
    contrast: request.settings.adjustments.contrast,
    sharpness: request.settings.adjustments.sharpness,
    template: request.settings.template.index,
  );
}

final class _CornersData {
  const _CornersData({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.confidence,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;
  final double confidence;
}

final class _RequestData {
  const _RequestData({
    required this.sourcePath,
    required this.outputDirectory,
    required this.outputId,
    required this.corners,
    required this.quarterTurns,
    required this.brightness,
    required this.contrast,
    required this.sharpness,
    required this.template,
  });

  final String sourcePath;
  final String outputDirectory;
  final String outputId;
  final List<double> corners;
  final int quarterTurns;
  final double brightness;
  final double contrast;
  final double sharpness;
  final int template;
}

final class _ProcessResultData {
  const _ProcessResultData({
    required this.path,
    required this.width,
    required this.height,
    required this.byteSize,
    required this.elapsedMicroseconds,
  });

  final String path;
  final int width;
  final int height;
  final int byteSize;
  final int elapsedMicroseconds;
}
