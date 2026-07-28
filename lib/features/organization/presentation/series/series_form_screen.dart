import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../card_sets/data/card_set_providers.dart';
import '../../../cards/data/card_providers.dart';
import '../../data/organization_providers.dart';
import '../../domain/organization_models.dart';

class SeriesFormScreen extends ConsumerStatefulWidget {
  const SeriesFormScreen({super.key, this.seriesId});

  final String? seriesId;

  @override
  ConsumerState<SeriesFormScreen> createState() => _SeriesFormScreenState();
}

class _SeriesFormScreenState extends ConsumerState<SeriesFormScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _definitionIds = <String>{};
  final _setIds = <String>{};
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(organizedCardListProvider);
    final sets = ref.watch(cardSetListProvider);
    final detail = widget.seriesId == null
        ? const AsyncValue<SeriesDetail?>.data(null)
        : ref.watch(seriesDetailProvider(widget.seriesId!));

    detail.whenData(_initialize);

    return Scaffold(
      appBar: AppBar(title: Text(widget.seriesId == null ? '新建系列' : '编辑系列')),
      body: detail.isLoading
          ? const Center(child: CircularProgressIndicator())
          : detail.hasError
          ? _LoadError(
              onRetry: () =>
                  ref.invalidate(seriesDetailProvider(widget.seriesId!)),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(
                context.tokens.spaceLg,
                context.tokens.spaceMd,
                context.tokens.spaceLg,
                context.tokens.spaceXl,
              ),
              children: <Widget>[
                TextField(
                  key: const Key('series-name-input'),
                  controller: _nameController,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    labelText: '系列名称',
                    hintText: '例如：城市交通、世界博览会',
                  ),
                ),
                SizedBox(height: context.tokens.spaceSm),
                TextField(
                  key: const Key('series-description-input'),
                  controller: _descriptionController,
                  maxLength: SaveSeriesRequest.maxDescriptionLength,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: '说明（可选）'),
                ),
                SizedBox(height: context.tokens.spaceLg),
                const _SectionTitle(
                  title: '卡片',
                  description: '同一定义下的多张实体卡只需选择一次。',
                ),
                cards.when(
                  loading: () =>
                      const LinearProgressIndicator(semanticsLabel: '加载卡片'),
                  error: (error, stackTrace) => const Text('卡片暂时无法加载，请稍后重试。'),
                  data: (items) => items.isEmpty
                      ? const _EmptySelection(label: '还没有可选择的卡片')
                      : Column(
                          children: <Widget>[
                            for (final card in items)
                              CheckboxListTile(
                                key: Key('series-card-${card.definitionId}'),
                                value: _definitionIds.contains(
                                  card.definitionId,
                                ),
                                title: Text(card.name),
                                subtitle: card.quantity > 1
                                    ? Text('持有 ${card.quantity} 张')
                                    : null,
                                onChanged: (selected) => setState(() {
                                  if (selected == true) {
                                    _definitionIds.add(card.definitionId);
                                  } else {
                                    _definitionIds.remove(card.definitionId);
                                  }
                                }),
                              ),
                          ],
                        ),
                ),
                SizedBox(height: context.tokens.spaceLg),
                const _SectionTitle(
                  title: '套卡',
                  description: '系列只负责归类，不改变套卡的完成度。',
                ),
                sets.when(
                  loading: () =>
                      const LinearProgressIndicator(semanticsLabel: '加载套卡'),
                  error: (error, stackTrace) => const Text('套卡暂时无法加载，请稍后重试。'),
                  data: (items) => items.isEmpty
                      ? const _EmptySelection(label: '还没有可选择的套卡')
                      : Column(
                          children: <Widget>[
                            for (final set in items)
                              CheckboxListTile(
                                key: Key('series-set-${set.id}'),
                                value: _setIds.contains(set.id),
                                title: Text(set.name),
                                onChanged: (selected) => setState(() {
                                  if (selected == true) {
                                    _setIds.add(set.id);
                                  } else {
                                    _setIds.remove(set.id);
                                  }
                                }),
                              ),
                          ],
                        ),
                ),
                SizedBox(height: context.tokens.spaceXl),
                FilledButton.icon(
                  key: const Key('save-series'),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_saving ? '正在保存' : '保存系列'),
                ),
              ],
            ),
    );
  }

  void _initialize(SeriesDetail? detail) {
    if (_initialized) return;
    _initialized = true;
    if (detail == null) return;
    _nameController.text = detail.name;
    _descriptionController.text = detail.description ?? '';
    _definitionIds.addAll(detail.cards.map((card) => card.id));
    _setIds.addAll(detail.sets.map((set) => set.id));
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final id = widget.seriesId ?? ref.read(idGeneratorProvider).newId();
      await ref
          .read(organizationRepositoryProvider)
          .saveSeries(
            SaveSeriesRequest(
              id: id,
              name: _nameController.text,
              description: _descriptionController.text,
              definitionIds: _definitionIds.toList(growable: false),
              setIds: _setIds.toList(growable: false),
            ),
          );
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
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
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

class _EmptySelection extends StatelessWidget {
  const _EmptySelection({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.tokens.spaceMd),
      child: Text(label),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('系列资料暂时无法加载'),
          TextButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}
