import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../card_sets/data/card_set_providers.dart';
import '../../../card_sets/domain/card_set_models.dart';
import '../../../organization/data/organization_providers.dart';
import '../../../organization/domain/organization_models.dart';
import '../../../purchases/data/purchase_providers.dart';
import '../../../purchases/domain/purchase_models.dart';
import '../../data/card_providers.dart';
import '../../domain/card_models.dart';
import '../../domain/card_autofill.dart';
import '../../domain/reserved_card_metadata.dart';
import '../widgets/card_entry_metadata_fields.dart';
import '../widgets/card_autofill_button.dart';
import '../widgets/optional_date_field.dart';
import '../widgets/reserved_card_metadata_fields.dart';

class EditCardScreen extends ConsumerStatefulWidget {
  const EditCardScreen({required this.cardItemId, super.key});

  final String cardItemId;

  @override
  ConsumerState<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends ConsumerState<EditCardScreen> {
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _issuer = TextEditingController();
  final _code = TextEditingController();
  final _notes = TextEditingController();
  final _quantity = TextEditingController();
  final _cardType = TextEditingController();
  final _amount = TextEditingController();
  final _shipping = TextEditingController();
  final _condition = TextEditingController();
  final _itemNotes = TextEditingController();
  final _issueQuantity = TextEditingController();
  final _issuePrice = TextEditingController();
  final _selectedTags = <String>{};
  final _selectedSets = <String>{};
  final _selectedAlbums = <String>{};

  PartialDate? _issuedAt;
  DateTime? _acquiredAt;
  List<CustomFieldValueInput> _fieldValues = const <CustomFieldValueInput>[];
  bool _needsCompletion = false;
  bool _initialized = false;
  bool _saving = false;
  String? _definitionId;

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _issuer.dispose();
    _code.dispose();
    _notes.dispose();
    _quantity.dispose();
    _cardType.dispose();
    _amount.dispose();
    _shipping.dispose();
    _condition.dispose();
    _itemNotes.dispose();
    _issueQuantity.dispose();
    _issuePrice.dispose();
    super.dispose();
  }

  void _initialize(
    CardDetail card,
    CardOrganizationDetail organization,
    CardEntryCost cost,
    List<CardSetMembership> memberships,
  ) {
    if (_initialized) return;
    _initialized = true;
    _name.text = card.name == untitledCardName ? '' : card.name;
    _city.text = card.city ?? '';
    _issuer.text = card.issuer ?? '';
    _code.text = card.code ?? '';
    _notes.text = card.notes ?? '';
    _quantity.text = card.quantity == 1 ? '' : card.quantity.toString();
    _cardType.text = organization.cardType ?? '';
    _issuedAt = card.issuedAt;
    _acquiredAt = organization.acquiredAt;
    _needsCompletion = organization.needsCompletion;
    _definitionId = organization.definitionId;
    _selectedTags.addAll(organization.tags.map((tag) => tag.id));
    _selectedSets.addAll(memberships.map((membership) => membership.setId));
    _selectedAlbums.addAll(organization.series.map((album) => album.id));
    _amount.text = formatCnyInput(cost.amountMinor);
    _shipping.text = formatCnyInput(cost.shippingMinor);
    _fieldValues = organization.fieldValues
        .map((field) => field.value)
        .toList(growable: false);
    final metadata = ReservedCardMetadata.fromDetails(organization.fieldValues);
    _condition.text = metadata.condition ?? '';
    _itemNotes.text = metadata.itemNotes ?? '';
    _issueQuantity.text = metadata.issueQuantity?.toString() ?? '';
    _issuePrice.text = metadata.issuePrice?.toString() ?? '';
  }

  Future<void> _save() async {
    if (_saving) return;
    final quantityText = _quantity.text.trim();
    final quantity = quantityText.isEmpty ? 1 : int.tryParse(quantityText);
    if (quantity == null || quantity <= 0) {
      _showMessage('数量请输入大于 0 的整数，或留空使用 1。');
      return;
    }
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

    setState(() => _saving = true);
    try {
      final fieldValues = await mergeReservedCardMetadata(
        repository: ref.read(organizationRepositoryProvider),
        idGenerator: ref.read(idGeneratorProvider),
        definitions:
            ref.read(organizationFieldDefinitionsProvider).value ??
            const <CustomFieldDefinition>[],
        existingValues: _fieldValues,
        metadata: ReservedCardMetadata(
          condition: metadataInput.condition,
          itemNotes: metadataInput.itemNotes,
          issueQuantity: metadataInput.issueQuantity,
          issuePrice: metadataInput.issuePrice,
        ),
      );
      await ref
          .read(cardRepositoryProvider)
          .updateCard(
            UpdateCardRequest(
              cardItemId: widget.cardItemId,
              name: _name.text,
              city: _city.text,
              issuer: _issuer.text,
              issuedAt: _issuedAt,
              code: _code.text,
              notes: _notes.text,
              quantity: quantity,
            ),
          );
      await ref
          .read(organizationRepositoryProvider)
          .saveCardOrganization(
            SaveCardOrganizationRequest(
              cardItemId: widget.cardItemId,
              cardType: _cardType.text,
              needsCompletion: _needsCompletion,
              acquiredAt: _acquiredAt,
              tagIds: _selectedTags.toList(growable: false),
              seriesIds: _selectedAlbums.toList(growable: false),
              fieldValues: fieldValues,
            ),
          );
      final definitionId = _definitionId;
      if (definitionId == null) {
        throw StateError('卡片整理信息尚未加载完成');
      }
      await saveCardSetSelections(
        ref: ref,
        definitionId: definitionId,
        selectedSetIds: _selectedSets,
      );
      await ref
          .read(purchaseRepositoryProvider)
          .saveCardEntryCost(
            SaveCardEntryCostRequest(
              cardItemId: widget.cardItemId,
              amountMinor: amountMinor,
              shippingMinor: shippingMinor,
            ),
          );
      if (mounted) context.pop(true);
    } on AppFailure catch (failure) {
      _showMessage(failure.userMessage);
    } catch (_) {
      _showMessage('保存失败，请重试。');
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

  void _applyAutofill(CardAutofillSuggestion suggestion) {
    setState(() {
      if (suggestion.name != null) _name.text = suggestion.name!;
      if (suggestion.city != null) _city.text = suggestion.city!;
      if (suggestion.issuer != null) _issuer.text = suggestion.issuer!;
      if (suggestion.code != null) _code.text = suggestion.code!;
      if (suggestion.issuedAt != null) {
        _issuedAt = PartialDate.tryParse(suggestion.issuedAt);
      }
      if (suggestion.cardType != null) _cardType.text = suggestion.cardType!;
      if (suggestion.issueQuantity != null) {
        _issueQuantity.text = suggestion.issueQuantity.toString();
      }
      if (suggestion.issuePrice != null) {
        _issuePrice.text = suggestion.issuePrice!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = ref.watch(cardDetailProvider(widget.cardItemId));
    final organization = ref.watch(cardOrganizationProvider(widget.cardItemId));
    final tags = ref.watch(organizationTagsProvider);
    final albums = ref.watch(organizationSeriesProvider);
    final cardSets = ref.watch(cardSetListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑卡片'),
        actions: <Widget>[
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('保存'),
          ),
          SizedBox(width: context.tokens.spaceSm),
        ],
        bottom: _saving
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: card.when(
        loading: _loading,
        error: (error, stackTrace) => _loadFailure(),
        data: (cardValue) => organization.when(
          loading: _loading,
          error: (error, stackTrace) => _loadFailure(),
          data: (organizationValue) {
            if (cardValue == null || organizationValue == null) {
              return const Center(child: Text('卡片不存在或已被删除。'));
            }
            final cost = ref.watch(cardEntryCostProvider(widget.cardItemId));
            final memberships = ref.watch(
              cardSetMembershipsProvider(organizationValue.definitionId),
            );
            return cost.when(
              loading: _loading,
              error: (error, stackTrace) => _loadFailure(),
              data: (costValue) => memberships.when(
                loading: _loading,
                error: (error, stackTrace) => _loadFailure(),
                data: (membershipValues) {
                  _initialize(
                    cardValue,
                    organizationValue,
                    costValue,
                    membershipValues,
                  );
                  return _form(
                    cardValue,
                    tags.value ?? const <TagSummary>[],
                    cardSets.value ?? const <CardSetSummary>[],
                    albums.value ?? const <SeriesSummary>[],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _loading() => const Center(child: CircularProgressIndicator());

  Widget _loadFailure() => Center(
    child: FilledButton.tonal(
      onPressed: () {
        ref.invalidate(cardDetailProvider(widget.cardItemId));
        ref.invalidate(cardOrganizationProvider(widget.cardItemId));
        ref.invalidate(cardEntryCostProvider(widget.cardItemId));
      },
      child: const Text('重新加载'),
    ),
  );

  Widget _form(
    CardDetail card,
    List<TagSummary> tags,
    List<CardSetSummary> cardSets,
    List<SeriesSummary> albums,
  ) {
    final tokens = context.tokens;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        tokens.spaceLg,
        tokens.spaceMd,
        tokens.spaceLg,
        tokens.spaceXl,
      ),
      children: <Widget>[
        if (card.cover != null) ...<Widget>[
          CardAutofillButton(
            imagePath: ref
                .read(managedImageStoreProvider)
                .resolve(
                  card.cover!.derivedRelativePath ?? card.cover!.relativePath,
                )
                .path,
            onApply: _applyAutofill,
          ),
          SizedBox(height: tokens.spaceLg),
        ],
        _sectionTitle('基础资料'),
        _textField(_name, '名称（可选）'),
        _gap(),
        _textField(_city, '城市（可选）'),
        _gap(),
        _textField(_issuer, '发行机构（可选）'),
        _gap(),
        OptionalDateField(
          label: '发行日期（可选）',
          value: _partialDateValue(_issuedAt),
          enabled: !_saving,
          onChanged: (value) => setState(
            () => _issuedAt = value == null
                ? null
                : PartialDate.tryParse(formatOptionalDate(value)),
          ),
        ),
        _gap(),
        _textField(_code, '编号（可选）'),
        _gap(),
        _textField(
          _quantity,
          '数量（可选，默认 1）',
          keyboardType: TextInputType.number,
        ),
        _gap(),
        _textField(_notes, '备注（可选）', minLines: 3, maxLines: 6),
        SizedBox(height: tokens.spaceLg),
        _sectionTitle('藏品与发行信息'),
        ReservedCardMetadataFields(
          conditionController: _condition,
          itemNotesController: _itemNotes,
          issueQuantityController: _issueQuantity,
          issuePriceController: _issuePrice,
          enabled: !_saving,
        ),
        SizedBox(height: tokens.spaceLg),
        _sectionTitle('整理信息'),
        _textField(_cardType, '卡片类型（可选）'),
        _gap(),
        OptionalDateField(
          label: '入手日期（可选）',
          value: _acquiredAt,
          enabled: !_saving,
          onChanged: (value) => setState(() => _acquiredAt = value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('标记为待补全'),
          value: _needsCompletion,
          onChanged: _saving
              ? null
              : (value) => setState(() => _needsCompletion = value),
        ),
        CardEntryMetadataFields(
          tags: tags,
          cardSets: cardSets,
          albums: albums,
          selectedTagIds: _selectedTags,
          selectedSetIds: _selectedSets,
          selectedAlbumIds: _selectedAlbums,
          enabled: !_saving,
          onCreateTag: _createTag,
          onTagSelected: (id, selected) => setState(
            () => selected ? _selectedTags.add(id) : _selectedTags.remove(id),
          ),
          onSetSelected: (id, selected) => setState(
            () => selected ? _selectedSets.add(id) : _selectedSets.remove(id),
          ),
          onAlbumSelected: (id, selected) => setState(
            () =>
                selected ? _selectedAlbums.add(id) : _selectedAlbums.remove(id),
          ),
        ),
        SizedBox(height: tokens.spaceLg),
        _sectionTitle('入手成本'),
        Text(
          '只记录人民币；两项都清空后不再计入累计花费。',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(height: tokens.spaceMd),
        CardEntryCostFields(
          amountController: _amount,
          shippingController: _shipping,
          enabled: !_saving,
        ),
        SizedBox(height: tokens.spaceXl),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? '正在保存…' : '保存修改'),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: EdgeInsets.only(bottom: context.tokens.spaceMd),
    child: Text(text, style: Theme.of(context).textTheme.titleLarge),
  );

  Widget _gap() => SizedBox(height: context.tokens.spaceMd);

  Widget _textField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: !_saving,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    );
  }
}

DateTime? _partialDateValue(PartialDate? value) {
  if (value == null) return null;
  return DateTime(value.year, value.month ?? 1, value.day ?? 1);
}
