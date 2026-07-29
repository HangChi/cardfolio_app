import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

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
      var matches = const <TransportCardCatalogMatch>[];
      if (catalog.isConfigured) {
        matches = await catalog.search(recognized.name ?? recognized.rawText);
      }
      if (!mounted) return;
      TransportCardCatalogMatch? selected;
      if (matches.isNotEmpty) {
        selected = await showModalBottomSheet<TransportCardCatalogMatch>(
          context: context,
          showDragHandle: true,
          builder: (context) => SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                const ListTile(
                  title: Text('选择公共资料库匹配项'),
                  subtitle: Text('不选择则只使用卡面文字识别结果。'),
                ),
                for (final match in matches)
                  ListTile(
                    title: Text(match.name),
                    subtitle: Text(
                      <String>[?match.city, ?match.issuer].join(' · '),
                    ),
                    trailing: Text('${(match.confidence * 100).round()}%'),
                    onTap: () => Navigator.pop(context, match),
                  ),
              ],
            ),
          ),
        );
      }
      widget.onApply(
        CardAutofillSuggestion.merge(recognized: recognized, catalog: selected),
      );
      _message(
        catalog.isConfigured ? '已填入识别资料，请核对后保存。' : '已填入 OCR 识别资料；公共资料库服务尚未配置。',
      );
    } on MissingPluginException {
      _message('当前平台暂不支持卡面文字识别。');
    } catch (_) {
      _message('识别或资料库查询失败，请稍后重试。');
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
      icon: const Icon(Icons.document_scanner_outlined),
      label: Text(_working ? '正在识别…' : '识别卡面并自动补全'),
    );
  }
}
