import 'package:cardfolio_app/features/cards/domain/image_processing.dart';
import 'package:cardfolio_app/features/cards/presentation/edit/image_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_image_processor.dart';

void main() {
  testWidgets('exposes crop, enhancement, comparison, history, and templates', (
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

    expect(find.text('图片裁切与增强'), findsOneWidget);
    expect(find.text('自动识别不确定，请拖动四角调整'), findsOneWidget);
    expect(find.text('旋转 90°'), findsOneWidget);
    expect(find.text('亮度'), findsOneWidget);
    expect(find.text('对比度'), findsOneWidget);
    expect(find.text('清晰度'), findsOneWidget);
    expect(find.text('标准卡片'), findsOneWidget);
    expect(find.text('方形浅色'), findsOneWidget);
    expect(find.text('方形深色'), findsOneWidget);
    expect(find.text('查看原图'), findsOneWidget);
    expect(find.text('撤销'), findsOneWidget);
    expect(find.text('重置'), findsOneWidget);
  });

  testWidgets('previews and compares a derived result before returning it', (
    tester,
  ) async {
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

    await tester.ensureVisible(find.text('生成预览'));
    await tester.tap(find.text('生成预览'));
    await tester.pumpAndSettle();

    expect(completed, isNull);
    expect(find.text('preview:/tmp/processed.jpg'), findsOneWidget);

    await tester.tap(find.text('查看原图'));
    await tester.pump();
    expect(find.text('preview:/tmp/original.jpg'), findsOneWidget);

    await tester.tap(find.text('查看编辑效果'));
    await tester.pump();
    expect(find.text('preview:/tmp/processed.jpg'), findsOneWidget);

    await tester.ensureVisible(find.text('使用此图片'));
    await tester.tap(find.text('使用此图片'));
    await tester.pump();

    expect(completed?.path, '/tmp/processed.jpg');
  });
}
