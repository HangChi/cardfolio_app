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
    return _consumeSelection(
      () => ref
          .read(galleryPickerProvider)
          .pickMany(limit: CreateCardRequest.maxImages),
      append: false,
    );
  }

  /// 向当前草稿追加图片。
  Future<bool> addImages() {
    final remaining = CreateCardRequest.maxImages - state.images.length;
    if (remaining <= 0 || state.isSaving) return Future<bool>.value(false);
    return _consumeSelection(
      () => ref.read(galleryPickerProvider).pickMany(limit: remaining),
      append: true,
    );
  }

  /// 打开系统相机拍摄一张。用户取消返回 false，不产生错误。
  Future<bool> captureImage({bool append = false}) {
    if (state.images.length >= CreateCardRequest.maxImages || state.isSaving) {
      return Future<bool>.value(false);
    }
    return _consumeSelection(() async {
      final captured = await ref.read(cameraCaptureProvider).capture();
      if (captured == null) return const <SelectedGalleryImage>[];
      return <SelectedGalleryImage>[
        SelectedGalleryImage(
          path: captured.path,
          displayName: captured.displayName,
        ),
      ];
    }, append: append);
  }

  /// 连续逐张调用系统相机；取消当前系统相机即结束，并保留已确认图片。
  Future<bool> captureContinuously() async {
    var capturedAny = false;
    while (state.images.length < CreateCardRequest.maxImages &&
        !state.isSaving) {
      final captured = await captureImage(append: state.hasImage);
      if (!captured) break;
      capturedAny = true;
    }
    return capturedAny;
  }

  Future<bool> recoverLostCapture() {
    return _consumeSelection(() async {
      final recovered = await ref.read(cameraCaptureProvider).recoverLost();
      return <SelectedGalleryImage>[
        for (final image in recovered)
          SelectedGalleryImage(
            path: image.path,
            displayName: image.displayName,
          ),
      ];
    }, append: state.hasImage);
  }

  /// 尝试恢复 Android 丢失的选择结果。返回是否恢复到图片。
  Future<bool> recoverLostImage() {
    return _consumeSelection(
      () => ref.read(galleryPickerProvider).recoverLost(),
      append: state.hasImage,
    );
  }

  Future<bool> _consumeSelection(
    Future<List<SelectedGalleryImage>> Function() select, {
    required bool append,
  }) async {
    if (state.isSaving) return false;

    state = state.copyWith(
      phase: CreateCardPhase.selecting,
      clearFailure: true,
    );

    final List<SelectedGalleryImage> selected;
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

    if (selected.isEmpty) {
      // 取消是正常路径：安静回到原阶段，不产生草稿。
      state = state.copyWith(
        phase: state.hasImage ? CreateCardPhase.editing : CreateCardPhase.idle,
      );
      return false;
    }

    final ids = state.ids ?? CardDraftIds.create(ref.read(idGeneratorProvider));
    final existing = append ? state.images : const <DraftCardImage>[];
    final accepted = selected
        .take(CreateCardRequest.maxImages - existing.length)
        .toList(growable: false);
    final selectedDrafts = <DraftCardImage>[];
    for (var index = 0; index < accepted.length; index++) {
      final existingAtIndex = !append && index < state.images.length
          ? state.images[index]
          : null;
      final id =
          existingAtIndex?.id ??
          (index == 0 && !append
              ? ids.imageId
              : ref.read(idGeneratorProvider).newId());
      selectedDrafts.add(
        DraftCardImage(
          id: id,
          selection: accepted[index],
          kind:
              existingAtIndex?.kind ??
              switch (existing.length + index) {
                0 => CardImageKind.front,
                1 => CardImageKind.back,
                _ => CardImageKind.other,
              },
        ),
      );
    }

    state = state.copyWith(
      phase: CreateCardPhase.editing,
      images: List<DraftCardImage>.unmodifiable(<DraftCardImage>[
        ...existing,
        ...selectedDrafts,
      ]),
      // 草稿 ID 只在第一次选图时生成，之后重选图片不改变幂等键。
      ids: ids,
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

  void updateQuantity(String value) =>
      _updateField(CardField.quantity, quantityText: value);

  void prefill({
    String? name,
    String? city,
    String? issuer,
    PartialDate? issuedAt,
    String? code,
    String? notes,
  }) {
    if (state.isSaving) return;
    state = state.copyWith(
      phase: state.hasImage ? CreateCardPhase.editing : CreateCardPhase.idle,
      name: name ?? state.name,
      city: city ?? state.city,
      issuer: issuer ?? state.issuer,
      issuedAtText: issuedAt?.toIsoString() ?? state.issuedAtText,
      code: code ?? state.code,
      notes: notes ?? state.notes,
      fieldErrors: const <CardField, String>{},
      clearFailure: true,
    );
  }

  /// Starts a copy flow without carrying over capture/import draft state.
  ///
  /// Copying duplicates descriptive metadata only. Images and idempotency IDs
  /// must belong to the new card and are therefore intentionally discarded.
  void startCopyDraft() => state = const CreateCardState();

  void updateImageKind(String imageId, CardImageKind kind) {
    if (state.isSaving) return;
    state = state.copyWith(
      images: <DraftCardImage>[
        for (final image in state.images)
          image.id == imageId ? image.copyWith(kind: kind) : image,
      ],
    );
  }

  void applyProcessedImage(String imageId, String derivedSourcePath) {
    if (state.isSaving || derivedSourcePath.trim().isEmpty) return;
    state = state.copyWith(
      images: <DraftCardImage>[
        for (final image in state.images)
          image.id == imageId
              ? image.copyWith(derivedSourcePath: derivedSourcePath.trim())
              : image,
      ],
    );
  }

  /// 丢弃一张尚未保存的草稿图片；用于取消刚拍照片的裁切流程。
  void discardImage(String imageId) {
    if (state.isSaving) return;
    final images = state.images
        .where((image) => image.id != imageId)
        .toList(growable: false);
    if (images.length == state.images.length) return;
    state = state.copyWith(
      phase: images.isEmpty ? CreateCardPhase.idle : CreateCardPhase.editing,
      images: List<DraftCardImage>.unmodifiable(images),
      clearFailure: true,
    );
  }

  void moveImage(String imageId, int delta) {
    if (state.isSaving || delta == 0) return;
    final from = state.images.indexWhere((image) => image.id == imageId);
    final to = from + delta;
    if (from < 0 || to < 0 || to >= state.images.length) return;
    final images = List<DraftCardImage>.of(state.images);
    final image = images.removeAt(from);
    images.insert(to, image);
    state = state.copyWith(images: List<DraftCardImage>.unmodifiable(images));
  }

  void _updateField(
    CardField field, {
    String? name,
    String? city,
    String? issuer,
    String? issuedAtText,
    String? code,
    String? notes,
    String? quantityText,
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
          quantityText: quantityText,
        )
        .withoutFieldError(field);
  }

  /// 保存卡片。成功返回藏品 ID；校验失败、重复提交或写入失败返回 null。
  Future<String?> save() async {
    // 保存期间的第二次点击直接丢弃，保持“保存中”状态。
    if (state.isSaving) return null;

    final images = state.images;
    final ids = state.ids ?? CardDraftIds.create(ref.read(idGeneratorProvider));
    if (state.ids == null) {
      state = state.copyWith(ids: ids);
    }

    final requiredErrors = <CardField, String>{};
    if (state.name.trim().isEmpty) {
      requiredErrors[CardField.name] = '请填写卡片名称。';
    }
    if (state.city.trim().isEmpty) {
      requiredErrors[CardField.city] = '请选择或填写城市。';
    }
    if (requiredErrors.isNotEmpty) {
      state = state.copyWith(
        phase: CreateCardPhase.editing,
        fieldErrors: <CardField, String>{
          ...state.fieldErrors,
          ...requiredErrors,
        },
      );
      return null;
    }

    final quantity = int.tryParse(state.quantityText.trim());
    if (quantity == null || quantity <= 0) {
      state = state.copyWith(
        phase: CreateCardPhase.editing,
        fieldErrors: <CardField, String>{
          ...state.fieldErrors,
          CardField.quantity: '持有数量请输入大于 0 的整数。',
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
        sourceImagePath: images.isEmpty ? '' : images.first.selection.path,
        derivedSourceImagePath: images.isEmpty
            ? null
            : images.first.derivedSourcePath,
        primaryImageKind: images.isEmpty
            ? CardImageKind.front
            : images.first.kind,
        additionalImages: <PendingCardImage>[
          for (final image in images.skip(1))
            PendingCardImage(
              id: image.id,
              sourcePath: image.selection.path,
              derivedSourcePath: image.derivedSourcePath,
              kind: image.kind,
            ),
        ],
        name: state.name,
        city: state.city,
        issuer: state.issuer,
        issuedAt: issuedAt,
        code: state.code,
        notes: state.notes,
        quantity: quantity,
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
