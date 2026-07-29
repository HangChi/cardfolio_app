import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../domain/image_processing.dart';
import 'image_edit_controller.dart';

typedef ImagePreviewBuilder =
    Widget Function(BuildContext context, String path);

final class ImageEditorScreen extends StatefulWidget {
  const ImageEditorScreen({
    required this.sourcePath,
    required this.outputId,
    required this.processor,
    this.previewBuilder,
    this.onCompleted,
    super.key,
  });

  final String sourcePath;
  final String outputId;
  final ImageProcessor processor;
  final ImagePreviewBuilder? previewBuilder;
  final ValueChanged<ProcessedImage>? onCompleted;

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  late final ImageEditController _controller;
  var _showOriginal = false;

  @override
  void initState() {
    super.initState();
    _controller = ImageEditController(
      processor: widget.processor,
      sourcePath: widget.sourcePath,
      outputId: widget.outputId,
    )..addListener(_changed);
    _controller.initialize();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_changed)
      ..dispose();
    super.dispose();
  }

  Future<void> _renderPreview() async {
    if (_showOriginal) setState(() => _showOriginal = false);
    await _controller.render();
  }

  void _complete() {
    final result = _controller.state.output;
    if (result == null) return;
    final callback = widget.onCompleted;
    if (callback != null) {
      callback(result);
    } else {
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final tokens = context.tokens;
    return Scaffold(
      appBar: AppBar(title: const Text('图片裁切与增强')),
      body: state.phase == ImageEditPhase.initializing
          ? const Center(
              child: CircularProgressIndicator(semanticsLabel: '正在识别卡片边缘'),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                tokens.spaceLg,
                tokens.spaceMd,
                tokens.spaceLg,
                tokens.spaceXl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    state.requiresManualAdjustment
                        ? '自动识别不确定，请拖动四角调整'
                        : '已生成边缘建议，可继续拖动四角微调',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: tokens.spaceMd),
                  _CornerPreview(
                    path: _showOriginal
                        ? widget.sourcePath
                        : (state.output?.path ?? widget.sourcePath),
                    corners: state.settings.corners,
                    previewBuilder: widget.previewBuilder,
                    onCornerChanged: _controller.setCorner,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      onPressed: () =>
                          setState(() => _showOriginal = !_showOriginal),
                      icon: Icon(
                        _showOriginal ? Icons.auto_fix_high : Icons.compare,
                      ),
                      label: Text(_showOriginal ? '查看编辑效果' : '查看原图'),
                    ),
                  ),
                  const Divider(),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: state.phase == ImageEditPhase.processing
                              ? null
                              : _controller.rotateClockwise,
                          icon: const Icon(Icons.rotate_right),
                          label: const Text('旋转 90°'),
                        ),
                      ),
                      SizedBox(width: tokens.spaceSm),
                      TextButton(
                        onPressed: state.canUndo ? _controller.undo : null,
                        child: const Text('撤销'),
                      ),
                      TextButton(
                        onPressed: state.phase == ImageEditPhase.processing
                            ? null
                            : _controller.reset,
                        child: const Text('重置'),
                      ),
                    ],
                  ),
                  _AdjustmentSlider(
                    label: '亮度',
                    value: state.settings.adjustments.brightness,
                    min: -1,
                    onChanged: _controller.setBrightness,
                  ),
                  _AdjustmentSlider(
                    label: '对比度',
                    value: state.settings.adjustments.contrast,
                    min: -1,
                    onChanged: _controller.setContrast,
                  ),
                  _AdjustmentSlider(
                    label: '清晰度',
                    value: state.settings.adjustments.sharpness,
                    onChanged: _controller.setSharpness,
                  ),
                  SizedBox(height: tokens.spaceSm),
                  Text('展示模板', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: tokens.spaceSm),
                  Wrap(
                    spacing: tokens.spaceSm,
                    runSpacing: tokens.spaceSm,
                    children: <Widget>[
                      for (final template in ImageOutputTemplate.values)
                        ChoiceChip(
                          label: Text(template.label),
                          selected: state.settings.template == template,
                          onSelected: state.phase == ImageEditPhase.processing
                              ? null
                              : (_) => _controller.setTemplate(template),
                        ),
                    ],
                  ),
                  if (state.failure case final failure?) ...<Widget>[
                    SizedBox(height: tokens.spaceMd),
                    Text(
                      failure.userMessage,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                  SizedBox(height: tokens.spaceLg),
                  OutlinedButton.icon(
                    onPressed: state.phase == ImageEditPhase.processing
                        ? null
                        : _renderPreview,
                    icon: state.phase == ImageEditPhase.processing
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_fix_high),
                    label: Text(
                      state.phase == ImageEditPhase.processing
                          ? '正在生成…'
                          : state.output == null
                          ? '生成预览'
                          : '重新生成预览',
                    ),
                  ),
                  if (state.output != null) ...<Widget>[
                    SizedBox(height: tokens.spaceSm),
                    FilledButton.icon(
                      onPressed: _complete,
                      icon: const Icon(Icons.check),
                      label: const Text('使用此图片'),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _CornerPreview extends StatelessWidget {
  const _CornerPreview({
    required this.path,
    required this.corners,
    required this.onCornerChanged,
    this.previewBuilder,
  });

  final String path;
  final ImageCorners corners;
  final void Function(int index, NormalizedPoint point) onCornerChanged;
  final ImagePreviewBuilder? previewBuilder;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final points = <NormalizedPoint>[
            corners.topLeft,
            corners.topRight,
            corners.bottomRight,
            corners.bottomLeft,
          ];
          return ClipRRect(
            borderRadius: BorderRadius.circular(context.tokens.radiusLg),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ColoredBox(
                  color: AppColors.primaryContainer,
                  child:
                      previewBuilder?.call(context, path) ??
                      Image.file(
                        File(path),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(Icons.broken_image_outlined),
                            ),
                      ),
                ),
                CustomPaint(painter: _CornerPainter(points)),
                for (var index = 0; index < points.length; index++)
                  _CornerHandle(
                    index: index,
                    point: points[index],
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    onChanged: onCornerChanged,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CornerHandle extends StatelessWidget {
  const _CornerHandle({
    required this.index,
    required this.point,
    required this.width,
    required this.height,
    required this.onChanged,
  });

  final int index;
  final NormalizedPoint point;
  final double width;
  final double height;
  final void Function(int index, NormalizedPoint point) onChanged;

  @override
  Widget build(BuildContext context) {
    const size = 32.0;
    return Positioned(
      left: point.x * width - size / 2,
      top: point.y * height - size / 2,
      child: Semantics(
        label: '裁切角 ${index + 1}',
        child: GestureDetector(
          onPanUpdate: (details) {
            final x = (point.x + details.delta.dx / width).clamp(0.0, 1.0);
            final y = (point.y + details.delta.dy / height).clamp(0.0, 1.0);
            onChanged(index, NormalizedPoint(x, y));
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
          ),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter(this.points);

  final List<NormalizedPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(points.first.x * size.width, points.first.y * size.height);
    for (final point in points.skip(1)) {
      path.lineTo(point.x * size.width, point.y * size.height);
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_CornerPainter oldDelegate) =>
      oldDelegate.points != points;
}

class _AdjustmentSlider extends StatelessWidget {
  const _AdjustmentSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
  });

  final String label;
  final double value;
  final double min;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(width: 56, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: 1,
            divisions: min < 0 ? 20 : 10,
            label: value.toStringAsFixed(1),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

extension on ImageOutputTemplate {
  String get label => switch (this) {
    ImageOutputTemplate.original => '原始比例',
    ImageOutputTemplate.standardCard => '标准卡片',
    ImageOutputTemplate.squareLight => '方形浅色',
    ImageOutputTemplate.squareDark => '方形深色',
  };
}
