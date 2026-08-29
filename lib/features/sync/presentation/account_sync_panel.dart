import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme.dart';
import '../../../core/errors/app_failure.dart';
import '../data/sync_providers.dart';
import '../domain/sync_models.dart';

enum _EmailAuthStep { credentials, registrationCode, passwordResetCode }

class AccountSyncPanel extends ConsumerStatefulWidget {
  const AccountSyncPanel({super.key});

  @override
  ConsumerState<AccountSyncPanel> createState() => _AccountSyncPanelState();
}

class _AccountSyncPanelState extends ConsumerState<AccountSyncPanel> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _newPassword = TextEditingController();
  final _emailOtp = TextEditingController();
  final _phone = TextEditingController(text: '+86');
  final _otp = TextEditingController();
  var _phoneMode = false;
  var _otpSent = false;
  var _emailStep = _EmailAuthStep.credentials;
  var _phoneCreateUser = false;
  var _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _newPassword.dispose();
    _emailOtp.dispose();
    _phone.dispose();
    _otp.dispose();
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: context.tokens.spaceXs),
        const Text('无需账号也能创建、浏览、编辑、统计和导出；登录仅用于云同步。'),
        SizedBox(height: context.tokens.spaceMd),
        SegmentedButton<bool>(
          segments: const <ButtonSegment<bool>>[
            ButtonSegment<bool>(
              value: true,
              icon: Icon(Icons.phone_android_outlined),
              label: Text('手机号'),
            ),
            ButtonSegment<bool>(
              value: false,
              icon: Icon(Icons.email_outlined),
              label: Text('邮箱'),
            ),
          ],
          selected: <bool>{_phoneMode},
          onSelectionChanged: _busy
              ? null
              : (selection) => setState(() {
                  _phoneMode = selection.single;
                  _otpSent = false;
                  _otp.clear();
                  _emailStep = _EmailAuthStep.credentials;
                  _emailOtp.clear();
                  _newPassword.clear();
                }),
        ),
        SizedBox(height: context.tokens.spaceSm),
        if (_phoneMode)
          _buildPhoneAuthentication(context)
        else
          _buildEmailAuthentication(context),
      ],
    );
  }

  Widget _buildPhoneAuthentication(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          key: const Key('account-phone'),
          controller: _phone,
          enabled: !_busy && !_otpSent,
          keyboardType: TextInputType.phone,
          autofillHints: const <String>[AutofillHints.telephoneNumber],
          decoration: const InputDecoration(
            labelText: '手机号 *',
            helperText: '使用国际格式，例如 +8613812345678',
          ),
        ),
        if (_otpSent) ...<Widget>[
          SizedBox(height: context.tokens.spaceSm),
          TextField(
            key: const Key('account-otp'),
            controller: _otp,
            enabled: !_busy,
            keyboardType: TextInputType.number,
            autofillHints: const <String>[AutofillHints.oneTimeCode],
            decoration: const InputDecoration(labelText: '短信验证码 *'),
          ),
        ],
        SizedBox(height: context.tokens.spaceMd),
        if (_otpSent)
          Wrap(
            spacing: context.tokens.spaceSm,
            runSpacing: context.tokens.spaceSm,
            children: <Widget>[
              FilledButton(
                onPressed: _busy ? null : _verifyPhoneOtp,
                child: const Text('验证并登录'),
              ),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => _sendPhoneOtp(register: _phoneCreateUser),
                child: const Text('重新发送'),
              ),
            ],
          )
        else
          Wrap(
            spacing: context.tokens.spaceSm,
            runSpacing: context.tokens.spaceSm,
            children: <Widget>[
              FilledButton(
                onPressed: _busy ? null : () => _sendPhoneOtp(register: false),
                child: const Text('获取登录验证码'),
              ),
              OutlinedButton(
                onPressed: _busy ? null : () => _sendPhoneOtp(register: true),
                child: const Text('注册并获取验证码'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildEmailAuthentication(BuildContext context) {
    final waitingForCode = _emailStep != _EmailAuthStep.credentials;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          key: const Key('account-email'),
          controller: _email,
          enabled: !_busy && !waitingForCode,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const <String>[AutofillHints.email],
          decoration: const InputDecoration(labelText: '邮箱 *'),
        ),
        if (_emailStep == _EmailAuthStep.credentials) ...<Widget>[
          SizedBox(height: context.tokens.spaceSm),
          TextField(
            key: const Key('account-password'),
            controller: _password,
            enabled: !_busy,
            obscureText: true,
            autofillHints: const <String>[AutofillHints.password],
            decoration: const InputDecoration(
              labelText: '密码 *',
              helperText: '至少 8 位',
            ),
          ),
        ] else ...<Widget>[
          SizedBox(height: context.tokens.spaceSm),
          TextField(
            key: const Key('account-email-otp'),
            controller: _emailOtp,
            enabled: !_busy,
            keyboardType: TextInputType.number,
            autofillHints: const <String>[AutofillHints.oneTimeCode],
            decoration: const InputDecoration(labelText: '邮箱验证码 *'),
          ),
          if (_emailStep == _EmailAuthStep.passwordResetCode) ...<Widget>[
            SizedBox(height: context.tokens.spaceSm),
            TextField(
              key: const Key('account-new-password'),
              controller: _newPassword,
              enabled: !_busy,
              obscureText: true,
              autofillHints: const <String>[AutofillHints.newPassword],
              decoration: const InputDecoration(
                labelText: '新密码 *',
                helperText: '至少 8 位',
              ),
            ),
          ],
        ],
        SizedBox(height: context.tokens.spaceMd),
        if (_emailStep == _EmailAuthStep.registrationCode)
          Wrap(
            spacing: context.tokens.spaceSm,
            runSpacing: context.tokens.spaceSm,
            children: <Widget>[
              FilledButton(
                onPressed: _busy ? null : _verifyRegistration,
                child: const Text('验证并完成注册'),
              ),
              TextButton(
                onPressed: _busy ? null : _resendRegistration,
                child: const Text('重新发送'),
              ),
              TextButton(
                onPressed: _busy ? null : _backToLogin,
                child: const Text('返回登录'),
              ),
            ],
          )
        else if (_emailStep == _EmailAuthStep.passwordResetCode)
          Wrap(
            spacing: context.tokens.spaceSm,
            runSpacing: context.tokens.spaceSm,
            children: <Widget>[
              FilledButton(
                onPressed: _busy ? null : _verifyPasswordReset,
                child: const Text('验证并重置密码'),
              ),
              TextButton(
                onPressed: _busy ? null : _sendPasswordReset,
                child: const Text('重新发送'),
              ),
              TextButton(
                onPressed: _busy ? null : _backToLogin,
                child: const Text('返回登录'),
              ),
            ],
          )
        else
          Wrap(
            spacing: context.tokens.spaceSm,
            runSpacing: context.tokens.spaceSm,
            children: <Widget>[
              FilledButton(
                onPressed: _busy ? null : _loginWithPassword,
                child: const Text('登录'),
              ),
              OutlinedButton(
                onPressed: _busy ? null : _startRegistration,
                child: const Text('注册'),
              ),
              TextButton(
                onPressed: _busy ? null : _sendPasswordReset,
                child: const Text('忘记密码？'),
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
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
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('删除账号与云端数据'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _conflictCard(SyncConflict conflict) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
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

  bool _validEmailAndPassword({bool passwordRequired = true}) {
    final email = _email.text.trim();
    if (!email.contains('@') || email.startsWith('@') || email.endsWith('@')) {
      _showMessage('请输入有效邮箱地址。');
      return false;
    }
    if (passwordRequired && _password.text.length < 8) {
      _showMessage('密码至少需要 8 位。');
      return false;
    }
    return true;
  }

  Future<void> _loginWithPassword() {
    if (!_validEmailAndPassword()) return Future<void>.value();
    return _run(
      () => ref
          .read(accountSyncRepositoryProvider)
          .login(email: _email.text.trim(), password: _password.text),
    );
  }

  Future<void> _startRegistration() {
    if (!_validEmailAndPassword()) return Future<void>.value();
    return _run(
      () => ref
          .read(accountSyncRepositoryProvider)
          .register(email: _email.text.trim(), password: _password.text),
      onSuccess: () {
        setState(() {
          _emailStep = _EmailAuthStep.registrationCode;
          _emailOtp.clear();
        });
        _showMessage('注册验证码已发送，请查看邮箱。');
      },
    );
  }

  Future<void> _verifyRegistration() {
    final code = _emailOtp.text.trim();
    if (!RegExp(r'^\d{6,10}$').hasMatch(code)) {
      _showMessage('请输入有效邮箱验证码。');
      return Future<void>.value();
    }
    return _run(
      () => ref
          .read(accountSyncRepositoryProvider)
          .verifyRegistration(email: _email.text.trim(), code: code),
    );
  }

  Future<void> _resendRegistration() => _run(
    () => ref
        .read(accountSyncRepositoryProvider)
        .resendRegistration(email: _email.text.trim()),
    onSuccess: () => _showMessage('注册验证码已重新发送。'),
  );

  Future<void> _sendPasswordReset() {
    if (!_validEmailAndPassword(passwordRequired: false)) {
      return Future<void>.value();
    }
    return _run(
      () => ref
          .read(accountSyncRepositoryProvider)
          .sendPasswordReset(email: _email.text.trim()),
      onSuccess: () {
        setState(() {
          _emailStep = _EmailAuthStep.passwordResetCode;
          _emailOtp.clear();
        });
        _showMessage('重置密码验证码已发送，请查看邮箱。');
      },
    );
  }

  Future<void> _verifyPasswordReset() {
    final code = _emailOtp.text.trim();
    if (!RegExp(r'^\d{6,10}$').hasMatch(code)) {
      _showMessage('请输入有效邮箱验证码。');
      return Future<void>.value();
    }
    if (_newPassword.text.length < 8) {
      _showMessage('新密码至少需要 8 位。');
      return Future<void>.value();
    }
    return _run(
      () => ref
          .read(accountSyncRepositoryProvider)
          .verifyPasswordReset(
            email: _email.text.trim(),
            code: code,
            newPassword: _newPassword.text,
          ),
    );
  }

  void _backToLogin() {
    setState(() {
      _emailStep = _EmailAuthStep.credentials;
      _emailOtp.clear();
      _newPassword.clear();
    });
  }

  Future<void> _sendPhoneOtp({required bool register}) {
    final phone = _phone.text.trim();
    if (!RegExp(
      r'^\+[1-9]\d{7,14}$',
    ).hasMatch(phone.replaceAll(RegExp(r'[\s()-]'), ''))) {
      _showMessage('手机号必须使用国际格式，例如 +8613812345678。');
      return Future<void>.value();
    }
    return _run(
      () => ref
          .read(accountSyncRepositoryProvider)
          .sendPhoneOtp(phone: phone, createUser: register),
      onSuccess: () {
        setState(() {
          _otpSent = true;
          _phoneCreateUser = register;
        });
        _showMessage('验证码已发送，请查看短信。');
      },
    );
  }

  Future<void> _verifyPhoneOtp() {
    final code = _otp.text.trim();
    if (!RegExp(r'^\d{6,10}$').hasMatch(code)) {
      _showMessage('请输入有效短信验证码。');
      return Future<void>.value();
    }
    return _run(
      () => ref
          .read(accountSyncRepositoryProvider)
          .verifyPhoneOtp(phone: _phone.text.trim(), code: code),
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
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
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

  Future<void> _run(
    Future<void> Function() operation, {
    VoidCallback? onSuccess,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await operation();
      if (mounted) onSuccess?.call();
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
  'seriesRecords' => '集卡册',
  'purchases' => '入手成本',
  _ => '收藏数据',
};
