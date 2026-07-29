import 'package:flutter/material.dart';

/// 可清空的日期选择字段。空值代表用户暂不填写。
class OptionalDateField extends StatelessWidget {
  const OptionalDateField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
    super.key,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final valueText = value == null ? '未填写' : formatOptionalDate(value!);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: enabled ? () => _pick(context) : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (value != null)
                IconButton(
                  tooltip: '清空日期',
                  onPressed: enabled ? () => onChanged(null) : null,
                  icon: const Icon(Icons.clear),
                ),
              const Icon(Icons.calendar_month_outlined),
              const SizedBox(width: 12),
            ],
          ),
        ),
        child: Text(
          valueText,
          style: value == null
              ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )
              : null,
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final selected = await showDatePicker(
      context: context,
      initialDate: value ?? today,
      firstDate: DateTime(1900),
      lastDate: DateTime(today.year + 100),
      helpText: label,
      cancelText: '取消',
      confirmText: '确定',
    );
    if (selected != null) onChanged(DateUtils.dateOnly(selected));
  }
}

String formatOptionalDate(DateTime value) {
  final date = DateUtils.dateOnly(value);
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
