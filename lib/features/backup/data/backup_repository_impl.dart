import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/time/clock.dart';
import '../../cards/data/files/managed_image_store.dart';
import '../../cards/data/local/card_database.dart';
import '../domain/backup_models.dart';
import '../domain/backup_repository.dart';
import 'backup_database.dart';

final class BackupRepositoryImpl implements BackupRepository {
  factory BackupRepositoryImpl({
    required AppDatabase database,
    required ManagedImageStore imageStore,
    required Directory workingDirectory,
    required Clock clock,
  }) => BackupRepositoryImpl._(database, imageStore, workingDirectory, clock);

  BackupRepositoryImpl._(
    this._database,
    this._imageStore,
    this._workingDirectory,
    this._clock,
  );

  final AppDatabase _database;
  final ManagedImageStore _imageStore;
  final Directory _workingDirectory;
  final Clock _clock;
  static const Uuid _uuid = Uuid();

  @override
  Future<BackupExportReport> exportBackup(
    File destination, {
    BackupCancellationToken? cancellationToken,
    BackupProgressCallback? onProgress,
  }) async {
    final operation = await _createOperationDirectory();
    final partFile = File('${destination.path}.part');
    try {
      _checkCancelled(cancellationToken);
      _progress(onProgress, BackupStage.readingDatabase, 0.05);
      final snapshot = await _database.exportLogicalBackup();
      _checkCancelled(cancellationToken);

      // 编码结构化数据、逐图哈希与 ZIP 压缩都是 CPU 密集操作，
      // 整体放到后台 isolate 执行，避免大收藏库备份时卡住 UI。
      // 取消令牌与进度回调无法跨 isolate，因此只在单元前后检查与上报。
      final createdAt = _clock.nowUtc();
      _progress(onProgress, BackupStage.checkingImages, 0.2);
      _progress(onProgress, BackupStage.writingArchive, 0.55);
      // 闭包不能引用实例字段（会捕获不可跨 isolate 的 this），
      // 因此先把实例字段全部提取为纯数据局部变量。
      final imageRootPath = _imageStore.root.path;
      final operationPath = operation.path;
      final schemaVersion = _database.schemaVersion;
      final result = await Isolate.run(
        () => _runExportPipeline(
          snapshot: snapshot,
          imageRootPath: imageRootPath,
          operationPath: operationPath,
          schemaVersion: schemaVersion,
          createdAt: createdAt,
        ),
      );
      _checkCancelled(cancellationToken);

      final archiveFile = File(p.join(operation.path, 'backup.zip'));
      await destination.parent.create(recursive: true);
      if (partFile.existsSync()) await partFile.delete();
      await archiveFile.copy(partFile.path);
      if (destination.existsSync()) await destination.delete();
      await partFile.rename(destination.path);

      _progress(onProgress, BackupStage.completed, 1);
      return BackupExportReport(
        createdAt: createdAt,
        entityCount: result.entityCount,
        imageCount: result.imageCount,
        byteSize: result.archiveByteSize,
      );
    } on AppFailure {
      rethrow;
    } on FileSystemException catch (error) {
      throw BackupStorageFailure('无法写入备份文件，请检查存储空间后重试。', error);
    } catch (error) {
      throw BackupStorageFailure('导出备份失败，请重试。', error);
    } finally {
      await _deleteFileQuietly(partFile);
      await _deleteDirectoryQuietly(operation);
    }
  }

  @override
  Future<BackupImportPreview> inspectBackup(
    File source, {
    required BackupMode mode,
    BackupCancellationToken? cancellationToken,
    BackupProgressCallback? onProgress,
  }) async {
    final operation = await _createOperationDirectory();
    try {
      final local = await _copySource(source, operation, cancellationToken);
      final validated = await _validateArchive(
        local,
        cancellationToken: cancellationToken,
        onProgress: onProgress,
      );
      final logical = await _database.previewLogicalImport(
        validated.snapshot,
        mode: mode,
      );
      return BackupImportPreview(
        createdAt: validated.manifest.createdAt,
        mode: mode,
        entityCounts: validated.snapshot.entityCounts,
        imageCount: validated.imagePaths.length,
        addedCount: logical.addedCount,
        skippedCount: logical.skippedCount,
        conflicts: logical.conflicts,
      );
    } finally {
      await _deleteDirectoryQuietly(operation);
    }
  }

  @override
  Future<BackupImportReport> importBackup(
    File source, {
    required BackupMode mode,
    BackupCancellationToken? cancellationToken,
    BackupProgressCallback? onProgress,
  }) async {
    final operation = await _createOperationDirectory();
    final stagedImages = Directory(p.join(operation.path, 'staged-images'));
    final committedFiles = <File>[];
    try {
      final local = await _copySource(source, operation, cancellationToken);
      final validated = await _validateArchive(
        local,
        cancellationToken: cancellationToken,
        onProgress: onProgress,
        extractImagesTo: stagedImages,
      );
      final preview = await _database.previewLogicalImport(
        validated.snapshot,
        mode: mode,
      );
      if (preview.conflicts.isNotEmpty) {
        throw const BackupValidationFailure('备份与当前收藏库存在冲突，未导入任何数据。');
      }
      _checkCancelled(cancellationToken);
      _progress(onProgress, BackupStage.committing, 0.9);
      // 图片复制/哈希在数据库事务外完成：大库恢复时不再长时间持有
      // SQLite 写锁。失败通过 committedFiles 补偿删除；提交前崩溃留下的
      // 孤儿文件由启动清理按引用收敛，语义与原先一致。
      await _commitImages(
        stagedImages,
        validated.imagePaths,
        validated.imageChecksums,
        committedFiles,
      );
      final result = await _database.importLogicalBackup(
        validated.snapshot,
        mode: mode,
      );
      _progress(onProgress, BackupStage.completed, 1);
      return BackupImportReport(
        completedAt: _clock.nowUtc(),
        mode: mode,
        addedCount: result.addedCount,
        skippedCount: result.skippedCount,
        imageCount: validated.imagePaths.length,
      );
    } on AppFailure {
      await _deleteFilesQuietly(committedFiles);
      rethrow;
    } on FileSystemException catch (error) {
      await _deleteFilesQuietly(committedFiles);
      throw BackupStorageFailure('导入图片失败，现有数据未改变。', error);
    } catch (error) {
      await _deleteFilesQuietly(committedFiles);
      throw BackupStorageFailure('导入失败，现有数据未改变。', error);
    } finally {
      await _deleteDirectoryQuietly(operation);
    }
  }

  Future<_ValidatedArchive> _validateArchive(
    File source, {
    BackupCancellationToken? cancellationToken,
    BackupProgressCallback? onProgress,
    Directory? extractImagesTo,
  }) async {
    _checkCancelled(cancellationToken);
    _progress(onProgress, BackupStage.validatingArchive, 0.1);
    if (!source.existsSync()) {
      throw const BackupStorageFailure('找不到所选备份文件。');
    }
    if (await source.length() > BackupLimits.maxUncompressedBytes) {
      throw const BackupValidationFailure('备份文件大小超出安全限制。');
    }

    // 解压、逐条哈希与 JSON 解析都是 CPU 密集操作，整体放到后台 isolate。
    // 取消令牌与进度回调无法跨 isolate，只在单元前后检查与上报。
    final sourcePath = source.path;
    final extractImagesToPath = extractImagesTo?.path;
    final validated = await Isolate.run(
      () => _validateArchiveFiles(
        sourcePath: sourcePath,
        extractImagesToPath: extractImagesToPath,
      ),
    );
    _checkCancelled(cancellationToken);
    _progress(onProgress, BackupStage.validatingData, 0.6);
    return validated;
  }

  Future<void> _commitImages(
    Directory stagedRoot,
    List<String> imagePaths,
    Map<String, String> checksums,
    List<File> committedFiles,
  ) async {
    for (final relativePath in imagePaths) {
      final staged = File(
        p.joinAll(<String>[stagedRoot.path, ...p.posix.split(relativePath)]),
      );
      final destination = _imageStore.resolve(relativePath);
      if (destination.existsSync()) {
        final existing = (await sha256.bind(destination.openRead()).first)
            .toString();
        if (existing != checksums[relativePath]) {
          throw const BackupStorageFailure('目标图片与备份冲突，未导入任何数据。');
        }
        continue;
      }
      await destination.parent.create(recursive: true);
      final temporary = File('${destination.path}.importing-${_uuid.v4()}');
      try {
        await staged.copy(temporary.path);
        await temporary.rename(destination.path);
        committedFiles.add(destination);
      } finally {
        await _deleteFileQuietly(temporary);
      }
    }
  }

  Future<File> _copySource(
    File source,
    Directory operation,
    BackupCancellationToken? token,
  ) async {
    _checkCancelled(token);
    if (!source.existsSync()) {
      throw const BackupStorageFailure('找不到所选备份文件。');
    }
    final local = File(p.join(operation.path, 'selected-backup.zip'));
    RandomAccessFile? output;
    try {
      if (await source.length() > BackupLimits.maxUncompressedBytes) {
        throw const BackupValidationFailure('备份文件大小超出安全限制。');
      }

      output = await local.open(mode: FileMode.write);
      var copiedBytes = 0;
      await for (final chunk in source.openRead()) {
        _checkCancelled(token);
        copiedBytes += chunk.length;
        if (copiedBytes > BackupLimits.maxUncompressedBytes) {
          throw const BackupValidationFailure('备份文件大小超出安全限制。');
        }
        await output.writeFrom(chunk);
      }
      await output.flush();
      await output.close();
      output = null;
    } on AppFailure {
      await _closeFileQuietly(output);
      output = null;
      await _deleteFileQuietly(local);
      rethrow;
    } on FileSystemException catch (error) {
      await _closeFileQuietly(output);
      output = null;
      await _deleteFileQuietly(local);
      throw BackupStorageFailure('无法读取所选备份文件。', error);
    } finally {
      await _closeFileQuietly(output);
    }
    _checkCancelled(token);
    return local;
  }

  Future<Directory> _createOperationDirectory() async {
    final operation = Directory(
      p.join(_workingDirectory.path, 'operation-${_uuid.v4()}'),
    );
    try {
      await operation.create(recursive: true);
      return operation;
    } on FileSystemException catch (error) {
      throw BackupStorageFailure('无法创建备份临时空间。', error);
    }
  }
}

/// 后台 isolate 中一次导出管线的结果。只允许纯数据字段。
final class _ExportPipelineResult {
  const _ExportPipelineResult({
    required this.entityCount,
    required this.imageCount,
    required this.archiveByteSize,
  });

  final int entityCount;
  final int imageCount;
  final int archiveByteSize;
}

/// 后台 isolate：编码结构化数据、逐图校验哈希、写清单并压缩为 ZIP。
///
/// 只能抛出不含 cause 的常量 [AppFailure]，保证错误对象可以跨 isolate
/// 传回主 isolate；取消与进度上报由调用方在单元边界处理。
Future<_ExportPipelineResult> _runExportPipeline({
  required BackupSnapshot snapshot,
  required String imageRootPath,
  required String operationPath,
  required int schemaVersion,
  required DateTime createdAt,
}) async {
  final dataBytes = utf8.encode(jsonEncode(snapshot.toJson()));
  if (dataBytes.length > BackupLimits.maxDataBytes) {
    throw const BackupValidationFailure('结构化数据超出备份安全限制。');
  }
  final dataFile = File(p.join(operationPath, BackupManifest.dataFileName));
  await dataFile.writeAsBytes(dataBytes, flush: true);

  final store = ManagedImageStore(Directory(imageRootPath));
  final plan = _exportImagePlan(snapshot);
  final images = <(String, String, int)>[];
  for (final relativePath in plan.paths.toList()..sort()) {
    final file = store.resolve(relativePath);
    if (!file.existsSync()) {
      throw const BackupStorageFailure('备份所需图片缺失，请先检查收藏图片。');
    }
    final size = await file.length();
    if (size > BackupLimits.maxEntryBytes) {
      throw const BackupValidationFailure('备份中的图片大小超出安全限制。');
    }
    final checksum = (await sha256.bind(file.openRead()).first).toString();
    final declared = plan.declaredOriginalChecksums[relativePath];
    if (declared != null && declared != checksum) {
      throw const BackupValidationFailure('收藏图片校验失败，导出已停止。');
    }
    images.add((relativePath, checksum, size));
  }

  final entries = <BackupEntry>[
    BackupEntry(
      path: BackupManifest.dataFileName,
      byteSize: dataBytes.length,
      sha256: sha256.convert(dataBytes).toString(),
    ),
    for (final image in images)
      BackupEntry(
        path: 'images/${image.$1}',
        byteSize: image.$3,
        sha256: image.$2,
      ),
  ];
  final manifest = BackupManifest(
    formatVersion: BackupManifest.currentVersion,
    sourceSchemaVersion: schemaVersion,
    createdAt: createdAt,
    entries: entries,
    entityCounts: snapshot.entityCounts,
  );
  final manifestBytes = utf8.encode(jsonEncode(manifest.toJson()));
  if (manifestBytes.length > BackupLimits.maxManifestBytes) {
    throw const BackupValidationFailure('备份清单超出安全限制。');
  }
  final manifestFile = File(
    p.join(operationPath, BackupManifest.manifestFileName),
  );
  await manifestFile.writeAsBytes(manifestBytes, flush: true);

  final archiveFile = File(p.join(operationPath, 'backup.zip'));
  final encoder = ZipFileEncoder()
    ..create(archiveFile.path, modified: createdAt);
  try {
    await encoder.addFile(manifestFile, BackupManifest.manifestFileName);
    await encoder.addFile(dataFile, BackupManifest.dataFileName);
    for (final image in images) {
      await encoder.addFile(store.resolve(image.$1), 'images/${image.$1}');
    }
  } finally {
    await encoder.close();
  }

  return _ExportPipelineResult(
    entityCount: snapshot.totalEntityCount,
    imageCount: images.length,
    archiveByteSize: await archiveFile.length(),
  );
}

/// 解析快照中需要导出的图片路径与已声明的原图校验和。
({Set<String> paths, Map<String, String> declaredOriginalChecksums})
_exportImagePlan(BackupSnapshot snapshot) {
  final declaredOriginalChecksums = <String, String>{};
  final paths = <String>{};
  for (final row in snapshot.rows('cardImages')) {
    final relativePath = _requiredString(row, 'relativePath');
    if (!paths.add(relativePath)) {
      throw const BackupValidationFailure('备份图片路径重复。');
    }
    declaredOriginalChecksums[relativePath] = _requiredString(row, 'checksum');
    final derived = row['derivedRelativePath'];
    if (derived != null) {
      if (derived is! String || !paths.add(derived)) {
        throw const BackupValidationFailure('备份图片路径重复或无效。');
      }
    }
  }
  for (final row in snapshot.rows('seriesRecords')) {
    final cover = row['coverRelativePath'];
    if (cover is String && cover.isNotEmpty) paths.add(cover);
  }
  for (final row in snapshot.rows('cardSets')) {
    final cover = row['coverRelativePath'];
    if (cover is String && cover.isNotEmpty) paths.add(cover);
  }
  return (paths: paths, declaredOriginalChecksums: declaredOriginalChecksums);
}

void _validateArchiveEntry(ArchiveFile entry) {
  final path = entry.name;
  final segments = path.split('/');
  final allowed =
      path == BackupManifest.manifestFileName ||
      path == BackupManifest.dataFileName ||
      path.startsWith('images/');
  if (path != BackupManifest.manifestFileName) {
    BackupEntry.validatePath(path);
  }
  if (!entry.isFile ||
      entry.isSymbolicLink ||
      path.isEmpty ||
      path.startsWith('/') ||
      path.contains(r'\') ||
      path.contains(':') ||
      path.runes.any((rune) => rune < 0x20 || rune == 0x7f) ||
      segments.any(
        (segment) => segment.isEmpty || segment == '.' || segment == '..',
      ) ||
      !allowed) {
    throw const BackupValidationFailure('备份包含不安全或未知的文件路径。');
  }
  final limit = path == BackupManifest.manifestFileName
      ? BackupLimits.maxManifestBytes
      : BackupLimits.maxEntryBytes;
  if (entry.size < 0 || entry.size > limit) {
    throw const BackupValidationFailure('备份中的文件大小超出安全限制。');
  }
}

BackupManifest _decodeManifest(ArchiveFile entry) {
  try {
    return BackupManifest.fromJson(jsonDecode(utf8.decode(entry.readBytes()!)));
  } on AppFailure {
    rethrow;
  } on Object {
    // 不携带 cause：本函数在后台 isolate 中执行，错误对象必须可跨 isolate 传递。
    throw const BackupValidationFailure('备份清单无法解析。');
  }
}

/// 后台 isolate：解压备份、逐条校验哈希并解析结构化数据。
///
/// 只能抛出不含 cause 的常量 [AppFailure]，保证错误对象可以跨 isolate
/// 传回主 isolate；取消与进度上报由调用方在单元边界处理。
Future<_ValidatedArchive> _validateArchiveFiles({
  required String sourcePath,
  required String? extractImagesToPath,
}) async {
  final extractImagesTo = extractImagesToPath == null
      ? null
      : Directory(extractImagesToPath);
  InputFileStream? input;
  Archive? archive;
  try {
    input = InputFileStream(sourcePath);
    final decoder = ZipDecoder();
    archive = decoder.decodeStream(input);
    final headers = decoder.directory.fileHeaders;
    if (headers.length > BackupLimits.maxEntries + 1) {
      throw const BackupValidationFailure('备份文件数量超出安全限制。');
    }
    final names = headers.map((header) => header.filename).toList();
    if (names.toSet().length != names.length ||
        archive.length != headers.length) {
      throw const BackupValidationFailure('备份包含重复文件路径。');
    }

    var totalSize = 0;
    final compressedSizes = <String, int>{};
    for (final header in headers) {
      compressedSizes[header.filename] = header.compressedSize;
    }
    for (final entry in archive) {
      _validateArchiveEntry(entry);
      totalSize += entry.size;
      if (totalSize > BackupLimits.maxUncompressedBytes) {
        throw const BackupValidationFailure('备份解压大小超出安全限制。');
      }
      final compressed = compressedSizes[entry.name] ?? 0;
      if (entry.size > 0 &&
          (compressed == 0 ||
              entry.size > compressed * BackupLimits.maxCompressionRatio)) {
        throw const BackupValidationFailure('备份压缩比超出安全限制。');
      }
    }

    final manifestEntry = archive.find(BackupManifest.manifestFileName);
    if (manifestEntry == null ||
        manifestEntry.size > BackupLimits.maxManifestBytes) {
      throw const BackupValidationFailure('备份清单缺失或过大。');
    }
    final manifest = _decodeManifest(manifestEntry);
    final actualPaths = archive
        .where((entry) => entry.name != BackupManifest.manifestFileName)
        .map((entry) => entry.name)
        .toSet();
    final declaredPaths = manifest.entries.map((entry) => entry.path).toSet();
    if (!_sameSet(actualPaths, declaredPaths)) {
      throw const BackupValidationFailure('备份清单与文件内容不一致。');
    }

    List<int>? dataBytes;
    final checksums = <String, String>{};
    for (final declared in manifest.entries) {
      final entry = archive.find(declared.path)!;
      if (entry.size != declared.byteSize) {
        throw const BackupValidationFailure('备份文件大小校验失败。');
      }
      final bytes = entry.readBytes();
      if (bytes == null) {
        throw const BackupValidationFailure('备份文件无法读取。');
      }
      final checksum = sha256.convert(bytes).toString();
      if (checksum != declared.sha256) {
        throw const BackupValidationFailure('备份文件校验失败，文件可能已损坏。');
      }
      checksums[declared.path] = checksum;
      if (declared.path == BackupManifest.dataFileName) {
        if (bytes.length > BackupLimits.maxDataBytes) {
          throw const BackupValidationFailure('备份数据大小超出安全限制。');
        }
        dataBytes = bytes;
      } else if (extractImagesTo != null) {
        final relativePath = declared.path.substring('images/'.length);
        final staged = File(
          p.joinAll(<String>[
            extractImagesTo.path,
            ...p.posix.split(relativePath),
          ]),
        );
        await staged.parent.create(recursive: true);
        await staged.writeAsBytes(bytes, flush: true);
      }
    }
    if (dataBytes == null) {
      throw const BackupValidationFailure('备份缺少结构化数据。');
    }

    final Object? rawSnapshot;
    try {
      rawSnapshot = jsonDecode(utf8.decode(dataBytes));
    } on Object {
      throw const BackupValidationFailure('备份数据无法解析。');
    }
    final snapshot = BackupSnapshot.fromJson(rawSnapshot);
    if (!_sameCounts(manifest.entityCounts, snapshot.entityCounts)) {
      throw const BackupValidationFailure('备份实体计数校验失败。');
    }

    final imagePaths = _snapshotImagePaths(snapshot);
    final archivedImagePaths = declaredPaths
        .where((path) => path.startsWith('images/'))
        .map((path) => path.substring('images/'.length))
        .toSet();
    if (!_sameSet(imagePaths, archivedImagePaths)) {
      throw const BackupValidationFailure('备份图片引用不完整。');
    }
    for (final row in snapshot.rows('cardImages')) {
      final relativePath = _requiredString(row, 'relativePath');
      final declaredChecksum = _requiredString(row, 'checksum');
      if (checksums['images/$relativePath'] != declaredChecksum) {
        throw const BackupValidationFailure('备份原图校验与数据记录不一致。');
      }
    }

    return _ValidatedArchive(
      manifest: manifest,
      snapshot: snapshot,
      imagePaths: imagePaths.toList()..sort(),
      imageChecksums: <String, String>{
        for (final path in imagePaths) path: checksums['images/$path']!,
      },
    );
  } on AppFailure {
    rethrow;
  } on Object {
    throw const BackupValidationFailure('备份 ZIP 无法读取或已损坏。');
  } finally {
    if (archive != null) await archive.clear();
    if (input != null) await input.close();
  }
}

final class _ValidatedArchive {
  const _ValidatedArchive({
    required this.manifest,
    required this.snapshot,
    required this.imagePaths,
    required this.imageChecksums,
  });

  final BackupManifest manifest;
  final BackupSnapshot snapshot;
  final List<String> imagePaths;
  final Map<String, String> imageChecksums;
}

Set<String> _snapshotImagePaths(BackupSnapshot snapshot) {
  final paths = <String>{};
  for (final row in snapshot.rows('cardImages')) {
    final original = _requiredString(row, 'relativePath');
    if (!paths.add(original)) {
      throw const BackupValidationFailure('备份图片路径重复。');
    }
    final derived = row['derivedRelativePath'];
    if (derived != null) {
      if (derived is! String || !paths.add(derived)) {
        throw const BackupValidationFailure('备份图片路径重复或无效。');
      }
    }
  }
  for (final row in snapshot.rows('seriesRecords')) {
    final cover = row['coverRelativePath'];
    if (cover is String && cover.isNotEmpty) paths.add(cover);
  }
  for (final row in snapshot.rows('cardSets')) {
    final cover = row['coverRelativePath'];
    if (cover is String && cover.isNotEmpty) paths.add(cover);
  }
  return paths;
}

String _requiredString(Map<String, Object?> row, String field) {
  final value = row[field];
  if (value is! String || value.isEmpty) {
    throw const BackupValidationFailure('备份图片字段无效。');
  }
  return value;
}

bool _sameSet<T>(Set<T> left, Set<T> right) =>
    left.length == right.length && left.containsAll(right);

bool _sameCounts(Map<String, int> left, Map<String, int> right) {
  if (left.length != right.length) return false;
  return left.entries.every((entry) => right[entry.key] == entry.value);
}

void _checkCancelled(BackupCancellationToken? token) =>
    token?.throwIfCancelled();

void _progress(
  BackupProgressCallback? callback,
  BackupStage stage,
  double fraction,
) {
  callback?.call(BackupProgress(stage: stage, fraction: fraction));
}

Future<void> _deleteFilesQuietly(Iterable<File> files) async {
  for (final file in files) {
    await _deleteFileQuietly(file);
  }
}

Future<void> _closeFileQuietly(RandomAccessFile? file) async {
  try {
    await file?.close();
  } on FileSystemException {
    // 失败路径只负责释放句柄，不能覆盖原始错误。
  }
}

Future<void> _deleteFileQuietly(File file) async {
  try {
    if (file.existsSync()) await file.delete();
  } on FileSystemException {
    // 补偿清理会在下次启动的孤儿清理再次覆盖。
  }
}

Future<void> _deleteDirectoryQuietly(Directory directory) async {
  try {
    if (directory.existsSync()) await directory.delete(recursive: true);
  } on FileSystemException {
    // 临时目录尽力清理，不能覆盖原始失败。
  }
}
