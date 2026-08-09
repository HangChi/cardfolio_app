import 'package:cardfolio_app/core/time/clock.dart';
import 'package:cardfolio_app/features/cards/data/card_providers.dart';
import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/cards/presentation/library/card_library_screen.dart';
import 'package:cardfolio_app/features/organization/data/local/organization_database.dart';
import 'package:cardfolio_app/features/organization/data/organization_providers.dart';
import 'package:cardfolio_app/features/organization/domain/organization_models.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late ProviderContainer container;
  final now = DateTime.utc(2026, 7, 28, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(FixedClock(now)),
        cardFilterFacetsProvider.overrideWith(
          (ref) => Stream<CardFilterFacets>.value(
            CardFilterFacets(
              cardTypes: const <String>[],
              cities: const <String>[],
              years: const <int>[],
              tags: <TagSummary>[
                TagSummary(
                  id: 'tag-1',
                  name: '纪念卡',
                  cardCount: 0,
                  createdAt: now,
                  updatedAt: now,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> pumpLibrary(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: CardLibraryScreen())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('search updates the query only after 250 ms debounce', (
    tester,
  ) async {
    await pumpLibrary(tester);

    await tester.enterText(find.byKey(const Key('library-search-input')), '上海');
    await tester.pump(const Duration(milliseconds: 249));
    expect(container.read(cardLibraryQueryProvider).searchText, isNull);

    await tester.pump(const Duration(milliseconds: 1));
    expect(container.read(cardLibraryQueryProvider).searchText, '上海');
  });

  testWidgets('filter sheet applies tags and set membership together', (
    tester,
  ) async {
    await db.createOrganizationTag(
      request: const CreateTagRequest(id: 'tag-1', name: '纪念卡').normalized(),
      now: now,
    );
    await pumpLibrary(tester);

    await tester.tap(find.byKey(const Key('open-library-filters')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).last, const Offset(0, -220));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('filter-tag-tag-1')));
    await tester.ensureVisible(find.byKey(const Key('filter-set-inSet')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('filter-set-inSet')));
    await tester.tap(find.byKey(const Key('apply-library-filters')));
    await tester.pumpAndSettle();

    final query = container.read(cardLibraryQueryProvider);
    expect(query.tagIds, <String>['tag-1']);
    expect(query.setMembership, SetMembershipFilter.inSet);
    expect(find.text('标签：任一 1'), findsOneWidget);
    expect(find.text('已加入套卡'), findsOneWidget);
  });

  testWidgets('sort menu changes field and direction without filtering', (
    tester,
  ) async {
    await pumpLibrary(tester);

    await tester.tap(find.byKey(const Key('library-sort-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('名称 A–Z').last);
    await tester.pumpAndSettle();

    final query = container.read(cardLibraryQueryProvider);
    expect(query.sortField, CardSortField.name);
    expect(query.sortDirection, SortDirection.ascending);
    expect(query.isFiltering, isFalse);
  });

  testWidgets('sort menu exposes issue-date ordering', (tester) async {
    await pumpLibrary(tester);

    await tester.tap(find.byKey(const Key('library-sort-menu')));
    await tester.pumpAndSettle();
    expect(find.textContaining('入手成本'), findsNothing);
    await tester.tap(find.text('发行日期：新到旧').last);
    await tester.pumpAndSettle();

    final query = container.read(cardLibraryQueryProvider);
    expect(query.sortField, CardSortField.issuedAt);
    expect(query.sortDirection, SortDirection.descending);
  });
}
