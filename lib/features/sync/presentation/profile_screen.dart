import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../app/app_theme.dart';
import 'account_sync_panel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.spaceLg,
          tokens.spaceMd,
          tokens.spaceLg,
          tokens.spaceXl,
        ),
        children: <Widget>[
          const AccountSyncPanel(),
          SizedBox(height: tokens.spaceMd),
          _entry(
            context,
            icon: Icons.tune,
            title: '整理管理',
            subtitle: '管理标签、系列和自定义字段。',
            path: organizationSettingsPath,
          ),
          _entry(
            context,
            icon: Icons.receipt_long_outlined,
            title: '购买记录',
            subtitle: '记录购买、分摊与退款，按原币种查看累计花费。',
            path: purchasesPath,
          ),
          _entry(
            context,
            icon: Icons.delete_outline,
            title: '回收站',
            subtitle: '恢复已删除卡片，或将其永久删除。',
            path: recycleBinPath,
          ),
          _entry(
            context,
            icon: Icons.import_export_outlined,
            title: '导入与导出',
            subtitle: '备份、恢复或合并你的全部收藏数据。',
            path: backupPath,
          ),
        ],
      ),
    );
  }

  Widget _entry(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String path,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(path),
      ),
    );
  }
}
