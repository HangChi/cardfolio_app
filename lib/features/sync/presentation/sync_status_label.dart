import '../domain/sync_models.dart';

/// 账号与同步状态的统一文案，供我的页状态卡与账号页共用。
String syncStatusLabel(SyncOverview overview) {
  if (!overview.enabled) return '同步已关闭';
  if (overview.conflictCount > 0) {
    return '需要处理 ${overview.conflictCount} 个冲突';
  }
  if (overview.lastErrorCode != null) return '同步失败，本地更改已保留';
  if (overview.pendingCount > 0) return '待同步 ${overview.pendingCount} 项';
  if (overview.lastSyncedAt != null) return '已同步';
  return '等待首次同步';
}
