import 'dart:async';

import 'package:cardfolio_app/features/sync/data/sync_scheduler.dart';
import 'package:cardfolio_app/features/sync/domain/account_sync_repository.dart';
import 'package:cardfolio_app/features/sync/domain/sync_models.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeSyncRepository implements AccountSyncRepository {
  _FakeSyncRepository(this.overview, {this.syncGate});

  SyncOverview overview;
  Completer<void>? syncGate;
  int syncNowCalls = 0;

  @override
  Stream<SyncOverview> watchOverview() async* {
    yield overview;
  }

  @override
  Future<void> syncNow() async {
    syncNowCalls++;
    await syncGate?.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('#${invocation.memberName}');
}

const _account = AccountSummary(userId: 'user-1', email: 'a@b.c');

SyncOverview _overview({
  required bool enabled,
  AccountSummary? account,
  int pendingCount = 0,
  DateTime? lastSyncedAt,
}) {
  return SyncOverview(
    account: account,
    enabled: enabled,
    phase: SyncPhase.synced,
    pendingCount: pendingCount,
    conflictCount: 0,
    lastSyncedAt: lastSyncedAt,
    lastErrorCode: null,
  );
}

void main() {
  final now = DateTime(2026, 9, 13, 12);

  test('local-only overview never triggers a sync', () async {
    final repository = _FakeSyncRepository(const SyncOverview.localOnly());
    final scheduler = SyncAutoScheduler(repository: repository, now: () => now);

    await scheduler.trigger();

    expect(repository.syncNowCalls, 0);
  });

  test('signed-in but disabled sync never triggers a sync', () async {
    final repository = _FakeSyncRepository(
      _overview(enabled: false, account: _account),
    );
    final scheduler = SyncAutoScheduler(repository: repository, now: () => now);

    await scheduler.trigger();

    expect(repository.syncNowCalls, 0);
  });

  test('due pending mutations trigger a sync', () async {
    final repository = _FakeSyncRepository(
      _overview(enabled: true, account: _account, pendingCount: 2),
    );
    final scheduler = SyncAutoScheduler(repository: repository, now: () => now);

    await scheduler.trigger();

    expect(repository.syncNowCalls, 1);
  });

  test('fresh synced state does not trigger a sync', () async {
    final repository = _FakeSyncRepository(
      _overview(
        enabled: true,
        account: _account,
        lastSyncedAt: now.subtract(const Duration(minutes: 30)),
      ),
    );
    final scheduler = SyncAutoScheduler(repository: repository, now: () => now);

    await scheduler.trigger();

    expect(repository.syncNowCalls, 0);
  });

  test(
    'stale last sync triggers a pull even without pending mutations',
    () async {
      final repository = _FakeSyncRepository(
        _overview(
          enabled: true,
          account: _account,
          lastSyncedAt: now.subtract(const Duration(hours: 7)),
        ),
      );
      final scheduler = SyncAutoScheduler(
        repository: repository,
        now: () => now,
      );

      await scheduler.trigger();

      expect(repository.syncNowCalls, 1);
    },
  );

  test('never synced before triggers immediately once enabled', () async {
    final repository = _FakeSyncRepository(
      _overview(enabled: true, account: _account),
    );
    final scheduler = SyncAutoScheduler(repository: repository, now: () => now);

    await scheduler.trigger();

    expect(repository.syncNowCalls, 1);
  });

  test('overlapping triggers share a single in-flight sync', () async {
    final gate = Completer<void>();
    final repository = _FakeSyncRepository(
      _overview(enabled: true, account: _account, pendingCount: 1),
      syncGate: gate,
    );
    final scheduler = SyncAutoScheduler(repository: repository, now: () => now);

    final first = scheduler.trigger();
    final second = scheduler.trigger();
    gate.complete();
    await Future.wait(<Future<void>>[first, second]);

    expect(repository.syncNowCalls, 1);
  });

  test('periodic timer keeps triggering checks while started', () async {
    final repository = _FakeSyncRepository(
      _overview(enabled: true, account: _account, pendingCount: 1),
    );
    final scheduler = SyncAutoScheduler(
      repository: repository,
      checkInterval: const Duration(milliseconds: 20),
      now: () => now,
    );

    scheduler.start();
    await Future<void>.delayed(const Duration(milliseconds: 70));
    scheduler.stop();
    final callsWhileRunning = repository.syncNowCalls;

    await Future<void>.delayed(const Duration(milliseconds: 70));

    expect(callsWhileRunning, greaterThanOrEqualTo(1));
    expect(repository.syncNowCalls, callsWhileRunning);
  });

  test('scheduler failures are swallowed silently', () async {
    final scheduler = SyncAutoScheduler(
      repository: _ThrowingOverviewRepository(),
      now: () => now,
    );

    // 不抛错：调度失败保留队列与退避状态，由下一次到点重试。
    await scheduler.trigger();
  });
}

final class _ThrowingOverviewRepository implements AccountSyncRepository {
  @override
  Stream<SyncOverview> watchOverview() async* {
    throw StateError('overview unavailable');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('#${invocation.memberName}');
}
