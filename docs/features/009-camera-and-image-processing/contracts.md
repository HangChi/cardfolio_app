# Feature 009 契约

## 相机

```text
CameraCapture
  capture() -> Future<CapturedImage?>
  recoverLost() -> Future<List<CapturedImage>>
```

`null` 表示用户取消，不是错误。平台异常转换为 `CameraAccessFailure`，领域层不得暴露
`XFile` 或 `PlatformException`。每次用户点击拍摄时调用一次 `capture()`；同一单卡可在编辑页重复添加，不自建取景器。

## 图片处理

```text
ImageProcessor
  detectEdges(sourcePath) -> Future<EdgeDetectionResult>
  process(ImageProcessingRequest) -> Future<ProcessedImage>
```

`ImageProcessingRequest` 包含源路径、输出 ID、四角、旋转、增强和模板。
`ProcessedImage` 只返回临时派生文件路径、宽高、字节数和耗时。实现必须在 isolate
处理，先写 `.tmp`，完成后再发布 `.jpg`。

## 编辑状态

```text
ImageEditController
  initialize(sourcePath, outputId)
  updateCorners/updateRotation/updateAdjustments/updateTemplate
  undo/reset
  render() -> Future<ProcessedImage?>
```

状态历史最多保留 20 步。渲染期间重复提交被忽略；失败保留参数；成功由调用方决定
是否把派生路径写入建卡草稿。

## 草稿与仓储

`PendingCardImage` 可携带可空 `derivedSourcePath`。`CardRepository.createCard/addImages`
同时导入原图和派生图；派生图失败视为整张图片导入失败，不得只保存半份关联。

## 错误

- `CameraAccessFailure`：权限拒绝、相机不可用、系统入口失败；
- `ImageProcessingFailure`：解码、像素上限、四角、处理或临时写入失败；
- `ImageImportFailure`：受管原图/派生图复制失败；
- 用户取消返回正常结果，不使用失败类型。
