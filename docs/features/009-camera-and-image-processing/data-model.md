# Feature 009 数据模型与文件布局

## 值对象

```text
NormalizedPoint(x: double, y: double)  // 各自 0..1
ImageCorners(topLeft, topRight, bottomRight, bottomLeft)
ImageAdjustments(brightness, contrast, sharpness)
ImageTemplate(original, standardCard, squareLight, squareDark)
ImageEditSettings(corners, quarterTurns, adjustments, template)
EdgeDetectionResult(corners, confidence, requiresManualAdjustment)
```

默认四角为 `(0.04,0.04)`、`(0.96,0.04)`、`(0.96,0.96)`、`(0.04,0.96)`。
标准卡片比例为 `85.60 / 53.98`，方形模板使用白色或近黑背景。

## 草稿

```text
DraftCardImage
  id
  selection.path            // 原图临时绝对路径
  derivedSourcePath?        // 派生图临时绝对路径
  kind
```

绝对路径不进入数据库、日志或用户文案。

## 受管文件

```text
images/
├── originals/<cardItemId>/<imageId>.<source-ext>
├── derived/<cardItemId>/<imageId>.jpg
└── staging/<operationId>/...
```

现有 `card_images.derived_relative_path` 承担关联，无需 schema 迁移。列表和详情继续使用
`derived_relative_path ?? relative_path` 展示。

## 生命周期

- 草稿取消：处理工作目录由下次启动清理；
- 保存失败：删除本次导入的 original 和 derived；
- 软删除：两者保留；
- 永久删除：两者删除；
- 替换派生图：原图不变，新派生成功发布后再更新关联。
