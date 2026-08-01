import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme.dart';
import '../../../core/errors/app_failure.dart';
import '../../cards/data/card_providers.dart';
import '../../cards/presentation/widgets/card_image.dart';
import '../data/recycle_bin_providers.dart';
import '../domain/recycle_bin_models.dart';

class RecycleBinScreen extends ConsumerWidget {
  const RecycleBinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(recycleBinEntriesProvider);
    final settings = ref.watch(recycleBinSettingsProvider);
    final retentionDays =
        settings.value?.retentionDays ??
        RecycleBinSettings.defaultRetentionDays;

    return Scaffold(
      appBar: AppBar(title: const Text('回收站')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(recycleBinEntriesProvider);
          ref.invalidate(recycleBinSettingsProvider);
        },
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            context.tokens.spaceLg,
            context.tokens.spaceMd,
            context.tokens.spaceLg,
            context.tokens.spaceXl,
          ),
          children: <Widget>[
            _RetentionCard(
              days: retentionDays,
              enabled: !settings.isLoading,
              onChanged: (days) => _updateRetention(context, ref, days),
            ),
            SizedBox(height: context.tokens.spaceLg),
            entries.when(
              loading: () => const _Loading(),
              error: (error, stackTrace) => _LoadError(
                onRetry: () => ref.invalidate(recycleBinEntriesProvider),
              ),
              data: (items) => items.isEmpty
                  ? const _EmptyState()
                  : _EntryList(entries: items, retentionDays: retentionDays),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateRetention(
    BuildContext context,
    WidgetRef ref,
    int days,
  ) async {
    try {
      await ref.read(recycleBinRepositoryProvider).updateRetentionDays(days);
      ref.invalidate(recycleBinSettingsProvider);
      ref.invalidate(recycleBinEntriesProvider);
    } on AppFailure catch (failure) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.userMessage)));
      }
    }
  }
}

class _RetentionCard extends StatelessWidget {
  const _RetentionCard({
    required this.days,
    required this.enabled,
    required this.onChanged,
  });

  final int days;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceMd),
        child: Row(
          children: <Widget>[
            const Icon(Icons.schedule_outlined),
            SizedBox(width: context.tokens.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('自动清理'),
                  Text(
                    '超过保留期的卡片会在下次启动时永久删除。',
                    style: TextStyle(color: context.palette.textSecondary),
                  ),
                ],
              ),
            ),
            SizedBox(width: context.tokens.spaceSm),
            DropdownButton<int>(
              key: const Key('retention-days'),
              value: days,
              onChanged: enabled
                  ? (value) {
                      if (value != null) onChanged(value);
                    }
                  : null,
              items: <DropdownMenuItem<int>>[
                for (final value in RecycleBinSettings.supportedRetentionDays)
                  DropdownMenuItem<int>(value: value, child: Text('$value 天')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryList extends ConsumerWidget {
  const _EntryList({required this.entries, required this.retentionDays});

  final List<RecycleBinEntry> entries;
  final int retentionDays;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).nowUtc();
    return Column(
      children: <Widget>[
        for (var index = 0; index < entries.length; index++) ...<Widget>[
          _EntryCard(
            entry: entries[index],
            remainingDays: entries[index].remainingDays(
              nowUtc: now,
              retentionDays: retentionDays,
            ),
          ),
          if (index != entries.length - 1)
            SizedBox(height: context.tokens.spaceMd),
        ],
      ],
    );
  }
}

class _EntryCard extends ConsumerWidget {
  const _EntryCard({required this.entry, required this.remainingDays});

  final RecycleBinEntry entry;
  final int remainingDays;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deleted = entry.deletedAt.toLocal();
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceMd),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 72,
                  height: 52,
                  child: entry.coverRelativePath == null
                      ? CardImage.placeholder(semanticLabel: '${entry.name}封面')
                      : CardImage.managed(
                          relativePath: entry.coverRelativePath!,
                          semanticLabel: '${entry.name}封面',
                        ),
                ),
                SizedBox(width: context.tokens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        entry.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: context.tokens.spaceXs),
                      Text(
                        '删除于 ${deleted.year}-${_two(deleted.month)}-'
                        '${_two(deleted.day)} · ${entry.imageCount} 张图片',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        remainingDays == 0 ? '等待下次启动清理' : '剩余 $remainingDays 天',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: context.tokens.spaceMd),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    key: Key('restore-${entry.cardItemId}'),
                    onPressed: () => _restore(context, ref),
                    child: const Text('恢复'),
                  ),
                ),
                SizedBox(width: context.tokens.spaceMd),
                Expanded(
                  child: FilledButton(
                    key: Key('permanently-delete-${entry.cardItemId}'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                    onPressed: () => _confirmPermanentDeletion(context, ref),
                    child: const Text('永久删除'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    await _run(
      context,
      () =>
          ref.read(recycleBinRepositoryProvider).restoreCard(entry.cardItemId),
    );
    ref.invalidate(recycleBinEntriesProvider);
  }

  Future<void> _confirmPermanentDeletion(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final PermanentDeletionImpact impact;
    try {
      impact = await ref
          .read(recycleBinRepositoryProvider)
          .previewPermanentDeletion(entry.cardItemId);
    } on AppFailure catch (failure) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.userMessage)));
      }
      return;
    }
    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('永久删除“${entry.name}”？'),
        content: Text(
          '将删除 ${impact.imageCount} 条图片记录、'
          '${impact.fileCount} 个图片文件，'
          '并移除 ${impact.purchaseAssociationCount} 条购买关联。'
          '此操作不可撤销。',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('永久删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _run(
      context,
      () => ref
          .read(recycleBinRepositoryProvider)
          .permanentlyDelete(entry.cardItemId),
    );
    ref.invalidate(recycleBinEntriesProvider);
  }
}

Future<void> _run(
  BuildContext context,
  Future<void> Function() operation,
) async {
  try {
    await operation();
  } on AppFailure catch (failure) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(48),
      child: Center(
        child: CircularProgressIndicator(semanticsLabel: '正在加载回收站'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.tokens.spaceXl),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.delete_outline,
            size: 48,
            color: context.palette.textSecondary,
          ),
          SizedBox(height: context.tokens.spaceMd),
          Text('回收站是空的', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: context.tokens.spaceSm),
          const Text('删除的卡片会在这里保留，期间可以随时恢复。', textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.tokens.spaceXl),
      child: Column(
        children: <Widget>[
          const Text('回收站暂时无法加载'),
          SizedBox(height: context.tokens.spaceMd),
          FilledButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}

String _two(int value) => value.toString().padLeft(2, '0');
