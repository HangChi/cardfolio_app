import 'dart:async';
import 'dart:io';

import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/features/backup/domain/backup_file_picker.dart';
import 'package:cardfolio_app/features/backup/domain/backup_models.dart';
import 'package:cardfolio_app/features/backup/domain/backup_repository.dart';

final class FakeBackupRepository implements BackupRepository {
  int exportCalls = 0;
  int inspectCalls = 0;
  int importCalls = 0;
  bool holdExport = false;
  BackupCancellationToken? exportToken;
  Completer<BackupExportReport>? _exportCompleter;

  BackupImportPreview preview = BackupImportPreview(
    createdAt: DateTime.utc(2026, 7, 29, 8),
    mode: BackupMode.emptyLibrary,
    entityCounts: const <String, int>{'cardDefinitions': 1, 'cardImages': 1},
    imageCount: 1,
    addedCount: 3,
    skippedCount: 0,
    conflicts: const <BackupConflict>[],
  );

  @override
  Future<BackupExportReport> exportBackup(
    File destination, {
    BackupCancellationToken? cancellationToken,
    BackupProgressCallback? onProgress,
  }) {
    exportCalls++;
    exportToken = cancellationToken;
    onProgress?.call(
      BackupProgress(stage: BackupStage.validatingArchive, fraction: 0.4),
    );
    if (holdExport) {
      _exportCompleter = Completer<BackupExportReport>();
      return _exportCompleter!.future;
    }
    return Future<BackupExportReport>.value(
      BackupExportReport(
        createdAt: DateTime.utc(2026, 7, 29, 8),
        entityCount: 3,
        imageCount: 1,
        byteSize: 512,
      ),
    );
  }

  void finishCancelledExport() {
    _exportCompleter?.completeError(const BackupCancelledFailure());
  }

  @override
  Future<BackupImportPreview> inspectBackup(
    File source, {
    required BackupMode mode,
    BackupCancellationToken? cancellationToken,
    BackupProgressCallback? onProgress,
  }) async {
    inspectCalls++;
    return BackupImportPreview(
      createdAt: preview.createdAt,
      mode: mode,
      entityCounts: preview.entityCounts,
      imageCount: preview.imageCount,
      addedCount: preview.addedCount,
      skippedCount: preview.skippedCount,
      conflicts: preview.conflicts,
    );
  }

  @override
  Future<BackupImportReport> importBackup(
    File source, {
    required BackupMode mode,
    BackupCancellationToken? cancellationToken,
    BackupProgressCallback? onProgress,
  }) async {
    importCalls++;
    return BackupImportReport(
      completedAt: DateTime.utc(2026, 7, 29, 9),
      mode: mode,
      addedCount: preview.addedCount,
      skippedCount: preview.skippedCount,
      imageCount: preview.imageCount,
    );
  }
}

final class FakeBackupFilePicker implements BackupFilePicker {
  String? exportPath;
  String? importPath;
  AppFailure? exportError;
  AppFailure? importError;
  int exportCalls = 0;
  int importCalls = 0;
  int publishCalls = 0;

  @override
  Future<String?> chooseExportPath(String suggestedName) async {
    exportCalls++;
    if (exportError case final error?) throw error;
    return exportPath;
  }

  @override
  Future<String?> chooseImportPath() async {
    importCalls++;
    if (importError case final error?) throw error;
    return importPath;
  }

  @override
  Future<bool> publishExport(String path) async {
    publishCalls++;
    return true;
  }
}
