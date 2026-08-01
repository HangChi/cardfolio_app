import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../app/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/preferences/local_app_state.dart';
import '../../../../core/preferences/local_app_state_providers.dart';
import '../../../../core/widgets/app_name_dialog.dart';
import '../../../card_sets/data/card_set_providers.dart';
import '../../../card_sets/domain/card_set_models.dart';
import '../../../organization/data/organization_providers.dart';
import '../../../organization/domain/organization_models.dart';
import '../../../purchases/data/purchase_providers.dart';
import '../../../purchases/domain/purchase_models.dart';
import '../../data/card_providers.dart';
import '../../domain/card_models.dart';
import '../../domain/image_processing.dart';
import '../widgets/card_image.dart';
import '../widgets/card_location_field.dart';
import '../widgets/card_entry_metadata_fields.dart';
import '../widgets/optional_date_field.dart';

class BatchCardEntryScreen extends ConsumerStatefulWidget {
  const BatchCardEntryScreen({super.key});

  @override
  ConsumerState<BatchCardEntryScreen> createState() =>
      _BatchCardEntryScreenState();
}

class _BatchCardEntryScreenState extends ConsumerState<BatchCardEntryScreen> {
  final _drafts = <_BatchCardDraft>[];
  final _selectedAlbumIds = <String>{};
  final _sharedSetIds = <String>{};
  final _sharedCity = TextEditingController();
  final _sharedIssuer = TextEditingController();
  final _sharedCardType = TextEditingController();
  DateTime? _sharedAcquiredAt;
  Timer? _persistDebounce;
  bool _restoring = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_restoreDrafts);
  }

  @override
  void dispose() {
    for (final draft in _drafts) {
      draft.dispose();
    }
    _persistDebounce?.cancel();
    _sharedCity.dispose();
    _sharedIssuer.dispose();
    _sharedCardType.dispose();
    super.dispose();
  }

  Future<void> _restoreDrafts() async {
    try {
      final snapshot =
          (await ref.read(localAppStateStoreProvider).read()).batchEntry;
      if (!mounted) return;
      if (snapshot != null && snapshot.drafts.isNotEmpty) {
        _sharedCity.text = snapshot.shared['city'] as String? ?? '';
        _sharedIssuer.text = snapshot.shared['issuer'] as String? ?? '';
        _sharedCardType.text = snapshot.shared['cardType'] as String? ?? '';
        _sharedAcquiredAt = DateTime.tryParse(
          snapshot.shared['acquiredAt'] as String? ?? '',
        );
        _selectedAlbumIds.addAll(
          (snapshot.shared['albumIds'] as List<Object?>? ?? const <Object?>[])
              .whereType<String>(),
        );
        _sharedSetIds.addAll(
          (snapshot.shared['setIds'] as List<Object?>? ?? const <Object?>[])
              .whereType<String>(),
        );
        _drafts.addAll(snapshot.drafts.map(_BatchCardDraft.fromJson));
      } else {
        _addDraft(rebuild: false);
      }
    } on Object {
      await ref.read(localAppStateProvider.notifier).clearBatchEntry();
      if (!mounted) return;
      _addDraft(rebuild: false);
    }
    setState(() => _restoring = false);
  }

  void _schedulePersist() {
    if (_restoring || _saving) return;
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(milliseconds: 300), () {
      ref
          .read(localAppStateProvider.notifier)
          .saveBatchEntry(
            BatchEntrySnapshot(
              shared: <String, Object?>{
                'city': _sharedCity.text,
                'issuer': _sharedIssuer.text,
                'cardType': _sharedCardType.text,
                'acquiredAt': _sharedAcquiredAt?.toIso8601String(),
                'albumIds': _selectedAlbumIds.toList(growable: false),
                'setIds': _sharedSetIds.toList(growable: false),
              },
              drafts: _drafts
                  .where((draft) => !draft.saved)
                  .map((draft) => draft.toJson())
                  .toList(growable: false),
            ),
          );
    });
  }

  void _addDraft({bool rebuild = true}) {
    final generator = ref.read(idGeneratorProvider);
    final draft = _BatchCardDraft(
      ids: CardDraftIds.create(generator),
      backImageId: generator.newId(),
    );
    if (rebuild) {
      setState(() => _drafts.add(draft));
    } else {
      _drafts.add(draft);
    }
    _schedulePersist();
  }

  void _removeDraft(_BatchCardDraft draft) {
    if (_drafts.length == 1 || draft.saved || _saving) return;
    setState(() => _drafts.remove(draft));
    draft.dispose();
    _schedulePersist();
  }

  Future<void> _chooseImage(_BatchCardDraft draft, CardImageKind side) async {
    if (_saving || draft.saved) return;
    final source = await showModalBottomSheet<_ImageSourceChoice>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('从相册选择'),
              onTap: () => context.pop(_ImageSourceChoice.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('拍摄'),
              onTap: () => context.pop(_ImageSourceChoice.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    try {
      final String? path;
      if (source == _ImageSourceChoice.gallery) {
        final images = await ref.read(galleryPickerProvider).pickMany(limit: 1);
        path = images.isEmpty ? null : images.first.path;
      } else {
        final captured = await ref.read(cameraCaptureProvider).capture();
        path = captured?.path;
      }
      if (path == null || !mounted) return;
      setState(() {
        if (side == CardImageKind.front) {
          draft.frontPath = path;
          draft.frontDerivedPath = null;
        } else {
          draft.backPath = path;
          draft.backDerivedPath = null;
        }
      });
      _schedulePersist();
    } on AppFailure catch (failure) {
      _showMessage(failure.userMessage);
    }
  }

  Future<void> _editImage(_BatchCardDraft draft, CardImageKind side) async {
    if (_saving || draft.saved || draft.confirmed) return;
    final sourcePath = side == CardImageKind.front
        ? draft.frontDerivedPath ?? draft.frontPath
        : draft.backDerivedPath ?? draft.backPath;
    if (sourcePath == null) return;
    final outputId = side == CardImageKind.front
        ? draft.ids.imageId
        : draft.backImageId;
    final processed = await context.push<ProcessedImage>(
      imageEditorPath,
      extra: ImageEditorRouteArgs(sourcePath: sourcePath, outputId: outputId),
    );
    if (processed == null || !mounted) return;
    setState(() {
      if (side == CardImageKind.front) {
        draft.frontDerivedPath = processed.path;
      } else {
        draft.backDerivedPath = processed.path;
      }
    });
    _schedulePersist();
  }

  Future<void> _saveAll() async {
    if (_saving) return;
    if (_drafts.any((draft) => !draft.saved && !draft.confirmed)) {
      _showMessage('请先逐张确认本批次中的卡片资料。');
      return;
    }
    setState(() => _saving = true);
    var savedCount = 0;
    try {
      for (final draft in _drafts.where((draft) => !draft.saved)) {
        final amountMinor = parseOptionalCnyMinor(draft.amount.text);
        final shippingMinor = parseOptionalCnyMinor(draft.shipping.text);
        final front = draft.frontPath;
        final back = draft.backPath;
        final primaryPath = front ?? back ?? '';
        final primaryDerivedPath = front != null
            ? draft.frontDerivedPath
            : draft.backDerivedPath;
        final primaryKind = front != null
            ? CardImageKind.front
            : CardImageKind.back;
        final request = CreateCardRequest(
          ids: draft.ids,
          sourceImagePath: primaryPath,
          derivedSourceImagePath: primaryDerivedPath,
          primaryImageKind: primaryKind,
          additionalImages: <PendingCardImage>[
            if (front != null && back != null)
              PendingCardImage(
                id: draft.backImageId,
                sourcePath: back,
                derivedSourcePath: draft.backDerivedPath,
                kind: CardImageKind.back,
              ),
          ],
          name: draft.name.text,
          city: _sharedCity.text,
          issuer: _sharedIssuer.text,
          issuedAt: draft.issuedAt == null
              ? null
              : PartialDate.tryParse(formatOptionalDate(draft.issuedAt!)),
        );
        final cardItemId = await ref
            .read(cardRepositoryProvider)
            .createCard(request);
        await ref
            .read(organizationRepositoryProvider)
            .saveCardOrganization(
              SaveCardOrganizationRequest(
                cardItemId: cardItemId,
                cardType: _sharedCardType.text,
                acquiredAt: _sharedAcquiredAt,
                tagIds: draft.tagIds.toList(growable: false),
                seriesIds: _selectedAlbumIds.toList(growable: false),
              ),
            );
        await saveCardSetSelections(
          ref: ref,
          definitionId: draft.ids.definitionId,
          selectedSetIds: <String>{..._sharedSetIds, ...draft.setIds},
        );
        await ref
            .read(purchaseRepositoryProvider)
            .saveCardEntryCost(
              SaveCardEntryCostRequest(
                cardItemId: cardItemId,
                amountMinor: amountMinor,
                shippingMinor: shippingMinor,
                purchasedAt: _sharedAcquiredAt,
              ),
            );
        if (!mounted) return;
        setState(() {
          draft.saved = true;
          draft.savedCardItemId = cardItemId;
        });
        savedCount++;
        _schedulePersist();
      }
      if (!mounted) return;
      _persistDebounce?.cancel();
      await ref.read(localAppStateProvider.notifier).clearBatchEntry();
      if (!mounted) return;
      _showMessage('已保存 $savedCount 张卡片。');
      context.go(libraryPath);
    } on AppFailure catch (failure) {
      _showMessage('已保存 $savedCount 张；当前草稿保存失败：${failure.userMessage}');
    } catch (_) {
      _showMessage('已保存 $savedCount 张；当前草稿保存失败，请重试。');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
        if (_drafts.any((draft) => !draft.saved)) _schedulePersist();
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _createTag(_BatchCardDraft draft) async {
    try {
      final id = await createTagInline(context, ref);
      if (id != null && mounted) {
        setState(() => draft.tagIds.add(id));
        _schedulePersist();
      }
    } on AppFailure catch (failure) {
      _showMessage(failure.userMessage);
    }
  }

  Future<void> _createSharedSet() async {
    final name = await showAppNameDialog(
      context,
      title: '创建本批次套卡',
      fieldLabel: '套卡名称',
      actionLabel: '创建并选中',
      maxLength: CreateCardSetRequest.maxNameLength,
    );
    if (name == null || name.isEmpty) return;
    try {
      final id = ref.read(idGeneratorProvider).newId();
      await ref
          .read(cardSetRepositoryProvider)
          .createSet(
            CreateCardSetRequest(id: id, name: name, countKnown: false),
          );
      if (!mounted) return;
      setState(() => _sharedSetIds.add(id));
      _schedulePersist();
    } on AppFailure catch (failure) {
      _showMessage(failure.userMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tags =
        ref.watch(organizationTagsProvider).value ?? const <TagSummary>[];
    final albums =
        ref.watch(organizationSeriesProvider).value ?? const <SeriesSummary>[];
    final cardSets =
        ref.watch(cardSetListProvider).value ?? const <CardSetSummary>[];
    final tokens = context.tokens;

    if (_restoring) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(semanticsLabel: '正在恢复批量草稿'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('批量录入卡片'),
        actions: <Widget>[
          TextButton(
            onPressed: _saving ? null : _saveAll,
            child: const Text('全部保存'),
          ),
          SizedBox(width: tokens.spaceSm),
        ],
        bottom: _saving
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.spaceLg,
          tokens.spaceMd,
          tokens.spaceLg,
          tokens.spaceXl,
        ),
        children: <Widget>[
          Text(
            '每张卡片都可只录正面、只录背面或暂不添加图片；填写后请逐张确认，再一次保存。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: tokens.spaceMd),
          Text('本批次共用资料', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: tokens.spaceSm),
          CardLocationField(
            value: _sharedCity.text,
            enabled: !_saving,
            label: '城市（共用）',
            onChanged: (value) {
              setState(() => _sharedCity.text = value);
              _schedulePersist();
            },
          ),
          SizedBox(height: tokens.spaceSm),
          TextField(
            controller: _sharedIssuer,
            enabled: !_saving,
            onChanged: (_) => _schedulePersist(),
            decoration: const InputDecoration(labelText: '发行机构（共用）'),
          ),
          SizedBox(height: tokens.spaceSm),
          TextField(
            controller: _sharedCardType,
            enabled: !_saving,
            onChanged: (_) => _schedulePersist(),
            decoration: const InputDecoration(labelText: '卡片类型（共用）'),
          ),
          SizedBox(height: tokens.spaceSm),
          OptionalDateField(
            label: '入手日期（共用）',
            value: _sharedAcquiredAt,
            enabled: !_saving,
            onChanged: (value) {
              setState(() => _sharedAcquiredAt = value);
              _schedulePersist();
            },
          ),
          SizedBox(height: tokens.spaceMd),
          Text(
            '加入卡册（本批次共用，可多选）',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: tokens.spaceSm),
          if (albums.isEmpty)
            Text('暂无卡册', style: Theme.of(context).textTheme.bodySmall)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final album in albums)
                  FilterChip(
                    label: Text(album.name),
                    selected: _selectedAlbumIds.contains(album.id),
                    onSelected: _saving
                        ? null
                        : (selected) => setState(() {
                            selected
                                ? _selectedAlbumIds.add(album.id)
                                : _selectedAlbumIds.remove(album.id);
                            _schedulePersist();
                          }),
                  ),
              ],
            ),
          SizedBox(height: tokens.spaceMd),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '加入套卡（本批次共用，可多选）',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton.icon(
                onPressed: _saving ? null : _createSharedSet,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('新建套卡'),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceSm),
          if (cardSets.isEmpty)
            Text('暂无套卡，可直接新建', style: Theme.of(context).textTheme.bodySmall)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final cardSet in cardSets)
                  FilterChip(
                    label: Text(cardSet.name),
                    selected: _sharedSetIds.contains(cardSet.id),
                    onSelected: _saving
                        ? null
                        : (selected) {
                            setState(() {
                              selected
                                  ? _sharedSetIds.add(cardSet.id)
                                  : _sharedSetIds.remove(cardSet.id);
                            });
                            _schedulePersist();
                          },
                  ),
              ],
            ),
          SizedBox(height: tokens.spaceLg),
          for (var index = 0; index < _drafts.length; index++) ...<Widget>[
            _BatchDraftCard(
              index: index,
              draft: _drafts[index],
              tags: tags,
              cardSets: cardSets,
              enabled: !_saving,
              onRemove: () => _removeDraft(_drafts[index]),
              onChooseFront: () =>
                  _chooseImage(_drafts[index], CardImageKind.front),
              onChooseBack: () =>
                  _chooseImage(_drafts[index], CardImageKind.back),
              onEditFront: () =>
                  _editImage(_drafts[index], CardImageKind.front),
              onEditBack: () => _editImage(_drafts[index], CardImageKind.back),
              onCreateTag: () => _createTag(_drafts[index]),
              onChanged: () {
                setState(() {});
                _schedulePersist();
              },
            ),
            SizedBox(height: tokens.spaceMd),
          ],
          OutlinedButton.icon(
            onPressed: _saving ? null : _addDraft,
            icon: const Icon(Icons.add),
            label: const Text('再添加一张卡片'),
          ),
          SizedBox(height: tokens.spaceMd),
          FilledButton(
            onPressed: _saving ? null : _saveAll,
            child: Text(_saving ? '正在保存…' : '保存全部卡片'),
          ),
        ],
      ),
    );
  }
}

class _BatchDraftCard extends StatelessWidget {
  const _BatchDraftCard({
    required this.index,
    required this.draft,
    required this.tags,
    required this.cardSets,
    required this.enabled,
    required this.onRemove,
    required this.onChooseFront,
    required this.onChooseBack,
    required this.onEditFront,
    required this.onEditBack,
    required this.onCreateTag,
    required this.onChanged,
  });

  final int index;
  final _BatchCardDraft draft;
  final List<TagSummary> tags;
  final List<CardSetSummary> cardSets;
  final bool enabled;
  final VoidCallback onRemove;
  final VoidCallback onChooseFront;
  final VoidCallback onChooseBack;
  final VoidCallback onEditFront;
  final VoidCallback onEditBack;
  final VoidCallback onCreateTag;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    draft.saved ? '卡片 ${index + 1} · 已保存' : '卡片 ${index + 1}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: enabled && !draft.saved ? onRemove : null,
                  tooltip: '移除草稿',
                  icon: draft.saved
                      ? Icon(Icons.check_circle, color: context.palette.success)
                      : const Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: tokens.spaceSm),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('已确认此卡资料'),
              subtitle: const Text('确认后锁定本卡草稿；取消勾选可继续修改。'),
              value: draft.confirmed,
              onChanged: enabled && !draft.saved
                  ? (value) {
                      draft.confirmed = value ?? false;
                      onChanged();
                    }
                  : null,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: _SideImage(
                    label: '正面',
                    path: draft.frontDerivedPath ?? draft.frontPath,
                    enabled: enabled && !draft.saved && !draft.confirmed,
                    onPressed: onChooseFront,
                    onEdit: onEditFront,
                  ),
                ),
                SizedBox(width: tokens.spaceMd),
                Expanded(
                  child: _SideImage(
                    label: '背面',
                    path: draft.backDerivedPath ?? draft.backPath,
                    enabled: enabled && !draft.saved && !draft.confirmed,
                    onPressed: onChooseBack,
                    onEdit: onEditBack,
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spaceMd),
            TextField(
              controller: draft.name,
              enabled: enabled && !draft.saved && !draft.confirmed,
              onChanged: (_) => onChanged(),
              decoration: const InputDecoration(labelText: '名称'),
            ),
            SizedBox(height: tokens.spaceMd),
            OptionalDateField(
              label: '发行日期',
              value: draft.issuedAt,
              enabled: enabled && !draft.saved && !draft.confirmed,
              onChanged: (value) {
                draft.issuedAt = value;
                onChanged();
              },
            ),
            SizedBox(height: tokens.spaceMd),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '卡片标签',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: enabled && !draft.saved && !draft.confirmed
                      ? onCreateTag
                      : null,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('新建标签'),
                ),
              ],
            ),
            SizedBox(height: tokens.spaceSm),
            if (tags.isEmpty)
              Text('暂无标签', style: Theme.of(context).textTheme.bodySmall)
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final tag in tags)
                    FilterChip(
                      label: Text(tag.name),
                      selected: draft.tagIds.contains(tag.id),
                      onSelected: enabled && !draft.saved && !draft.confirmed
                          ? (selected) {
                              selected
                                  ? draft.tagIds.add(tag.id)
                                  : draft.tagIds.remove(tag.id);
                              onChanged();
                            }
                          : null,
                    ),
                ],
              ),
            SizedBox(height: tokens.spaceMd),
            Text('加入套卡', style: Theme.of(context).textTheme.titleSmall),
            SizedBox(height: tokens.spaceSm),
            if (cardSets.isEmpty)
              Text('暂无套卡', style: Theme.of(context).textTheme.bodySmall)
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final cardSet in cardSets)
                    FilterChip(
                      label: Text(cardSet.name),
                      selected: draft.setIds.contains(cardSet.id),
                      onSelected: enabled && !draft.saved && !draft.confirmed
                          ? (selected) {
                              selected
                                  ? draft.setIds.add(cardSet.id)
                                  : draft.setIds.remove(cardSet.id);
                              onChanged();
                            }
                          : null,
                    ),
                ],
              ),
            SizedBox(height: tokens.spaceMd),
            CardEntryCostFields(
              amountController: draft.amount,
              shippingController: draft.shipping,
              enabled: enabled && !draft.saved && !draft.confirmed,
              onChanged: (_) => onChanged(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideImage extends StatelessWidget {
  const _SideImage({
    required this.label,
    required this.path,
    required this.enabled,
    required this.onPressed,
    required this.onEdit,
  });

  final String label;
  final String? path;
  final bool enabled;
  final VoidCallback onPressed;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 85.60 / 53.98,
          child: path == null
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(
                      context.tokens.radiusMd,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.image_outlined, size: 36),
                  ),
                )
              : Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CardImage.local(
                      path: path!,
                      semanticLabel: label,
                      borderRadius: BorderRadius.circular(
                        context.tokens.radiusMd,
                      ),
                    ),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Chip(
                        label: Text(label),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: enabled ? onPressed : null,
                child: Text(path == null ? '添加${label.substring(0, 2)}' : '更换'),
              ),
            ),
            if (path != null) ...<Widget>[
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: enabled ? onEdit : null,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('编辑'),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

final class _BatchCardDraft {
  _BatchCardDraft({required this.ids, required this.backImageId});

  factory _BatchCardDraft.fromJson(Map<String, Object?> json) {
    final draft = _BatchCardDraft(
      ids: CardDraftIds(
        definitionId: json['definitionId'] as String,
        cardItemId: json['cardItemId'] as String,
        imageId: json['imageId'] as String,
      ),
      backImageId: json['backImageId'] as String,
    );
    draft.name.text = json['name'] as String? ?? '';
    draft.amount.text = json['amount'] as String? ?? '';
    draft.shipping.text = json['shipping'] as String? ?? '';
    draft.frontPath = json['frontPath'] as String?;
    draft.backPath = json['backPath'] as String?;
    draft.frontDerivedPath = json['frontDerivedPath'] as String?;
    draft.backDerivedPath = json['backDerivedPath'] as String?;
    draft.issuedAt = DateTime.tryParse(json['issuedAt'] as String? ?? '');
    draft.confirmed = json['confirmed'] as bool? ?? false;
    draft.tagIds.addAll(
      (json['tagIds'] as List<Object?>? ?? const <Object?>[])
          .whereType<String>(),
    );
    draft.setIds.addAll(
      (json['setIds'] as List<Object?>? ?? const <Object?>[])
          .whereType<String>(),
    );
    return draft;
  }

  final CardDraftIds ids;
  final String backImageId;
  final TextEditingController name = TextEditingController();
  final TextEditingController amount = TextEditingController();
  final TextEditingController shipping = TextEditingController();
  final Set<String> tagIds = <String>{};
  final Set<String> setIds = <String>{};
  String? frontPath;
  String? backPath;
  String? frontDerivedPath;
  String? backDerivedPath;
  DateTime? issuedAt;
  bool saved = false;
  bool confirmed = false;
  String? savedCardItemId;

  Map<String, Object?> toJson() => <String, Object?>{
    'definitionId': ids.definitionId,
    'cardItemId': ids.cardItemId,
    'imageId': ids.imageId,
    'backImageId': backImageId,
    'name': name.text,
    'amount': amount.text,
    'shipping': shipping.text,
    'frontPath': frontPath,
    'backPath': backPath,
    'frontDerivedPath': frontDerivedPath,
    'backDerivedPath': backDerivedPath,
    'issuedAt': issuedAt?.toIso8601String(),
    'confirmed': confirmed,
    'tagIds': tagIds.toList(growable: false),
    'setIds': setIds.toList(growable: false),
  };

  void dispose() {
    name.dispose();
    amount.dispose();
    shipping.dispose();
  }
}

enum _ImageSourceChoice { gallery, camera }
