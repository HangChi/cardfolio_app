import '../../../core/errors/app_failure.dart';
import '../../../core/time/clock.dart';
import '../../cards/data/files/managed_image_store.dart';
import '../../cards/data/local/card_database.dart';
import '../domain/recycle_bin_models.dart';
import '../domain/recycle_bin_repository.dart';
import 'local/recycle_bin_database.dart';

final class RecycleBinRepositoryImpl implements RecycleBinRepository {
  const RecycleBinRepositoryImpl({
    required AppDatabase database,
    required ManagedImageStore imageStore,
    required this.clock,
  }) : _db = database,
       _images = imageStore;

  final AppDatabase _db;
  final ManagedImageStore _images;
  final Clock clock;

  @override
  Stream<List<RecycleBinEntry>> watchEntries() async* {
    try {
      yield* _db.watchRecycleBinEntries();
    } on Object catch (error) {
      throw _mapFailure(error);
    }
  }

  @override
  Stream<RecycleBinSettings> watchSettings() =>
      _mapStream(_db.watchRecycleBinSettings());

  @override
  Future<void> deleteCard(String cardItemId) {
    return _run(() => _db.softDeleteCard(cardItemId, clock.nowUtc()));
  }

  @override
  Future<void> restoreCard(String cardItemId) {
    return _run(() => _db.restoreCard(cardItemId, clock.nowUtc()));
  }

  @override
  Future<PermanentDeletionImpact> previewPermanentDeletion(String cardItemId) {
    return _run(() => _db.previewPermanentDeletion(cardItemId));
  }

  @override
  Future<void> permanentlyDelete(String cardItemId) {
    return _run(() async {
      await _db.permanentlyDeleteCard(cardItemId, clock.nowUtc());
      await retryPendingFileCleanup();
    });
  }

  @override
  Future<void> updateRetentionDays(int days) {
    if (!RecycleBinSettings.isSupported(days)) {
      return Future<void>.error(
        RecycleBinValidationFailure(
          RecycleBinField.retention,
          '保留期只支持 7、30 或 90 天。',
          ArgumentError.value(days, 'days'),
        ),
      );
    }
    return _run(() => _db.updateRecycleBinRetention(days, clock.nowUtc()));
  }

  @override
  Future<int> purgeExpired() {
    return _run(() async {
      final days = await _db.currentRecycleBinRetentionDays();
      final ids = await _db.expiredRecycleBinIds(
        nowUtc: clock.nowUtc(),
        retentionDays: days,
      );
      for (final id in ids) {
        await _db.permanentlyDeleteCard(id, clock.nowUtc());
      }
      await retryPendingFileCleanup();
      return ids.length;
    });
  }

  @override
  Future<void> retryPendingFileCleanup() {
    return _run(() async {
      final pending = await _db.pendingFileCleanup();
      for (final entry in pending) {
        try {
          await _images.delete(entry.relativePath);
          await _db.completeFileCleanup(entry.relativePath);
        } on Object {
          await _db.markFileCleanupAttempt(entry.relativePath, clock.nowUtc());
        }
      }
    });
  }

  Stream<T> _mapStream<T>(Stream<T> source) async* {
    try {
      yield* source;
    } on Object catch (error) {
      throw _mapFailure(error);
    }
  }

  Future<T> _run<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on AppFailure {
      rethrow;
    } on ArgumentError catch (error) {
      throw RecycleBinValidationFailure(
        RecycleBinField.retention,
        '保留期只支持 7、30 或 90 天。',
        error,
      );
    } on StateError catch (error) {
      throw RecycleBinValidationFailure(
        RecycleBinField.card,
        '这张卡片当前无法执行该回收站操作。',
        error,
      );
    } on Object catch (error) {
      throw DatabaseUnavailableFailure('回收站操作失败，请重试。', error);
    }
  }

  AppFailure _mapFailure(Object error) {
    if (error is AppFailure) return error;
    return DatabaseUnavailableFailure('回收站操作失败，请重试。', error);
  }
}
