import 'package:cardfolio_app/features/recycle_bin/domain/recycle_bin_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('retention accepts only the three supported periods', () {
    for (final days in <int>[7, 30, 90]) {
      expect(RecycleBinSettings.isSupported(days), isTrue);
    }

    expect(RecycleBinSettings.isSupported(0), isFalse);
    expect(RecycleBinSettings.isSupported(14), isFalse);
    expect(RecycleBinSettings.isSupported(365), isFalse);
  });

  test('remaining days rounds a partial day up and never goes negative', () {
    final deletedAt = DateTime.utc(2026, 7, 1, 12);
    final entry = RecycleBinEntry(
      cardItemId: 'item-1',
      name: '樱花纪念卡',
      deletedAt: deletedAt,
      imageCount: 2,
    );

    expect(
      entry.remainingDays(
        nowUtc: DateTime.utc(2026, 7, 30, 13),
        retentionDays: 30,
      ),
      1,
    );
    expect(
      entry.remainingDays(nowUtc: DateTime.utc(2026, 8, 1), retentionDays: 30),
      0,
    );
  });
}
