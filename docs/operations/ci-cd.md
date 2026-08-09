# CI/CD 基线

状态：CI 质量门禁已实现；制品归档、签名和发布流水线尚未实现
更新日期：2026-08-09

## 1. 当前已实现的工作流

工作流位于 [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml)，在 Pull Request 和
推送到 `main` 时运行。环境固定为 Ubuntu、Flutter 3.44.0 和 Java 21，权限只有
`contents: read`。

当前单个 `verify` Job 按顺序执行：

1. 检出仓库；
2. 安装 Flutter 并使用依赖缓存；
3. `flutter pub get`；
4. `dart format --output=none --set-exit-if-changed lib test integration_test`；
5. `flutter analyze --fatal-infos --fatal-warnings`；
6. 执行 Drift 迁移专项，覆盖 v1–v8 到 schema v9；
7. `flutter test --concurrency=1`；
8. `flutter build apk --debug`。

任一步失败都会使工作流失败。相同分支的新运行会取消旧运行，避免重复占用资源。

## 2. 本地等价门禁

开发者在提交前应运行[工程基线](../engineering-baseline.md)中的同等命令。涉及生成代码或
数据库模式时，还需先执行：

```powershell
dart run build_runner build --delete-conflicting-outputs
git diff --check
```

生成代码与源文件必须进入同一提交。当前 CI 不会自动重新生成代码并检查工作区差异，
因此不能把本地生成步骤写成已经由 CI 覆盖。

## 3. 尚未实现的增强

以下内容是后续工程目标，不属于当前 CI 能力：

- 在干净工作区重新生成代码并检查无差异；
- 上传机器可读测试报告、覆盖率、APK、依赖清单和 SHA-256；
- 依赖安全与许可证检查；
- 把第三方 Action 从版本标签固定到不可变提交 SHA；
- 生成带构建号的内部测试包；
- 正式签名、人工批准、受保护标签和分阶段商店发布；
- 自动生成发布说明和变更记录。

这些增强实现前，发布流程仍需人工执行对应检查，不得在其他文档中标记为“已建立”。

## 4. 供应链原则

- 锁文件必须提交。
- 自动依赖更新只创建 PR，不自动合并主版本升级。
- 密钥和签名材料只能进入受保护的发布系统，不能写入仓库或日志。
- 第三方 Action 与 Flutter 版本升级必须独立评审并执行完整门禁。
