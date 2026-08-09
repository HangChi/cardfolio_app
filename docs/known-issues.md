# 已知问题

更新日期：2026-08-09

本页只记录已确认存在、会影响当前开发或验收判断的问题。发布级隐私、设备矩阵、性能、
签名和商店材料由各自 P2 文档管理，不在本页重复。

## OCR 当前不可用

状态：待诊断，不能作为已交付能力

- Android ML Kit 中文识别、iOS Vision、Flutter MethodChannel、候选解析和逐项确认 UI 已有实现。
- 当前实际运行中 OCR 无法使用；现有自动化只覆盖 Dart 契约和 MethodChannel 调用，不等于
  Android/iOS 原生识别链路可用。
- 在完成错误复现、原生日志核对、真实图片样本和 Android/iOS 真机验收前，README、路线图
  和 Feature 索引不得写成“可用”或“自动化通过”。
- 核心建卡不依赖 OCR；用户仍可手动填写资料或使用资料库候选。

关闭条件：记录根因与修复、增加可复现回归测试，并在至少一台 Android 真机和一台 iOS
真机上验证中文卡面、无文字卡面、模糊图片和失败提示。

## Flutter Built-in Kotlin 兼容预告

状态：非阻塞技术债

Flutter 3.44.0 构建会提示 `file_picker` 与 `share_plus` 当前仍应用 Kotlin Gradle Plugin。
本轮 Android debug APK 构建成功，但未来 Flutter 版本可能把该提示提升为错误。处理时应优先
升级到支持 Built-in Kotlin 的插件版本，并重新执行完整 Android 构建与文件选择/分享验收。
