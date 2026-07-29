import 'package:meta/meta.dart';

@immutable
final class RecycleBinSettings {
  const RecycleBinSettings({this.retentionDays = defaultRetentionDays});

  static const int defaultRetentionDays = 30;
  static const List<int> supportedRetentionDays = <int>[7, 30, 90];

  final int retentionDays;

  static bool isSupported(int days) => supportedRetentionDays.contains(days);
}

@immutable
final class RecycleBinEntry {
  const RecycleBinEntry({
    required this.cardItemId,
    required this.name,
    required this.deletedAt,
    required this.imageCount,
    this.coverRelativePath,
  });

  final String cardItemId;
  final String name;
  final DateTime deletedAt;
  final int imageCount;
  final String? coverRelativePath;

  int remainingDays({required DateTime nowUtc, required int retentionDays}) {
    final expiry = deletedAt.toUtc().add(Duration(days: retentionDays));
    final remainingSeconds = expiry.difference(nowUtc.toUtc()).inSeconds;
    if (remainingSeconds <= 0) return 0;
    return (remainingSeconds + Duration.secondsPerDay - 1) ~/
        Duration.secondsPerDay;
  }
}

@immutable
final class PermanentDeletionImpact {
  const PermanentDeletionImpact({
    required this.imageCount,
    required this.fileCount,
    required this.purchaseAssociationCount,
  });

  final int imageCount;
  final int fileCount;
  final int purchaseAssociationCount;
}
