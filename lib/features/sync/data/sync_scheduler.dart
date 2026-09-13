import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/account_sync_repository.dart';

/// 同步自动调度器：周期到点或 App 回到前台时检查一次同步状态。
///
/// 只有在「同步已启用 + 已登录 +（存在到期未推送变更 或 距上次成功同步
/// 超过 [staleThreshold]）」时才真正触发 [AccountSyncRepository.syncNow]，
/// 避免空闲时反复执行全库变更捕获。调度失败一律静默：outbox 与退避状态
/// 由同步层维护，下一次到点会自动重试。
class SyncAutoScheduler {
  factory SyncAutoScheduler({
    required AccountSyncRepository repository,
    Duration checkInterval = const Duration(minutes: 15),
    Duration staleThreshold = const Duration(hours: 6),
    DateTime Function()? now,
  }) => SyncAutoScheduler._(
    repository,
    checkInterval,
    staleThreshold,
    now ?? DateTime.now,
  );

  SyncAutoScheduler._(
    this._repository,
    this.checkInterval,
    this.staleThreshold,
    this._now,
  );

  final AccountSyncRepository _repository;

  /// 周期检查间隔。App 在前台存活期间每个间隔检查一次。
  final Duration checkInterval;

  /// 距上次成功同步超过该时长时，即使没有本地待推送变更也补一次
  /// 增量拉取，让多设备编辑最终可见。
  final Duration staleThreshold;

  final DateTime Function() _now;

  Timer? _timer;
  Future<void>? _running;

  /// 开始周期检查；重复调用无副作用。
  void start() {
    _timer ??= Timer.periodic(checkInterval, (_) => trigger());
  }

  /// 停止周期检查；进行中的检查不受影响。
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// 立即检查一次；App 从后台恢复前台时调用。
  ///
  /// 与进行中的检查单飞合并，避免恢复瞬间重复触发。
  Future<void> trigger() {
    final running = _running;
    if (running != null) return running;
    final operation = _tick();
    _running = operation;
    return operation.whenComplete(() {
      if (identical(_running, operation)) _running = null;
    });
  }

  Future<void> _tick() async {
    try {
      final overview = await _repository.watchOverview().first;
      final lastSyncedAt = overview.lastSyncedAt;
      final hasDueWork =
          overview.pendingCount > 0 ||
          lastSyncedAt == null ||
          _now().difference(lastSyncedAt) > staleThreshold;
      if (!overview.enabled || overview.account == null || !hasDueWork) {
        return;
      }
      await _repository.syncNow();
    } on Object {
      // 静默处理：失败保留队列与退避状态，下次到点自动重试。
    }
  }
}

/// 未注入同步依赖时为 null；生产环境由启动流程用真实同步仓库覆盖，
/// 测试或纯本地模式保持 null 即不启动自动调度。
final Provider<SyncAutoScheduler?> syncAutoSchedulerProvider =
    Provider<SyncAutoScheduler?>((ref) => null);
