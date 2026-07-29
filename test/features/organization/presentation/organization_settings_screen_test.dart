import 'package:cardfolio_app/core/time/clock.dart';
import 'package:cardfolio_app/features/cards/data/card_providers.dart';
import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:cardfolio_app/features/organization/data/local/organization_database.dart';
import 'package:cardfolio_app/features/organization/domain/organization_models.dart';
import 'package:cardfolio_app/features/organization/presentation/management/organization_settings_screen.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  final now = DateTime.utc(2026, 7, 28, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Widget app() {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(FixedClock(now)),
      ],
      child: const MaterialApp(home: OrganizationSettingsScreen()),
    );
  }

  Future<void> insertCard() {
    return db.insertCardGraph(
      CardRowGraph(
        definition: CardDefinitionsCompanion.insert(
          id: 'definition-1',
          name: '测试卡',
          createdAt: now,
          updatedAt: now,
        ),
        item: CardItemsCompanion.insert(
          id: 'item-1',
          definitionId: 'definition-1',
          createdAt: now,
          updatedAt: now,
        ),
        images: <CardImagesCompanion>[
          CardImagesCompanion.insert(
            id: 'image-1',
            cardItemId: 'item-1',
            kind: CardImageKind.front,
            relativePath: 'originals/item-1/image-1.jpg',
            checksum: 'sha256-1',
            isCover: const Value(true),
            createdAt: now,
          ),
        ],
      ),
    );
  }

  testWidgets('creates tags and typed custom fields from management sections', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add-tag')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('name-input')), '限定');
    await tester.tap(find.widgetWithText(FilledButton, '创建'));
    await tester.pumpAndSettle();
    expect(find.text('限定'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-custom-field')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('name-input')), '发行数量');
    await tester.tap(find.byKey(const Key('field-type-number')));
    await tester.tap(find.widgetWithText(FilledButton, '创建'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('发行数量'), 200);
    expect(find.text('发行数量'), findsOneWidget);
    expect(find.text('数字 · 0 个值'), findsOneWidget);
    await _disposeApp(tester);
  });

  testWidgets('exposes the purchase ledger entry from profile management', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('购买记录'), findsOneWidget);
    expect(find.textContaining('分摊与退款'), findsOneWidget);
    await _disposeApp(tester);
  });

  testWidgets('previews tag deletion impact and keeps the card', (
    tester,
  ) async {
    await insertCard();
    await db.createOrganizationTag(
      request: const CreateTagRequest(id: 'tag-1', name: '限定').normalized(),
      now: now,
    );
    await db.replaceCardTags(
      definitionId: 'definition-1',
      tagIds: const <String>['tag-1'],
      now: now,
    );

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tag-menu-tag-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();

    expect(find.textContaining('影响 1 款卡片'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '删除标签'));
    await tester.pumpAndSettle();

    expect(find.text('限定'), findsNothing);
    expect(await db.select(db.cardItems).get(), hasLength(1));
    await _disposeApp(tester);
  });

  testWidgets('merges tag relationships into a selected target', (
    tester,
  ) async {
    await insertCard();
    for (final (id, name) in <(String, String)>[
      ('source', '来源'),
      ('target', '目标'),
    ]) {
      await db.createOrganizationTag(
        request: CreateTagRequest(id: id, name: name).normalized(),
        now: now,
      );
    }
    await db.replaceCardTags(
      definitionId: 'definition-1',
      tagIds: const <String>['source'],
      now: now,
    );

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tag-menu-source')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('合并'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('merge-target-target')));
    await tester.tap(find.widgetWithText(FilledButton, '合并标签'));
    await tester.pumpAndSettle();

    final targetLinks = await (db.select(
      db.cardTags,
    )..where((link) => link.tagId.equals('target'))).get();
    expect(targetLinks, hasLength(1));
    expect(find.text('来源'), findsNothing);
    await _disposeApp(tester);
  });
}

Future<void> _disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}
