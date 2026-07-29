import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/backup_file_picker.dart';

final class FilePickerBackupFiles implements BackupFilePicker {
  @override
  Future<String?> chooseExportPath(String suggestedName) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final temporaryRoot = await getTemporaryDirectory();
        final exports = Directory(p.join(temporaryRoot.path, 'backup-exports'));
        if (await exports.exists()) {
          await exports.delete(recursive: true);
        }
        await exports.create(recursive: true);
        return p.join(exports.path, suggestedName);
      }
      return FilePicker.saveFile(
        dialogTitle: '保存卡藏完整备份',
        fileName: suggestedName,
        type: FileType.custom,
        allowedExtensions: const <String>['zip'],
      );
    } on Object catch (error) {
      throw BackupStorageFailure('无法打开系统保存位置，请重试。', error);
    }
  }

  @override
  Future<bool> publishExport(String path) async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;
    final file = File(path);
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[XFile(path, mimeType: 'application/zip')],
          title: '保存卡藏完整备份',
          text: '卡藏完整备份，请保存到可信位置。',
          sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
        ),
      );
      final published = result.status != ShareResultStatus.dismissed;
      if (!published && await file.exists()) await file.delete();
      return published;
    } on Object catch (error) {
      if (await file.exists()) await file.delete();
      throw BackupStorageFailure('无法打开系统分享面板，请重试。', error);
    }
  }

  @override
  Future<String?> chooseImportPath() async {
    try {
      final result = await FilePicker.pickFiles(
        dialogTitle: '选择卡藏备份',
        type: FileType.custom,
        allowedExtensions: const <String>['zip'],
        allowMultiple: false,
        withData: false,
      );
      return result?.files.single.path;
    } on Object catch (error) {
      throw BackupStorageFailure('无法打开系统文件选择器，请重试。', error);
    }
  }
}
