import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/features/cards/data/platform/image_picker_camera_capture.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

final class FakeImagePicker extends ImagePicker {
  FakeImagePicker({this.picked, this.pickError, LostDataResponse? lost})
    : lost = lost ?? LostDataResponse.empty();

  final XFile? picked;
  final PlatformException? pickError;
  final LostDataResponse lost;
  ImageSource? requestedSource;
  bool? requestedFullMetadata;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    requestedSource = source;
    requestedFullMetadata = requestFullMetadata;
    if (pickError != null) throw pickError!;
    return picked;
  }

  @override
  Future<LostDataResponse> retrieveLostData() async => lost;
}

void main() {
  test('requests the system camera without full metadata', () async {
    final picker = FakeImagePicker(picked: XFile('/tmp/camera.jpg'));
    final capture = ImagePickerCameraCapture(picker);

    final result = await capture.capture();

    expect(result?.path, '/tmp/camera.jpg');
    expect(picker.requestedSource, ImageSource.camera);
    expect(picker.requestedFullMetadata, isFalse);
  });

  test('treats cancellation as a normal null result', () async {
    final capture = ImagePickerCameraCapture(FakeImagePicker());

    expect(await capture.capture(), isNull);
  });

  test('maps permission errors to a safe camera failure', () async {
    final capture = ImagePickerCameraCapture(
      FakeImagePicker(
        pickError: PlatformException(code: 'camera_access_denied'),
      ),
    );

    await expectLater(
      capture.capture(),
      throwsA(
        isA<CameraAccessFailure>().having(
          (failure) => failure.userMessage,
          'message',
          contains('从相册导入'),
        ),
      ),
    );
  });

  test('recovers the single-file Android lost-data shape', () async {
    final capture = ImagePickerCameraCapture(
      FakeImagePicker(
        lost: LostDataResponse(
          file: XFile('/tmp/recovered.jpg'),
          type: RetrieveType.image,
        ),
      ),
    );

    final recovered = await capture.recoverLost();

    expect(recovered.single.path, '/tmp/recovered.jpg');
  });
}
