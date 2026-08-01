import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../app/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../card_sets/data/card_set_providers.dart';
import '../../../card_sets/domain/card_set_models.dart';
import '../../../organization/data/organization_providers.dart';
import '../../../organization/domain/organization_models.dart';
import '../../../purchases/data/purchase_providers.dart';
import '../../../purchases/domain/purchase_models.dart';
import '../../domain/card_models.dart';
import '../../domain/card_autofill.dart';
import '../../domain/reserved_card_metadata.dart';
import '../../data/card_providers.dart';
import '../../domain/image_processing.dart';
import 'create_card_controller.dart';
import 'create_card_state.dart';
import '../widgets/card_image.dart';
import '../widgets/card_condition_field.dart';
import '../widgets/card_entry_metadata_fields.dart';
import '../widgets/card_autofill_button.dart';
import '../widgets/card_image_kind_label.dart';
import '../widgets/card_location_field.dart';
import '../widgets/optional_date_field.dart';
import '../widgets/reserved_card_metadata_fields.dart';

/// 新建卡片表单。名称和城市必填，其余资料可在保存后继续补充。
class CreateCardScreen extends ConsumerStatefulWidget {
  const CreateCardScreen({this.copyFromCardItemId, super.key});

  final String? copyFromCardItemId;

  @override
  ConsumerState<CreateCardScreen> createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends ConsumerState<CreateCardScreen> {
  final _amount = TextEditingController();
  final _shipping = TextEditingController();
  final _condition = TextEditingController();
  final _itemNotes = TextEditingController();
  final _issueQuantity = TextEditingController();
  final _issuePrice = TextEditingController();
  final _cardType = TextEditingController();
  final _selectedTags = <String>{};
  final _selectedSets = <String>{};
  final _selectedAlbums = <String>{};
  DateTime? _acquiredAt;
  bool _needsCompletion = false;
  bool _copyLoaded = false;
  int _formRevision = 0;

  @override
  void initState() {
    super.initState();
    if (widget.copyFromCardItemId != null) {
      Future<void>.microtask(_loadCopy);
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _shipping.dispose();
    _condition.dispose();
    _itemNotes.dispose();
    _issueQuantity.dispose();
    _issuePrice.dispose();
    _cardType.dispose();
    super.dispose();
  }

  Future<void> _loadCopy() async {
    if (_copyLoaded) return;
    _copyLoaded = true;
    final sourceId = widget.copyFromCardItemId!;
    try {
      final card = await ref
          .read(cardRepositoryProvider)
          .watchCard(sourceId)
          .first;
      final organization = await ref
          .read(organizationRepositoryProvider)
          .watchCardOrganization(sourceId)
          .first;
      if (card == null || organization == null || !mounted) return;
      final memberships = await ref
          .read(cardSetRepositoryProvider)
          .watchMemberships(organization.definitionId)
          .first;
      ref
          .read(createCardControllerProvider.notifier)
          .prefill(
            name: card.name == untitledCardName ? null : '${card.name} 副本',
            city: card.city,
            issuer: card.issuer,
            issuedAt: card.issuedAt,
            code: card.code,
            notes: card.notes,
          );
      final metadata = ReservedCardMetadata.fromDetails(
        organization.fieldValues,
      );
      setState(() {
        _formRevision++;
        _cardType.text = organization.cardType ?? '';
        _acquiredAt = organization.acquiredAt;
        _needsCompletion = organization.needsCompletion;
        _selectedTags.addAll(organization.tags.map((value) => value.id));
        _selectedAlbums.addAll(organization.series.map((value) => value.id));
        _selectedSets.addAll(memberships.map((value) => value.setId));
        _condition.text = metadata.condition ?? '';
        _itemNotes.text = metadata.itemNotes ?? '';
        _issueQuantity.text = metadata.issueQuantity?.toString() ?? '';
        _issuePrice.text = metadata.issuePrice?.toString() ?? '';
      });
    } catch (_) {
      _showMessage('复制资料加载失败，你仍可手动新建卡片。');
    }
  }

  void _applyAutofill(CardAutofillSuggestion suggestion) {
    ref
        .read(createCardControllerProvider.notifier)
        .prefill(
          name: suggestion.name,
          city: suggestion.city,
          issuer: suggestion.issuer,
          issuedAt: PartialDate.tryParse(suggestion.issuedAt),
          code: suggestion.code,
        );
    setState(() {
      _formRevision++;
      if (suggestion.cardType != null) {
        _cardType.text = suggestion.cardType!;
      }
      if (suggestion.issueQuantity != null) {
        _issueQuantity.text = suggestion.issueQuantity.toString();
      }
      if (suggestion.issuePrice != null) {
        _issuePrice.text = suggestion.issuePrice!;
      }
    });
  }

  Future<void> _save() async {
    final int amountMinor;
    final int shippingMinor;
    final ReservedMetadataInput metadataInput;
    try {
      amountMinor = parseOptionalCnyMinor(_amount.text);
      shippingMinor = parseOptionalCnyMinor(_shipping.text);
      metadataInput = parseReservedMetadataInput(
        condition: _condition,
        itemNotes: _itemNotes,
        issueQuantity: _issueQuantity,
        issuePrice: _issuePrice,
      );
    } on AppFailure catch (failure) {
      _showMessage(failure.userMessage);
      return;
    } on FormatException catch (failure) {
      _showMessage(failure.message);
      return;
    }

    final id = await ref.read(createCardControllerProvider.notifier).save();
    if (!mounted || id == null) return;
    final draft = ref.read(createCardControllerProvider);
    try {
      final fieldValues = await mergeReservedCardMetadata(
        repository: ref.read(organizationRepositoryProvider),
        idGenerator: ref.read(idGeneratorProvider),
        definitions:
            ref.read(organizationFieldDefinitionsProvider).value ??
            const <CustomFieldDefinition>[],
        existingValues: const <CustomFieldValueInput>[],
        metadata: ReservedCardMetadata(
          condition: metadataInput.condition,
          itemNotes: metadataInput.itemNotes,
          issueQuantity: metadataInput.issueQuantity,
          issuePrice: metadataInput.issuePrice,
        ),
      );
      await ref
          .read(organizationRepositoryProvider)
          .saveCardOrganization(
            SaveCardOrganizationRequest(
              cardItemId: id,
              cardType: _cardType.text,
              acquiredAt: _acquiredAt,
              needsCompletion: _needsCompletion,
              tagIds: _selectedTags.toList(growable: false),
              seriesIds: _selectedAlbums.toList(growable: false),
              fieldValues: fieldValues,
            ),
          );
      await saveCardSetSelections(
        ref: ref,
        definitionId: draft.ids!.definitionId,
        selectedSetIds: _selectedSets,
      );
      await ref
          .read(purchaseRepositoryProvider)
          .saveCardEntryCost(
            SaveCardEntryCostRequest(
              cardItemId: id,
              amountMinor: amountMinor,
              shippingMinor: shippingMinor,
            ),
          );
    } on AppFailure catch (failure) {
      _showMessage(failure.userMessage);
      return;
    } catch (_) {
      _showMessage('卡片已创建，整理信息暂未保存，请重试。');
      return;
    }
    if (mounted) context.pushReplacement(cardDetailPath(id));
  }

  Future<void> _createTag() async {
    try {
      final id = await createTagInline(context, ref);
      if (id != null && mounted) {
        setState(() => _selectedTags.add(id));
      }
    } on AppFailure catch (failure) {
      _showMessage(failure.userMessage);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _close() {
    ref.read(createCardControllerProvider.notifier).reset();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(libraryPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createCardControllerProvider);
    final tokens = context.tokens;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(createCardControllerProvider.notifier).reset();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: state.isSaving ? null : _close,
            tooltip: '取消新建',
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('新建卡片'),
          actions: <Widget>[
            TextButton(
              onPressed: state.isSaving ? null : _save,
              child: const Text('保存'),
            ),
            SizedBox(width: tokens.spaceSm),
          ],
          bottom: state.isSaving
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(2),
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    semanticsLabel: '正在保存',
                  ),
                )
              : null,
        ),
        body: _CreateCardForm(
          key: ValueKey<int>(_formRevision),
          state: state,
          amountController: _amount,
          shippingController: _shipping,
          selectedTags: _selectedTags,
          selectedSets: _selectedSets,
          selectedAlbums: _selectedAlbums,
          conditionController: _condition,
          issueQuantityController: _issueQuantity,
          issuePriceController: _issuePrice,
          cardTypeController: _cardType,
          acquiredAt: _acquiredAt,
          needsCompletion: _needsCompletion,
          onAcquiredAtChanged: (value) => setState(() => _acquiredAt = value),
          onNeedsCompletionChanged: (value) =>
              setState(() => _needsCompletion = value),
          onAutofill: _applyAutofill,
          onCreateTag: _createTag,
          onSelectionChanged: setState,
          onSave: _save,
        ),
      ),
    );
  }
}

class _CreateCardForm extends ConsumerWidget {
  const _CreateCardForm({
    required this.state,
    required this.amountController,
    required this.shippingController,
    required this.selectedTags,
    required this.selectedSets,
    required this.selectedAlbums,
    required this.conditionController,
    required this.issueQuantityController,
    required this.issuePriceController,
    required this.cardTypeController,
    required this.acquiredAt,
    required this.needsCompletion,
    required this.onAcquiredAtChanged,
    required this.onNeedsCompletionChanged,
    required this.onAutofill,
    super.key,
    required this.onCreateTag,
    required this.onSelectionChanged,
    required this.onSave,
  });

  final CreateCardState state;
  final TextEditingController amountController;
  final TextEditingController shippingController;
  final Set<String> selectedTags;
  final Set<String> selectedSets;
  final Set<String> selectedAlbums;
  final TextEditingController conditionController;
  final TextEditingController issueQuantityController;
  final TextEditingController issuePriceController;
  final TextEditingController cardTypeController;
  final DateTime? acquiredAt;
  final bool needsCompletion;
  final ValueChanged<DateTime?> onAcquiredAtChanged;
  final ValueChanged<bool> onNeedsCompletionChanged;
  final ValueChanged<CardAutofillSuggestion> onAutofill;
  final VoidCallback onCreateTag;
  final void Function(VoidCallback callback) onSelectionChanged;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final controller = ref.read(createCardControllerProvider.notifier);
    final tags =
        ref.watch(organizationTagsProvider).value ?? const <TagSummary>[];
    final cardSets =
        ref.watch(cardSetListProvider).value ?? const <CardSetSummary>[];
    final albums =
        ref.watch(organizationSeriesProvider).value ?? const <SeriesSummary>[];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        tokens.spaceLg,
        tokens.spaceMd,
        tokens.spaceLg,
        tokens.spaceXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _DraftImagesEditor(state: state),
          if (state.images.isNotEmpty) ...<Widget>[
            SizedBox(height: tokens.spaceSm),
            CardAutofillButton(
              imagePath: state.images.first.displayPath,
              onApply: onAutofill,
            ),
          ],
          SizedBox(height: tokens.spaceLg),
          Text('基本信息', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: tokens.spaceMd),
          _CardTextField(
            key: const Key('card-name-field'),
            label: '名称 *',
            initialValue: state.name,
            errorText: state.fieldErrors[CardField.name],
            onChanged: controller.updateName,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: tokens.spaceMd),
          CardLocationField(
            label: '城市 *',
            value: state.city,
            errorText: state.fieldErrors[CardField.city],
            enabled: !state.isSaving,
            onChanged: controller.updateCity,
          ),
          SizedBox(height: tokens.spaceMd),
          _CardTextField(
            label: '发行机构',
            initialValue: state.issuer,
            errorText: state.fieldErrors[CardField.issuer],
            onChanged: controller.updateIssuer,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: tokens.spaceMd),
          OptionalDateField(
            label: '发行日期',
            value: _dateFromPartialText(state.issuedAtText),
            errorText: state.fieldErrors[CardField.issuedAt],
            enabled: !state.isSaving,
            onChanged: (date) => controller.updateIssuedAt(
              date == null ? '' : formatOptionalDate(date),
            ),
          ),
          SizedBox(height: tokens.spaceMd),
          _CardTextField(
            label: '编号',
            initialValue: state.code,
            errorText: state.fieldErrors[CardField.code],
            onChanged: controller.updateCode,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: tokens.spaceMd),
          _CardTextField(
            label: '备注',
            initialValue: state.notes,
            errorText: state.fieldErrors[CardField.notes],
            onChanged: controller.updateNotes,
            minLines: 3,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
          ),
          SizedBox(height: tokens.spaceLg),
          Text('藏品与发行信息', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: tokens.spaceMd),
          ReservedCardMetadataFields(
            issueQuantityController: issueQuantityController,
            issuePriceController: issuePriceController,
            enabled: !state.isSaving,
          ),
          SizedBox(height: tokens.spaceLg),
          Text('整理归属', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: tokens.spaceMd),
          TextField(
            controller: cardTypeController,
            enabled: !state.isSaving,
            decoration: const InputDecoration(labelText: '卡片类型'),
          ),
          SizedBox(height: tokens.spaceMd),
          OptionalDateField(
            label: '入手日期',
            value: acquiredAt,
            enabled: !state.isSaving,
            onChanged: onAcquiredAtChanged,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('标记为待补全'),
            value: needsCompletion,
            onChanged: state.isSaving ? null : onNeedsCompletionChanged,
          ),
          CardEntryMetadataFields(
            tags: tags,
            cardSets: cardSets,
            albums: albums,
            selectedTagIds: selectedTags,
            selectedSetIds: selectedSets,
            selectedAlbumIds: selectedAlbums,
            enabled: !state.isSaving,
            onCreateTag: onCreateTag,
            onTagSelected: (id, selected) => onSelectionChanged(
              () => selected ? selectedTags.add(id) : selectedTags.remove(id),
            ),
            onSetSelected: (id, selected) => onSelectionChanged(
              () => selected ? selectedSets.add(id) : selectedSets.remove(id),
            ),
            onAlbumSelected: (id, selected) => onSelectionChanged(
              () =>
                  selected ? selectedAlbums.add(id) : selectedAlbums.remove(id),
            ),
          ),
          SizedBox(height: tokens.spaceLg),
          Text('入手成本', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: tokens.spaceMd),
          CardConditionField(
            controller: conditionController,
            enabled: !state.isSaving,
          ),
          SizedBox(height: tokens.spaceSm),
          Text(
            '只记录人民币；两项都留空时不计入累计花费。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: tokens.spaceMd),
          CardEntryCostFields(
            amountController: amountController,
            shippingController: shippingController,
            enabled: !state.isSaving,
          ),
          if (state.failure case final failure?) ...<Widget>[
            SizedBox(height: tokens.spaceMd),
            _SaveFailure(failure: failure),
          ],
          SizedBox(height: tokens.spaceLg),
          FilledButton(
            onPressed: state.isSaving ? null : onSave,
            child: Text(state.isSaving ? '正在保存…' : '保存卡片'),
          ),
        ],
      ),
    );
  }
}

class _DraftImagesEditor extends ConsumerWidget {
  const _DraftImagesEditor({required this.state});

  final CreateCardState state;

  Future<void> _addImages(BuildContext context, WidgetRef ref) async {
    final source = await showModalBottomSheet<_DraftImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('拍摄'),
              subtitle: const Text('拍摄后直接添加，可稍后编辑'),
              onTap: () => context.pop(_DraftImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('从相册选择'),
              onTap: () => context.pop(_DraftImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;

    final controller = ref.read(createCardControllerProvider.notifier);
    if (source == _DraftImageSource.gallery) {
      if (state.images.isEmpty) {
        await controller.pickImage();
      } else {
        await controller.addImages();
      }
      return;
    }

    final captured = await controller.captureImage(append: state.hasImage);
    if (!captured || !context.mounted) return;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final controller = ref.read(createCardControllerProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '正反面与其他图片（${state.images.length} 张）',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton.icon(
              onPressed:
                  state.isSaving ||
                      state.images.length >= CreateCardRequest.maxImages
                  ? null
                  : () => _addImages(context, ref),
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('添加图片'),
            ),
          ],
        ),
        SizedBox(height: tokens.spaceSm),
        if (state.images.isEmpty)
          OutlinedButton.icon(
            onPressed: state.isSaving ? null : () => _addImages(context, ref),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('添加正面或背面'),
          )
        else
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.images.length,
              separatorBuilder: (context, index) =>
                  SizedBox(width: tokens.spaceMd),
              itemBuilder: (context, index) {
                final image = state.images[index];
                return Semantics(
                  label:
                      '第 ${index + 1} 张，${image.kind.label}'
                      '${index == 0 ? '，封面' : ''}',
                  child: SizedBox(
                    width: 248,
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: EdgeInsets.all(tokens.spaceSm),
                        child: Column(
                          children: <Widget>[
                            AspectRatio(
                              aspectRatio: 85.60 / 53.98,
                              child: Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                  CardImage.local(
                                    path: image.displayPath,
                                    semanticLabel: '待保存卡片第 ${index + 1} 张',
                                    borderRadius: BorderRadius.circular(
                                      tokens.radiusMd,
                                    ),
                                  ),
                                  if (index == 0)
                                    Positioned(
                                      top: tokens.spaceSm,
                                      left: tokens.spaceSm,
                                      child: const Chip(
                                        avatar: Icon(Icons.star, size: 16),
                                        label: Text('封面'),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: tokens.spaceSm),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<CardImageKind>(
                                      value: image.kind,
                                      isExpanded: true,
                                      onChanged: state.isSaving
                                          ? null
                                          : (kind) {
                                              if (kind != null) {
                                                controller.updateImageKind(
                                                  image.id,
                                                  kind,
                                                );
                                              }
                                            },
                                      items: <DropdownMenuItem<CardImageKind>>[
                                        for (final kind in CardImageKind.values)
                                          DropdownMenuItem<CardImageKind>(
                                            value: kind,
                                            child: Text(kind.label),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: state.isSaving
                                      ? null
                                      : () async {
                                          final result = await context
                                              .push<ProcessedImage>(
                                                imageEditorPath,
                                                extra: ImageEditorRouteArgs(
                                                  sourcePath:
                                                      image.selection.path,
                                                  outputId: image.id,
                                                ),
                                              );
                                          if (result != null) {
                                            controller.applyProcessedImage(
                                              image.id,
                                              result.path,
                                            );
                                          }
                                        },
                                  tooltip: '编辑图片',
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  onPressed: state.isSaving || index == 0
                                      ? null
                                      : () =>
                                            controller.moveImage(image.id, -1),
                                  tooltip: '前移',
                                  icon: const Icon(Icons.arrow_back),
                                ),
                                IconButton(
                                  onPressed:
                                      state.isSaving ||
                                          index == state.images.length - 1
                                      ? null
                                      : () => controller.moveImage(image.id, 1),
                                  tooltip: '后移',
                                  icon: const Icon(Icons.arrow_forward),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

enum _DraftImageSource { camera, gallery }

class _CardTextField extends StatelessWidget {
  const _CardTextField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.errorText,
    this.textInputAction,
    this.minLines,
    this.maxLines = 1,
    super.key,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final TextInputAction? textInputAction;
  final int? minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      enabled: true,
      textInputAction: textInputAction,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, errorText: errorText),
    );
  }
}

class _SaveFailure extends StatelessWidget {
  const _SaveFailure({required this.failure});

  final AppFailure failure;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: EdgeInsets.all(context.tokens.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(context.tokens.radiusMd),
        ),
        child: Text(
          failure.userMessage,
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }
}

DateTime? _dateFromPartialText(String text) {
  final value = PartialDate.tryParse(text);
  if (value == null) return null;
  return DateTime(value.year, value.month ?? 1, value.day ?? 1);
}
