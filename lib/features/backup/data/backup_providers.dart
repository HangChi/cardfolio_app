import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/backup_file_picker.dart';
import '../domain/backup_repository.dart';
import 'platform/file_picker_backup_files.dart';

/// 依赖应用私有目录，由启动流程或测试覆盖。
final Provider<BackupRepository> backupRepositoryProvider =
    Provider<BackupRepository>((ref) {
      throw StateError('backupRepositoryProvider 必须由启动流程覆盖');
    });

final Provider<BackupFilePicker> backupFilePickerProvider =
    Provider<BackupFilePicker>((ref) => FilePickerBackupFiles());
