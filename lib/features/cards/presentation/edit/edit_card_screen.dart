import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../organization/data/organization_providers.dart';
import '../../../organization/domain/organization_models.dart';
import '../../data/card_providers.dart';
import '../../domain/card_models.dart';
import '../widgets/optional_date_field.dart';

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
  final _selectedTags = <String>{};
  final _selectedAlbums = <String>{};

  PartialDate? _issuedAt;
  DateTime? _acquiredAt;
  List<CustomFieldValueInput> _fieldValues = const <CustomFieldValueInput>[];
  bool _needsCompletion = false;
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _issuer.dispose();
    _code.dispose();
    _notes.dispose();
    _quantity.dispose();
    _cardType.dispose();
    super.dispose();
  }

  void _initialize(CardDetail card, CardOrganizationDetail organization) {
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
    _selectedTags.addAll(organization.tags.map((tag) => tag.id));
    _selectedAlbums.addAll(organization.series.map((album) => album.id));
    _fieldValues = organization.fieldValues
        .map((field) => field.value)
        .toList(growable: false);
  }

  Future<void> _save() async {
    if (_saving) return;
    final quantityText = _quantity.text.trim();
    final quantity = quantityText.isEmpty ? 1 : int.tryParse(quantityText);
    if (quantity == null || quantity <= 0) {
      _showMessage('数量请输入大于 0 的整数，或留空使用 1。');
      return;
    }

    setState(() => _saving = true);
    try {
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
              fieldValues: _fieldValues,
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

  @override
  Widget build(BuildContext context) {
    final card = ref.watch(cardDetailProvider(widget.cardItemId));
    final organization = ref.watch(cardOrganizationProvider(widget.cardItemId));
    final tags = ref.watch(organizationTagsProvider);
    final albums = ref.watch(organizationSeriesProvider);

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
            _initialize(cardValue, organizationValue);
            return _form(
              tags.value ?? const <TagSummary>[],
              albums.value ?? const <SeriesSummary>[],
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
      },
      child: const Text('重新加载'),
    ),
  );

  Widget _form(List<TagSummary> tags, List<SeriesSummary> albums) {
    final tokens = context.tokens;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        tokens.spaceLg,
        tokens.spaceMd,
        tokens.spaceLg,
        tokens.spaceXl,
      ),
      children: <Widget>[
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
        _chips(
          title: '卡片标签（可选）',
          emptyText: '暂无标签，可在整理设置中创建。',
          values: tags,
          selected: _selectedTags,
        ),
        SizedBox(height: tokens.spaceMd),
        _chips(
          title: '加入集卡册（可选）',
          emptyText: '暂无集卡册，可在集卡册页创建。',
          values: albums,
          selected: _selectedAlbums,
        ),
        SizedBox(height: tokens.spaceXl),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? '正在保存…' : '保存修改'),
        ),
      ],
    );
  }

  Widget _chips<T>({
    required String title,
    required String emptyText,
    required List<T> values,
    required Set<String> selected,
  }) {
    String idOf(T value) => switch (value) {
      TagSummary(:final id) => id,
      SeriesSummary(:final id) => id,
      _ => '',
    };
    String nameOf(T value) => switch (value) {
      TagSummary(:final name) => name,
      SeriesSummary(:final name) => name,
      _ => '',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (values.isEmpty)
          Text(emptyText, style: Theme.of(context).textTheme.bodySmall)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final value in values)
                FilterChip(
                  label: Text(nameOf(value)),
                  selected: selected.contains(idOf(value)),
                  onSelected: _saving
                      ? null
                      : (checked) => setState(() {
                          checked
                              ? selected.add(idOf(value))
                              : selected.remove(idOf(value));
                        }),
                ),
            ],
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
