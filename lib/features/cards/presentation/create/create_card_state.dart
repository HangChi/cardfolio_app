import 'package:meta/meta.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/card_models.dart';

/// 建卡流程的阶段。
enum CreateCardPhase {
  /// 尚未选图。
  idle,

  /// 正在等待系统选择器。
  selecting,

  /// 已有图片，正在填写表单。
  editing,

  /// 正在写入，禁止重复提交。
  saving,

  /// 已成功保存。
  saved,

  /// 可恢复的失败，表单内容保留。
  failure,
}

/// 建卡页的不可变状态。
@immutable
final class CreateCardState {
  const CreateCardState({
    this.phase = CreateCardPhase.idle,
    this.image,
    this.ids,
    this.name = '',
    this.city = '',
    this.issuer = '',
    this.issuedAtText = '',
    this.code = '',
    this.notes = '',
    this.fieldErrors = const <CardField, String>{},
    this.failure,
    this.savedCardItemId,
  });

  final CreateCardPhase phase;
  final SelectedGalleryImage? image;

  /// 首次选图时生成，之后保持不变，使重试保存保持幂等。
  final CardDraftIds? ids;

  final String name;
  final String city;
  final String issuer;
  final String issuedAtText;
  final String code;
  final String notes;

  final Map<CardField, String> fieldErrors;
  final AppFailure? failure;
  final String? savedCardItemId;

  bool get isSaving => phase == CreateCardPhase.saving;

  bool get hasImage => image != null && ids != null;

  CreateCardState copyWith({
    CreateCardPhase? phase,
    SelectedGalleryImage? image,
    CardDraftIds? ids,
    String? name,
    String? city,
    String? issuer,
    String? issuedAtText,
    String? code,
    String? notes,
    Map<CardField, String>? fieldErrors,
    AppFailure? failure,
    bool clearFailure = false,
    String? savedCardItemId,
  }) {
    return CreateCardState(
      phase: phase ?? this.phase,
      image: image ?? this.image,
      ids: ids ?? this.ids,
      name: name ?? this.name,
      city: city ?? this.city,
      issuer: issuer ?? this.issuer,
      issuedAtText: issuedAtText ?? this.issuedAtText,
      code: code ?? this.code,
      notes: notes ?? this.notes,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      failure: clearFailure ? null : (failure ?? this.failure),
      savedCardItemId: savedCardItemId ?? this.savedCardItemId,
    );
  }

  /// 清除单个字段的错误，用户一旦修改就不应继续看到旧提示。
  CreateCardState withoutFieldError(CardField field) {
    if (!fieldErrors.containsKey(field)) return this;
    final next = Map<CardField, String>.of(fieldErrors)..remove(field);
    return copyWith(fieldErrors: next);
  }
}
