import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/core/time/clock.dart';
import 'package:cardfolio_app/features/cards/data/card_providers.dart';
import 'package:cardfolio_app/features/recycle_bin/data/recycle_bin_providers.dart';
import 'package:cardfolio_app/features/recycle_bin/domain/recycle_bin_models.dart';
import 'package:cardfolio_app/features/recycle_bin/presentation/recycle_bin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_recycle_bin_repository.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    FakeRecycleBinRepository repository,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recycleBinRepositoryProvider.overrideWithValue(repository),
          clockProvider.overrideWithValue(
            FixedClock(DateTime.utc(2026, 7, 29)),
          ),
        ],
        child: const MaterialApp(home: RecycleBinScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows an actionable empty state', (tester) async {
    await pump(tester, FakeRecycleBinRepository());

    expect(find.text('回收站是空的'), findsOneWidget);
    expect(find.textContaining('删除的卡片会在这里保留'), findsOneWidget);
  });

  testWidgets('restores a listed card', (tester) async {
    final repository = FakeRecycleBinRepository(
      entries: <RecycleBinEntry>[
        RecycleBinEntry(
          cardItemId: 'item-1',
          name: '樱花纪念卡',
          deletedAt: DateTime.utc(2026, 7, 29),
          imageCount: 2,
        ),
      ],
    );
    await pump(tester, repository);

    expect(find.text('樱花纪念卡'), findsOneWidget);
    expect(find.textContaining('剩余 30 天'), findsOneWidget);
    await tester.tap(find.byKey(const Key('restore-item-1')));
    await tester.pumpAndSettle();

    expect(repository.restoredCardId, 'item-1');
  });

  testWidgets('previews impact before permanent deletion', (tester) async {
    final repository = FakeRecycleBinRepository(
      entries: <RecycleBinEntry>[
        RecycleBinEntry(
          cardItemId: 'item-1',
          name: '樱花纪念卡',
          deletedAt: DateTime.utc(2026, 7, 29),
          imageCount: 2,
        ),
      ],
      impact: const PermanentDeletionImpact(
        imageCount: 2,
        fileCount: 3,
        purchaseAssociationCount: 1,
      ),
    );
    await pump(tester, repository);

    await tester.tap(find.byKey(const Key('permanently-delete-item-1')));
    await tester.pumpAndSettle();

    expect(find.textContaining('2 条图片记录'), findsOneWidget);
    expect(find.textContaining('3 个图片文件'), findsOneWidget);
    expect(find.textContaining('1 条购买关联'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '永久删除').last);
    await tester.pumpAndSettle();
    expect(repository.permanentlyDeletedCardId, 'item-1');
  });

  testWidgets('updates the retention period', (tester) async {
    final repository = FakeRecycleBinRepository();
    await pump(tester, repository);

    await tester.tap(find.byKey(const Key('retention-days')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('7 天').last);
    await tester.pumpAndSettle();

    expect(repository.updatedRetentionDays, 7);
  });

  testWidgets('shows a retry action when reading fails', (tester) async {
    final repository = FakeRecycleBinRepository(
      entriesStream: () => Stream<List<RecycleBinEntry>>.error(
        const DatabaseUnavailableFailure('回收站操作失败，请重试。'),
      ),
    );
    await pump(tester, repository);

    expect(find.text('回收站暂时无法加载'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
  });
}
