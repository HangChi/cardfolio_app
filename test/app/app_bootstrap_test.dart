import 'dart:io';

import 'package:cardfolio_app/app/bootstrap/app_bootstrap.dart';
import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

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
    expect(find.text('把每一张卡，整理成收藏'), findsOneWidget);

    await tester.tap(find.text('跳过'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始使用'));
    await tester.pumpAndSettle();
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).title, '卡迹');

    await tester.runAsync(dependencies.close);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.runAsync(() async {
      if (supportDirectory.existsSync()) {
        await supportDirectory.delete(recursive: true);
      }
    });
  });

  test('startup permanently deletes expired cards and managed files', () async {
    final supportDirectory = await Directory.systemTemp.createTemp(
      'cardfolio-bootstrap-purge-',
    );
    addTearDown(() async {
      if (supportDirectory.existsSync()) {
        await supportDirectory.delete(recursive: true);
      }
    });
    final dataRoot = Directory(p.join(supportDirectory.path, 'cardfolio'));
    final imageRoot = Directory(p.join(dataRoot.path, 'images'));
    await imageRoot.create(recursive: true);
    final database = AppDatabase(
      NativeDatabase(File(p.join(dataRoot.path, 'cardfolio.sqlite'))),
    );
    final now = DateTime.now().toUtc();
    await database.insertCardGraph(
      CardRowGraph(
        definition: CardDefinitionsCompanion.insert(
          id: 'definition-expired',
          name: '已过期卡片',
          createdAt: now.subtract(const Duration(days: 40)),
          updatedAt: now.subtract(const Duration(days: 40)),
        ),
        item: CardItemsCompanion.insert(
          id: 'item-expired',
          definitionId: 'definition-expired',
          createdAt: now.subtract(const Duration(days: 40)),
          updatedAt: now.subtract(const Duration(days: 40)),
          deletedAt: Value(now.subtract(const Duration(days: 31))),
        ),
        images: <CardImagesCompanion>[
          CardImagesCompanion.insert(
            id: 'image-expired',
            cardItemId: 'item-expired',
            kind: CardImageKind.front,
            relativePath: 'originals/item-expired/front.jpg',
            checksum: 'sha256-expired',
            isCover: const Value(true),
            createdAt: now.subtract(const Duration(days: 40)),
          ),
        ],
      ),
    );
    await database.close();
    final image = File(
      p.join(imageRoot.path, 'originals', 'item-expired', 'front.jpg'),
    );
    await image.parent.create(recursive: true);
    await image.writeAsBytes(<int>[1, 2, 3], flush: true);
    final staleDerived = File(
      p.join(dataRoot.path, 'image-processing-work', 'outputs', 'stale.jpg'),
    );
    await staleDerived.parent.create(recursive: true);
    await staleDerived.writeAsBytes(<int>[0xff, 0xd8, 0xff], flush: true);

    final dependencies = await CardfolioDependencies.initialize(
      supportDirectory: supportDirectory,
    );
    addTearDown(dependencies.close);

    expect(await dependencies.database.countItems(), 0);
    expect(image.existsSync(), isFalse);
    expect(staleDerived.existsSync(), isFalse);
    expect(
      Directory(p.join(dataRoot.path, 'image-processing-work')).existsSync(),
      isTrue,
    );
    expect(
      await dependencies.database
          .select(dependencies.database.fileCleanupQueueEntries)
          .get(),
      isEmpty,
    );
  });
}
