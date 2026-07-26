import 'package:cardfolio_app/app/app_router.dart';
import 'package:cardfolio_app/app/cardfolio_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpShell(WidgetTester tester, {String? initialLocation}) async {
    await tester.pumpWidget(
      CardfolioApp(
        router: createAppRouter(
          initialLocation: initialLocation ?? libraryPath,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  NavigationBar shellBar(WidgetTester tester) =>
      tester.widget<NavigationBar>(find.byType(NavigationBar));

  testWidgets('renders the five Cardfolio destinations in order', (
    tester,
  ) async {
    await pumpShell(tester);

    final labels = shellBar(tester).destinations
        .cast<NavigationDestination>()
        .map((destination) => destination.label)
        .toList();

    expect(labels, <String>['首页', '收藏', '拍摄', '统计', '我的']);
  });

  testWidgets('starts on the collection destination', (tester) async {
    await pumpShell(tester);

    expect(shellBar(tester).selectedIndex, 1);
  });

  testWidgets('is branded as 卡迹', (tester) async {
    await pumpShell(tester);

    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).title, '卡迹');
  });

  testWidgets('selecting a destination navigates to its branch', (
    tester,
  ) async {
    await pumpShell(tester);

    await tester.tap(find.text('统计'));
    await tester.pumpAndSettle();

    expect(shellBar(tester).selectedIndex, 3);
  });

  testWidgets('unimplemented destinations announce 后续开放', (tester) async {
    await pumpShell(tester, initialLocation: statsPath);

    expect(find.text('后续开放'), findsOneWidget);
  });
}
