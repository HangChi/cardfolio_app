import 'recycle_bin_models.dart';

abstract interface class RecycleBinRepository {
  Stream<List<RecycleBinEntry>> watchEntries();

  Stream<RecycleBinSettings> watchSettings();

  Future<void> deleteCard(String cardItemId);

  Future<void> restoreCard(String cardItemId);

  Future<PermanentDeletionImpact> previewPermanentDeletion(String cardItemId);

  Future<void> permanentlyDelete(String cardItemId);

  Future<void> updateRetentionDays(int days);

  Future<int> purgeExpired();

  Future<void> retryPendingFileCleanup();
}
