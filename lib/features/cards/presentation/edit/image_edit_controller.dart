import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/image_processing.dart';

enum ImageEditPhase { initializing, ready, processing, completed, failure }

@immutable
final class ImageEditState {
  const ImageEditState({
    required this.phase,
    required this.settings,
    this.requiresManualAdjustment = true,
    this.historyDepth = 0,
    this.output,
    this.failure,
  });

  final ImageEditPhase phase;
  final ImageEditSettings settings;
  final bool requiresManualAdjustment;
  final int historyDepth;
  final ProcessedImage? output;
  final AppFailure? failure;

  bool get canUndo => historyDepth > 0;

  ImageEditState copyWith({
    ImageEditPhase? phase,
    ImageEditSettings? settings,
    bool? requiresManualAdjustment,
    int? historyDepth,
    ProcessedImage? output,
    AppFailure? failure,
    bool clearFailure = false,
    bool clearOutput = false,
  }) {
    return ImageEditState(
      phase: phase ?? this.phase,
      settings: settings ?? this.settings,
      requiresManualAdjustment:
          requiresManualAdjustment ?? this.requiresManualAdjustment,
      historyDepth: historyDepth ?? this.historyDepth,
      output: clearOutput ? null : (output ?? this.output),
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

final class ImageEditController extends ChangeNotifier {
  ImageEditController({
    required this.processor,
    required this.sourcePath,
    required this.outputId,
  }) : state = ImageEditState(
         phase: ImageEditPhase.initializing,
         settings: ImageEditSettings.initial(),
       );

  static const int maxHistory = 20;

  final ImageProcessor processor;
  final String sourcePath;
  final String outputId;

  ImageEditState state;
  ImageEditSettings? _baseline;
  final List<ImageEditSettings> _history = <ImageEditSettings>[];
  var _generation = 0;

  Future<void> initialize() async {
    final settings = ImageEditSettings.initial();
    _baseline = settings;
    _history.clear();
    state = ImageEditState(
      phase: ImageEditPhase.ready,
      settings: settings,
      requiresManualAdjustment: false,
    );
    notifyListeners();
  }

  void setCorners(ImageCorners value) =>
      _apply(state.settings.copyWith(corners: value));

  void setCorner(int index, NormalizedPoint value) {
    final corners = state.settings.corners;
    try {
      setCorners(
        ImageCorners(
          topLeft: index == 0 ? value : corners.topLeft,
          topRight: index == 1 ? value : corners.topRight,
          bottomRight: index == 2 ? value : corners.bottomRight,
          bottomLeft: index == 3 ? value : corners.bottomLeft,
        ),
      );
    } on ArgumentError {
      // 拖动经过交叉/退化位置时忽略该帧，保持最后一个有效四边形。
    }
  }

  void rotateClockwise() => _apply(
    state.settings.copyWith(quarterTurns: state.settings.quarterTurns + 1),
  );

  void setBrightness(double value) {
    final current = state.settings.adjustments;
    _apply(
      state.settings.copyWith(
        adjustments: ImageAdjustments(
          brightness: value,
          contrast: current.contrast,
          sharpness: current.sharpness,
        ),
      ),
    );
  }

  void setContrast(double value) {
    final current = state.settings.adjustments;
    _apply(
      state.settings.copyWith(
        adjustments: ImageAdjustments(
          brightness: current.brightness,
          contrast: value,
          sharpness: current.sharpness,
        ),
      ),
    );
  }

  void setSharpness(double value) {
    final current = state.settings.adjustments;
    _apply(
      state.settings.copyWith(
        adjustments: ImageAdjustments(
          brightness: current.brightness,
          contrast: current.contrast,
          sharpness: value,
        ),
      ),
    );
  }

  void setTemplate(ImageOutputTemplate value) =>
      _apply(state.settings.copyWith(template: value));

  void undo() {
    if (_history.isEmpty || state.phase == ImageEditPhase.processing) return;
    final previous = _history.removeLast();
    state = state.copyWith(
      phase: ImageEditPhase.ready,
      settings: previous,
      historyDepth: _history.length,
      clearFailure: true,
      clearOutput: true,
    );
    notifyListeners();
  }

  void reset() {
    final baseline = _baseline;
    if (baseline == null || state.phase == ImageEditPhase.processing) return;
    if (state.settings != baseline) _remember(state.settings);
    state = state.copyWith(
      phase: ImageEditPhase.ready,
      settings: baseline,
      historyDepth: _history.length,
      clearFailure: true,
      clearOutput: true,
    );
    notifyListeners();
  }

  Future<ProcessedImage?> render() async {
    if (state.phase == ImageEditPhase.processing) return null;
    final generation = ++_generation;
    state = state.copyWith(
      phase: ImageEditPhase.processing,
      clearFailure: true,
      clearOutput: true,
    );
    notifyListeners();
    try {
      final output = await processor.process(
        ImageProcessingRequest(
          sourcePath: sourcePath,
          outputId: outputId,
          settings: state.settings,
        ),
      );
      if (generation != _generation) {
        try {
          final unpublished = File(output.path);
          if (await unpublished.exists()) await unpublished.delete();
        } on FileSystemException {
          // 工作目录会在下次启动统一清理，取消结果绝不进入草稿。
        }
        return null;
      }
      state = state.copyWith(
        phase: ImageEditPhase.completed,
        output: output,
        clearFailure: true,
      );
      notifyListeners();
      return output;
    } on AppFailure catch (failure) {
      if (generation != _generation) return null;
      state = state.copyWith(phase: ImageEditPhase.failure, failure: failure);
      notifyListeners();
      return null;
    } catch (error) {
      if (generation != _generation) return null;
      state = state.copyWith(
        phase: ImageEditPhase.failure,
        failure: ImageProcessingFailure('保存编辑图片失败，请重试。', error),
      );
      notifyListeners();
      return null;
    }
  }

  void cancelPending() {
    _generation++;
    if (state.phase == ImageEditPhase.processing) {
      state = state.copyWith(phase: ImageEditPhase.ready);
      notifyListeners();
    }
  }

  void _apply(ImageEditSettings next) {
    if (next == state.settings || state.phase == ImageEditPhase.processing) {
      return;
    }
    _remember(state.settings);
    state = state.copyWith(
      phase: ImageEditPhase.ready,
      settings: next,
      historyDepth: _history.length,
      clearFailure: true,
      clearOutput: true,
    );
    notifyListeners();
  }

  void _remember(ImageEditSettings settings) {
    _history.add(settings);
    if (_history.length > maxHistory) {
      _history.removeAt(0);
    }
  }

  @override
  void dispose() {
    cancelPending();
    super.dispose();
  }
}
