import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../core/preferences/local_app_state_providers.dart';
import '../domain/device_settings.dart';

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(deviceSettingsSnapshotProvider);
    final localState = ref.watch(localAppStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('应用设置')),
      body: ListView(
        children: <Widget>[
          const _Heading('权限'),
          device.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, stackTrace) =>
                const ListTile(title: Text('暂时无法读取权限状态')),
            data: (value) => Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('相机'),
                  trailing: Text(_permissionLabel(value.cameraPermission)),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('照片与媒体'),
                  trailing: Text(_permissionLabel(value.photoPermission)),
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('打开系统权限设置'),
                  onTap: () =>
                      ref.read(deviceSettingsGatewayProvider).openAppSettings(),
                ),
              ],
            ),
          ),
          const Divider(),
          const _Heading('存储与诊断'),
          device.when(
            loading: () => const SizedBox.shrink(),
            error: (error, stackTrace) => const SizedBox.shrink(),
            data: (value) => ListTile(
              leading: const Icon(Icons.storage_outlined),
              title: const Text('设备可用空间'),
              subtitle: Text(
                value.freeBytes == null
                    ? '当前平台不可读取'
                    : '${_formatBytes(value.freeBytes!)} 可用'
                          '${value.totalBytes == null ? '' : ' / ${_formatBytes(value.totalBytes!)}'}',
              ),
              trailing: IconButton(
                tooltip: '刷新',
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.invalidate(deviceSettingsSnapshotProvider),
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.bug_report_outlined),
            title: const Text('启用本地诊断记录'),
            subtitle: const Text('仅记录应用运行状态，不包含卡面图片；默认关闭。'),
            value: localState.value?.diagnosticsEnabled ?? false,
            onChanged: localState.isLoading
                ? null
                : (value) => ref
                      .read(localAppStateProvider.notifier)
                      .setDiagnosticsEnabled(value),
          ),
          const Divider(),
          const _Heading('帮助'),
          ListTile(
            leading: const Icon(Icons.slideshow_outlined),
            title: const Text('重新查看首次引导'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(onboardingPath),
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

String _permissionLabel(String value) => switch (value) {
  'granted' => '已允许',
  'denied' => '未允许',
  'notRequired' => '无需授权',
  _ => '未知',
};

String _formatBytes(int bytes) {
  const unit = 1024;
  if (bytes < unit) return '$bytes B';
  if (bytes < unit * unit) return '${(bytes / unit).toStringAsFixed(1)} KB';
  if (bytes < unit * unit * unit) {
    return '${(bytes / (unit * unit)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (unit * unit * unit)).toStringAsFixed(1)} GB';
}
