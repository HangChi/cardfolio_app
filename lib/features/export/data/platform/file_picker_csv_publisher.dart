import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/csv_file_publisher.dart';

final class FilePickerCsvPublisher implements CsvFilePublisher {
  @override
  Future<String?> choosePath(String suggestedName) async {
    if (Platform.isAndroid || Platform.isIOS) {
      final root = await getTemporaryDirectory();
      final directory = Directory(p.join(root.path, 'csv-exports'));
      await directory.create(recursive: true);
      return p.join(directory.path, suggestedName);
    }
    return FilePicker.saveFile(
      dialogTitle: '导出卡片 CSV',
      fileName: suggestedName,
      type: FileType.custom,
      allowedExtensions: const <String>['csv'],
    );
  }

  @override
  Future<bool> writeAndPublish(String path, String contents) async {
    await File(path).writeAsString(contents, flush: true);
    if (!Platform.isAndroid && !Platform.isIOS) return true;
    final result = await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(path, mimeType: 'text/csv')],
        title: '导出卡片 CSV',
        text: '卡迹卡片清单',
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
      ),
    );
    return result.status != ShareResultStatus.dismissed;
  }
}
