# 卡迹 Cardfolio

<p align="center">
  <img src="docs/design/brand/app_icon_master.png" alt="卡迹应用图标" width="112" />
</p>

卡迹是一款本地优先的交通卡收藏管理应用。它以 Drift/SQLite 和 App 私有图片目录为
唯一的本地事实来源；没有账号、没有网络或没有配置同步服务时，建卡、整理、统计、
备份与恢复仍可完整使用。

## 已实现能力

- 首页、收藏、拍摄、统计、我的五入口；手机使用底部导航，宽屏使用侧边导航。
- 亮色/暗色主题、首次启动三屏引导、主题与诊断设置持久化、Android 双击返回退出。
- 新建与编辑卡片，支持名称、城市、机构、发行日期、编号、备注、数量、品相、发行量、
  发售价、入手日期、标签、自定义字段、套卡和集卡册归属。
- 新建卡片时名称与城市必填；已有卡片可继续补充资料。中国城市使用省/市/县区选择，
  县区可省略，国外地址可手动填写。
- 系统相机和相册导入、单卡最多 20 张图片、正反面/包装/编号/细节等用途、排序与封面。
- 拍照后直接进入资料页；用户主动编辑图片时再使用系统相册式裁剪、缩放和旋转，并可
  调整亮度、对比度和清晰度。原图保持不变，编辑结果单独保存。
- 已接入卡面 OCR 平台桥接、资料候选确认和内置/远程资料库接口；当前 OCR 运行时仍不可用，
  需完成诊断与 Android/iOS 真机验收后才能作为交付能力使用。
- 多卡批量录入、共享资料、草稿中断恢复、逐张确认，以及自动关联套卡和集卡册。
- 套卡成员、整套张数、封面、已拥有/缺失/重复张数和完成度；集卡册可同时收纳卡片与套卡。
- 标签、自定义字段、全文搜索、组合筛选、重复卡/待完善/本月入手筛选和稳定排序。
- 卡片录入与编辑内直接维护人民币“卡片金额 + 运费”；首页展示全时期活跃收藏净消费。
- 首页收藏摘要、最近录入、即将集齐、待补资料；六维数量分布、消费趋势、消费日历与下钻。
- 卡片软删除、恢复、永久删除、7/30/90 天保留期、级联可见性和持久文件清理队列。
- 版本化 ZIP 完整备份、校验、空库恢复、仅新增合并，以及 UTF-8 BOM CSV 导出。
- 可选邮箱账号和本地优先同步：安全会话、持久 outbox、增量游标、附件校验、重试与冲突副本。
- 数据库启动失败时保留原文件并提供重试；启动时重放清理队列并删除未引用图片。

未注入服务地址时 App 保持纯本地模式。测试/生产同步服务通过 HTTPS 地址注入：

```powershell
flutter run --dart-define=CARD_FOLIO_API_BASE_URL=https://sync.example.com
```

远程交通卡资料库是可选能力：

```powershell
flutter run --dart-define=CARD_FOLIO_CATALOG_BASE_URL=https://catalog.example.com
```

## 本地开发

需要 Flutter 3.44.0、Dart 3.12+、JDK 21 和 Android SDK。Windows 使用 Flutter 插件时需先开启
开发者模式以允许创建符号链接。在项目根目录依次运行：

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --fatal-infos --fatal-warnings
flutter test test/drift/app/migration_test.dart test/features/cards/data/card_database_migration_test.dart
flutter test --concurrency=1
flutter build apk --debug
flutter run
```

> [!NOTE]
> Android Studio 应打开项目根目录，而不是只打开 `android/`。JDK 21 可用于运行 Gradle，
> Android Java/Kotlin 字节码目标仍统一为 17。

运行持久化集成测试时，请指定一个已连接设备：

```powershell
flutter devices
flutter test -d <device-id> integration_test/card_persistence_test.dart
```

构建 Android debug APK：

```powershell
flutter build apk --debug
```

输出文件位于 `build/app/outputs/flutter-apk/app-debug.apk`。Release APK 对应
`build/app/outputs/flutter-apk/app-release.apk`。

完整质量门禁和最近一次验证结果见[工程基线](docs/engineering-baseline.md)；当前限制见
[已知问题](docs/known-issues.md)。

## 验收平台

首轮验收目标是 Android 模拟器或真机。核心路径包括：

1. 首次启动三屏引导、首页和亮暗主题；
2. 取消系统相册/相机，确认不生成卡片；
3. 录入名称、城市、数量、正反面和成本，连续点击保存仍只生成一张卡；
4. 编辑图片，验证裁剪、旋转、亮度/对比度以及原图保留；
5. 批量录入多张卡，验证草稿恢复、标签、套卡和集卡册归属；
6. 强制停止并重启，确认卡片、关联、成本、图片和主题仍存在；
7. 删除并恢复卡片，核对集卡册、统计和消费金额随活跃状态变化；
8. 导出 ZIP 后在空库恢复，再导出 CSV 检查中文与特殊字符；
9. 在 360/393/430dp、200% 字体及 TalkBack/VoiceOver 下完成核心流程。

生产 Dart 代码和插件配置保持 iOS 兼容；macOS/iOS 构建与真机验证需在 macOS
环境补充。

## 数据位置与安全

数据库和图片保存在平台提供的应用支持目录下。数据库仅记录受管图片的相对路径，
不会依赖系统相册中的原文件持续存在。数据库打开失败时应用不会自动删除或重建
现有数据。

更完整的产品、架构与测试资料见 [docs/README.md](docs/README.md)。
