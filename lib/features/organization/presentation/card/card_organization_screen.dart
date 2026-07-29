import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../data/organization_providers.dart';
import '../../domain/organization_models.dart';

class CardOrganizationScreen extends ConsumerStatefulWidget {
  const CardOrganizationScreen({required this.cardItemId, super.key});

  final String cardItemId;

  @override
  ConsumerState<CardOrganizationScreen> createState() =>
      _CardOrganizationScreenState();
}

class _CardOrganizationScreenState
    extends ConsumerState<CardOrganizationScreen> {
  final _cardTypeController = TextEditingController();
  final _acquiredAtController = TextEditingController();
  final _fieldControllers = <String, TextEditingController>{};
  final _selectedTags = <String>{};
  final _selectedSeries = <String>{};
  bool _needsCompletion = false;
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _cardTypeController.dispose();
    _acquiredAtController.dispose();
    for (final controller in _fieldControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initialize(CardOrganizationDetail detail) {
    if (_initialized) return;
    _initialized = true;
    _cardTypeController.text = detail.cardType ?? '';
    _acquiredAtController.text =
        detail.acquiredAt?.toIso8601String().split('T').first ?? '';
    _needsCompletion = detail.needsCompletion;
    _selectedTags.addAll(detail.tags.map((tag) => tag.id));
    _selectedSeries.addAll(detail.series.map((series) => series.id));
    for (final value in detail.fieldValues) {
      _fieldControllers[value.fieldId] = TextEditingController(
        text: _displayValue(value.value),
      );
    }
  }

  Future<void> _save(List<CustomFieldDefinition> fields) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final acquiredText = _acquiredAtController.text.trim();
      final acquiredAt = acquiredText.isEmpty
          ? null
          : DateTime.tryParse(acquiredText);
      if (acquiredText.isNotEmpty && acquiredAt == null) {
        throw const OrganizationValidationFailure(
          OrganizationField.value,
          '入手日期请使用 YYYY-MM-DD。',
        );
      }
      final values = <CustomFieldValueInput>[];
      for (final field in fields) {
        final text = _fieldControllers[field.id]?.text.trim() ?? '';
        if (text.isEmpty) continue;
        switch (field.fieldType) {
          case CustomFieldType.text:
            values.add(
              CustomFieldValueInput.text(fieldId: field.id, value: text),
            );
          case CustomFieldType.number:
            final number = double.tryParse(text);
            if (number == null) {
              throw OrganizationValidationFailure(
                OrganizationField.value,
                '“${field.name}”请输入有效数字。',
              );
            }
            values.add(
              CustomFieldValueInput.number(fieldId: field.id, value: number),
            );
          case CustomFieldType.date:
            final date = DateTime.tryParse(text);
            if (date == null) {
              throw OrganizationValidationFailure(
                OrganizationField.value,
                '“${field.name}”请使用 YYYY-MM-DD。',
              );
            }
            values.add(
              CustomFieldValueInput.date(fieldId: field.id, value: date),
            );
        }
      }
      await ref
          .read(organizationRepositoryProvider)
          .saveCardOrganization(
            SaveCardOrganizationRequest(
              cardItemId: widget.cardItemId,
              cardType: _cardTypeController.text,
              needsCompletion: _needsCompletion,
              acquiredAt: acquiredAt,
              tagIds: _selectedTags.toList(),
              seriesIds: _selectedSeries.toList(),
              fieldValues: values,
            ),
          );
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
    } on AppFailure catch (failure) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.userMessage)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(cardOrganizationProvider(widget.cardItemId));
    final tags = ref.watch(organizationTagsProvider);
    final series = ref.watch(organizationSeriesProvider);
    final fields = ref.watch(organizationFieldDefinitionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('整理卡片')),
      body: detail.when(
        loading: () => const Center(
          child: CircularProgressIndicator(semanticsLabel: '正在加载整理信息'),
        ),
        error: (error, stackTrace) => _LoadError(
          onRetry: () =>
              ref.invalidate(cardOrganizationProvider(widget.cardItemId)),
        ),
        data: (value) {
          if (value == null) return const _MissingCard();
          _initialize(value);
          return _Form(
            detail: value,
            tags: tags,
            series: series,
            fields: fields,
            cardTypeController: _cardTypeController,
            acquiredAtController: _acquiredAtController,
            fieldControllers: _fieldControllers,
            selectedTags: _selectedTags,
            selectedSeries: _selectedSeries,
            needsCompletion: _needsCompletion,
            saving: _saving,
            onNeedsCompletionChanged: (selected) =>
                setState(() => _needsCompletion = selected),
            onTagChanged: (id, selected) => setState(
              () => selected ? _selectedTags.add(id) : _selectedTags.remove(id),
            ),
            onSeriesChanged: (id, selected) => setState(
              () => selected
                  ? _selectedSeries.add(id)
                  : _selectedSeries.remove(id),
            ),
            onSave: () =>
                _save(fields.value ?? const <CustomFieldDefinition>[]),
          );
        },
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({
    required this.detail,
    required this.tags,
    required this.series,
    required this.fields,
    required this.cardTypeController,
    required this.acquiredAtController,
    required this.fieldControllers,
    required this.selectedTags,
    required this.selectedSeries,
    required this.needsCompletion,
    required this.saving,
    required this.onNeedsCompletionChanged,
    required this.onTagChanged,
    required this.onSeriesChanged,
    required this.onSave,
  });

  final CardOrganizationDetail detail;
  final AsyncValue<List<TagSummary>> tags;
  final AsyncValue<List<SeriesSummary>> series;
  final AsyncValue<List<CustomFieldDefinition>> fields;
  final TextEditingController cardTypeController;
  final TextEditingController acquiredAtController;
  final Map<String, TextEditingController> fieldControllers;
  final Set<String> selectedTags;
  final Set<String> selectedSeries;
  final bool needsCompletion;
  final bool saving;
  final ValueChanged<bool> onNeedsCompletionChanged;
  final void Function(String id, bool selected) onTagChanged;
  final void Function(String id, bool selected) onSeriesChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        tokens.spaceLg,
        tokens.spaceMd,
        tokens.spaceLg,
        tokens.spaceXl,
      ),
      children: <Widget>[
        Text(
          '整理${detail.name}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: tokens.spaceSm),
        Text(
          '把稳定资料放在这里，之后可直接搜索和筛选。',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: tokens.spaceLg),
        TextField(
          key: const Key('card-type-input'),
          controller: cardTypeController,
          maxLength: 100,
          decoration: const InputDecoration(
            labelText: '卡片类型',
            hintText: '例如：纪念卡、单程票',
          ),
        ),
        TextField(
          key: const Key('acquired-at-input'),
          controller: acquiredAtController,
          keyboardType: TextInputType.datetime,
          decoration: const InputDecoration(
            labelText: '入手日期',
            hintText: 'YYYY-MM-DD',
          ),
        ),
        SwitchListTile(
          key: const Key('needs-completion-switch'),
          contentPadding: EdgeInsets.zero,
          value: needsCompletion,
          onChanged: onNeedsCompletionChanged,
          title: const Text('资料待补全'),
          subtitle: const Text('在收藏筛选中快速找到仍需整理的卡片'),
        ),
        SizedBox(height: tokens.spaceLg),
        const _GroupTitle(title: '标签', description: '可多选，最近使用的标签排在前面。'),
        tags.when(
          loading: () =>
              const LinearProgressIndicator(semanticsLabel: '正在加载标签'),
          error: (error, stackTrace) => const Text('标签暂时无法加载'),
          data: (items) => items.isEmpty
              ? const Text('还没有标签，可在“我的 · 整理管理”创建。')
              : Wrap(
                  spacing: tokens.spaceSm,
                  runSpacing: tokens.spaceSm,
                  children: <Widget>[
                    for (final tag in items)
                      FilterChip(
                        key: Key('tag-chip-${tag.id}'),
                        label: Text(tag.name),
                        selected: selectedTags.contains(tag.id),
                        onSelected: (selected) =>
                            onTagChanged(tag.id, selected),
                      ),
                  ],
                ),
        ),
        SizedBox(height: tokens.spaceLg),
        const _GroupTitle(title: '集卡册', description: '一张卡可以加入多个集卡册。'),
        series.when(
          loading: () =>
              const LinearProgressIndicator(semanticsLabel: '正在加载集卡册'),
          error: (error, stackTrace) => const Text('集卡册暂时无法加载'),
          data: (items) => items.isEmpty
              ? const Text('还没有集卡册，可从收藏页的“集卡册”新建。')
              : Wrap(
                  spacing: tokens.spaceSm,
                  runSpacing: tokens.spaceSm,
                  children: <Widget>[
                    for (final item in items)
                      FilterChip(
                        key: Key('series-chip-${item.id}'),
                        label: Text(item.name),
                        selected: selectedSeries.contains(item.id),
                        onSelected: (selected) =>
                            onSeriesChanged(item.id, selected),
                      ),
                  ],
                ),
        ),
        SizedBox(height: tokens.spaceLg),
        const _GroupTitle(title: '自定义字段', description: '空白值不会保存。'),
        fields.when(
          loading: () =>
              const LinearProgressIndicator(semanticsLabel: '正在加载自定义字段'),
          error: (error, stackTrace) => const Text('自定义字段暂时无法加载'),
          data: (items) => items.isEmpty
              ? const Text('还没有自定义字段。')
              : Column(
                  children: <Widget>[
                    for (final field in items) ...<Widget>[
                      TextField(
                        key: Key('field-input-${field.id}'),
                        controller: fieldControllers.putIfAbsent(
                          field.id,
                          TextEditingController.new,
                        ),
                        keyboardType: field.fieldType == CustomFieldType.number
                            ? const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              )
                            : field.fieldType == CustomFieldType.date
                            ? TextInputType.datetime
                            : TextInputType.text,
                        decoration: InputDecoration(
                          labelText: field.name,
                          hintText: field.fieldType == CustomFieldType.date
                              ? 'YYYY-MM-DD'
                              : null,
                        ),
                      ),
                      SizedBox(height: tokens.spaceSm),
                    ],
                  ],
                ),
        ),
        SizedBox(height: tokens.spaceXl),
        FilledButton.icon(
          key: const Key('save-card-organization'),
          onPressed: saving ? null : onSave,
          icon: saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: Text(saving ? '保存中…' : '保存整理信息'),
        ),
      ],
    );
  }
}

String _displayValue(CustomFieldValueInput value) => switch (value.fieldType) {
  CustomFieldType.text => value.textValue!,
  CustomFieldType.number => value.numberValue!.toString(),
  CustomFieldType.date => value.dateValue!.toIso8601String().split('T').first,
};

class _GroupTitle extends StatelessWidget {
  const _GroupTitle({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.tokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: context.tokens.spaceXs),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
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
    return Center(
      child: FilledButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text('整理信息加载失败，重试'),
      ),
    );
  }
}

class _MissingCard extends StatelessWidget {
  const _MissingCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('这张卡片已不存在'),
          SizedBox(height: context.tokens.spaceMd),
          TextButton(
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            child: const Text('返回'),
          ),
        ],
      ),
    );
  }
}
