import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/card_autofill_providers.dart';
import '../../domain/card_autofill.dart';

class CardAutofillButton extends ConsumerStatefulWidget {
  const CardAutofillButton({
    required this.imagePath,
    required this.onApply,
    super.key,
  });

  final String imagePath;
  final ValueChanged<CardAutofillSuggestion> onApply;

  @override
  ConsumerState<CardAutofillButton> createState() => _CardAutofillButtonState();
}

class _CardAutofillButtonState extends ConsumerState<CardAutofillButton> {
  bool _working = false;

  Future<void> _recognize() async {
    if (_working) return;
    setState(() => _working = true);
    try {
      final recognized = await ref
          .read(cardTextRecognizerProvider)
          .recognize(widget.imagePath);
      if (recognized.rawText.trim().isEmpty) {
        _message('没有识别到清晰文字，请换一张卡面照片重试。');
        return;
      }
      final catalog = ref.read(transportCardCatalogProvider);
      final matches = await catalog.search(recognized.rawText);
      if (!mounted) return;
      final suggestion = await showModalBottomSheet<CardAutofillSuggestion>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) =>
            _AutofillReviewSheet(recognized: recognized, matches: matches),
      );
      if (suggestion == null || !mounted) return;
      widget.onApply(suggestion);
      _message('已填入你确认的识别资料，请核对后保存。');
    } on MissingPluginException {
      _message('当前平台暂不支持卡面文字识别。');
    } on PlatformException catch (error) {
      _message(switch (error.code) {
        'invalid_path' => '图片已经不可用，请重新拍摄或选择后再识别。',
        'invalid_image' => '无法读取这张图片，请换一张清晰的卡面照片。',
        'recognition_failed' => '文字识别服务暂时不可用，请稍后重试。',
        _ => '文字识别失败，请换一张图片重试。',
      });
    } catch (_) {
      _message('文字识别失败，请换一张图片重试。');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _working ? null : _recognize,
      icon: _working
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.document_scanner_outlined),
      label: Text(_working ? '正在识别…' : '识别卡面文字'),
    );
  }
}

class _AutofillReviewSheet extends StatefulWidget {
  const _AutofillReviewSheet({required this.recognized, required this.matches});

  final RecognizedCardText recognized;
  final List<TransportCardCatalogMatch> matches;

  @override
  State<_AutofillReviewSheet> createState() => _AutofillReviewSheetState();
}

class _AutofillReviewSheetState extends State<_AutofillReviewSheet> {
  late final TextEditingController _name;
  late final TextEditingController _city;
  late final TextEditingController _issuer;
  late final TextEditingController _code;
  late final TextEditingController _year;
  String? _cardType;
  int? _issueQuantity;
  String? _issuePrice;
  bool _useName = true;
  bool _useCity = true;
  bool _useIssuer = true;
  bool _useCode = true;
  bool _useYear = true;

  @override
  void initState() {
    super.initState();
    TransportCardCatalogMatch? best;
    for (final match in widget.matches) {
      if (match.confidence >= 0.75) {
        best = match;
        break;
      }
    }
    _name = TextEditingController(
      text: best?.name ?? widget.recognized.name ?? '',
    );
    _city = TextEditingController(
      text: best?.city ?? widget.recognized.city ?? '',
    );
    _issuer = TextEditingController(
      text: best?.issuer ?? widget.recognized.issuer ?? '',
    );
    _code = TextEditingController(
      text: best?.code ?? widget.recognized.code ?? '',
    );
    _year = TextEditingController(
      text: best?.issuedAt ?? widget.recognized.issuedAt ?? '',
    );
    _cardType = best?.cardType;
    _issueQuantity = best?.issueQuantity;
    _issuePrice = best?.issuePrice;
    _useName = _name.text.isNotEmpty;
    _useCity = _city.text.isNotEmpty;
    _useIssuer = _issuer.text.isNotEmpty;
    _useCode = _code.text.isNotEmpty;
    _useYear = _year.text.isNotEmpty;
  }

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _issuer.dispose();
    _code.dispose();
    _year.dispose();
    super.dispose();
  }

  void _selectMatch(TransportCardCatalogMatch match) {
    setState(() {
      _name.text = match.name;
      if (match.city != null) _city.text = match.city!;
      if (match.issuer != null) _issuer.text = match.issuer!;
      if (match.code != null) _code.text = match.code!;
      if (match.issuedAt != null) _year.text = match.issuedAt!;
      _cardType = match.cardType;
      _issueQuantity = match.issueQuantity;
      _issuePrice = match.issuePrice;
      _useName = true;
      _useCity = _city.text.isNotEmpty;
      _useIssuer = _issuer.text.isNotEmpty;
    });
  }

  String? _selected(bool selected, TextEditingController controller) {
    final value = controller.text.trim();
    return selected && value.isNotEmpty ? value : null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('确认识别结果', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              const Text('只会填入已勾选的项目，不会自动覆盖其他资料。'),
              if (widget.matches.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                Text('可能的卡片', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final match in widget.matches.take(5))
                      ActionChip(
                        label: Text(
                          '${match.name} ${(match.confidence * 100).round()}%',
                        ),
                        onPressed: () => _selectMatch(match),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              _ReviewField(
                label: '名称',
                controller: _name,
                selected: _useName,
                onSelected: (v) => setState(() => _useName = v),
              ),
              _ReviewField(
                label: '城市',
                controller: _city,
                selected: _useCity,
                onSelected: (v) => setState(() => _useCity = v),
              ),
              _ReviewField(
                label: '发行机构',
                controller: _issuer,
                selected: _useIssuer,
                onSelected: (v) => setState(() => _useIssuer = v),
              ),
              _ReviewField(
                label: '编号',
                controller: _code,
                selected: _useCode,
                onSelected: (v) => setState(() => _useCode = v),
              ),
              _ReviewField(
                label: '发行年份',
                controller: _year,
                selected: _useYear,
                onSelected: (v) => setState(() => _useYear = v),
              ),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('查看识别到的原始文字'),
                children: <Widget>[
                  SelectableText(widget.recognized.lines.join('\n')),
                  const SizedBox(height: 12),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.pop(
                  context,
                  CardAutofillSuggestion(
                    name: _selected(_useName, _name),
                    city: _selected(_useCity, _city),
                    issuer: _selected(_useIssuer, _issuer),
                    code: _selected(_useCode, _code),
                    issuedAt: _selected(_useYear, _year),
                    cardType: _cardType,
                    issueQuantity: _issueQuantity,
                    issuePrice: _issuePrice,
                  ),
                ),
                child: const Text('填入已选资料'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewField extends StatelessWidget {
  const _ReviewField({
    required this.label,
    required this.controller,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final TextEditingController controller;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: selected,
            onChanged: (value) => onSelected(value ?? false),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(labelText: label),
            ),
          ),
        ],
      ),
    );
  }
}
