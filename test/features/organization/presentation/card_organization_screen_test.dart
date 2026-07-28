import 'package:cardfolio_app/core/time/clock.dart';
import 'package:cardfolio_app/features/cards/data/card_providers.dart';
import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:cardfolio_app/features/organization/data/local/organization_database.dart';
import 'package:cardfolio_app/features/organization/domain/organization_models.dart';
import 'package:cardfolio_app/features/organization/presentation/card/card_organization_screen.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  final now = DateTime.utc(2026, 7, 28, 12);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.insertCardGraph(
      CardRowGraph(
        definition: CardDefinitionsCompanion.insert(
          id: 'definition-1',
          name: '樱花卡',
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
    await db.createOrganizationTag(
      request: const CreateTagRequest(id: 'tag-1', name: '限定').normalized(),
      now: now,
    );
    await db.saveOrganizationSeries(
      request: const SaveSeriesRequest(
        id: 'series-1',
        name: '世博会',
      ).normalized(),
      now: now,
    );
    await db.createOrganizationField(
      request: const CreateCustomFieldRequest(
        id: 'field-1',
        name: '品相说明',
        fieldType: CustomFieldType.text,
      ).normalized(),
      now: now,
    );
  });

  tearDown(() => db.close());

  Widget app() {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(FixedClock(now)),
      ],
      child: const MaterialApp(
        home: CardOrganizationScreen(cardItemId: 'item-1'),
      ),
    );
  }

  testWidgets('saves metadata, tags, series, and typed field values together', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('整理樱花卡'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('card-type-input')), '纪念卡');
    await tester.tap(find.byKey(const Key('needs-completion-switch')));
    await tester.tap(find.byKey(const Key('tag-chip-tag-1')));
    await tester.scrollUntilVisible(
      find.byKey(const Key('series-chip-series-1')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('series-chip-series-1')));
    await tester.scrollUntilVisible(
      find.byKey(const Key('field-input-field-1')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.byKey(const Key('field-input-field-1')),
      '票面完好',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('save-card-organization')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('save-card-organization')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final definition = await db.select(db.cardDefinitions).getSingle();
    expect(definition.cardType, '纪念卡');
    expect(definition.needsCompletion, isTrue);
    expect(await db.select(db.cardTags).get(), hasLength(1));
    expect(await db.select(db.seriesCards).get(), hasLength(1));
    expect(
      (await db.select(db.organizationFieldValues).getSingle()).textValue,
      '票面完好',
    );
    await _disposeApp(tester);
  });

  testWidgets('shows a recoverable missing-card state', (tester) async {
    await db.setItemDeletedAtForTest('item-1', now);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('这张卡片已不存在'), findsOneWidget);
    expect(find.text('返回'), findsOneWidget);
    await _disposeApp(tester);
  });
}

Future<void> _disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}
