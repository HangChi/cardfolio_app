import 'package:cardfolio_app/features/recycle_bin/domain/recycle_bin_models.dart';
import 'package:cardfolio_app/features/recycle_bin/domain/recycle_bin_repository.dart';

final class FakeRecycleBinRepository implements RecycleBinRepository {
  FakeRecycleBinRepository({
    this.entries = const <RecycleBinEntry>[],
    this.settings = const RecycleBinSettings(),
    this.entriesStream,
    this.impact = const PermanentDeletionImpact(
      imageCount: 0,
      fileCount: 0,
      purchaseAssociationCount: 0,
    ),
  });

  final List<RecycleBinEntry> entries;
  final RecycleBinSettings settings;
  final Stream<List<RecycleBinEntry>> Function()? entriesStream;
  final PermanentDeletionImpact impact;

  String? deletedCardId;
  String? restoredCardId;
  String? permanentlyDeletedCardId;
  int? updatedRetentionDays;

  @override
  Future<void> deleteCard(String cardItemId) async {
    deletedCardId = cardItemId;
  }

  @override
  Future<void> restoreCard(String cardItemId) async {
    restoredCardId = cardItemId;
  }

  @override
  Future<PermanentDeletionImpact> previewPermanentDeletion(
    String cardItemId,
  ) async => impact;

  @override
  Future<void> permanentlyDelete(String cardItemId) async {
    permanentlyDeletedCardId = cardItemId;
  }

  @override
  Future<int> purgeExpired() async => 0;

  @override
  Future<void> retryPendingFileCleanup() async {}

  @override
  Future<void> updateRetentionDays(int days) async {
    updatedRetentionDays = days;
  }

  @override
  Stream<List<RecycleBinEntry>> watchEntries() =>
      entriesStream?.call() ?? Stream<List<RecycleBinEntry>>.value(entries);

  @override
  Stream<RecycleBinSettings> watchSettings() =>
      Stream<RecycleBinSettings>.value(settings);
}
