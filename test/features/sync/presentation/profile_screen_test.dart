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

  testWidgets('local mode explains offline use and submits login', (
    tester,
  ) async {
    await pumpProfile(tester);

    expect(find.text('本地模式'), findsOneWidget);
    expect(find.textContaining('无需账号'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('account-email')),
      'collector@example.test',
    );
    await tester.enterText(
      find.byKey(const Key('account-password')),
      'password-123',
    );
    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    await tester.pumpAndSettle();

    expect(repository.loginEmail, 'collector@example.test');
    expect(repository.loginPassword, 'password-123');
  });

  testWidgets('signed-in mode shows queue, toggle and manual retry', (
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
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );

    await tester.tap(find.text('立即同步'));
    await tester.pumpAndSettle();
    expect(repository.syncCalls, 1);
  });

  testWidgets('conflict copy offers local and remote resolution', (
    tester,
  ) async {
    repository.overview = SyncOverview(
      account: const AccountSummary(
        userId: 'user-1',
        email: 'collector@example.test',
      ),
      enabled: true,
      phase: SyncPhase.conflicts,
      pendingCount: 1,
      conflictCount: 1,
      lastSyncedAt: null,
      lastErrorCode: null,
    );
    repository.conflicts = <SyncConflict>[
      SyncConflict(
        id: 'conflict-1',
        entityType: 'cardDefinitions',
        entityId: 'definition-1',
        localOperation: SyncOperation.upsert,
        localPayload: const <String, Object?>{'name': '本地名称'},
        remoteOperation: SyncOperation.upsert,
        remotePayload: const <String, Object?>{'name': '远端名称'},
        remoteServerVersion: 2,
        conflictingFields: const <String>{'name'},
        detectedAt: DateTime.utc(2026, 7, 29),
      ),
    ];
    await pumpProfile(tester);

    expect(find.text('需要处理 1 个冲突'), findsWidgets);
    expect(find.textContaining('本地名称'), findsOneWidget);
    expect(find.textContaining('远端名称'), findsOneWidget);

    await tester.ensureVisible(find.text('保留本地'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('保留本地'));
    await tester.pumpAndSettle();
    expect(repository.resolvedConflictId, 'conflict-1');
    expect(repository.resolution, SyncConflictResolution.keepLocal);
  });

  testWidgets('account deletion confirms whether to remove local copy', (
    tester,
  ) async {
    repository.overview = SyncOverview(
      account: const AccountSummary(
        userId: 'user-1',
        email: 'collector@example.test',
      ),
      enabled: false,
      phase: SyncPhase.disabled,
      pendingCount: 0,
      conflictCount: 0,
      lastSyncedAt: null,
      lastErrorCode: null,
    );
    await pumpProfile(tester);

    await tester.tap(find.text('删除账号与云端数据'));
    await tester.pumpAndSettle();
    expect(find.textContaining('不可撤销'), findsOneWidget);

    await tester.tap(find.text('同时删除本地副本'));
    await tester.tap(find.widgetWithText(FilledButton, '确认删除账号'));
    await tester.pumpAndSettle();

    expect(repository.deleteLocalCopy, isTrue);
  });
}
