abstract interface class BackupFilePicker {
  Future<String?> chooseExportPath(String suggestedName);

  Future<bool> publishExport(String path);

  Future<String?> chooseImportPath();
}
