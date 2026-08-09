# Feature 009：相机与图片处理

状态：实现完成，自动化通过，待设备验收

> 本 Feature 只覆盖相机与图片处理。OCR 是后续跨 Feature 增强：平台桥接和确认 UI 已存在，
> 但当前运行时不可用，不属于本页“实现完成/自动化通过”的结论。见
> [已知问题](../../known-issues.md)。

文档导航：

- [规格](spec.md)
- [验收](acceptance.md)
- [契约](contracts.md)
- [数据模型与文件布局](data-model.md)
- [UX 映射](ux-mapping.md)
- [错误场景](error-cases.md)
- [测试矩阵](test-matrix.md)
- [实施计划](plan.md)
- [任务清单](tasks.md)

## 目标

验证并产品化单卡多图逐张拍摄、主动相册式裁剪、旋转和基础增强，同时保留原图。

## 范围

- 相机逐张拍摄，并可在单卡编辑流程中继续添加多张；
- Android/iOS 原生裁剪器中的移动、缩放与旋转；
- 亮度、对比度、清晰度；
- 调整撤销、重置与派生图；
- 原像素尺寸处理，不做固定长边高清输出。

## 追踪

- FR-IMG-002..005、FR-IMG-007；
- BR-IMG-001..003；
- NFR-PERF、NFR-DATA、NFR-PLAT；
- Figma 节点 `3:137`、`3:181`。

## Spike 结论

采用 `image_picker` 的系统相机入口、`image_cropper` 的平台裁剪界面和纯 Dart `image` 调整管线。该组合不上传图片，
裁剪操作符合 Android/iOS 平台习惯，并以 isolate 避免在 UI isolate 解码
和处理 12MP 图片。真机的权限、HEIC、性能和进程恢复仍是发布门禁。

- `image_picker` 1.2.3：Flutter 官方维护，Apache-2.0/BSD-3-Clause；
- `image` 4.9.1：跨平台纯 Dart，MIT，支持 EXIF 方向、透视矫正和基础增强；
- HEIC 可由平台采集，但纯 Dart 管线不承诺解码，无法处理时保留原图并给出可恢复提示；
- 拍摄后不强制裁剪，用户从资料页图片操作中主动进入裁剪；
- 派生图统一为 JPEG，原图字节永不被覆盖。

## 风险

设备差异、内存崩溃、处理不可逆、草稿丢失、模型许可和效果承诺过高。

## Definition of Done

九件套、相机适配器、单卡多图追加、编辑状态机、处理管线、原图/派生图持久化、
权限声明、接口/单元/Widget 自动化和静态分析完成。模拟器与真机验收只列步骤，
不在自动化执行中启动设备。
