import 'dart:io';

import 'backup_models.dart';

abstract interface class BackupRepository {
  Future<BackupExportReport> exportBackup(
    File destination, {
    BackupCancellationToken? cancellationToken,
    BackupProgressCallback? onProgress,
  });

  Future<BackupImportPreview> inspectBackup(
    File source, {
    required BackupMode mode,
    BackupCancellationToken? cancellationToken,
    BackupProgressCallback? onProgress,
  });

  Future<BackupImportReport> importBackup(
    File source, {
    required BackupMode mode,
    BackupCancellationToken? cancellationToken,
    BackupProgressCallback? onProgress,
  });
}
