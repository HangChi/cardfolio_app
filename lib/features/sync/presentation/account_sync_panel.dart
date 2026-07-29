import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme.dart';
import '../../../core/errors/app_failure.dart';
import '../data/sync_providers.dart';
import '../domain/sync_models.dart';

class AccountSyncPanel extends ConsumerStatefulWidget {
  const AccountSyncPanel({super.key});

  @override
  ConsumerState<AccountSyncPanel> createState() => _AccountSyncPanelState();
}

class _AccountSyncPanelState extends ConsumerState<AccountSyncPanel> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overview = ref.watch(syncOverviewProvider);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceLg),
        child: overview.when(
          loading: () => const Center(
            child: CircularProgressIndicator(semanticsLabel: '正在读取同步状态'),
          ),
          error: (error, stackTrace) => const Text('同步状态暂时无法读取，本地数据不受影响。'),
          data: (value) => value.account == null
              ? _buildSignedOut(context)
              : _buildSignedIn(context, value),
        ),
      ),
    );
  }

  Widget _buildSignedOut(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('账号与同步', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: context.tokens.spaceXs),
        Text(
          '本地模式',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.primary),
        ),
        SizedBox(height: context.tokens.spaceXs),
        const Text('无需账号也能创建、浏览、编辑、统计和导出；登录只用于可选云同步。'),
        SizedBox(height: context.tokens.spaceMd),
        TextField(
          key: const Key('account-email'),
          controller: _email,
          enabled: !_busy,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const <String>[AutofillHints.email],
          decoration: const InputDecoration(labelText: '邮箱'),
        ),
        SizedBox(height: context.tokens.spaceSm),
        TextField(
          key: const Key('account-password'),
          controller: _password,
          enabled: !_busy,
          obscureText: true,
          autofillHints: const <String>[AutofillHints.password],
          decoration: const InputDecoration(labelText: '密码（至少 8 位）'),
        ),
        SizedBox(height: context.tokens.spaceMd),
        Wrap(
          spacing: context.tokens.spaceSm,
          runSpacing: context.tokens.spaceSm,
          children: <Widget>[
            FilledButton(
              onPressed: _busy ? null : () => _authenticate(register: false),
              child: const Text('登录'),
            ),
            OutlinedButton(
              onPressed: _busy ? null : () => _authenticate(register: true),
              child: const Text('注册'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignedIn(BuildContext context, SyncOverview overview) {
    final conflicts = ref.watch(syncConflictsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('账号与同步', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: context.tokens.spaceSm),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(child: Icon(Icons.person_outline)),
          title: Text(overview.account!.email),
          subtitle: Text(_statusLabel(overview)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('云同步'),
          subtitle: const Text('关闭后仍可完整使用本地收藏。'),
          value: overview.enabled,
          onChanged: _busy
              ? null
              : (enabled) => _run(
                  () => ref
                      .read(accountSyncRepositoryProvider)
                      .setSyncEnabled(enabled),
                ),
        ),
        if (overview.enabled)
          FilledButton.tonalIcon(
            onPressed: _busy
                ? null
                : () => _run(ref.read(accountSyncRepositoryProvider).syncNow),
            icon: const Icon(Icons.sync),
            label: const Text('立即同步'),
          ),
        if (overview.conflictCount > 0) ...<Widget>[
          SizedBox(height: context.tokens.spaceMd),
          Text(
            '需要处理 ${overview.conflictCount} 个冲突',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.error),
          ),
          SizedBox(height: context.tokens.spaceSm),
          conflicts.when(
            loading: () =>
                const LinearProgressIndicator(semanticsLabel: '正在加载冲突副本'),
            error: (error, stackTrace) => const Text('冲突副本暂时无法读取。'),
            data: (items) => Column(
              children: <Widget>[
                for (final conflict in items) _conflictCard(conflict),
              ],
            ),
          ),
        ],
        SizedBox(height: context.tokens.spaceLg),
        const Divider(),
        Wrap(
          spacing: context.tokens.spaceSm,
          runSpacing: context.tokens.spaceSm,
          children: <Widget>[
            TextButton(
              onPressed: _busy ? null : _confirmSignOut,
              child: const Text('退出账号'),
            ),
            TextButton(
              onPressed: _busy ? null : _confirmDeleteAccount,
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('删除账号与云端数据'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _conflictCard(SyncConflict conflict) {
    return Card(
      color: AppColors.error.withValues(alpha: 0.06),
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              '${_entityLabel(conflict.entityType)} · '
              '${conflict.conflictingFields.join('、')}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: context.tokens.spaceXs),
            Text('本地：${_payloadSummary(conflict.localPayload)}'),
            Text('远端：${_payloadSummary(conflict.remotePayload)}'),
            SizedBox(height: context.tokens.spaceSm),
            Wrap(
              spacing: context.tokens.spaceSm,
              children: <Widget>[
                OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => _resolve(
                          conflict.id,
                          SyncConflictResolution.keepLocal,
                        ),
                  child: const Text('保留本地'),
                ),
                OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => _resolve(
                          conflict.id,
                          SyncConflictResolution.useRemote,
                        ),
                  child: const Text('采用远端'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _authenticate({required bool register}) {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.length < 8) {
      _showMessage('请输入有效邮箱和至少 8 位密码。');
      return Future<void>.value();
    }
    final repository = ref.read(accountSyncRepositoryProvider);
    return _run(
      () => register
          ? repository.register(email: email, password: password)
          : repository.login(email: email, password: password),
    );
  }

  Future<void> _resolve(String conflictId, SyncConflictResolution resolution) =>
      _run(
        () => ref
            .read(accountSyncRepositoryProvider)
            .resolveConflict(conflictId: conflictId, resolution: resolution),
      );

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出账号？'),
        content: const Text('退出会停止同步并清除登录令牌，本地收藏和图片会完整保留。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('退出并保留本地'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _run(ref.read(accountSyncRepositoryProvider).signOut);
    }
  }

  Future<void> _confirmDeleteAccount() async {
    var deleteLocal = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('删除账号与云端数据？'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text('此操作不可撤销。云端卡片、图片和账号将被永久删除。'),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('同时删除本地副本'),
                subtitle: const Text('不勾选则本地收藏继续可离线使用。'),
                value: deleteLocal,
                onChanged: (value) =>
                    setDialogState(() => deleteLocal = value ?? false),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('确认删除账号'),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && mounted) {
      await _run(
        () => ref
            .read(accountSyncRepositoryProvider)
            .deleteAccount(deleteLocalCopy: deleteLocal),
      );
    }
  }

  Future<void> _run(Future<void> Function() operation) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await operation();
    } on AppFailure catch (failure) {
      _showMessage(failure.userMessage);
    } on Object {
      _showMessage('操作失败，本地数据不受影响，请重试。');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

String _statusLabel(SyncOverview overview) {
  if (!overview.enabled) return '同步已关闭';
  if (overview.conflictCount > 0) {
    return '需要处理 ${overview.conflictCount} 个冲突';
  }
  if (overview.lastErrorCode != null) {
    return '同步失败，本地更改已保留';
  }
  if (overview.pendingCount > 0) return '待同步 ${overview.pendingCount} 项';
  if (overview.lastSyncedAt != null) return '已同步';
  return '等待首次同步';
}

String _payloadSummary(Map<String, Object?>? payload) {
  if (payload == null) return '已删除';
  if (payload.containsKey('name')) return payload['name'].toString();
  return jsonEncode(payload);
}

String _entityLabel(String entityType) => switch (entityType) {
  'cardDefinitions' => '卡片资料',
  'cardItems' => '藏品',
  'cardImages' => '图片',
  'cardSets' => '套卡',
  'tags' => '标签',
  'seriesRecords' => '系列',
  'purchases' => '购买记录',
  _ => '收藏数据',
};
