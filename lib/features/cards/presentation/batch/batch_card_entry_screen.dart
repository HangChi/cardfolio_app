import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../app/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../organization/data/organization_providers.dart';
import '../../../organization/domain/organization_models.dart';
import '../../data/card_providers.dart';
import '../../domain/card_models.dart';
import '../widgets/card_image.dart';
import '../widgets/optional_date_field.dart';

class BatchCardEntryScreen extends ConsumerStatefulWidget {
  const BatchCardEntryScreen({super.key});

  @override
  ConsumerState<BatchCardEntryScreen> createState() =>
      _BatchCardEntryScreenState();
}

class _BatchCardEntryScreenState extends ConsumerState<BatchCardEntryScreen> {
  final _drafts = <_BatchCardDraft>[];
  String? _albumId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _addDraft(rebuild: false);
  }

  @override
  void dispose() {
    for (final draft in _drafts) {
      draft.dispose();
    }
    super.dispose();
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
  }

  void _removeDraft(_BatchCardDraft draft) {
    if (_drafts.length == 1 || draft.saved || _saving) return;
    setState(() => _drafts.remove(draft));
    draft.dispose();
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
        path = (await ref.read(cameraCaptureProvider).capture())?.path;
      }
      if (path == null || !mounted) return;
      setState(() {
        if (side == CardImageKind.front) {
          draft.frontPath = path;
        } else {
          draft.backPath = path;
        }
      });
    } on AppFailure catch (failure) {
      _showMessage(failure.userMessage);
    }
  }

  Future<void> _saveAll() async {
    if (_saving) return;
    setState(() => _saving = true);
    var savedCount = 0;
    try {
      for (final draft in _drafts.where((draft) => !draft.saved)) {
        final front = draft.frontPath;
        final back = draft.backPath;
        final primaryPath = front ?? back ?? '';
        final primaryKind = front != null
            ? CardImageKind.front
            : CardImageKind.back;
        final request = CreateCardRequest(
          ids: draft.ids,
          sourceImagePath: primaryPath,
          primaryImageKind: primaryKind,
          additionalImages: <PendingCardImage>[
            if (front != null && back != null)
              PendingCardImage(
                id: draft.backImageId,
                sourcePath: back,
                kind: CardImageKind.back,
              ),
          ],
          name: draft.name.text,
          issuedAt: draft.issuedAt == null
              ? null
              : PartialDate.tryParse(formatOptionalDate(draft.issuedAt!)),
        );
        final cardItemId = await ref
            .read(cardRepositoryProvider)
            .createCard(request);
        if (draft.tagIds.isNotEmpty || _albumId != null) {
          await ref
              .read(organizationRepositoryProvider)
              .saveCardOrganization(
                SaveCardOrganizationRequest(
                  cardItemId: cardItemId,
                  tagIds: draft.tagIds.toList(growable: false),
                  seriesIds: _albumId == null
                      ? const <String>[]
                      : <String>[_albumId!],
                ),
              );
        }
        if (!mounted) return;
        setState(() {
          draft.saved = true;
          draft.savedCardItemId = cardItemId;
        });
        savedCount++;
      }
      if (!mounted) return;
      _showMessage('已保存 $savedCount 张卡片。');
      context.go(libraryPath);
    } on AppFailure catch (failure) {
      _showMessage('已保存 $savedCount 张；当前草稿保存失败：${failure.userMessage}');
    } catch (_) {
      _showMessage('已保存 $savedCount 张；当前草稿保存失败，请重试。');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final tags =
        ref.watch(organizationTagsProvider).value ?? const <TagSummary>[];
    final albums =
        ref.watch(organizationSeriesProvider).value ?? const <SeriesSummary>[];
    final tokens = context.tokens;

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
            '每张卡片都可只录正面、只录背面或暂不添加图片；名称、日期和标签也都可稍后补充。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: tokens.spaceMd),
          DropdownButtonFormField<String>(
            initialValue: _albumId ?? '',
            decoration: const InputDecoration(labelText: '集卡册（本批次共用，可选）'),
            items: <DropdownMenuItem<String>>[
              const DropdownMenuItem<String>(value: '', child: Text('暂不加入集卡册')),
              for (final album in albums)
                DropdownMenuItem<String>(
                  value: album.id,
                  child: Text(album.name),
                ),
            ],
            onChanged: _saving
                ? null
                : (value) => setState(
                    () => _albumId = value == null || value.isEmpty
                        ? null
                        : value,
                  ),
          ),
          SizedBox(height: tokens.spaceLg),
          for (var index = 0; index < _drafts.length; index++) ...<Widget>[
            _BatchDraftCard(
              index: index,
              draft: _drafts[index],
              tags: tags,
              enabled: !_saving,
              onRemove: () => _removeDraft(_drafts[index]),
              onChooseFront: () =>
                  _chooseImage(_drafts[index], CardImageKind.front),
              onChooseBack: () =>
                  _chooseImage(_drafts[index], CardImageKind.back),
              onChanged: () => setState(() {}),
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
    required this.enabled,
    required this.onRemove,
    required this.onChooseFront,
    required this.onChooseBack,
    required this.onChanged,
  });

  final int index;
  final _BatchCardDraft draft;
  final List<TagSummary> tags;
  final bool enabled;
  final VoidCallback onRemove;
  final VoidCallback onChooseFront;
  final VoidCallback onChooseBack;
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
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: tokens.spaceSm),
            Row(
              children: <Widget>[
                Expanded(
                  child: _SideImage(
                    label: '正面（可选）',
                    path: draft.frontPath,
                    enabled: enabled && !draft.saved,
                    onPressed: onChooseFront,
                  ),
                ),
                SizedBox(width: tokens.spaceMd),
                Expanded(
                  child: _SideImage(
                    label: '背面（可选）',
                    path: draft.backPath,
                    enabled: enabled && !draft.saved,
                    onPressed: onChooseBack,
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spaceMd),
            TextField(
              controller: draft.name,
              enabled: enabled && !draft.saved,
              decoration: const InputDecoration(labelText: '名称（可选）'),
            ),
            SizedBox(height: tokens.spaceMd),
            OptionalDateField(
              label: '发行日期（可选）',
              value: draft.issuedAt,
              enabled: enabled && !draft.saved,
              onChanged: (value) {
                draft.issuedAt = value;
                onChanged();
              },
            ),
            SizedBox(height: tokens.spaceMd),
            Text('卡片标签（可选）', style: Theme.of(context).textTheme.titleSmall),
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
                      onSelected: enabled && !draft.saved
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
  });

  final String label;
  final String? path;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 0.72,
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
              : CardImage.local(
                  path: path!,
                  semanticLabel: label,
                  borderRadius: BorderRadius.circular(context.tokens.radiusMd),
                ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: enabled ? onPressed : null,
          child: Text(path == null ? label : '更换${label.substring(0, 2)}'),
        ),
      ],
    );
  }
}

final class _BatchCardDraft {
  _BatchCardDraft({required this.ids, required this.backImageId});

  final CardDraftIds ids;
  final String backImageId;
  final TextEditingController name = TextEditingController();
  final Set<String> tagIds = <String>{};
  String? frontPath;
  String? backPath;
  DateTime? issuedAt;
  bool saved = false;
  String? savedCardItemId;

  void dispose() => name.dispose();
}

enum _ImageSourceChoice { gallery, camera }
