import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

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
  static const int _editedJpegQuality = 95;

  late ImageEditController _controller;
  late String _workingPath;
  var _allowJpegPassthrough = false;
  var _cropping = false;

  @override
  void initState() {
    super.initState();
    _workingPath = widget.sourcePath;
    _installController();
  }

  void _installController() {
    _controller = ImageEditController(
      processor: widget.processor,
      sourcePath: _workingPath,
      outputId: widget.outputId,
      allowJpegPassthrough: _allowJpegPassthrough,
    )..addListener(_changed);
    _controller.initialize();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  void _replaceWorkingPath(String path) {
    _controller
      ..removeListener(_changed)
      ..dispose();
    _workingPath = path;
    _allowJpegPassthrough = true;
    _installController();
    setState(() {});
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_changed)
      ..dispose();
    super.dispose();
  }

  Future<void> _crop() async {
    if (_cropping || _controller.state.phase == ImageEditPhase.processing)
      return;
    setState(() => _cropping = true);
    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: _workingPath,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: _editedJpegQuality,
        uiSettings: <PlatformUiSettings>[
          AndroidUiSettings(
            toolbarTitle: '裁剪与旋转',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: AppColors.primary,
            lockAspectRatio: false,
            hideBottomControls: false,
            showCropGrid: true,
            aspectRatioPresets: const <CropAspectRatioPresetData>[
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: '裁剪与旋转',
            doneButtonTitle: '完成',
            cancelButtonTitle: '取消',
            rotateButtonsHidden: false,
            resetButtonHidden: false,
            aspectRatioPickerButtonHidden: false,
            aspectRatioPresets: const <CropAspectRatioPresetData>[
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );
      if (cropped != null && mounted) _replaceWorkingPath(cropped.path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('当前设备无法打开裁剪器，请稍后重试。')));
      }
    } finally {
      if (mounted) setState(() => _cropping = false);
    }
  }

  Future<void> _complete() async {
    final result = await _controller.render();
    if (result == null || !mounted) return;
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
    final busy = _cropping || state.phase == ImageEditPhase.processing;
    return Scaffold(
      appBar: AppBar(title: const Text('编辑图片')),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          tokens.spaceLg,
          tokens.spaceMd,
          tokens.spaceLg,
          tokens.spaceXl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.15,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(tokens.radiusLg),
                child: ColoredBox(
                  color: Colors.black,
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 5,
                    child: _AdjustmentPreview(
                      path: _workingPath,
                      adjustments: state.settings.adjustments,
                      previewBuilder: widget.previewBuilder,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: tokens.spaceMd),
            OutlinedButton.icon(
              onPressed: busy ? null : _crop,
              icon: _cropping
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.crop_rotate),
              label: const Text('裁剪与旋转'),
            ),
            SizedBox(height: tokens.spaceSm),
            Text(
              '亮度和对比度会立即预览；清晰度在保存时应用。图片保持当前像素尺寸，不会放大。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.palette.textSecondary,
              ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: busy ? null : _controller.undo,
                  child: const Text('撤销调整'),
                ),
                TextButton(
                  onPressed: busy ? null : _controller.reset,
                  child: const Text('重置调整'),
                ),
              ],
            ),
            if (state.failure case final failure?) ...<Widget>[
              SizedBox(height: tokens.spaceSm),
              Text(
                failure.userMessage,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            SizedBox(height: tokens.spaceMd),
            FilledButton.icon(
              onPressed: busy ? null : _complete,
              icon: state.phase == ImageEditPhase.processing
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(
                state.phase == ImageEditPhase.processing
                    ? '正在保存原尺寸图片…'
                    : '使用此图片',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdjustmentPreview extends StatelessWidget {
  const _AdjustmentPreview({
    required this.path,
    required this.adjustments,
    this.previewBuilder,
  });

  final String path;
  final ImageAdjustments adjustments;
  final ImagePreviewBuilder? previewBuilder;

  @override
  Widget build(BuildContext context) {
    final contrast = 1 + adjustments.contrast * 0.5;
    final offset = adjustments.brightness * 64 + 128 * (1 - contrast);
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(<double>[
        contrast,
        0,
        0,
        0,
        offset,
        0,
        contrast,
        0,
        0,
        offset,
        0,
        0,
        contrast,
        0,
        offset,
        0,
        0,
        0,
        1,
        0,
      ]),
      child:
          previewBuilder?.call(context, path) ??
          Image.file(
            File(path),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.broken_image_outlined, color: Colors.white),
            ),
          ),
    );
  }
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
