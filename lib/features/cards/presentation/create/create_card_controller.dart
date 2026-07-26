import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../data/card_providers.dart';
import '../../domain/card_models.dart';
import 'create_card_state.dart';

final NotifierProvider<CreateCardController, CreateCardState>
createCardControllerProvider =
    NotifierProvider<CreateCardController, CreateCardState>(
      CreateCardController.new,
    );

/// 建卡流程的状态机。
///
/// 重复提交守卫放在控制器而非页面：页面可能被重建，控制器才是唯一事实来源。
class CreateCardController extends Notifier<CreateCardState> {
  @override
  CreateCardState build() => const CreateCardState();

  /// 打开相册选择一张图片。返回是否得到了图片。
  Future<bool> pickImage() {
    return _consumeSelection(() => ref.read(galleryPickerProvider).pickOne());
  }

  /// 尝试恢复 Android 丢失的选择结果。返回是否恢复到图片。
  Future<bool> recoverLostImage() {
    return _consumeSelection(
      () => ref.read(galleryPickerProvider).recoverLost(),
    );
  }

  Future<bool> _consumeSelection(
    Future<SelectedGalleryImage?> Function() select,
  ) async {
    if (state.isSaving) return false;

    state = state.copyWith(
      phase: CreateCardPhase.selecting,
      clearFailure: true,
    );

    final SelectedGalleryImage? selected;
    try {
      selected = await select();
    } on AppFailure catch (failure) {
      state = state.copyWith(
        phase: state.hasImage
            ? CreateCardPhase.editing
            : CreateCardPhase.failure,
        failure: failure,
      );
      return false;
    }

    if (selected == null) {
      // 取消是正常路径：安静回到原阶段，不产生草稿。
      state = state.copyWith(
        phase: state.hasImage ? CreateCardPhase.editing : CreateCardPhase.idle,
      );
      return false;
    }

    state = state.copyWith(
      phase: CreateCardPhase.editing,
      image: selected,
      // 草稿 ID 只在第一次选图时生成，之后重选图片不改变幂等键。
      ids: state.ids ?? CardDraftIds.create(ref.read(idGeneratorProvider)),
      clearFailure: true,
    );
    return true;
  }

  void updateName(String value) => _updateField(CardField.name, name: value);

  void updateCity(String value) => _updateField(CardField.city, city: value);

  void updateIssuer(String value) =>
      _updateField(CardField.issuer, issuer: value);

  void updateIssuedAt(String value) =>
      _updateField(CardField.issuedAt, issuedAtText: value);

  void updateCode(String value) => _updateField(CardField.code, code: value);

  void updateNotes(String value) => _updateField(CardField.notes, notes: value);

  void _updateField(
    CardField field, {
    String? name,
    String? city,
    String? issuer,
    String? issuedAtText,
    String? code,
    String? notes,
  }) {
    if (state.isSaving) return;
    state = state
        .copyWith(
          name: name,
          city: city,
          issuer: issuer,
          issuedAtText: issuedAtText,
          code: code,
          notes: notes,
        )
        .withoutFieldError(field);
  }

  /// 保存卡片。成功返回藏品 ID；校验失败、重复提交或写入失败返回 null。
  Future<String?> save() async {
    // 保存期间的第二次点击直接丢弃，保持“保存中”状态。
    if (state.isSaving) return null;

    final image = state.image;
    final ids = state.ids;
    if (image == null || ids == null) {
      state = state.copyWith(
        fieldErrors: <CardField, String>{
          ...state.fieldErrors,
          CardField.image: '请先选择一张卡片图片。',
        },
      );
      return null;
    }

    // 部分日期需要在构造请求前解析，无法解析属于字段级错误。
    final issuedAtText = state.issuedAtText.trim();
    final issuedAt = issuedAtText.isEmpty
        ? null
        : PartialDate.tryParse(issuedAtText);
    if (issuedAtText.isNotEmpty && issuedAt == null) {
      state = state.copyWith(
        fieldErrors: <CardField, String>{
          ...state.fieldErrors,
          CardField.issuedAt: '请填写 2025、2025-03 或 2025-03-15 这样的日期。',
        },
      );
      return null;
    }

    final CreateCardRequest request;
    try {
      request = CreateCardRequest(
        ids: ids,
        sourceImagePath: image.path,
        name: state.name,
        city: state.city,
        issuer: state.issuer,
        issuedAt: issuedAt,
        code: state.code,
        notes: state.notes,
      ).normalized();
    } on ValidationFailure catch (failure) {
      state = state.copyWith(
        phase: CreateCardPhase.editing,
        fieldErrors: <CardField, String>{
          ...state.fieldErrors,
          failure.field: failure.userMessage,
        },
      );
      return null;
    }

    state = state.copyWith(
      phase: CreateCardPhase.saving,
      fieldErrors: const <CardField, String>{},
      clearFailure: true,
    );

    try {
      final cardItemId = await ref
          .read(cardRepositoryProvider)
          .createCard(request);
      state = state.copyWith(
        phase: CreateCardPhase.saved,
        savedCardItemId: cardItemId,
        clearFailure: true,
      );
      return cardItemId;
    } on AppFailure catch (failure) {
      // 表单内容必须保留，用户可以直接重试。
      state = state.copyWith(phase: CreateCardPhase.failure, failure: failure);
      return null;
    }
  }

  /// 离开建卡页时重置草稿，避免下次进入看到上一次的输入。
  void reset() => state = const CreateCardState();
}
