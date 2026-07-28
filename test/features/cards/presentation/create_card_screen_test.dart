import 'package:cardfolio_app/app/app_router.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'card_flow_test.dart';

void main() {
  testWidgets('create screen exposes the Feature 001 editable fields', (
    tester,
  ) async {
    final harness = CardFlowHarness.empty();
    addTearDown(harness.dispose);
    await harness.pump(tester, initialLocation: capturePath);

    await tester.scrollUntilVisible(
      find.text('从相册导入'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('从相册导入'));
    await tester.pumpAndSettle();

    expect(harness.hasDraft, isTrue);
    expect(find.byKey(const Key('card-name-field')), findsOneWidget);
    expect(find.text('城市'), findsOneWidget);
    expect(find.text('发行机构'), findsOneWidget);
    expect(find.text('发行时间'), findsOneWidget);
    expect(find.text('编号'), findsOneWidget);
    expect(find.text('备注'), findsOneWidget);
  });

  testWidgets('create flow remains usable at 200 percent text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final harness = CardFlowHarness.empty();
    addTearDown(harness.dispose);
    await harness.pump(tester, initialLocation: capturePath);

    await tester.scrollUntilVisible(
      find.text('从相册导入'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('从相册导入'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('card-name-field')), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('create screen shows every selected image and its kind', (
    tester,
  ) async {
    final harness = CardFlowHarness.empty(
      selections: const <SelectedGalleryImage>[
        SelectedGalleryImage(path: 'C:/test/front.jpg'),
        SelectedGalleryImage(path: 'C:/test/back.jpg'),
        SelectedGalleryImage(path: 'C:/test/package.jpg'),
      ],
    );
    addTearDown(harness.dispose);
    await harness.pump(tester, initialLocation: capturePath);

    await tester.scrollUntilVisible(
      find.text('从相册导入'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('从相册导入'));
    await tester.pumpAndSettle();

    expect(find.text('3 张图片'), findsOneWidget);
    expect(find.text('封面'), findsOneWidget);
    expect(find.text('正面'), findsOneWidget);
    expect(find.text('其他'), findsNWidgets(2));
    expect(find.text('添加图片'), findsOneWidget);
  });
}
