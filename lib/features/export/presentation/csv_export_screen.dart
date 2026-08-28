import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/csv_export_providers.dart';
import '../domain/csv_export.dart';

class CsvExportScreen extends ConsumerStatefulWidget {
  const CsvExportScreen({super.key});

  @override
  ConsumerState<CsvExportScreen> createState() => _CsvExportScreenState();
}

class _CsvExportScreenState extends ConsumerState<CsvExportScreen> {
  bool _exporting = false;

  Future<void> _export() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final rows = await ref.read(csvExportRepositoryProvider).loadRows();
      final now = DateTime.now();
      final suggested =
          'cardfolio-${now.year}${now.month.toString().padLeft(2, '0')}'
          '${now.day.toString().padLeft(2, '0')}.csv';
      final publisher = ref.read(csvFilePublisherProvider);
      final path = await publisher.choosePath(suggested);
      if (path == null) return;
      final published = await publisher.writeAndPublish(
        path,
        encodeCardCsv(rows),
      );
      if (mounted && published) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('已导出 ${rows.length} 张卡片。')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('CSV 导出失败，请重试。')));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CSV 导出')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Icon(Icons.table_view_outlined, size: 72),
            const SizedBox(height: 24),
            Text(
              '导出全部未删除卡片',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              '包含基础资料、持有数量、品相、发行信息、标签、套卡、集卡册与入手成本。'
              '文件使用 UTF-8 编码，可直接用 Excel 打开。',
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _exporting ? null : _export,
              icon: const Icon(Icons.download_outlined),
              label: Text(_exporting ? '正在导出…' : '选择位置并导出'),
            ),
          ],
        ),
      ),
    );
  }
}
