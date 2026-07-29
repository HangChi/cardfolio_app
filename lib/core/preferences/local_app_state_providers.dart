import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/cards/data/card_providers.dart';
import '../../features/organization/domain/organization_models.dart';
import 'local_app_state.dart';

final Provider<LocalAppStateStore> localAppStateStoreProvider =
    Provider<LocalAppStateStore>((ref) => MemoryLocalAppStateStore());

final class MemoryLocalAppStateStore implements LocalAppStateStore {
  MemoryLocalAppStateStore([this._state = const LocalAppState()]);

  LocalAppState _state;

  @override
  Future<LocalAppState> read() async => _state;

  @override
  Future<LocalAppState> update(
    LocalAppState Function(LocalAppState current) change,
  ) async {
    _state = change(_state);
    return _state;
  }
}

final AsyncNotifierProvider<LocalAppStateController, LocalAppState>
localAppStateProvider =
    AsyncNotifierProvider<LocalAppStateController, LocalAppState>(
      LocalAppStateController.new,
    );

final class LocalAppStateController extends AsyncNotifier<LocalAppState> {
  @override
  Future<LocalAppState> build() {
    return ref.watch(localAppStateStoreProvider).read();
  }

  Future<void> completeOnboarding() =>
      _update((value) => value.copyWith(onboardingCompleted: true));

  Future<void> resetOnboarding() =>
      _update((value) => value.copyWith(onboardingCompleted: false));

  Future<void> setDiagnosticsEnabled(bool enabled) =>
      _update((value) => value.copyWith(diagnosticsEnabled: enabled));

  Future<void> saveFilter({
    String? id,
    required String name,
    required CardLibraryQuery query,
  }) {
    final filterId = id ?? ref.read(idGeneratorProvider).newId();
    return _update((value) {
      final next = <SavedCardFilter>[
        for (final filter in value.savedFilters)
          if (filter.id != filterId) filter,
        SavedCardFilter(id: filterId, name: name.trim(), query: query),
      ];
      return value.copyWith(savedFilters: next);
    });
  }

  Future<void> deleteFilter(String id) => _update(
    (value) => value.copyWith(
      savedFilters: value.savedFilters
          .where((filter) => filter.id != id)
          .toList(growable: false),
    ),
  );

  Future<void> saveBatchEntry(BatchEntrySnapshot snapshot) =>
      _update((value) => value.copyWith(batchEntry: snapshot));

  Future<void> clearBatchEntry() =>
      _update((value) => value.copyWith(clearBatchEntry: true));

  Future<void> _update(
    LocalAppState Function(LocalAppState current) change,
  ) async {
    final current =
        state.value ?? await ref.read(localAppStateStoreProvider).read();
    state = AsyncData(
      await ref.read(localAppStateStoreProvider).update((_) => change(current)),
    );
  }
}
