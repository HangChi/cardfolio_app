import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/features/cards/domain/image_processing.dart';

final class FakeImageProcessor implements ImageProcessor {
  FakeImageProcessor({EdgeDetectionResult? edges, this.processed, this.failure})
    : edges =
          edges ??
          EdgeDetectionResult(corners: ImageCorners.safeInset, confidence: 0.2);

  final EdgeDetectionResult edges;
  final ProcessedImage? processed;
  final AppFailure? failure;
  final List<ImageProcessingRequest> requests = <ImageProcessingRequest>[];

  @override
  Future<EdgeDetectionResult> detectEdges(String sourcePath) async => edges;

  @override
  Future<ProcessedImage> process(ImageProcessingRequest request) async {
    requests.add(request);
    if (failure != null) throw failure!;
    return processed ??
        const ProcessedImage(
          path: '/tmp/processed.jpg',
          width: 400,
          height: 400,
          byteSize: 1024,
          elapsed: Duration(milliseconds: 12),
        );
  }
}
