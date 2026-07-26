import 'package:uuid/uuid.dart';

/// ID 生成抽象。所有实体 ID 在本地生成，便于离线创建与测试注入固定序列
/// （见 ADR-006）。
abstract interface class IdGenerator {
  String newId();
}

/// 生产实现：UUID v4。
final class UuidGenerator implements IdGenerator {
  const UuidGenerator([this._uuid = const Uuid()]);

  final Uuid _uuid;

  @override
  String newId() => _uuid.v4();
}
