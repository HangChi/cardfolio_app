import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../app/app_theme.dart';
import '../../../../core/widgets/app_layout.dart';
import '../../../../core/widgets/app_surface.dart';
import '../create/create_card_controller.dart';

/// 卡片采集方式入口。
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
    final controller = ref.read(createCardControllerProvider.notifier);
    final recovered = await controller.recoverLostCapture();
    if (!mounted || !recovered) return;
    context.push(createCardPath);
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
    _showFailure(context);
  }

  Future<void> _capture(BuildContext context) async {
    final captured = await ref
        .read(createCardControllerProvider.notifier)
        .captureImage();
    if (!context.mounted) return;
    if (captured) {
      context.push(createCardPath);
      return;
    }
    _showFailure(context);
  }

  void _showFailure(BuildContext context) {
    final failure = ref.read(createCardControllerProvider).failure;
    if (failure == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(failure.userMessage)));
  }

  @override
  Widget build(BuildContext context) {
    // 入口页在新建页压入根导航器后仍保留监听，确保草稿状态跨路由存活。
    final state = ref.watch(createCardControllerProvider);
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;

    return AppContentView(
      safeTop: true,
      child: ListView(
        children: <Widget>[
          const AppPageHeader(
            eyebrow: 'CAPTURE & ARCHIVE',
            title: '快速建档',
            subtitle: '选择最适合这次录入的方式，图片和资料都可以稍后补充。',
          ),
          Semantics(
            button: true,
            label: '拍摄单张卡，主要操作',
            child: Material(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(tokens.radiusLg),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: state.isSaving ? null : () => _capture(context),
                child: Padding(
                  padding: EdgeInsets.all(tokens.spaceLg),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: scheme.onPrimary.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: state.isSaving
                            ? Padding(
                                padding: EdgeInsets.all(tokens.spaceMd),
                                child: CircularProgressIndicator(
                                  color: scheme.onPrimary,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                Icons.center_focus_strong_rounded,
                                size: tokens.iconLg,
                                color: scheme.onPrimary,
                              ),
                      ),
                      SizedBox(width: tokens.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '拍摄单张卡',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: scheme.onPrimary),
                            ),
                            SizedBox(height: tokens.spaceXs),
                            Text(
                              '拍摄后直接进入资料页，可继续添加正面、背面与细节。',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: scheme.onPrimary.withValues(
                                      alpha: 0.82,
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: tokens.spaceSm),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: scheme.onPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: tokens.spaceLg),
          const AppSectionHeader(
            title: '其他录入方式',
            icon: Icons.add_photo_alternate_outlined,
          ),
          AppActionTile(
            icon: Icons.grid_on_outlined,
            title: '批量建卡 / 创建套卡',
            subtitle: '多张卡独立建档，共用资料并自动加入套卡。',
            onTap: () => context.push(batchCardEntryPath),
          ),
          SizedBox(height: tokens.spaceSm),
          AppActionTile(
            icon: Icons.file_upload_outlined,
            title: '从相册导入',
            subtitle: '选择一张已有图片作为卡片封面。',
            onTap: state.isSaving ? null : () => _pickFromGallery(context),
          ),
          SizedBox(height: tokens.spaceLg),
          AppSurfaceCard(
            color: scheme.primaryContainer,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.tips_and_updates_outlined, color: scheme.primary),
                SizedBox(width: tokens.spaceSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '拍摄小提示',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      SizedBox(height: tokens.spaceXs),
                      Text(
                        '拍摄后不会强制裁剪；在资料页点击图片的“编辑”即可裁剪、旋转并调整画面。',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
