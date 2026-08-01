import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../app/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../cards/data/card_providers.dart';
import '../../data/organization_providers.dart';
import '../../domain/organization_models.dart';

class OrganizationSettingsScreen extends ConsumerWidget {
  const OrganizationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(organizationTagsProvider);
    final fields = ref.watch(organizationFieldDefinitionsProvider);
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(title: const Text('整理管理')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.spaceLg,
          tokens.spaceMd,
          tokens.spaceLg,
          tokens.spaceXl,
        ),
        children: <Widget>[
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('回收站'),
              subtitle: const Text('恢复已删除卡片，或将其永久删除。'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(recycleBinPath),
            ),
          ),
          SizedBox(height: tokens.spaceMd),
          Card(
            child: ListTile(
              leading: const Icon(Icons.import_export_outlined),
              title: const Text('导入与导出'),
              subtitle: const Text('备份、恢复或合并你的全部收藏数据。'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(backupPath),
            ),
          ),
          SizedBox(height: tokens.spaceXl),
          _SectionHeader(
            title: '标签',
            description: '轻量标记卡片，可用于搜索和组合筛选。',
            action: TextButton.icon(
              key: const Key('add-tag'),
              onPressed: () => _createTag(context, ref),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('新建标签'),
            ),
          ),
          SizedBox(height: tokens.spaceMd),
          tags.when(
            loading: () => const _Loading(label: '正在加载标签'),
            error: (error, stackTrace) => _InlineError(
              message: '标签暂时无法加载',
              onRetry: () => ref.invalidate(organizationTagsProvider),
            ),
            data: (items) => items.isEmpty
                ? const _EmptyCard(message: '还没有标签，先创建一个常用分类。')
                : Column(
                    children: <Widget>[
                      for (final tag in items)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.sell_outlined),
                            title: Text(tag.name),
                            subtitle: Text('${tag.cardCount} 款卡片'),
                            trailing: PopupMenuButton<String>(
                              key: Key('tag-menu-${tag.id}'),
                              tooltip: '管理${tag.name}',
                              onSelected: (action) =>
                                  _handleTagAction(context, ref, tag, action),
                              itemBuilder: (context) =>
                                  const <PopupMenuEntry<String>>[
                                    PopupMenuItem(
                                      value: 'rename',
                                      child: Text('重命名'),
                                    ),
                                    PopupMenuItem(
                                      value: 'merge',
                                      child: Text('合并'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('删除'),
                                    ),
                                  ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          SizedBox(height: tokens.spaceXl),
          _SectionHeader(
            title: '自定义字段',
            description: '给卡片补充文本、数字或日期资料。',
            action: TextButton.icon(
              key: const Key('add-custom-field'),
              onPressed: () => _createField(context, ref),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('新建字段'),
            ),
          ),
          SizedBox(height: tokens.spaceMd),
          fields.when(
            loading: () => const _Loading(label: '正在加载自定义字段'),
            error: (error, stackTrace) => _InlineError(
              message: '自定义字段暂时无法加载',
              onRetry: () =>
                  ref.invalidate(organizationFieldDefinitionsProvider),
            ),
            data: (items) => items.isEmpty
                ? const _EmptyCard(message: '还没有自定义字段。')
                : Column(
                    children: <Widget>[
                      for (final field in items)
                        Card(
                          child: ListTile(
                            leading: Icon(_fieldIcon(field.fieldType)),
                            title: Text(field.name),
                            subtitle: Text(
                              '${_fieldTypeLabel(field.fieldType)}'
                              ' · ${field.valueCount} 个值',
                            ),
                            trailing: PopupMenuButton<String>(
                              key: Key('field-menu-${field.id}'),
                              tooltip: '管理${field.name}',
                              onSelected: (action) => _handleFieldAction(
                                context,
                                ref,
                                field,
                                action,
                              ),
                              itemBuilder: (context) =>
                                  const <PopupMenuEntry<String>>[
                                    PopupMenuItem(
                                      value: 'rename',
                                      child: Text('重命名'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('删除'),
                                    ),
                                  ],
                            ),
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

Future<void> _createTag(BuildContext context, WidgetRef ref) async {
  final name = await _nameDialog(context, title: '新建标签');
  if (name == null || !context.mounted) return;
  await _run(
    context,
    () => ref
        .read(organizationRepositoryProvider)
        .createTag(
          CreateTagRequest(
            id: ref.read(idGeneratorProvider).newId(),
            name: name,
          ),
        ),
  );
}

Future<void> _createField(BuildContext context, WidgetRef ref) async {
  final result = await showDialog<(String, CustomFieldType)>(
    context: context,
    builder: (context) {
      var type = CustomFieldType.text;
      final controller = TextEditingController();
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('新建自定义字段'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                key: const Key('name-input'),
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(labelText: '字段名称 *'),
              ),
              SizedBox(height: context.tokens.spaceMd),
              Wrap(
                spacing: context.tokens.spaceSm,
                children: <Widget>[
                  for (final value in CustomFieldType.values)
                    ChoiceChip(
                      key: Key('field-type-${value.name}'),
                      label: Text(_fieldTypeLabel(value)),
                      selected: type == value,
                      onSelected: (_) => setState(() => type = value),
                    ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, (controller.text, type)),
              child: const Text('创建'),
            ),
          ],
        ),
      );
    },
  );
  if (result == null || !context.mounted) return;
  await _run(
    context,
    () => ref
        .read(organizationRepositoryProvider)
        .createField(
          CreateCustomFieldRequest(
            id: ref.read(idGeneratorProvider).newId(),
            name: result.$1,
            fieldType: result.$2,
          ),
        ),
  );
}

Future<void> _handleTagAction(
  BuildContext context,
  WidgetRef ref,
  TagSummary tag,
  String action,
) async {
  switch (action) {
    case 'rename':
      final name = await _nameDialog(
        context,
        title: '重命名标签',
        initialValue: tag.name,
        actionLabel: '保存',
      );
      if (name == null || !context.mounted) return;
      await _run(
        context,
        () => ref
            .read(organizationRepositoryProvider)
            .renameTag(RenameTagRequest(id: tag.id, name: name)),
      );
    case 'merge':
      await _mergeTag(context, ref, tag);
    case 'delete':
      await _deleteTag(context, ref, tag);
  }
}

Future<void> _mergeTag(
  BuildContext context,
  WidgetRef ref,
  TagSummary source,
) async {
  final tags = ref.read(organizationTagsProvider).value ?? const <TagSummary>[];
  final targets = tags.where((tag) => tag.id != source.id).toList();
  if (targets.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('请先创建另一个目标标签。')));
    return;
  }
  final impact = await _impact(
    context,
    () => ref.read(organizationRepositoryProvider).previewTagChange(source.id),
  );
  if (impact == null || !context.mounted) return;
  var targetId = targets.first.id;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('合并“${source.name}”'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('将迁移 ${impact.associationCount} 款卡片的关联。'),
            for (final target in targets)
              RadioListTile<String>(
                key: Key('merge-target-${target.id}'),
                value: target.id,
                // ignore: deprecated_member_use, 兼容当前 Flutter 稳定版。
                groupValue: targetId,
                // ignore: deprecated_member_use, 兼容当前 Flutter 稳定版。
                onChanged: (value) => setState(() => targetId = value!),
                title: Text(target.name),
              ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('合并标签'),
          ),
        ],
      ),
    ),
  );
  if (confirmed != true || !context.mounted) return;
  await _run(
    context,
    () => ref
        .read(organizationRepositoryProvider)
        .mergeTags(
          MergeTagsRequest(sourceTagId: source.id, targetTagId: targetId),
        ),
  );
}

Future<void> _deleteTag(
  BuildContext context,
  WidgetRef ref,
  TagSummary tag,
) async {
  final impact = await _impact(
    context,
    () => ref.read(organizationRepositoryProvider).previewTagChange(tag.id),
  );
  if (impact == null || !context.mounted) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('删除“${tag.name}”？'),
      content: Text('将影响 ${impact.associationCount} 款卡片，但不会删除任何卡片。'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('删除标签'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  await _run(
    context,
    () => ref.read(organizationRepositoryProvider).deleteTag(tag.id),
  );
}

Future<void> _handleFieldAction(
  BuildContext context,
  WidgetRef ref,
  CustomFieldDefinition field,
  String action,
) async {
  if (action == 'rename') {
    final name = await _nameDialog(
      context,
      title: '重命名字段',
      initialValue: field.name,
      actionLabel: '保存',
    );
    if (name == null || !context.mounted) return;
    await _run(
      context,
      () => ref
          .read(organizationRepositoryProvider)
          .renameField(RenameCustomFieldRequest(id: field.id, name: name)),
    );
    return;
  }
  final impact = await _impact(
    context,
    () =>
        ref.read(organizationRepositoryProvider).previewFieldDeletion(field.id),
  );
  if (impact == null || !context.mounted) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('删除“${field.name}”？'),
      content: Text('将隐藏 ${impact.valueCount} 个已有值。值会保留，供后续恢复与导出。'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('删除字段'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  await _run(
    context,
    () => ref.read(organizationRepositoryProvider).deleteField(field.id),
  );
}

Future<String?> _nameDialog(
  BuildContext context, {
  required String title,
  String? initialValue,
  String actionLabel = '创建',
}) {
  final controller = TextEditingController(text: initialValue);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        key: const Key('name-input'),
        controller: controller,
        autofocus: true,
        maxLength: 100,
        decoration: const InputDecoration(labelText: '名称 *'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text(actionLabel),
        ),
      ],
    ),
  );
}

Future<ChangeImpact?> _impact(
  BuildContext context,
  Future<ChangeImpact> Function() operation,
) async {
  try {
    return await operation();
  } on AppFailure catch (failure) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
    return null;
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

String _fieldTypeLabel(CustomFieldType type) => switch (type) {
  CustomFieldType.text => '文本',
  CustomFieldType.number => '数字',
  CustomFieldType.date => '日期',
};

IconData _fieldIcon(CustomFieldType type) => switch (type) {
  CustomFieldType.text => Icons.text_fields,
  CustomFieldType.number => Icons.numbers,
  CustomFieldType.date => Icons.calendar_today_outlined,
};

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.description,
    required this.action,
  });

  final String title;
  final String description;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            action,
          ],
        ),
        SizedBox(height: context.tokens.spaceXs),
        Text(
          description,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceLg),
        child: CircularProgressIndicator(semanticsLabel: label),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceLg),
        child: Text(message),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.error_outline, color: AppColors.error),
        title: Text(message),
        trailing: TextButton(onPressed: onRetry, child: const Text('重试')),
      ),
    );
  }
}
