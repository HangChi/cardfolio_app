# 开发指南

## 1. 环境

- Flutter 固定为 3.44.0、Dart 最低为 3.12.0，CI 使用 JDK 21；升级必须独立提交并记录迁移影响。
- Android 是首轮验收平台，生产 Dart 代码和插件配置保持 iOS 兼容。
- 推荐 Android Studio 或 VS Code，启用 Dart 格式化和静态分析。

首次准备：

```powershell
flutter doctor
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

日常验证：

```powershell
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --fatal-infos --fatal-warnings
flutter test test/drift/app/migration_test.dart test/features/cards/data/card_database_migration_test.dart
flutter test --concurrency=1
flutter build apk --debug
```

## 2. 目录约定

```text
lib/
  app/                 应用启动、路由、主题和主导航
  core/                无业务归属的稳定基础能力
  features/<feature>/
    domain/            实体、值对象、仓储接口和业务规则
    data/              数据库、文件、平台适配和仓储实现
    presentation/      页面、组件和状态控制器
```

依赖方向为 `presentation -> domain <- data`。领域层不得依赖 Flutter、Drift、平台插件或文件系统。

## 3. 开发流程

1. 确认 Feature 的 Definition of Ready 已满足。
2. 从 `codex/` 前缀创建短生命周期分支。
3. 先写失败测试，再写最小实现，通过后重构。
4. 每完成一个可验证行为运行目标测试。
5. 合并前运行格式、分析、全量测试和对应平台验收。
6. 更新 Feature 文档、追踪矩阵和发布说明。

## 4. 数据库变更

- 永不编辑已经发布的 schema 快照。
- 每次迁移包含新版本快照、生成夹具、升级逻辑、从所有旧版本分步升级的迁移测试和
  回滚/恢复说明。
- 数据库打开失败不得自动删库重建。
- 任何写入多个聚合表的操作使用事务。
- 文件与数据库跨资源写入需实现补偿和启动清理。

## 5. 依赖管理

- 添加依赖前记录用途、替代方案、维护状态、许可证和平台支持。
- 不为单个简单工具函数引入第三方包。
- 锁文件纳入版本控制。
- 主版本升级单独评审，不与业务功能混在同一提交。

## 6. 完成定义

- 验收标准有自动化测试或明确的人工验收记录。
- 无分析警告、格式差异和未处理异常路径。
- 新增公开契约有文档，数据变更有迁移验证。
- 权限、隐私和可访问性影响已检查。
- 范围外能力未混入生产路径。
