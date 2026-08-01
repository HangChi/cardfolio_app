import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../card_sets/data/card_set_providers.dart';
import '../../../cards/data/card_providers.dart';
import '../../../cards/presentation/widgets/card_image.dart';
import '../../data/organization_providers.dart';
import '../../domain/organization_models.dart';
import 'series_cover_presets.dart';

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
  String? _coverRelativePath;
  late final String _seriesId;
  bool _initialized = false;
  bool _saving = false;
  bool _coverBusy = false;

  @override
  void initState() {
    super.initState();
    _seriesId = widget.seriesId ?? ref.read(idGeneratorProvider).newId();
  }

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
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(title: Text(widget.seriesId == null ? '新建集卡册' : '编辑集卡册')),
      body: detail.isLoading
          ? const Center(child: CircularProgressIndicator())
          : detail.hasError
          ? _LoadError(
              onRetry: () =>
                  ref.invalidate(seriesDetailProvider(widget.seriesId!)),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(
                tokens.spaceLg,
                tokens.spaceMd,
                tokens.spaceLg,
                tokens.spaceXl,
              ),
              children: <Widget>[
                TextField(
                  key: const Key('series-name-input'),
                  controller: _nameController,
                  maxLength: 100,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: '集卡册名称 *',
                    hintText: '例如：城市交通、世界博览会',
                  ),
                ),
                SizedBox(height: tokens.spaceMd),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        height: 176,
                        child: _coverRelativePath == null
                            ? CardImage.placeholder(semanticLabel: '集卡册封面')
                            : CardImage.managed(
                                relativePath: _coverRelativePath!,
                                semanticLabel: '集卡册封面',
                              ),
                      ),
                      ListTile(
                        onTap: _saving || _coverBusy ? null : _openCoverMenu,
                        leading: _coverBusy
                            ? const SizedBox.square(
                                dimension: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.add_a_photo_outlined),
                        title: Text(
                          _coverRelativePath == null ? '选择集卡册封面' : '已设置集卡册封面',
                        ),
                        subtitle: const Text('支持拍摄、从相册选择，或使用下方成员封面'),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: tokens.spaceMd),
                TextField(
                  key: const Key('series-description-input'),
                  controller: _descriptionController,
                  maxLength: SaveSeriesRequest.maxDescriptionLength,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: '说明',
                    hintText: '记录主题、收录范围或整理说明',
                  ),
                ),
                SizedBox(height: tokens.spaceLg),
                const _SectionTitle(
                  title: '卡片',
                  description: '选择要收录的卡片，并可将其中一张设为封面。',
                ),
                SizedBox(height: tokens.spaceSm),
                cards.when(
                  loading: () =>
                      const LinearProgressIndicator(semanticsLabel: '加载卡片'),
                  error: (error, stackTrace) => const Text('卡片暂时无法加载，请稍后重试。'),
                  data: (items) => items.isEmpty
                      ? const _EmptySelection(label: '还没有可选择的卡片')
                      : Card(
                          child: Column(
                            children: <Widget>[
                              for (
                                var index = 0;
                                index < items.length;
                                index++
                              ) ...<Widget>[
                                if (index > 0) const Divider(height: 1),
                                _SelectableMemberTile(
                                  key: Key(
                                    'series-card-${items[index].definitionId}',
                                  ),
                                  name: items[index].name,
                                  subtitle: '持有 ${items[index].quantity} 张',
                                  coverRelativePath:
                                      items[index].coverRelativePath,
                                  selected: _definitionIds.contains(
                                    items[index].definitionId,
                                  ),
                                  isCover:
                                      _coverRelativePath != null &&
                                      _coverRelativePath ==
                                          items[index].coverRelativePath,
                                  enabled: !_saving && !_coverBusy,
                                  onChanged: (selected) => _changeSelection(
                                    ids: _definitionIds,
                                    id: items[index].definitionId,
                                    coverPath: items[index].coverRelativePath,
                                    selected: selected,
                                  ),
                                  onSetCover:
                                      items[index].coverRelativePath == null
                                      ? null
                                      : () => _setCover(
                                          items[index].coverRelativePath,
                                        ),
                                ),
                              ],
                            ],
                          ),
                        ),
                ),
                SizedBox(height: tokens.spaceLg),
                const _SectionTitle(
                  title: '套卡',
                  description: '收纳套卡不会改变套卡原有的完成度。',
                ),
                SizedBox(height: tokens.spaceSm),
                sets.when(
                  loading: () =>
                      const LinearProgressIndicator(semanticsLabel: '加载套卡'),
                  error: (error, stackTrace) => const Text('套卡暂时无法加载，请稍后重试。'),
                  data: (items) => items.isEmpty
                      ? const _EmptySelection(label: '还没有可选择的套卡')
                      : Card(
                          child: Column(
                            children: <Widget>[
                              for (
                                var index = 0;
                                index < items.length;
                                index++
                              ) ...<Widget>[
                                if (index > 0) const Divider(height: 1),
                                _SelectableMemberTile(
                                  key: Key('series-set-${items[index].id}'),
                                  name: items[index].name,
                                  subtitle: items[index].countKnown
                                      ? '${items[index].progress.ownedRequiredCount} / '
                                            '${items[index].progress.requiredMemberCount}'
                                      : '总数未知',
                                  coverRelativePath:
                                      items[index].coverRelativePath,
                                  selected: _setIds.contains(items[index].id),
                                  isCover:
                                      _coverRelativePath != null &&
                                      _coverRelativePath ==
                                          items[index].coverRelativePath,
                                  enabled: !_saving && !_coverBusy,
                                  onChanged: (selected) => _changeSelection(
                                    ids: _setIds,
                                    id: items[index].id,
                                    coverPath: items[index].coverRelativePath,
                                    selected: selected,
                                  ),
                                  onSetCover:
                                      items[index].coverRelativePath == null
                                      ? null
                                      : () => _setCover(
                                          items[index].coverRelativePath,
                                        ),
                                ),
                              ],
                            ],
                          ),
                        ),
                ),
                SizedBox(height: tokens.spaceXl),
                FilledButton(
                  key: const Key('save-series'),
                  onPressed: _saving || _coverBusy ? null : _save,
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.seriesId == null ? '创建集卡册' : '保存修改'),
                ),
              ],
            ),
    );
  }

  void _changeSelection({
    required Set<String> ids,
    required String id,
    required String? coverPath,
    required bool selected,
  }) {
    setState(() {
      if (selected) {
        ids.add(id);
      } else {
        ids.remove(id);
        if (coverPath != null && coverPath == _coverRelativePath) {
          _coverRelativePath = null;
        }
      }
    });
  }

  Future<void> _openCoverMenu() async {
    final action = await showModalBottomSheet<_CoverAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('拍摄封面'),
              onTap: () => Navigator.pop(sheetContext, _CoverAction.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('从相册选择'),
              onTap: () => Navigator.pop(sheetContext, _CoverAction.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('使用默认封面'),
              onTap: () => Navigator.pop(sheetContext, _CoverAction.preset),
            ),
            if (_coverRelativePath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('清除封面'),
                onTap: () => Navigator.pop(sheetContext, _CoverAction.clear),
              ),
            const ListTile(
              leading: Icon(Icons.star_border),
              title: Text('也可以使用下方已选卡片或套卡的封面'),
            ),
          ],
        ),
      ),
    );
    switch (action) {
      case _CoverAction.camera:
        await _captureCover();
      case _CoverAction.gallery:
        await _pickCover();
      case _CoverAction.preset:
        await _choosePresetCover();
      case _CoverAction.clear:
        _setCover(null);
      case null:
        break;
    }
  }

  Future<void> _captureCover() async {
    setState(() => _coverBusy = true);
    try {
      final captured = await ref.read(cameraCaptureProvider).capture();
      if (captured != null) await _importCover(captured.path);
    } on AppFailure catch (failure) {
      _showMessage(failure.userMessage);
    } finally {
      if (mounted) setState(() => _coverBusy = false);
    }
  }

  Future<void> _pickCover() async {
    setState(() => _coverBusy = true);
    try {
      final selected = await ref.read(galleryPickerProvider).pickMany(limit: 1);
      if (selected.isNotEmpty) await _importCover(selected.first.path);
    } on AppFailure catch (failure) {
      _showMessage(failure.userMessage);
    } finally {
      if (mounted) setState(() => _coverBusy = false);
    }
  }

  Future<void> _choosePresetCover() async {
    final preset = await showModalBottomSheet<SeriesCoverPreset>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            sheetContext.tokens.spaceLg,
            0,
            sheetContext.tokens.spaceLg,
            sheetContext.tokens.spaceLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('默认封面', style: Theme.of(sheetContext).textTheme.titleLarge),
              SizedBox(height: sheetContext.tokens.spaceMd),
              Wrap(
                spacing: sheetContext.tokens.spaceSm,
                runSpacing: sheetContext.tokens.spaceSm,
                children: <Widget>[
                  for (final item in seriesCoverPresets)
                    InkWell(
                      borderRadius: BorderRadius.circular(
                        sheetContext.tokens.radiusMd,
                      ),
                      onTap: () => Navigator.pop(sheetContext, item),
                      child: Container(
                        width: 96,
                        height: 76,
                        padding: EdgeInsets.all(sheetContext.tokens.spaceSm),
                        decoration: BoxDecoration(
                          color: item.background,
                          borderRadius: BorderRadius.circular(
                            sheetContext.tokens.radiusMd,
                          ),
                          border: Border(
                            left: BorderSide(color: item.accent, width: 8),
                          ),
                        ),
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          item.name,
                          maxLines: 2,
                          style: Theme.of(sheetContext).textTheme.labelSmall
                              ?.copyWith(color: item.foreground),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (preset == null || !mounted) return;
    setState(() => _coverBusy = true);
    try {
      final sourcePath = await createSeriesPresetCover(
        preset: preset,
        title: _nameController.text,
        outputId: ref.read(idGeneratorProvider).newId(),
      );
      await _importCover(sourcePath);
    } on AppFailure catch (failure) {
      _showMessage(failure.userMessage);
    } catch (_) {
      _showMessage('默认封面生成失败，请重试。');
    } finally {
      if (mounted) setState(() => _coverBusy = false);
    }
  }

  Future<void> _importCover(String sourcePath) async {
    final managed = await ref
        .read(managedImageStoreProvider)
        .importImage(
          sourcePath: sourcePath,
          cardItemId: 'series-$_seriesId',
          imageId: ref.read(idGeneratorProvider).newId(),
        );
    _setCover(managed.relativePath);
  }

  void _setCover(String? relativePath) {
    if (!mounted) return;
    setState(() => _coverRelativePath = relativePath);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _initialize(SeriesDetail? detail) {
    if (_initialized) return;
    _initialized = true;
    if (detail == null) return;
    _nameController.text = detail.name;
    _descriptionController.text = detail.description ?? '';
    _coverRelativePath = detail.coverRelativePath;
    _definitionIds.addAll(detail.cards.map((card) => card.id));
    _setIds.addAll(detail.sets.map((set) => set.id));
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(organizationRepositoryProvider)
          .saveSeries(
            SaveSeriesRequest(
              id: _seriesId,
              name: _nameController.text,
              description: _descriptionController.text,
              coverRelativePath: _coverRelativePath,
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

enum _CoverAction { camera, gallery, preset, clear }

class _SelectableMemberTile extends StatelessWidget {
  const _SelectableMemberTile({
    required this.name,
    required this.subtitle,
    required this.coverRelativePath,
    required this.selected,
    required this.isCover,
    required this.enabled,
    required this.onChanged,
    required this.onSetCover,
    super.key,
  });

  final String name;
  final String subtitle;
  final String? coverRelativePath;
  final bool selected;
  final bool isCover;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onSetCover;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.tokens.spaceSm),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 72,
            height: 52,
            child: coverRelativePath == null
                ? CardImage.placeholder(semanticLabel: '$name封面')
                : CardImage.managed(
                    relativePath: coverRelativePath!,
                    semanticLabel: '$name封面',
                  ),
          ),
          SizedBox(width: context.tokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(name, maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (selected && onSetCover != null)
            IconButton(
              tooltip: isCover ? '当前封面' : '设为封面',
              onPressed: enabled ? onSetCover : null,
              icon: Icon(
                isCover ? Icons.star : Icons.star_border,
                color: isCover ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          Checkbox(
            value: selected,
            onChanged: enabled ? (value) => onChanged(value ?? false) : null,
          ),
        ],
      ),
    );
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
          ).textTheme.bodySmall?.copyWith(color: context.palette.textSecondary),
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
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceMd),
        child: Text(label),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('集卡册资料暂时无法加载'),
          TextButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}
