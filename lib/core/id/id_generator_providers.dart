import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'id_generator.dart';

/// 放在 core 层：core/preferences 的本地应用状态与建卡等 feature 都依赖它，
/// 定义在 feature 的 data 层会造成 core 反向依赖 features。
final Provider<IdGenerator> idGeneratorProvider = Provider<IdGenerator>(
  (ref) => const UuidGenerator(),
);
