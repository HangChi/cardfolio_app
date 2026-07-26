import 'package:meta/meta.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/id/id_generator.dart';

/// 发行时间的精度。收藏者常常只记得年份或年月。
enum DatePrecision { year, yearMonth, day }

/// 支持 `YYYY`、`YYYY-MM`、`YYYY-MM-DD` 三种精度的部分日期。
@immutable
final class PartialDate {
  const PartialDate._(this.year, this.month, this.day, this.precision);

  final int year;
  final int? month;
  final int? day;
  final DatePrecision precision;

  static final RegExp _pattern = RegExp(r'^(\d{4})(?:-(\d{2})(?:-(\d{2}))?)?$');

  /// 解析部分日期；格式非法或日期不存在时返回 null。
  static PartialDate? tryParse(String? raw) {
    final text = raw?.trim() ?? '';
    final match = _pattern.firstMatch(text);
    if (match == null) return null;

    final year = int.parse(match.group(1)!);
    final monthText = match.group(2);
    final dayText = match.group(3);

    if (monthText == null) {
      return PartialDate._(year, null, null, DatePrecision.year);
    }

    final month = int.parse(monthText);
    if (month < 1 || month > 12) return null;

    if (dayText == null) {
      return PartialDate._(year, month, null, DatePrecision.yearMonth);
    }

    final day = int.parse(dayText);
    if (day < 1 || day > _daysInMonth(year, month)) return null;

    return PartialDate._(year, month, day, DatePrecision.day);
  }

  static int _daysInMonth(int year, int month) {
    // 下个月的第 0 天即本月最后一天。
    return DateTime.utc(year, month + 1, 0).day;
  }

  /// 以原精度回写 ISO 文本，用于持久化与展示。
  String toIsoString() {
    final yearText = year.toString().padLeft(4, '0');
    return switch (precision) {
      DatePrecision.year => yearText,
      DatePrecision.yearMonth =>
        '$yearText-${month!.toString().padLeft(2, '0')}',
      DatePrecision.day =>
        '$yearText-${month!.toString().padLeft(2, '0')}'
            '-${day!.toString().padLeft(2, '0')}',
    };
  }

  @override
  String toString() => toIsoString();

  @override
  bool operator ==(Object other) =>
      other is PartialDate &&
      other.year == year &&
      other.month == month &&
      other.day == day &&
      other.precision == precision;

  @override
  int get hashCode => Object.hash(year, month, day, precision);
}

/// 一次建卡草稿预先生成的三个实体 ID。
///
/// [cardItemId] 同时是创建操作的幂等键：相同草稿重复提交返回既有藏品，
/// 不复制第二份图片，也不插入第二组数据。
@immutable
final class CardDraftIds {
  const CardDraftIds({
    required this.definitionId,
    required this.cardItemId,
    required this.imageId,
  });

  factory CardDraftIds.create(IdGenerator generator) {
    return CardDraftIds(
      definitionId: generator.newId(),
      cardItemId: generator.newId(),
      imageId: generator.newId(),
    );
  }

  final String definitionId;
  final String cardItemId;
  final String imageId;

  @override
  bool operator ==(Object other) =>
      other is CardDraftIds &&
      other.definitionId == definitionId &&
      other.cardItemId == cardItemId &&
      other.imageId == imageId;

  @override
  int get hashCode => Object.hash(definitionId, cardItemId, imageId);
}

/// 图片用途。Feature 001 只产生正面图。
enum CardImageKind { front, back }

/// 相册中被选中的一张图片。领域层只持有路径，不暴露 `XFile`。
@immutable
final class SelectedGalleryImage {
  const SelectedGalleryImage({required this.path, this.displayName});

  final String path;
  final String? displayName;

  @override
  bool operator ==(Object other) =>
      other is SelectedGalleryImage &&
      other.path == path &&
      other.displayName == displayName;

  @override
  int get hashCode => Object.hash(path, displayName);
}

/// 建卡请求。持久化前必须调用 [normalized]。
@immutable
final class CreateCardRequest {
  const CreateCardRequest({
    required this.ids,
    required this.sourceImagePath,
    required this.name,
    this.city,
    this.issuer,
    this.issuedAt,
    this.code,
    this.notes,
    this.quantity = 1,
    this.isNormalized = false,
  });

  static const int maxNameLength = 100;
  static const int maxShortTextLength = 100;
  static const int maxNotesLength = 1000;

  final CardDraftIds ids;
  final String sourceImagePath;
  final String name;
  final String? city;
  final String? issuer;
  final PartialDate? issuedAt;
  final String? code;
  final String? notes;
  final int quantity;

  /// 标记该实例是否已通过 [normalized]，使规范化幂等。
  final bool isNormalized;

  /// 去空白、空串转 null 并校验业务约束。
  ///
  /// 违反约束时抛出 [ValidationFailure]，携带出错字段供页面聚焦。
  CreateCardRequest normalized() {
    if (isNormalized) return this;

    if (sourceImagePath.trim().isEmpty) {
      throw const ValidationFailure(CardField.image, '请先选择一张卡片图片。');
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const ValidationFailure(CardField.name, '名称不能为空');
    }
    if (trimmedName.length > maxNameLength) {
      throw const ValidationFailure(CardField.name, '名称最多 $maxNameLength 个字符。');
    }

    if (quantity <= 0) {
      throw const ValidationFailure(CardField.quantity, '数量必须大于 0。');
    }

    return CreateCardRequest(
      ids: ids,
      sourceImagePath: sourceImagePath.trim(),
      name: trimmedName,
      city: _optional(city, CardField.city, maxShortTextLength),
      issuer: _optional(issuer, CardField.issuer, maxShortTextLength),
      issuedAt: issuedAt,
      code: _optional(code, CardField.code, maxShortTextLength),
      notes: _optional(notes, CardField.notes, maxNotesLength),
      quantity: quantity,
      isNormalized: true,
    );
  }

  static String? _optional(String? value, CardField field, int maxLength) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    if (trimmed.length > maxLength) {
      throw ValidationFailure(field, '内容最多 $maxLength 个字符。');
    }
    return trimmed;
  }

  @override
  bool operator ==(Object other) =>
      other is CreateCardRequest &&
      other.ids == ids &&
      other.sourceImagePath == sourceImagePath &&
      other.name == name &&
      other.city == city &&
      other.issuer == issuer &&
      other.issuedAt == issuedAt &&
      other.code == code &&
      other.notes == notes &&
      other.quantity == quantity &&
      other.isNormalized == isNormalized;

  @override
  int get hashCode => Object.hash(
    ids,
    sourceImagePath,
    name,
    city,
    issuer,
    issuedAt,
    code,
    notes,
    quantity,
    isNormalized,
  );
}

/// 收藏列表用只读摘要。
@immutable
final class CardSummary {
  const CardSummary({
    required this.cardItemId,
    required this.name,
    required this.quantity,
    required this.createdAt,
    this.coverRelativePath,
    this.city,
    this.issuedAt,
  });

  final String cardItemId;
  final String name;
  final int quantity;
  final DateTime createdAt;
  final String? coverRelativePath;
  final String? city;
  final PartialDate? issuedAt;
}

/// 卡片详情页用只读快照。
@immutable
final class CardDetail {
  const CardDetail({
    required this.cardItemId,
    required this.definitionId,
    required this.name,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    required this.images,
    this.city,
    this.issuer,
    this.issuedAt,
    this.code,
    this.notes,
  });

  final String cardItemId;
  final String definitionId;
  final String name;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// 按 `sortOrder` 升序，首项为封面。
  final List<CardImageRef> images;

  final String? city;
  final String? issuer;
  final PartialDate? issuedAt;
  final String? code;
  final String? notes;

  CardImageRef? get cover => images.isEmpty ? null : images.first;
}

/// 详情中的一张受管图片引用。只暴露相对路径，绝不暴露绝对路径。
@immutable
final class CardImageRef {
  const CardImageRef({
    required this.id,
    required this.relativePath,
    required this.kind,
    required this.sortOrder,
  });

  final String id;
  final String relativePath;
  final CardImageKind kind;
  final int sortOrder;
}
