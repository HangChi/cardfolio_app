import 'dart:io';

import 'package:test/test.dart';
import 'package:cardfolio_app/core/preferences/local_app_state.dart';
import 'package:cardfolio_app/core/preferences/json_local_app_state_store.dart';
import 'package:cardfolio_app/features/organization/domain/organization_models.dart';

void main() {
  test('saved filter and batch draft survive a JSON round trip', () async {
    final root = await Directory.systemTemp.createTemp('cardfolio-state-');
    addTearDown(() => root.delete(recursive: true));
    final store = JsonLocalAppStateStore(File('${root.path}/state.json'));

    final filter = SavedCardFilter(
      id: 'filter-1',
      name: '上海交通卡',
      query: const CardLibraryQuery(
        searchText: '交通',
        city: '上海',
        year: 2025,
        tagIds: <String>['tag-1'],
        tagMatchMode: TagMatchMode.all,
        setMembership: SetMembershipFilter.inSet,
        duplicate: true,
        needsCompletion: false,
        sortField: CardSortField.name,
        sortDirection: SortDirection.ascending,
      ),
    );
    final batch = BatchEntrySnapshot(
      shared: const <String, Object?>{'city': '上海', 'issuer': '上海公共交通卡股份有限公司'},
      drafts: const <Map<String, Object?>>[
        <String, Object?>{
          'cardItemId': 'card-1',
          'name': '上海交通卡',
          'frontPath': 'C:/tmp/front.jpg',
        },
      ],
    );

    await store.update(
      (state) => state.copyWith(
        onboardingCompleted: true,
        diagnosticsEnabled: true,
        savedFilters: <SavedCardFilter>[filter],
        batchEntry: batch,
      ),
    );

    final reloaded = JsonLocalAppStateStore(File('${root.path}/state.json'));
    final state = await reloaded.read();
    expect(state.onboardingCompleted, isTrue);
    expect(state.diagnosticsEnabled, isTrue);
    expect(state.savedFilters.single.name, '上海交通卡');
    expect(state.savedFilters.single.query.city, '上海');
    expect(state.savedFilters.single.query.tagMatchMode, TagMatchMode.all);
    expect(state.savedFilters.single.query.sortField, CardSortField.name);
    expect(state.batchEntry?.shared['issuer'], contains('公共交通卡'));
    expect(state.batchEntry?.drafts.single['cardItemId'], 'card-1');
  });

  test('a corrupt state file falls back to defaults', () async {
    final root = await Directory.systemTemp.createTemp('cardfolio-state-');
    addTearDown(() => root.delete(recursive: true));
    final file = File('${root.path}/state.json');
    await file.writeAsString('{broken');

    final state = await JsonLocalAppStateStore(file).read();

    expect(state, const LocalAppState());
  });
}
