import 'dart:io';

import 'package:cardfolio_app/app/bootstrap/app_bootstrap.dart';
import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('startup failure offers retry and enters the app on success', (
    tester,
  ) async {
    final supportDirectory = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('cardfolio-bootstrap-'),
    ))!;
    final dependencies = (await tester.runAsync(
      () =>
          CardfolioDependencies.initialize(supportDirectory: supportDirectory),
    ))!;
    var attempts = 0;

    Future<CardfolioDependencies> initialize() async {
      attempts++;
      if (attempts == 1) {
        throw const DatabaseUnavailableFailure();
      }
      return dependencies;
    }

    await tester.pumpWidget(AppBootstrap(initializer: initialize));
    await tester.pump();
    await tester.pump();

    expect(find.text('收藏库暂时无法打开，请重试。'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await tester.pump();
    await tester.pump();

    expect(attempts, 2);
    expect(find.text('我的收藏'), findsOneWidget);

    await tester.runAsync(dependencies.close);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.runAsync(() async {
      if (supportDirectory.existsSync()) {
        await supportDirectory.delete(recursive: true);
      }
    });
  });
}
