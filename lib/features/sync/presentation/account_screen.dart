import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../../../core/widgets/app_layout.dart';
import 'account_sync_panel.dart';

/// 账号与同步独立页面：认证、同步开关、冲突处理与账号管理。
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      appBar: AppBar(title: const Text('账号与同步')),
      body: AppContentView(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: tokens.spaceMd),
          children: const <Widget>[AccountSyncPanel()],
        ),
      ),
    );
  }
}
