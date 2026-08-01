import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../app/app_theme.dart';
import '../../../core/widgets/app_layout.dart';
import '../../../core/widgets/app_surface.dart';
import 'account_sync_panel.dart';

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
            const AccountSyncPanel(),
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
