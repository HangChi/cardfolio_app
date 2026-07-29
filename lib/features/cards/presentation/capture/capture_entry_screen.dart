import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../app/app_theme.dart';
import '../create/create_card_controller.dart';

/// Feature 001 的采集方式入口；仅相册导入可执行。
class CaptureEntryScreen extends ConsumerStatefulWidget {
  const CaptureEntryScreen({super.key});

  @override
  ConsumerState<CaptureEntryScreen> createState() => _CaptureEntryScreenState();
}

class _CaptureEntryScreenState extends ConsumerState<CaptureEntryScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_recoverLostCapture);
  }

  Future<void> _recoverLostCapture() async {
    final recovered = await ref
        .read(createCardControllerProvider.notifier)
        .recoverLostCapture();
    if (mounted && recovered) context.push(createCardPath);
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final picked = await ref
        .read(createCardControllerProvider.notifier)
        .pickImage();
    if (!context.mounted) return;

    if (picked) {
      context.push(createCardPath);
      return;
    }

    final failure = ref.read(createCardControllerProvider).failure;
    if (failure != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
  }

  Future<void> _capture(
    BuildContext context, {
    required bool continuous,
  }) async {
    final controller = ref.read(createCardControllerProvider.notifier);
    final captured = continuous
        ? await controller.captureContinuously()
        : await controller.captureImage();
    if (!context.mounted) return;
    if (captured) {
      context.push(createCardPath);
      return;
    }
    final failure = ref.read(createCardControllerProvider).failure;
    if (failure != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 入口页在新建页压入根导航器后仍保留监听，确保草稿状态跨路由存活。
    ref.watch(createCardControllerProvider);
    final tokens = context.tokens;

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.spaceLg,
          tokens.spaceLg,
          tokens.spaceLg,
          tokens.spaceXl,
        ),
        children: <Widget>[
          Text('快速建档', style: Theme.of(context).textTheme.headlineMedium),
          SizedBox(height: tokens.spaceXs),
          Text(
            '选择最适合这次录入的方式',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: tokens.spaceLg),
          _CaptureOption(
            icon: Icons.center_focus_strong_outlined,
            title: '拍摄单张卡',
            subtitle: '自动识别边缘并校正',
            enabled: true,
            onTap: () => _capture(context, continuous: false),
          ),
          SizedBox(height: tokens.spaceMd),
          _CaptureOption(
            icon: Icons.view_stream_outlined,
            title: '连续拍摄',
            subtitle: '适合一次录入多张卡',
            enabled: true,
            onTap: () => _capture(context, continuous: true),
          ),
          SizedBox(height: tokens.spaceMd),
          const _CaptureOption(
            icon: Icons.grid_on_outlined,
            title: '创建套卡并拍摄',
            subtitle: '先建套卡，再连续录入',
          ),
          SizedBox(height: tokens.spaceMd),
          _CaptureOption(
            icon: Icons.file_upload_outlined,
            title: '从相册导入',
            subtitle: '选择一张已有图片',
            enabled: true,
            onTap: () => _pickFromGallery(context),
          ),
          SizedBox(height: tokens.spaceXl),
          Container(
            padding: EdgeInsets.all(tokens.spaceMd),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(tokens.radiusLg),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '小提示',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Text('拍摄时才会申请相机权限；若不可用，仍可从相册导入。'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptureOption extends StatelessWidget {
  const _CaptureOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.enabled = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Semantics(
      button: true,
      enabled: enabled,
      label: enabled ? title : '$title，后续开放',
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          child: Padding(
            padding: EdgeInsets.all(tokens.spaceMd),
            child: Row(
              children: <Widget>[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: enabled
                        ? AppColors.primary
                        : AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(tokens.radiusLg),
                  ),
                  child: Icon(
                    icon,
                    color: enabled ? AppColors.onPrimary : AppColors.primary,
                  ),
                ),
                SizedBox(width: tokens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: tokens.spaceXs),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (!enabled) ...<Widget>[
                        SizedBox(height: tokens.spaceSm),
                        const Text(
                          '后续开放',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (enabled)
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
