# 卡迹 Cardfolio

卡迹是一个本地优先的交通卡收藏管理应用。当前 Feature 001 提供 Android-first
的单图建卡闭环：从系统相册选择图片、填写卡片资料、保存到本地收藏库，并在应用
重启后恢复卡片与图片。

## 当前范围

- 五入口应用壳：首页、收藏、拍摄、统计、我的。
- 收藏列表、空状态和卡片详情。
- 从系统相册导入一张图片。
- 名称必填，城市、发行机构、发行时间、编号和备注可选。
- Drift/SQLite 本地持久化与 App 私有图片存储。
- 保存幂等、事务失败补偿、启动孤儿图片清理。
- 数据库启动失败时保留原文件并提供“重试”。

相机拍摄、裁切增强、多图、套卡、标签、购买记录、统计、导入导出、账号与同步
尚未开放。

## 本地开发

需要已配置 Flutter SDK 和 Android SDK。在项目根目录依次运行：

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run
```

运行持久化集成测试时，请指定一个已连接设备：

```powershell
flutter devices
flutter test -d <device-id> integration_test/card_persistence_test.dart
```

构建 Android debug APK：

```powershell
flutter build apk --debug
```

## 验收平台

首轮验收目标是 Android 模拟器或真机。核心路径包括：

1. 空收藏启动；
2. 取消一次系统相册选择，确认没有生成卡片；
3. 选择有效图片；
4. 验证空名称提示；
5. 快速点击两次保存，确认只创建一张卡；
6. 强制停止并重启应用；
7. 确认收藏列表、详情和图片仍可访问。

生产 Dart 代码和插件配置保持 iOS 兼容；macOS/iOS 构建与真机验证需在 macOS
环境补充。

## 数据位置与安全

数据库和图片保存在平台提供的应用支持目录下。数据库仅记录受管图片的相对路径，
不会依赖系统相册中的原文件持续存在。数据库打开失败时应用不会自动删除或重建
现有数据。

更完整的产品、架构与测试资料见 [docs/README.md](docs/README.md)。
