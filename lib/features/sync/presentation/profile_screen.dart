import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../app/app_theme.dart';
import '../../../core/widgets/app_layout.dart';
import '../../../core/widgets/app_surface.dart';
import '../data/sync_providers.dart';
import 'sync_status_label.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: AppContentView(
        child: ListView(
          children: <Widget>[
            const AppPageHeader(
              eyebrow: 'MY CARDFOLIO',
              title: '我的',
              subtitle: '管理账号、收藏结构与本地数据。',
            ),
            const AppSectionHeader(
              title: '账号与同步',
              icon: Icons.cloud_sync_outlined,
              subtitle: '本地收藏始终可用，登录后可选择开启同步。',
            ),
            const _AccountStatusTile(),
            SizedBox(height: tokens.spaceLg),
            const AppSectionHeader(
              title: '收藏整理',
              icon: Icons.auto_awesome_motion_outlined,
            ),
            AppActionTile(
              icon: Icons.tune_rounded,
              title: '整理管理',
              subtitle: '管理标签、集卡册和自定义字段。',
              onTap: () => context.push(organizationSettingsPath),
            ),
            SizedBox(height: tokens.spaceSm),
            AppActionTile(
              icon: Icons.settings_outlined,
              title: '应用设置',
              subtitle: '设置外观、权限、存储空间与诊断。',
              onTap: () => context.push(appSettingsPath),
            ),
            SizedBox(height: tokens.spaceLg),
            const AppSectionHeader(
              title: '数据管理',
              icon: Icons.folder_copy_outlined,
              subtitle: '导出、备份或恢复你的收藏数据。',
            ),
            AppActionTile(
              icon: Icons.import_export_outlined,
              title: '导入与导出',
              subtitle: '备份、恢复或合并你的全部收藏数据。',
              onTap: () => context.push(backupPath),
            ),
            SizedBox(height: tokens.spaceSm),
            AppActionTile(
              icon: Icons.table_view_outlined,
              title: '导出 CSV',
              subtitle: '导出可在 Excel 中查看的卡片清单。',
              onTap: () => context.push(csvExportPath),
            ),
            SizedBox(height: tokens.spaceLg),
            const AppSectionHeader(
              title: '回收与恢复',
              icon: Icons.restore_from_trash_outlined,
            ),
            AppActionTile(
              icon: Icons.delete_outline,
              title: '回收站',
              subtitle: '恢复已删除卡片，或将其永久删除。',
              destructive: true,
              onTap: () => context.push(recycleBinPath),
            ),
          ],
        ),
      ),
    );
  }
}

/// 我的页的账号状态卡：本地模式或登录邮箱 + 同步状态，点击进入账号页。
class _AccountStatusTile extends ConsumerWidget {
  const _AccountStatusTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(syncOverviewProvider);
    return Card(
      child: overview.when(
        loading: () => const ListTile(
          leading: CircleAvatar(child: Icon(Icons.cloud_outlined)),
          title: Text('正在读取同步状态…'),
        ),
        error: (error, stackTrace) => ListTile(
          key: const Key('account-status-tile'),
          leading: const CircleAvatar(child: Icon(Icons.cloud_off_outlined)),
          title: const Text('账号与同步'),
          subtitle: const Text('同步状态暂时无法读取，本地数据不受影响。'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(accountPath),
        ),
        data: (value) {
          final account = value.account;
          return ListTile(
            key: const Key('account-status-tile'),
            leading: CircleAvatar(
              child: Icon(
                account == null
                    ? Icons.cloud_off_outlined
                    : Icons.cloud_done_outlined,
              ),
            ),
            title: Text(
              account == null ? '本地模式 · 未登录' : account.email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              account == null ? '登录后可开启云同步' : syncStatusLabel(value),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(accountPath),
          );
        },
      ),
    );
  }
}
