# 工程基线

状态：Flutter 完整基线最近于 2026-08-09 验证；2026-08-29 服务端门禁已补充

仓库固定使用 Flutter 3.44.0、Dart 3.12.0 和 CI JDK 21。Pull Request 与推送到
`main` 必须通过 [.github/workflows/ci.yml](../.github/workflows/ci.yml) 中的质量门禁。

## 本地等价命令

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --fatal-infos --fatal-warnings
flutter test test/drift/app/migration_test.dart test/features/cards/data/card_database_migration_test.dart
flutter test --concurrency=1
flutter build apk --debug
```

默认并发的 `flutter test` 也应在重要基线修复后补跑，用于发现测试间共享状态和时序污染。

## 数据库门禁

数据库模式变更必须：

1. 在 `drift_schemas/app/` 新增对应版本快照；
2. 重新生成 `test/drift/app/generated/` 迁移夹具；
3. 验证每个旧版本到当前版本的分步升级；
4. 保持旧快照只读，不能把旧快照修改成新版本状态。

当前数据库版本为 schema v9，支持从 v1–v8 分步迁移到 v9。

## 最近验证证据

2026-08-09，提交 `dce53c1` 对应的工作树通过：

- Drift 迁移专项：42/42；
- 全量测试：410/410，串行与默认并发均通过；
- 严格静态分析：0 问题；
- 格式检查：198 个文件，0 处漂移；
- Android debug APK：构建成功。

OCR 不在上述宿主机质量门禁的可用性结论内，当前状态见[已知问题](known-issues.md)。

2026-08-29，当前工作树的 Node.js 24 同步网关通过：

- 网关、超时、账号删除顺序与迁移静态守卫：17/17；
- `node --check`：通过；
- 当前 CI 已加入服务端测试、语法检查、迁移守卫和 Docker 构建；
- 本次记录环境没有 Flutter/Dart 命令，因此不能把 2026-08-09 的 Flutter 结果写成当前
  HEAD 复验结果；合并前仍须由 CI 完成 Flutter 全门禁。
