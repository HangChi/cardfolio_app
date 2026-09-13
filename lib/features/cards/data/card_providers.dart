import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../domain/card_models.dart';
import '../domain/card_repository.dart';
import '../domain/camera_capture.dart';
import '../domain/gallery_picker.dart';
import '../domain/image_processing.dart';
import 'card_repository_impl.dart';
import 'files/managed_image_store.dart';
import 'local/card_database.dart';
import 'platform/image_picker_camera_capture.dart';
import 'platform/image_picker_gallery.dart';

// idGeneratorProvider 已下沉到 core，这里转发导出以免既有引用全部改动。
export '../../../core/id/id_generator_providers.dart' show idGeneratorProvider;

/// 数据库实例。需要应用支持目录，由启动流程在 `ProviderScope` 中覆盖。
final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw StateError('appDatabaseProvider 必须由启动流程覆盖');
});

/// 受管图片存储。同样在启动流程中覆盖。
final Provider<ManagedImageStore> managedImageStoreProvider =
    Provider<ManagedImageStore>((ref) {
      throw StateError('managedImageStoreProvider 必须由启动流程覆盖');
    });

final Provider<Clock> clockProvider = Provider<Clock>(
  (ref) => const SystemClock(),
);

final Provider<GalleryPicker> galleryPickerProvider = Provider<GalleryPicker>(
  (ref) => ImagePickerGallery(),
);

final Provider<CameraCapture> cameraCaptureProvider = Provider<CameraCapture>(
  (ref) => ImagePickerCameraCapture(),
);

final Provider<ImageProcessor> imageProcessorProvider =
    Provider<ImageProcessor>((ref) {
      throw StateError('imageProcessorProvider 必须由启动流程覆盖');
    });

final Provider<CardRepository> cardRepositoryProvider =
    Provider<CardRepository>((ref) {
      return CardRepositoryImpl(
        database: ref.watch(appDatabaseProvider),
        imageStore: ref.watch(managedImageStoreProvider),
        clock: ref.watch(clockProvider),
      );
    });

/// 收藏列表数据流。
final StreamProvider<List<CardSummary>> cardListProvider =
    StreamProvider<List<CardSummary>>(
      (ref) => ref.watch(cardRepositoryProvider).watchCards(),
    );

/// 单张卡片详情数据流。
///
/// flutter_riverpod 3 不再导出 family 的具体类型，这里依赖类型推断。
/// autoDispose 确保离开详情页后释放底层的 Drift watch 流，避免长会话下
/// 累积的流在每次写库时被全部唤醒。
final cardDetailProvider = StreamProvider.autoDispose
    .family<CardDetail?, String>(
      (ref, cardItemId) =>
          ref.watch(cardRepositoryProvider).watchCard(cardItemId),
    );
