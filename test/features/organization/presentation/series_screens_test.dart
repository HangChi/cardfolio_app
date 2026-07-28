import 'package:cardfolio_app/core/time/clock.dart';
import 'package:cardfolio_app/features/card_sets/data/local/card_set_database.dart';
import 'package:cardfolio_app/features/card_sets/domain/card_set_models.dart';
import 'package:cardfolio_app/features/cards/data/card_providers.dart';
import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:cardfolio_app/features/organization/data/local/organization_database.dart';
import 'package:cardfolio_app/features/organization/domain/organization_models.dart';
import 'package:cardfolio_app/features/organization/presentation/series/series_collection_view.dart';
import 'package:cardfolio_app/features/organization/presentation/series/series_detail_screen.dart';
import 'package:cardfolio_app/features/organization/presentation/series/series_form_screen.dart';
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
    await db.createCardSet(
      request: const CreateCardSetRequest(
        id: 'set-1',
        name: '四季套卡',
        countKnown: false,
      ).normalized(),
      now: now,
    );
  });

  tearDown(() => db.close());

  Widget app(Widget child) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(FixedClock(now)),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('series collection shows empty guidance and responsive counts', (
    tester,
  ) async {
    await tester.pumpWidget(app(const SeriesCollectionView()));
    await tester.pumpAndSettle();
    expect(find.text('还没有系列'), findsOneWidget);
    expect(find.text('新建系列'), findsOneWidget);

    await db.saveOrganizationSeries(
      request: const SaveSeriesRequest(
        id: 'series-1',
        name: '世博会',
        definitionIds: <String>['definition-1'],
        setIds: <String>['set-1'],
      ).normalized(),
      now: now,
    );
    await tester.pumpAndSettle();

    expect(find.text('世博会'), findsOneWidget);
    expect(find.text('1 款卡片 · 1 套卡'), findsOneWidget);
    await _disposeApp(tester);
  });

  testWidgets('series form saves selected card and set memberships', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app(const SeriesFormScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('series-name-input')), '东京');
    await tester.enterText(
      find.byKey(const Key('series-description-input')),
      '东京主题收藏',
    );
    await tester.tap(find.byKey(const Key('series-card-definition-1')));
    await tester.tap(find.byKey(const Key('series-set-set-1')));
    await tester.tap(find.byKey(const Key('save-series')));
    await tester.pumpAndSettle();

    final series = await db.select(db.seriesRecords).getSingle();
    expect(series.name, '东京');
    expect(await db.select(db.seriesCards).get(), hasLength(1));
    expect(await db.select(db.seriesSets).get(), hasLength(1));
    await _disposeApp(tester);
  });

  testWidgets('series detail separates cards and sets without completion', (
    tester,
  ) async {
    await db.saveOrganizationSeries(
      request: const SaveSeriesRequest(
        id: 'series-1',
        name: '东京系列',
        description: '宽泛主题',
        definitionIds: <String>['definition-1'],
        setIds: <String>['set-1'],
      ).normalized(),
      now: now,
    );

    await tester.pumpWidget(
      app(const SeriesDetailScreen(seriesId: 'series-1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('东京系列'), findsOneWidget);
    expect(find.text('系列用于宽泛归类，不计算完成度。'), findsOneWidget);
    expect(find.text('卡片 · 1'), findsOneWidget);
    expect(find.text('套卡 · 1'), findsOneWidget);
    expect(find.text('樱花卡'), findsOneWidget);
    expect(find.text('四季套卡'), findsOneWidget);
    await _disposeApp(tester);
  });
}

Future<void> _disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}
