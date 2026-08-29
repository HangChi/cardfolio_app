import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../app/app_theme.dart';
import '../../../core/preferences/local_app_state.dart';
import '../../../core/preferences/local_app_state_providers.dart';
import '../../../core/widgets/app_layout.dart';
import '../../../core/widgets/app_surface.dart';
import '../domain/device_settings.dart';

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final device = ref.watch(deviceSettingsSnapshotProvider);
    final localState = ref.watch(localAppStateProvider);
    final preference =
        localState.value?.themePreference ?? AppThemePreference.system;

    return Scaffold(
      appBar: AppBar(title: const Text('应用设置')),
      body: AppContentView(
        child: ListView(
          children: <Widget>[
            const AppPageHeader(
              eyebrow: 'APP SETTINGS',
              title: '应用设置',
              subtitle: '调整显示方式、设备权限与本地诊断。',
            ),
            const AppSectionHeader(
              title: '外观',
              icon: Icons.palette_outlined,
              subtitle: '选择你在不同使用环境下更舒适的显示方式。',
            ),
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('主题模式', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: tokens.spaceSm),
                  Text(
                    '跟随系统会自动匹配设备的浅色或深色外观。',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SizedBox(height: tokens.spaceMd),
                  Wrap(
                    spacing: tokens.spaceSm,
                    runSpacing: tokens.spaceSm,
                    children: <Widget>[
                      for (final option in _themeOptions)
                        ChoiceChip(
                          avatar: Icon(option.icon, size: tokens.iconSm),
                          label: Text(option.label),
                          selected: preference == option.preference,
                          onSelected: localState.isLoading
                              ? null
                              : (_) => ref
                                    .read(localAppStateProvider.notifier)
                                    .setThemePreference(option.preference),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: tokens.spaceLg),
            const AppSectionHeader(
              title: '权限',
              icon: Icons.verified_user_outlined,
              subtitle: 'Cardfolio 只在对应功能需要时请求系统权限。',
            ),
            device.when(
              loading: () => const AppSurfaceCard(
                child: LinearProgressIndicator(semanticsLabel: '正在读取权限状态'),
              ),
              error: (error, stackTrace) => const AppSurfaceCard(
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('暂时无法读取权限状态'),
                  subtitle: Text('你仍可打开系统设置进行检查。'),
                ),
              ),
              data: (value) => AppSurfaceCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.photo_camera_outlined),
                      title: const Text('相机'),
                      trailing: AppStatusBadge(
                        label: _permissionLabel(value.cameraPermission),
                        icon: _permissionIcon(value.cameraPermission),
                        color: _permissionColor(
                          context,
                          value.cameraPermission,
                        ),
                      ),
                    ),
                    const Divider(indent: 72),
                    ListTile(
                      leading: const Icon(Icons.photo_library_outlined),
                      title: const Text('照片与媒体'),
                      subtitle: value.photoPermission == 'notRequired'
                          ? const Text('使用系统照片选择器，不申请广泛媒体权限。')
                          : null,
                      trailing: AppStatusBadge(
                        label: _permissionLabel(value.photoPermission),
                        icon: _permissionIcon(value.photoPermission),
                        color: _permissionColor(context, value.photoPermission),
                      ),
                    ),
                    const Divider(indent: 72),
                    ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: const Text('打开系统权限设置'),
                      subtitle: const Text('前往设备设置调整相机与相册权限。'),
                      trailing: const Icon(Icons.open_in_new_rounded),
                      onTap: () => ref
                          .read(deviceSettingsGatewayProvider)
                          .openAppSettings(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: tokens.spaceLg),
            const AppSectionHeader(
              title: '存储与诊断',
              icon: Icons.storage_outlined,
            ),
            AppSurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  device.when(
                    loading: () => const ListTile(
                      leading: CircularProgressIndicator(),
                      title: Text('正在读取设备空间'),
                    ),
                    error: (error, stackTrace) => const ListTile(
                      leading: Icon(Icons.storage_outlined),
                      title: Text('设备可用空间'),
                      subtitle: Text('当前平台暂时无法读取。'),
                    ),
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
                        tooltip: '刷新存储空间',
                        icon: const Icon(Icons.refresh_rounded),
                        onPressed: () =>
                            ref.invalidate(deviceSettingsSnapshotProvider),
                      ),
                    ),
                  ),
                  const Divider(indent: 72),
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
                ],
              ),
            ),
            SizedBox(height: tokens.spaceLg),
            const AppSectionHeader(title: '帮助', icon: Icons.help_outline),
            AppActionTile(
              icon: Icons.slideshow_outlined,
              title: '重新查看首次引导',
              subtitle: '重新了解核心录入与收藏流程。',
              onTap: () => context.push(onboardingPath),
            ),
          ],
        ),
      ),
    );
  }
}

const _themeOptions = <_ThemeOption>[
  _ThemeOption(
    preference: AppThemePreference.system,
    icon: Icons.brightness_auto_outlined,
    label: '跟随系统',
  ),
  _ThemeOption(
    preference: AppThemePreference.light,
    icon: Icons.light_mode_outlined,
    label: '浅色',
  ),
  _ThemeOption(
    preference: AppThemePreference.dark,
    icon: Icons.dark_mode_outlined,
    label: '深色',
  ),
];

@immutable
class _ThemeOption {
  const _ThemeOption({
    required this.preference,
    required this.icon,
    required this.label,
  });

  final AppThemePreference preference;
  final IconData icon;
  final String label;
}

String _permissionLabel(String value) => switch (value) {
  'granted' => '已允许',
  'denied' => '未允许',
  'notRequired' => '无需授权',
  _ => '未知',
};

IconData _permissionIcon(String value) => switch (value) {
  'granted' => Icons.check_circle_outline,
  'denied' => Icons.block_outlined,
  'notRequired' => Icons.remove_circle_outline,
  _ => Icons.help_outline,
};

Color _permissionColor(BuildContext context, String value) => switch (value) {
  'granted' => context.palette.success,
  'denied' => Theme.of(context).colorScheme.error,
  _ => context.palette.textSecondary,
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
