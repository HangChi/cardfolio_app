# 迁移到 macOS 运行指南

本文档说明如何在另一台 macOS 电脑上解压本仓库压缩包并运行「卡迹 Cardfolio」。

## 前提

- 压缩包：`cardfolio_app-macos-full.zip`（含完整 git 历史与全部源码）
- 目标环境：macOS

## 1. 解压

双击 `cardfolio_app-macos-full.zip` 解压（macOS 归档工具能正确识别中文文件名），
然后进入目录：

```bash
cd cardfolio_app
```

> 若使用第三方解压工具导致中文文件名乱码，改用系统命令重新解压：
>
> ```bash
> ditto -x -k cardfolio_app-macos-full.zip .
> ```

解压后即为完整 git 仓库，可先确认提交历史完好：

```bash
git log --oneline
```

## 2. 环境准备（一次性）

项目要求 **Flutter 3.44.0 / Dart 3.12+**。macOS 桌面端与 iOS 模拟器都需要 **Xcode**：

```bash
# 1. 从 App Store 安装 Xcode，然后装命令行工具并接受许可
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept

# 2. 安装 Flutter 3.44.0（官网下载，或使用 fvm 固定版本）
flutter --version   # 确认版本为 3.44.0，Dart 3.12+
flutter doctor      # 确认 Xcode 一项打勾
```

> 只跑 macOS 桌面版或 iOS 模拟器**不需要** JDK 21 和 Android SDK；
> 这两项仅在构建 Android 时需要。

## 3. 拉依赖 + 生成代码 + 运行

在项目根目录依次执行：

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d macos
```

`build_runner` 用于生成 Drift 数据库代码，**必须执行**。生成的 `.g.dart` 文件
虽已提交在仓库中，但换机器后仍建议重跑一次以保持一致。

跑 iPhone 模拟器（本应用面向手机，使用底部导航）：

```bash
flutter devices        # 列出可用设备
flutter run -d ios
```

## 4. 可选服务配置

不注入服务地址时，应用保持**纯本地模式**，可直接使用。以下为可选能力，
仅在需要时通过 `--dart-define` 注入：

```bash
# 测试/生产同步服务
flutter run -d macos --dart-define=CARD_FOLIO_API_BASE_URL=https://sync.example.com

# 远程交通卡资料库
flutter run -d macos --dart-define=CARD_FOLIO_CATALOG_BASE_URL=https://catalog.example.com
```

## 5. 注意事项

- **macOS 平台尚未完整验收**：`macos/` 目录已配置好 entitlements（Keychain/网络
  权限），但 `image_picker`、`image_cropper` 等依赖在 macOS 桌面端的行为与手机端
  可能存在差异，首次运行时留意拍照、相册、裁剪相关功能。
- 数据（数据库 + 图片）保存在平台应用支持目录下，卸载或删除应用会一并清除。
- 完整开发流程、质量门禁与已知问题见 [README.md](README.md)、
  [docs/engineering-baseline.md](docs/engineering-baseline.md) 与
  [docs/known-issues.md](docs/known-issues.md)。
