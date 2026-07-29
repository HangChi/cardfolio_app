import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../../../../core/errors/app_failure.dart';

/// 受支持的图片媒体类型。扩展名由内容魔数决定，不盲信原始文件名
/// （见 `docs/architecture/image-storage.md` §5）。
enum ImageMediaType {
  jpeg('jpg'),
  png('png'),
  webp('webp'),
  heic('heic');

  const ImageMediaType(this.extension);

  final String extension;
}

/// 一次成功导入的结果。
class ManagedImage {
  const ManagedImage({
    required this.relativePath,
    required this.checksum,
    required this.byteSize,
    required this.mediaType,
  });

  /// 相对于受管根目录的路径，形如 `originals/<cardItemId>/<imageId>.<ext>`。
  final String relativePath;

  /// 源字节的 SHA-256。
  final String checksum;

  final int byteSize;
  final ImageMediaType mediaType;
}

/// App 私有目录中的受管图片存储。
///
/// 目录结构遵循 `docs/architecture/image-storage.md` §2。导入走
/// staging → 校验 → 移动到最终路径，保证 `originals/` 下不出现半写入文件。
class ManagedImageStore {
  ManagedImageStore(this.root);

  /// 受管根目录。数据库只保存相对于它的路径。
  final Directory root;

  static const String _originalsDir = 'originals';
  static const String _derivedDir = 'derived';
  static const String _stagingDir = 'staging';

  /// 单文件大小上限，避免选到超大文件时耗尽内存与磁盘。
  static const int maxByteSize = 64 * 1024 * 1024;

  /// 导入一张图片到受管目录。
  ///
  /// 失败时抛出 [ImageImportFailure]，且不在 `originals/` 留下任何文件。
  Future<ManagedImage> importImage({
    required String sourcePath,
    required String cardItemId,
    required String imageId,
  }) async {
    final source = File(sourcePath);
    if (!source.existsSync()) {
      throw const ImageImportFailure('找不到所选图片，请重新选择。');
    }

    final Uint8List bytes;
    try {
      bytes = await source.readAsBytes();
    } on FileSystemException catch (error) {
      throw ImageImportFailure('这张图片无法读取，请重新选择。', error);
    }

    if (bytes.isEmpty) {
      throw const ImageImportFailure('这张图片是空文件，请重新选择。');
    }
    if (bytes.length > maxByteSize) {
      throw const ImageImportFailure('这张图片太大，请选择更小的图片。');
    }

    final mediaType = _sniffMediaType(bytes);
    if (mediaType == null) {
      throw const ImageImportFailure('只支持 JPG、PNG、WebP 和 HEIC 图片。');
    }

    final relativePath = p.url.join(
      _originalsDir,
      cardItemId,
      '$imageId.${mediaType.extension}',
    );

    // 先写入 staging，校验通过后再移动到最终路径。
    final staged = File(
      p.join(root.path, _stagingDir, imageId, '$imageId.tmp'),
    );
    try {
      await staged.parent.create(recursive: true);
      await staged.writeAsBytes(bytes, flush: true);

      final destination = resolve(relativePath);
      await destination.parent.create(recursive: true);
      await _moveInto(staged, destination);
    } on FileSystemException catch (error) {
      throw ImageImportFailure('保存图片失败，请检查存储空间后重试。', error);
    } finally {
      await _deleteDirectoryQuietly(staged.parent);
    }

    return ManagedImage(
      relativePath: relativePath,
      checksum: sha256.convert(bytes).toString(),
      byteSize: bytes.length,
      mediaType: mediaType,
    );
  }

  /// 导入处理管线生成的展示图。派生图固定为 JPEG，绝不覆盖原图目录。
  Future<ManagedImage> importDerivedImage({
    required String sourcePath,
    required String cardItemId,
    required String imageId,
  }) async {
    final source = File(sourcePath);
    if (!source.existsSync()) {
      throw const ImageImportFailure('找不到派生图，请重新生成。');
    }

    final Uint8List bytes;
    try {
      bytes = await source.readAsBytes();
    } on FileSystemException catch (error) {
      throw ImageImportFailure('派生图无法读取，请重新生成。', error);
    }
    if (bytes.isEmpty || bytes.length > maxByteSize) {
      throw const ImageImportFailure('派生图无效，请重新生成。');
    }
    if (_sniffMediaType(bytes) != ImageMediaType.jpeg) {
      throw const ImageImportFailure('派生图必须为 JPEG，请重新生成。');
    }

    final relativePath = p.url.join(_derivedDir, cardItemId, '$imageId.jpg');
    final staged = File(
      p.join(root.path, _stagingDir, '$imageId-derived', '$imageId.tmp'),
    );
    try {
      await staged.parent.create(recursive: true);
      await staged.writeAsBytes(bytes, flush: true);
      final destination = resolve(relativePath);
      await destination.parent.create(recursive: true);
      await _moveInto(staged, destination);
    } on FileSystemException catch (error) {
      throw ImageImportFailure('保存派生图失败，请检查存储空间后重试。', error);
    } finally {
      await _deleteDirectoryQuietly(staged.parent);
    }

    return ManagedImage(
      relativePath: relativePath,
      checksum: sha256.convert(bytes).toString(),
      byteSize: bytes.length,
      mediaType: ImageMediaType.jpeg,
    );
  }

  /// 把云端同步得到的图片原子发布到原有受管相对路径。
  ///
  /// 只有 `originals/` 与 `derived/` 可写；字节、扩展名和 SHA-256 全部验证后，
  /// 才从 staging 移入最终位置。失败不会留下可见半文件。
  Future<void> writeSyncedImage({
    required String relativePath,
    required Uint8List bytes,
    required String expectedChecksum,
  }) async {
    final segments = p.url.split(relativePath);
    if (segments.length < 3 ||
        !<String>{_originalsDir, _derivedDir}.contains(segments.first)) {
      throw const ImageImportFailure('同步图片路径无效。');
    }
    if (bytes.isEmpty || bytes.length > maxByteSize) {
      throw const ImageImportFailure('同步图片为空或超过大小限制。');
    }
    final actualChecksum = sha256.convert(bytes).toString();
    if (actualChecksum != expectedChecksum) {
      throw const ImageImportFailure('同步图片校验失败，请重试。');
    }
    final mediaType = _sniffMediaType(bytes);
    final extension = p
        .extension(relativePath)
        .replaceFirst('.', '')
        .toLowerCase();
    if (mediaType == null || extension != mediaType.extension) {
      throw const ImageImportFailure('同步图片格式与路径不一致。');
    }

    final destination = resolve(relativePath);
    if (destination.existsSync()) {
      try {
        if (sha256.convert(await destination.readAsBytes()).toString() ==
            expectedChecksum) {
          return;
        }
      } on FileSystemException {
        // 继续走 staging 覆盖损坏的受管副本。
      }
    }

    final staged = File(
      p.join(root.path, _stagingDir, 'sync-$expectedChecksum', 'image.tmp'),
    );
    try {
      await staged.parent.create(recursive: true);
      await staged.writeAsBytes(bytes, flush: true);
      await destination.parent.create(recursive: true);
      await _moveInto(staged, destination);
    } on FileSystemException catch (error) {
      throw ImageImportFailure('同步图片保存失败，请检查存储空间。', error);
    } finally {
      await _deleteDirectoryQuietly(staged.parent);
    }
  }

  /// 把受管相对路径解析为绝对文件。
  ///
  /// 路径逃逸或绝对路径一律抛出 [ImageImportFailure]，绝不接受任意路径
  /// （见 `docs/architecture/image-storage.md` §5）。
  File resolve(String relativePath) {
    if (relativePath.trim().isEmpty) {
      throw const ImageImportFailure('图片路径无效。');
    }
    if (p.isAbsolute(relativePath)) {
      throw const ImageImportFailure('图片路径无效。');
    }

    final rootPath = p.normalize(root.absolute.path);
    final candidate = p.normalize(p.join(rootPath, relativePath));

    if (!p.isWithin(rootPath, candidate)) {
      throw const ImageImportFailure('图片路径无效。');
    }

    return File(candidate);
  }

  /// 删除一个受管文件。文件不存在视为成功。
  Future<void> delete(String relativePath) async {
    final file = resolve(relativePath);
    if (!file.existsSync()) return;

    try {
      await file.delete();
    } on FileSystemException catch (error) {
      throw ImageImportFailure('删除图片失败，请重试。', error);
    }
  }

  /// 删除未被数据库引用的受管文件，并清空 staging。
  ///
  /// [referencedPaths] 必须包含软删除卡片的图片：回收站中的卡片恢复后仍需要它们。
  Future<void> removeOrphans(Set<String> referencedPaths) async {
    if (!root.existsSync()) return;

    final rootPath = p.normalize(root.absolute.path);

    for (final directoryName in <String>[_originalsDir, _derivedDir]) {
      final managedDirectory = Directory(p.join(rootPath, directoryName));
      if (!managedDirectory.existsSync()) continue;
      await for (final entity in managedDirectory.list(recursive: true)) {
        if (entity is! File) continue;
        final relative = p.url.joinAll(
          p.split(p.relative(entity.path, from: rootPath)),
        );
        if (referencedPaths.contains(relative)) continue;
        await _deleteFileQuietly(entity);
      }
    }

    // staging 里的一切都属于未完成的操作，重启后一律丢弃。
    await _deleteDirectoryQuietly(Directory(p.join(rootPath, _stagingDir)));
  }

  /// 跨卷 rename 会失败，退回复制加删除。
  Future<void> _moveInto(File source, File destination) async {
    try {
      await source.rename(destination.path);
    } on FileSystemException {
      await source.copy(destination.path);
      await source.delete();
    }
  }

  Future<void> _deleteFileQuietly(File file) async {
    try {
      if (file.existsSync()) await file.delete();
    } on FileSystemException {
      // 清理失败不阻断启动；下次启动会重试。
    }
  }

  Future<void> _deleteDirectoryQuietly(Directory directory) async {
    try {
      if (directory.existsSync()) await directory.delete(recursive: true);
    } on FileSystemException {
      // 同上：清理是尽力而为的后台维护。
    }
  }

  static ImageMediaType? _sniffMediaType(Uint8List bytes) {
    bool startsWith(List<int> magic, {int offset = 0}) {
      if (bytes.length < offset + magic.length) return false;
      for (var i = 0; i < magic.length; i++) {
        if (bytes[offset + i] != magic[i]) return false;
      }
      return true;
    }

    if (startsWith(<int>[0xFF, 0xD8, 0xFF])) return ImageMediaType.jpeg;
    if (startsWith(<int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
      return ImageMediaType.png;
    }
    if (startsWith('RIFF'.codeUnits) &&
        startsWith('WEBP'.codeUnits, offset: 8)) {
      return ImageMediaType.webp;
    }
    // ISO-BMFF：`ftyp` 位于第 4 字节，后跟 brand。
    if (startsWith('ftyp'.codeUnits, offset: 4)) {
      const List<String> heifBrands = <String>[
        'heic',
        'heix',
        'heim',
        'heis',
        'hevc',
        'hevx',
        'mif1',
        'msf1',
      ];
      final brand = String.fromCharCodes(bytes.sublist(8, 12));
      if (heifBrands.contains(brand)) return ImageMediaType.heic;
    }

    return null;
  }
}
