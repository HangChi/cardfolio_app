/// 数据层之上唯一允许出现的失败类型。
///
/// [userMessage] 是可直接展示的安全文案，不得包含 SQL、堆栈、绝对路径或内部异常
/// （见 `docs/features/001-local-card-creation/error-cases.md`）。[cause] 仅用于测试
/// 与脱敏诊断，禁止直接渲染。
sealed class AppFailure implements Exception {
  const AppFailure(this.userMessage, [this.cause]);

  final String userMessage;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $userMessage';
}

/// 可被校验的表单字段，供页面把焦点移到首个错误字段。
enum CardField { name, city, issuer, issuedAt, code, notes, quantity, image }

/// 输入不满足业务约束。不产生任何写入。
final class ValidationFailure extends AppFailure {
  const ValidationFailure(this.field, super.userMessage, [super.cause]);

  final CardField field;
}

/// 套卡表单与关系操作可定位的字段。
enum CardSetField { name, expectedCount, issueInfo, notes, member, cover }

/// 套卡输入或成员关系不满足业务约束。
final class CardSetValidationFailure extends AppFailure {
  const CardSetValidationFailure(this.field, super.userMessage, [super.cause]);

  final CardSetField field;
}

/// 标签、系列、自定义字段与收藏筛选可定位的输入范围。
enum OrganizationField { name, tag, series, customField, value, filter, target }

/// 整理输入、关系或查询条件不满足业务约束。
final class OrganizationValidationFailure extends AppFailure {
  const OrganizationValidationFailure(
    this.field,
    super.userMessage, [
    super.cause,
  ]);

  final OrganizationField field;
}

/// 购买账本、金额、分摊和调整可定位的输入范围。
enum PurchaseField {
  amount,
  currency,
  date,
  channel,
  seller,
  notes,
  target,
  allocation,
  adjustment,
  exchangeRate,
}

/// 购买输入、关系或金额口径不满足业务约束。
final class PurchaseValidationFailure extends AppFailure {
  const PurchaseValidationFailure(this.field, super.userMessage, [super.cause]);

  final PurchaseField field;
}

/// 回收站设置与状态操作可定位的输入范围。
enum RecycleBinField { card, retention }

/// 回收站操作不满足状态或保留期约束。
final class RecycleBinValidationFailure extends AppFailure {
  const RecycleBinValidationFailure(
    this.field,
    super.userMessage, [
    super.cause,
  ]);

  final RecycleBinField field;
}

/// 相册选择器不可用、权限被拒绝或返回了无法使用的结果。
final class GalleryAccessFailure extends AppFailure {
  const GalleryAccessFailure([
    super.userMessage = '无法访问相册，请检查权限后重试。',
    super.cause,
  ]);
}

/// 源图片不可读、格式不支持或复制到受管目录失败。
final class ImageImportFailure extends AppFailure {
  const ImageImportFailure([
    super.userMessage = '这张图片无法导入，请重新选择。',
    super.cause,
  ]);
}

/// 数据库写入失败。事务已回滚，本次复制的文件已被补偿删除。
final class PersistenceFailure extends AppFailure {
  const PersistenceFailure([super.userMessage = '保存失败，请重试。', super.cause]);
}

/// 数据库无法打开或迁移失败。绝不静默重建或删除既有数据。
final class DatabaseUnavailableFailure extends AppFailure {
  const DatabaseUnavailableFailure([
    super.userMessage = '收藏库暂时无法打开，请重试。',
    super.cause,
  ]);
}
