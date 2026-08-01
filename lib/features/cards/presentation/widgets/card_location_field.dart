import 'package:flutter/material.dart';

import '../../data/china_regions.dart';

final class CardLocationField extends StatelessWidget {
  const CardLocationField({
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.label = '城市（可选）',
    this.errorText,
    super.key,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final String label;
  final String? errorText;

  Future<void> _open(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _LocationPickerSheet(initialValue: value),
    );
    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => _open(context) : null,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        isEmpty: value.trim().isEmpty,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          suffixIcon: const Icon(Icons.arrow_drop_down),
          enabled: enabled,
        ),
        child: Text(
          value.trim().isEmpty ? '请选择中国地区或手动填写国外城市' : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _LocationPickerSheet extends StatefulWidget {
  const _LocationPickerSheet({required this.initialValue});

  final String initialValue;

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  late bool _overseas;
  late final TextEditingController _manual;
  ChinaRegionNode? _province;
  ChinaRegionNode? _city;
  ChinaRegionNode? _district;

  @override
  void initState() {
    super.initState();
    final parts = widget.initialValue.split(' / ');
    _overseas = widget.initialValue.isNotEmpty && parts.length < 2;
    _manual = TextEditingController(text: _overseas ? widget.initialValue : '');
    if (!_overseas && parts.isNotEmpty) {
      _province = _first(ChinaRegions.provinces, parts[0]);
      if (_province != null && parts.length > 1) {
        _city = _first(_province!.children, parts[1]);
      }
      if (_city != null && parts.length > 2) {
        _district = _first(_city!.children, parts[2]);
      }
    }
  }

  ChinaRegionNode? _first(List<ChinaRegionNode> values, String name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }

  @override
  void dispose() {
    _manual.dispose();
    super.dispose();
  }

  void _finish() {
    if (_overseas) {
      Navigator.pop(context, _manual.text.trim());
      return;
    }
    if (_province == null || _city == null || _district == null) return;
    Navigator.pop(
      context,
      '${_province!.name} / ${_city!.name} / ${_district!.name}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('选择城市', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const <ButtonSegment<bool>>[
                ButtonSegment<bool>(
                  value: false,
                  label: Text('中国省市区'),
                  icon: Icon(Icons.location_city),
                ),
                ButtonSegment<bool>(
                  value: true,
                  label: Text('国外 / 其他'),
                  icon: Icon(Icons.public),
                ),
              ],
              selected: <bool>{_overseas},
              onSelectionChanged: (value) =>
                  setState(() => _overseas = value.first),
            ),
            const SizedBox(height: 16),
            if (_overseas)
              TextField(
                controller: _manual,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: '国家 / 城市',
                  hintText: '例如：日本 / 东京',
                ),
                onSubmitted: (_) => _finish(),
              )
            else ...<Widget>[
              DropdownButtonFormField<ChinaRegionNode>(
                initialValue: _province,
                decoration: const InputDecoration(labelText: '省 / 自治区 / 直辖市'),
                isExpanded: true,
                items: <DropdownMenuItem<ChinaRegionNode>>[
                  for (final value in ChinaRegions.provinces)
                    DropdownMenuItem(value: value, child: Text(value.name)),
                ],
                onChanged: (value) => setState(() {
                  _province = value;
                  _city = null;
                  _district = null;
                }),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ChinaRegionNode>(
                key: ValueKey<String?>('city-${_province?.code}'),
                initialValue: _city,
                decoration: const InputDecoration(labelText: '市 / 地区'),
                isExpanded: true,
                items: <DropdownMenuItem<ChinaRegionNode>>[
                  for (final value
                      in _province?.children ?? const <ChinaRegionNode>[])
                    DropdownMenuItem(value: value, child: Text(value.name)),
                ],
                onChanged: _province == null
                    ? null
                    : (value) => setState(() {
                        _city = value;
                        _district = null;
                      }),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ChinaRegionNode>(
                key: ValueKey<String?>('district-${_city?.code}'),
                initialValue: _district,
                decoration: const InputDecoration(labelText: '县 / 区'),
                isExpanded: true,
                items: <DropdownMenuItem<ChinaRegionNode>>[
                  for (final value
                      in _city?.children ?? const <ChinaRegionNode>[])
                    DropdownMenuItem(value: value, child: Text(value.name)),
                ],
                onChanged: _city == null
                    ? null
                    : (value) => setState(() => _district = value),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _overseas
                  ? _finish
                  : (_province != null && _city != null && _district != null
                        ? _finish
                        : null),
              child: const Text('确定'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ''),
              child: const Text('清空城市'),
            ),
          ],
        ),
      ),
    );
  }
}
