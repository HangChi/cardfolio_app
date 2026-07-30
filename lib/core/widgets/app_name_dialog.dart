import 'package:flutter/material.dart';

Future<String?> showAppNameDialog(
  BuildContext context, {
  required String title,
  String? initialValue,
  String actionLabel = '创建',
  String fieldLabel = '名称',
  int maxLength = 100,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _AppNameDialog(
      title: title,
      initialValue: initialValue,
      actionLabel: actionLabel,
      fieldLabel: fieldLabel,
      maxLength: maxLength,
    ),
  );
}

class _AppNameDialog extends StatefulWidget {
  const _AppNameDialog({
    required this.title,
    required this.actionLabel,
    required this.fieldLabel,
    required this.maxLength,
    this.initialValue,
  });

  final String title;
  final String? initialValue;
  final String actionLabel;
  final String fieldLabel;
  final int maxLength;

  @override
  State<_AppNameDialog> createState() => _AppNameDialogState();
}

class _AppNameDialogState extends State<_AppNameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        key: const Key('app-name-input'),
        controller: _controller,
        autofocus: true,
        maxLength: widget.maxLength,
        decoration: InputDecoration(labelText: widget.fieldLabel),
        onSubmitted: (_) => _submit(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.actionLabel)),
      ],
    );
  }
}
