import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme.dart';
import '../../../core/errors/app_failure.dart';
import '../data/backup_providers.dart';
import '../domain/backup_models.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  BackupMode _mode = BackupMode.emptyLibrary;
  BackupImportPreview? _preview;
  BackupProgress? _progress;
  BackupCancellationToken? _cancellationToken;
  File? _selectedBackup;
  String? _report;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      appBar: AppBar(title: const Text('导入与导出')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.spaceLg,
          tokens.spaceMd,
          tokens.spaceLg,
          tokens.spaceXl,
        ),
        children: <Widget>[
          Card(
            child: Padding(
              padding: EdgeInsets.all(tokens.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Row(
                    children: <Widget>[
                      Icon(Icons.privacy_tip_outlined),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '完整备份包含私人图片、备注和购买信息',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: tokens.spaceSm),
                  const Text('备份离开 App 私有目录后，请保存到你信任的位置。'),
                ],
              ),
            ),
          ),
          SizedBox(height: tokens.spaceMd),
          _ActionCard(
            icon: Icons.archive_outlined,
            title: '导出完整备份',
            description: '生成带版本、清单和逐文件校验和的 ZIP。',
            onPressed: _busy ? null : _startExport,
          ),
          SizedBox(height: tokens.spaceMd),
          Card(
            child: Padding(
              padding: EdgeInsets.all(tokens.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text('导入备份', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: tokens.spaceSm),
                  SegmentedButton<BackupMode>(
                    segments: const <ButtonSegment<BackupMode>>[
                      ButtonSegment<BackupMode>(
                        value: BackupMode.emptyLibrary,
                        label: Text('恢复到空库'),
                        icon: Icon(Icons.inventory_2_outlined),
                      ),
                      ButtonSegment<BackupMode>(
                        value: BackupMode.mergeAddOnly,
                        label: Text('仅新增合并'),
                        icon: Icon(Icons.merge_outlined),
                      ),
                    ],
                    selected: <BackupMode>{_mode},
                    onSelectionChanged: _busy
                        ? null
                        : (selection) {
                            setState(() {
                              _mode = selection.single;
                              _preview = null;
                              _selectedBackup = null;
                              _report = null;
                            });
                          },
                  ),
                  SizedBox(height: tokens.spaceMd),
                  FilledButton.tonalIcon(
                    onPressed: _busy ? null : _chooseImport,
                    icon: const Icon(Icons.folder_open_outlined),
                    label: const Text('选择备份文件'),
                  ),
                ],
              ),
            ),
          ),
          if (_progress case final progress?) ...<Widget>[
            SizedBox(height: tokens.spaceMd),
            _ProgressCard(
              progress: progress,
              onCancel: _busy && progress.stage != BackupStage.committing
                  ? () {
                      _cancellationToken?.cancel();
                      setState(() {});
                    }
                  : null,
            ),
          ],
          if (_preview case final preview?) ...<Widget>[
            SizedBox(height: tokens.spaceMd),
            _PreviewCard(
              preview: preview,
              busy: _busy,
              onConfirm: preview.canImport && !_busy ? _confirmImport : null,
            ),
          ],
          if (_report case final report?) ...<Widget>[
            SizedBox(height: tokens.spaceMd),
            Card(
              color: AppColors.primaryContainer,
              child: ListTile(
                leading: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.primary,
                ),
                title: const Text('操作完成'),
                subtitle: Text(report),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _startExport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('备份包含敏感内容'),
        content: const Text('ZIP 将包含全部结构化数据、私人图片、备注和购买信息。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('选择保存位置'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    String? path;
    try {
      path = await ref
          .read(backupFilePickerProvider)
          .chooseExportPath(_suggestedName(DateTime.now().toUtc()));
    } on AppFailure catch (failure) {
      _showFailure(failure);
      return;
    }
    if (path == null || !mounted) return;

    final token = BackupCancellationToken();
    setState(() {
      _busy = true;
      _cancellationToken = token;
      _progress = BackupProgress(stage: BackupStage.preparing, fraction: 0);
      _preview = null;
      _report = null;
    });
    try {
      final result = await ref
          .read(backupRepositoryProvider)
          .exportBackup(
            File(path),
            cancellationToken: token,
            onProgress: _updateProgress,
          );
      final published = await ref
          .read(backupFilePickerProvider)
          .publishExport(path);
      if (!published) throw const BackupCancelledFailure();
      if (!mounted) return;
      setState(() {
        _report =
            '已导出 ${result.entityCount} 项数据和 '
            '${result.imageCount} 个图片文件';
      });
    } on AppFailure catch (failure) {
      _showFailure(failure);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _cancellationToken = null;
          _progress = null;
        });
      }
    }
  }

  Future<void> _chooseImport() async {
    String? path;
    try {
      path = await ref.read(backupFilePickerProvider).chooseImportPath();
    } on AppFailure catch (failure) {
      _showFailure(failure);
      return;
    }
    if (path == null || !mounted) return;
    final file = File(path);
    final token = BackupCancellationToken();
    setState(() {
      _busy = true;
      _cancellationToken = token;
      _selectedBackup = file;
      _preview = null;
      _report = null;
      _progress = BackupProgress(stage: BackupStage.preparing, fraction: 0);
    });
    try {
      final preview = await ref
          .read(backupRepositoryProvider)
          .inspectBackup(
            file,
            mode: _mode,
            cancellationToken: token,
            onProgress: _updateProgress,
          );
      if (mounted) setState(() => _preview = preview);
    } on AppFailure catch (failure) {
      _showFailure(failure);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _cancellationToken = null;
          _progress = null;
        });
      }
    }
  }

  Future<void> _confirmImport() async {
    final file = _selectedBackup;
    if (file == null) return;
    final token = BackupCancellationToken();
    setState(() {
      _busy = true;
      _cancellationToken = token;
      _report = null;
      _progress = BackupProgress(stage: BackupStage.preparing, fraction: 0);
    });
    try {
      final report = await ref
          .read(backupRepositoryProvider)
          .importBackup(
            file,
            mode: _mode,
            cancellationToken: token,
            onProgress: _updateProgress,
          );
      if (!mounted) return;
      setState(() {
        _preview = null;
        _report =
            '已导入 ${report.addedCount} 项，跳过 '
            '${report.skippedCount} 项';
      });
    } on AppFailure catch (failure) {
      _showFailure(failure);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _cancellationToken = null;
          _progress = null;
        });
      }
    }
  }

  void _updateProgress(BackupProgress progress) {
    if (mounted) setState(() => _progress = progress);
  }

  void _showFailure(AppFailure failure) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(failure.userMessage)));
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        enabled: onPressed != null,
        onTap: onPressed,
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.progress, required this.onCancel});

  final BackupProgress progress;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final percent = (progress.fraction * 100).round();
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('${_stageLabel(progress.stage)} $percent%'),
            SizedBox(height: context.tokens.spaceSm),
            LinearProgressIndicator(value: progress.fraction),
            if (onCancel != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: onCancel, child: const Text('取消')),
              ),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.preview,
    required this.busy,
    required this.onConfirm,
  });

  final BackupImportPreview preview;
  final bool busy;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final hasConflicts = preview.conflicts.isNotEmpty;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('导入影响预览', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: context.tokens.spaceSm),
            Text('可新增 ${preview.addedCount} 项'),
            Text('将跳过 ${preview.skippedCount} 项'),
            Text('${preview.imageCount} 个图片文件'),
            if (hasConflicts) ...<Widget>[
              SizedBox(height: context.tokens.spaceSm),
              Row(
                children: <Widget>[
                  const Icon(Icons.error_outline, color: AppColors.error),
                  SizedBox(width: context.tokens.spaceSm),
                  Expanded(
                    child: Text('发现 ${preview.conflicts.length} 个冲突，当前模式不能导入'),
                  ),
                ],
              ),
            ],
            SizedBox(height: context.tokens.spaceMd),
            FilledButton.icon(
              onPressed: busy ? null : onConfirm,
              icon: const Icon(Icons.restore_outlined),
              label: const Text('确认导入'),
            ),
          ],
        ),
      ),
    );
  }
}

String _stageLabel(BackupStage stage) => switch (stage) {
  BackupStage.preparing => '正在准备',
  BackupStage.readingDatabase => '正在读取收藏',
  BackupStage.checkingImages => '正在校验图片',
  BackupStage.writingArchive => '正在生成 ZIP',
  BackupStage.validatingArchive => '正在验证备份',
  BackupStage.validatingData => '正在验证数据',
  BackupStage.stagingImages => '正在准备图片',
  BackupStage.committing => '正在提交',
  BackupStage.completed => '已完成',
};

String _suggestedName(DateTime nowUtc) {
  String two(int value) => value.toString().padLeft(2, '0');
  return 'cardfolio-backup-'
      '${nowUtc.year}${two(nowUtc.month)}${two(nowUtc.day)}-'
      '${two(nowUtc.hour)}${two(nowUtc.minute)}${two(nowUtc.second)}.zip';
}
