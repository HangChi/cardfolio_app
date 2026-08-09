import 'package:cardfolio_app/features/cards/domain/image_processing.dart';
import 'package:cardfolio_app/features/cards/presentation/edit/image_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_image_processor.dart';

void main() {
  testWidgets('exposes crop, enhancement, and adjustment history', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ImageEditorScreen(
          sourcePath: '/tmp/original.jpg',
          outputId: 'image-1',
          processor: FakeImageProcessor(),
          previewBuilder: (context, path) => Text('preview:$path'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('编辑图片'), findsOneWidget);
    expect(find.text('裁剪与旋转'), findsOneWidget);
    expect(find.text('亮度'), findsOneWidget);
    expect(find.text('对比度'), findsOneWidget);
    expect(find.text('清晰度'), findsOneWidget);
    expect(find.text('撤销调整'), findsOneWidget);
    expect(find.text('重置调整'), findsOneWidget);
    expect(find.text('使用此图片'), findsOneWidget);
  });

  testWidgets('renders and returns the edited image', (tester) async {
    ProcessedImage? completed;
    await tester.pumpWidget(
      MaterialApp(
        home: ImageEditorScreen(
          sourcePath: '/tmp/original.jpg',
          outputId: 'image-1',
          processor: FakeImageProcessor(),
          previewBuilder: (context, path) => Text('preview:$path'),
          onCompleted: (result) => completed = result,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('使用此图片'));
    await tester.tap(find.text('使用此图片'));
    await tester.pump();

    expect(completed?.path, '/tmp/processed.jpg');
  });
}
