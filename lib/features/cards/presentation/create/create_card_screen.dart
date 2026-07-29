import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../app/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../domain/card_models.dart';
import '../../domain/image_processing.dart';
import 'create_card_controller.dart';
import 'create_card_state.dart';
import '../widgets/card_image.dart';
import '../widgets/card_image_kind_label.dart';
import '../widgets/optional_date_field.dart';

/// 新建卡片表单。资料和图片都可留空，之后可在详情页继续补充。
class CreateCardScreen extends ConsumerStatefulWidget {
  const CreateCardScreen({super.key});

  @override
  ConsumerState<CreateCardScreen> createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends ConsumerState<CreateCardScreen> {
  Future<void> _save() async {
    final id = await ref.read(createCardControllerProvider.notifier).save();
    if (!mounted || id == null) return;
    context.go(cardDetailPath(id));
  }

  void _close() {
    ref.read(createCardControllerProvider.notifier).reset();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(libraryPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createCardControllerProvider);
    final tokens = context.tokens;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(createCardControllerProvider.notifier).reset();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: state.isSaving ? null : _close,
            tooltip: '取消新建',
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('新建卡片'),
          actions: <Widget>[
            TextButton(
              onPressed: state.isSaving ? null : _save,
              child: const Text('保存'),
            ),
            SizedBox(width: tokens.spaceSm),
          ],
          bottom: state.isSaving
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(2),
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    semanticsLabel: '正在保存',
                  ),
                )
              : null,
        ),
        body: _CreateCardForm(state: state),
      ),
    );
  }
}

class _CreateCardForm extends ConsumerWidget {
  const _CreateCardForm({required this.state});

  final CreateCardState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final controller = ref.read(createCardControllerProvider.notifier);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        tokens.spaceLg,
        tokens.spaceMd,
        tokens.spaceLg,
        tokens.spaceXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _DraftImagesEditor(state: state),
          SizedBox(height: tokens.spaceLg),
          Text('基本信息', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: tokens.spaceMd),
          _CardTextField(
            key: const Key('card-name-field'),
            label: '名称（可选）',
            initialValue: state.name,
            errorText: state.fieldErrors[CardField.name],
            onChanged: controller.updateName,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: tokens.spaceMd),
          _CardTextField(
            label: '城市',
            initialValue: state.city,
            errorText: state.fieldErrors[CardField.city],
            onChanged: controller.updateCity,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: tokens.spaceMd),
          _CardTextField(
            label: '发行机构',
            initialValue: state.issuer,
            errorText: state.fieldErrors[CardField.issuer],
            onChanged: controller.updateIssuer,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: tokens.spaceMd),
          OptionalDateField(
            label: '发行日期（可选）',
            value: _dateFromPartialText(state.issuedAtText),
            errorText: state.fieldErrors[CardField.issuedAt],
            enabled: !state.isSaving,
            onChanged: (date) => controller.updateIssuedAt(
              date == null ? '' : formatOptionalDate(date),
            ),
          ),
          SizedBox(height: tokens.spaceMd),
          _CardTextField(
            label: '编号',
            initialValue: state.code,
            errorText: state.fieldErrors[CardField.code],
            onChanged: controller.updateCode,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: tokens.spaceMd),
          _CardTextField(
            label: '备注',
            initialValue: state.notes,
            errorText: state.fieldErrors[CardField.notes],
            onChanged: controller.updateNotes,
            minLines: 3,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
          ),
          if (state.failure case final failure?) ...<Widget>[
            SizedBox(height: tokens.spaceMd),
            _SaveFailure(failure: failure),
          ],
          SizedBox(height: tokens.spaceLg),
          FilledButton(
            onPressed: state.isSaving
                ? null
                : () async {
                    final id = await controller.save();
                    if (context.mounted && id != null) {
                      context.go(cardDetailPath(id));
                    }
                  },
            child: Text(state.isSaving ? '正在保存…' : '保存卡片'),
          ),
        ],
      ),
    );
  }
}

class _DraftImagesEditor extends ConsumerWidget {
  const _DraftImagesEditor({required this.state});

  final CreateCardState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final controller = ref.read(createCardControllerProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '正反面与其他图片（${state.images.length} 张，可选）',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton.icon(
              onPressed:
                  state.isSaving ||
                      state.images.length >= CreateCardRequest.maxImages
                  ? null
                  : state.images.isEmpty
                  ? controller.pickImage
                  : controller.addImages,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('添加图片'),
            ),
          ],
        ),
        SizedBox(height: tokens.spaceSm),
        if (state.images.isEmpty)
          OutlinedButton.icon(
            onPressed: state.isSaving ? null : controller.pickImage,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('添加正面或背面'),
          )
        else
          SizedBox(
            height: 246,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.images.length,
              separatorBuilder: (context, index) =>
                  SizedBox(width: tokens.spaceMd),
              itemBuilder: (context, index) {
                final image = state.images[index];
                return Semantics(
                  label:
                      '第 ${index + 1} 张，${image.kind.label}'
                      '${index == 0 ? '，封面' : ''}',
                  child: SizedBox(
                    width: 184,
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: EdgeInsets.all(tokens.spaceSm),
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                  CardImage.local(
                                    path: image.displayPath,
                                    semanticLabel: '待保存卡片第 ${index + 1} 张',
                                    borderRadius: BorderRadius.circular(
                                      tokens.radiusMd,
                                    ),
                                  ),
                                  if (index == 0)
                                    Positioned(
                                      top: tokens.spaceSm,
                                      left: tokens.spaceSm,
                                      child: const Chip(
                                        avatar: Icon(Icons.star, size: 16),
                                        label: Text('封面'),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: tokens.spaceSm),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<CardImageKind>(
                                      value: image.kind,
                                      isExpanded: true,
                                      onChanged: state.isSaving
                                          ? null
                                          : (kind) {
                                              if (kind != null) {
                                                controller.updateImageKind(
                                                  image.id,
                                                  kind,
                                                );
                                              }
                                            },
                                      items: <DropdownMenuItem<CardImageKind>>[
                                        for (final kind in CardImageKind.values)
                                          DropdownMenuItem<CardImageKind>(
                                            value: kind,
                                            child: Text(kind.label),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: state.isSaving
                                      ? null
                                      : () async {
                                          final result = await context
                                              .push<ProcessedImage>(
                                                imageEditorPath,
                                                extra: ImageEditorRouteArgs(
                                                  sourcePath:
                                                      image.selection.path,
                                                  outputId: image.id,
                                                ),
                                              );
                                          if (result != null) {
                                            controller.applyProcessedImage(
                                              image.id,
                                              result.path,
                                            );
                                          }
                                        },
                                  tooltip: '裁切与增强',
                                  icon: const Icon(
                                    Icons.auto_fix_high_outlined,
                                  ),
                                ),
                                IconButton(
                                  onPressed: state.isSaving || index == 0
                                      ? null
                                      : () =>
                                            controller.moveImage(image.id, -1),
                                  tooltip: '前移',
                                  icon: const Icon(Icons.arrow_back),
                                ),
                                IconButton(
                                  onPressed:
                                      state.isSaving ||
                                          index == state.images.length - 1
                                      ? null
                                      : () => controller.moveImage(image.id, 1),
                                  tooltip: '后移',
                                  icon: const Icon(Icons.arrow_forward),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _CardTextField extends StatelessWidget {
  const _CardTextField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.errorText,
    this.textInputAction,
    this.minLines,
    this.maxLines = 1,
    super.key,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final TextInputAction? textInputAction;
  final int? minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      enabled: true,
      textInputAction: textInputAction,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, errorText: errorText),
    );
  }
}

class _SaveFailure extends StatelessWidget {
  const _SaveFailure({required this.failure});

  final AppFailure failure;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: EdgeInsets.all(context.tokens.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(context.tokens.radiusMd),
        ),
        child: Text(
          failure.userMessage,
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }
}

DateTime? _dateFromPartialText(String text) {
  final value = PartialDate.tryParse(text);
  if (value == null) return null;
  return DateTime(value.year, value.month ?? 1, value.day ?? 1);
}
