import 'package:flutter/material.dart';

final class CardConditionField extends StatefulWidget {
  const CardConditionField({
    required this.controller,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;
  final bool enabled;

  @override
  State<CardConditionField> createState() => _CardConditionFieldState();
}

class _CardConditionFieldState extends State<CardConditionField> {
  static const options = <String>[
    '未填写',
    '全新',
    '近全新',
    '轻微使用痕迹',
    '明显使用痕迹',
    '重度使用 / 破损',
    '其他',
  ];

  late String _selection;

  @override
  void initState() {
    super.initState();
    _sync();
    widget.controller.addListener(_controllerChanged);
  }

  @override
  void didUpdateWidget(covariant CardConditionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_controllerChanged);
      widget.controller.addListener(_controllerChanged);
      _sync();
    }
  }

  void _controllerChanged() {
    if (_selection == '其他' && !options.contains(widget.controller.text)) {
      return;
    }
    final previous = _selection;
    _sync();
    if (previous != _selection && mounted) setState(() {});
  }

  void _sync() {
    final value = widget.controller.text;
    _selection = value.isEmpty
        ? '未填写'
        : (options.contains(value) ? value : '其他');
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DropdownButtonFormField<String>(
          key: ValueKey<String>(_selection),
          initialValue: _selection,
          isExpanded: true,
          decoration: const InputDecoration(labelText: '品相'),
          items: <DropdownMenuItem<String>>[
            for (final option in options)
              DropdownMenuItem(
                value: option,
                child: Text(
                  option,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: widget.enabled
              ? (value) => setState(() {
                  _selection = value ?? '未填写';
                  if (_selection == '未填写') {
                    widget.controller.clear();
                  } else if (_selection != '其他') {
                    widget.controller.text = _selection;
                  } else if (options.contains(widget.controller.text)) {
                    widget.controller.clear();
                  }
                })
              : null,
        ),
        if (_selection == '其他') ...<Widget>[
          const SizedBox(height: 12),
          TextField(
            controller: widget.controller,
            enabled: widget.enabled,
            decoration: const InputDecoration(
              labelText: '自定义品相',
              hintText: '请输入品相说明',
            ),
          ),
        ],
      ],
    );
  }
}
