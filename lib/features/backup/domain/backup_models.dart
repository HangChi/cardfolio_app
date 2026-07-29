import '../../../core/errors/app_failure.dart';

export '../../../core/errors/app_failure.dart'
    show
        BackupCancelledFailure,
        BackupCompatibilityFailure,
        BackupStorageFailure,
        BackupValidationFailure;

enum BackupMode { emptyLibrary, mergeAddOnly }

enum BackupStage {
  preparing,
  readingDatabase,
  checkingImages,
  writingArchive,
  validatingArchive,
  validatingData,
  stagingImages,
  committing,
  completed,
}

final class BackupLimits {
  const BackupLimits._();

  static const int maxEntries = 50000;
  static const int maxManifestBytes = 2 * 1024 * 1024;
  static const int maxDataBytes = 64 * 1024 * 1024;
  static const int maxEntryBytes = 64 * 1024 * 1024;
  static const int maxUncompressedBytes = 2 * 1024 * 1024 * 1024;
  static const int maxCompressionRatio = 100;
}

final class BackupProgress {
  BackupProgress({required this.stage, required this.fraction}) {
    if (!fraction.isFinite || fraction < 0 || fraction > 1) {
      throw ArgumentError.value(
        fraction,
        'fraction',
        'must be between 0 and 1',
      );
    }
  }

  final BackupStage stage;
  final double fraction;
}

typedef BackupProgressCallback = void Function(BackupProgress progress);

final class BackupCancellationToken {
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  void cancel() => _cancelled = true;

  void throwIfCancelled() {
    if (_cancelled) throw const BackupCancelledFailure();
  }
}

final class BackupEntry {
  BackupEntry({
    required this.path,
    required this.byteSize,
    required this.sha256,
  }) {
    validatePath(path);
    if (byteSize < 0 || byteSize > BackupLimits.maxEntryBytes) {
      throw const BackupValidationFailure('备份中的文件大小超出安全限制。');
    }
    if (!_sha256Pattern.hasMatch(sha256)) {
      throw const BackupValidationFailure('备份清单中的校验信息无效。');
    }
  }

  factory BackupEntry.fromJson(Object? value) {
    final json = _jsonObject(value, '备份清单条目无效。');
    return BackupEntry(
      path: _jsonString(json['path'], '备份清单路径无效。'),
      byteSize: _jsonInt(json['byteSize'], '备份清单大小无效。'),
      sha256: _jsonString(json['sha256'], '备份清单校验信息无效。'),
    );
  }

  static final RegExp _sha256Pattern = RegExp(r'^[0-9a-f]{64}$');

  final String path;
  final int byteSize;
  final String sha256;

  Map<String, Object?> toJson() => <String, Object?>{
    'path': path,
    'byteSize': byteSize,
    'sha256': sha256,
  };

  static void validatePath(String value) {
    final segments = value.split('/');
    final invalid =
        value.isEmpty ||
        value.startsWith('/') ||
        value.contains(r'\') ||
        value.contains(':') ||
        value.runes.any((rune) => rune < 0x20 || rune == 0x7f) ||
        segments.any(
          (segment) => segment.isEmpty || segment == '.' || segment == '..',
        ) ||
        (value != BackupManifest.dataFileName && !value.startsWith('images/'));
    if (invalid) {
      throw const BackupValidationFailure('备份包含不安全或未知的文件路径。');
    }
  }
}

final class BackupManifest {
  BackupManifest({
    required this.formatVersion,
    required this.sourceSchemaVersion,
    required this.createdAt,
    required this.entries,
    required this.entityCounts,
  }) {
    if (sourceSchemaVersion < 1) {
      throw const BackupValidationFailure('备份来源版本无效。');
    }
    if (!createdAt.isUtc) {
      throw const BackupValidationFailure('备份创建时间必须使用 UTC。');
    }
    final paths = entries.map((entry) => entry.path).toSet();
    if (paths.length != entries.length) {
      throw const BackupValidationFailure('备份清单包含重复路径。');
    }
    if (!paths.contains(dataFileName)) {
      throw const BackupValidationFailure('备份缺少结构化数据清单。');
    }
    if (entries.length > BackupLimits.maxEntries) {
      throw const BackupValidationFailure('备份文件数量超出安全限制。');
    }
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.byteSize);
    if (total > BackupLimits.maxUncompressedBytes) {
      throw const BackupValidationFailure('备份解压大小超出安全限制。');
    }
  }

  factory BackupManifest.fromJson(Object? value) {
    final json = _jsonObject(value, '备份清单无效。');
    final format = _jsonString(json['format'], '备份格式标识无效。');
    if (format != formatName) {
      throw const BackupValidationFailure('这不是卡迹备份文件。');
    }
    final formatVersion = _jsonInt(json['formatVersion'], '备份格式版本无效。');
    if (formatVersion < minSupportedVersion) {
      throw const BackupCompatibilityFailure('备份版本过旧，当前应用无法导入。');
    }
    if (formatVersion > currentVersion) {
      throw const BackupCompatibilityFailure('备份版本较新，请更新应用后重试。');
    }
    final dataFile = _jsonString(json['dataFile'], '备份数据文件无效。');
    if (dataFile != dataFileName) {
      throw const BackupValidationFailure('备份数据文件路径无效。');
    }

    final createdAtValue = _jsonString(json['createdAt'], '备份创建时间无效。');
    final createdAt = DateTime.tryParse(createdAtValue);
    if (createdAt == null || !createdAtValue.endsWith('Z')) {
      throw const BackupValidationFailure('备份创建时间无效。');
    }

    final rawEntries = json['entries'];
    if (rawEntries is! List<Object?>) {
      throw const BackupValidationFailure('备份清单条目无效。');
    }
    final rawCounts = _jsonObject(json['entityCounts'], '备份实体计数无效。');
    final counts = <String, int>{};
    for (final MapEntry(:key, :value) in rawCounts.entries) {
      final count = _jsonInt(value, '备份实体计数无效。');
      if (count < 0) {
        throw const BackupValidationFailure('备份实体计数无效。');
      }
      counts[key] = count;
    }

    return BackupManifest(
      formatVersion: formatVersion,
      sourceSchemaVersion: _jsonInt(json['sourceSchemaVersion'], '备份来源版本无效。'),
      createdAt: createdAt.toUtc(),
      entries: rawEntries.map(BackupEntry.fromJson).toList(growable: false),
      entityCounts: Map<String, int>.unmodifiable(counts),
    );
  }

  static const String formatName = 'cardfolio-backup';
  static const String manifestFileName = 'manifest.json';
  static const String dataFileName = 'data.json';
  static const int currentVersion = 1;
  static const int minSupportedVersion = 1;

  final int formatVersion;
  final int sourceSchemaVersion;
  final DateTime createdAt;
  final List<BackupEntry> entries;
  final Map<String, int> entityCounts;

  Map<String, Object?> toJson() => <String, Object?>{
    'format': formatName,
    'formatVersion': formatVersion,
    'sourceSchemaVersion': sourceSchemaVersion,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'dataFile': dataFileName,
    'entries': entries.map((entry) => entry.toJson()).toList(growable: false),
    'entityCounts': entityCounts,
  };
}

final class BackupConflict {
  const BackupConflict({required this.entity, required this.key});

  final String entity;
  final String key;
}

final class BackupImportPreview {
  const BackupImportPreview({
    required this.createdAt,
    required this.mode,
    required this.entityCounts,
    required this.imageCount,
    required this.addedCount,
    required this.skippedCount,
    required this.conflicts,
  });

  final DateTime createdAt;
  final BackupMode mode;
  final Map<String, int> entityCounts;
  final int imageCount;
  final int addedCount;
  final int skippedCount;
  final List<BackupConflict> conflicts;

  bool get canImport => conflicts.isEmpty;
}

final class BackupExportReport {
  const BackupExportReport({
    required this.createdAt,
    required this.entityCount,
    required this.imageCount,
    required this.byteSize,
  });

  final DateTime createdAt;
  final int entityCount;
  final int imageCount;
  final int byteSize;
}

final class BackupImportReport {
  const BackupImportReport({
    required this.completedAt,
    required this.mode,
    required this.addedCount,
    required this.skippedCount,
    required this.imageCount,
  });

  final DateTime completedAt;
  final BackupMode mode;
  final int addedCount;
  final int skippedCount;
  final int imageCount;
}

Map<String, Object?> _jsonObject(Object? value, String message) {
  if (value is! Map<Object?, Object?>) {
    throw BackupValidationFailure(message);
  }
  final result = <String, Object?>{};
  for (final MapEntry(:key, :value) in value.entries) {
    if (key is! String) throw BackupValidationFailure(message);
    result[key] = value;
  }
  return result;
}

String _jsonString(Object? value, String message) {
  if (value is! String) throw BackupValidationFailure(message);
  return value;
}

int _jsonInt(Object? value, String message) {
  if (value is! int) throw BackupValidationFailure(message);
  return value;
}
