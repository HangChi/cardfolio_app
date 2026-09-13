import 'package:cardfolio_app/features/sync/data/sync_providers.dart';
import 'package:cardfolio_app/features/sync/domain/sync_models.dart';
import 'package:cardfolio_app/features/sync/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  late FakeAccountSyncRepository repository;

  setUp(() {
    repository = FakeAccountSyncRepository();
  });

  Future<void> pumpProfile(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountSyncRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('profile shows a compact local-mode account tile', (
    tester,
  ) async {
    await pumpProfile(tester);

    final tile = find.byKey(const Key('account-status-tile'));
    expect(tile, findsOneWidget);
    expect(find.text('本地模式 · 未登录'), findsOneWidget);
    expect(find.text('登录后可开启云同步'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('profile account tile surfaces email and pending count', (
    tester,
  ) async {
    repository.overview = SyncOverview(
      account: const AccountSummary(
        userId: 'user-1',
        email: 'collector@example.test',
      ),
      enabled: true,
      phase: SyncPhase.pending,
      pendingCount: 20,
      conflictCount: 0,
      lastSyncedAt: null,
      lastErrorCode: null,
    );
    await pumpProfile(tester);

    expect(find.text('collector@example.test'), findsOneWidget);
    expect(find.text('待同步 20 项'), findsOneWidget);
  });

  testWidgets('profile keeps the rest of the hub entries', (tester) async {
    await pumpProfile(tester);

    expect(find.text('整理管理'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('回收站'),
      find.byType(Scrollable).first,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    expect(find.text('导入与导出'), findsOneWidget);
    expect(find.text('回收站'), findsOneWidget);
  });
}
