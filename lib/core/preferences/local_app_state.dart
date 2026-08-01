import 'package:meta/meta.dart';

import '../../features/organization/domain/organization_models.dart';

enum AppThemePreference { system, light, dark }

@immutable
final class SavedCardFilter {
  const SavedCardFilter({
    required this.id,
    required this.name,
    required this.query,
  });

  final String id;
  final String name;
  final CardLibraryQuery query;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'name': name,
    'query': _queryToJson(query),
  };

  factory SavedCardFilter.fromJson(Map<String, Object?> json) {
    return SavedCardFilter(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      query: _queryFromJson(_map(json['query'])),
    );
  }
}

@immutable
final class BatchEntrySnapshot {
  const BatchEntrySnapshot({
    this.shared = const <String, Object?>{},
    this.drafts = const <Map<String, Object?>>[],
  });

  final Map<String, Object?> shared;
  final List<Map<String, Object?>> drafts;

  Map<String, Object?> toJson() => <String, Object?>{
    'shared': shared,
    'drafts': drafts,
  };

  factory BatchEntrySnapshot.fromJson(Map<String, Object?> json) {
    return BatchEntrySnapshot(
      shared: Map<String, Object?>.unmodifiable(_map(json['shared'])),
      drafts: List<Map<String, Object?>>.unmodifiable(
        (json['drafts'] as List<Object?>? ?? const <Object?>[])
            .map(_map)
            .where((value) => value.isNotEmpty),
      ),
    );
  }
}

@immutable
final class LocalAppState {
  const LocalAppState({
    this.onboardingCompleted = false,
    this.diagnosticsEnabled = false,
    this.themePreference = AppThemePreference.system,
    this.savedFilters = const <SavedCardFilter>[],
    this.batchEntry,
  });

  final bool onboardingCompleted;
  final bool diagnosticsEnabled;
  final AppThemePreference themePreference;
  final List<SavedCardFilter> savedFilters;
  final BatchEntrySnapshot? batchEntry;

  LocalAppState copyWith({
    bool? onboardingCompleted,
    bool? diagnosticsEnabled,
    AppThemePreference? themePreference,
    List<SavedCardFilter>? savedFilters,
    BatchEntrySnapshot? batchEntry,
    bool clearBatchEntry = false,
  }) {
    return LocalAppState(
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      diagnosticsEnabled: diagnosticsEnabled ?? this.diagnosticsEnabled,
      themePreference: themePreference ?? this.themePreference,
      savedFilters: savedFilters ?? this.savedFilters,
      batchEntry: clearBatchEntry ? null : batchEntry ?? this.batchEntry,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'version': 1,
    'onboardingCompleted': onboardingCompleted,
    'diagnosticsEnabled': diagnosticsEnabled,
    'themePreference': themePreference.name,
    'savedFilters': savedFilters.map((value) => value.toJson()).toList(),
    'batchEntry': batchEntry?.toJson(),
  };

  factory LocalAppState.fromJson(Map<String, Object?> json) {
    return LocalAppState(
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      diagnosticsEnabled: json['diagnosticsEnabled'] as bool? ?? false,
      themePreference: _themePreferenceFromJson(json['themePreference']),
      savedFilters: List<SavedCardFilter>.unmodifiable(
        (json['savedFilters'] as List<Object?>? ?? const <Object?>[])
            .map(_map)
            .where((value) => value.isNotEmpty)
            .map(SavedCardFilter.fromJson),
      ),
      batchEntry: switch (json['batchEntry']) {
        final Map<Object?, Object?> value => BatchEntrySnapshot.fromJson(
          value.map((key, value) => MapEntry('$key', value)),
        ),
        _ => null,
      },
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LocalAppState &&
      other.onboardingCompleted == onboardingCompleted &&
      other.diagnosticsEnabled == diagnosticsEnabled &&
      other.themePreference == themePreference &&
      other.savedFilters.length == savedFilters.length &&
      other.batchEntry == batchEntry;

  @override
  int get hashCode => Object.hash(
    onboardingCompleted,
    diagnosticsEnabled,
    themePreference,
    savedFilters.length,
    batchEntry,
  );
}

AppThemePreference _themePreferenceFromJson(Object? value) =>
    AppThemePreference.values
        .where((preference) => preference.name == value)
        .firstOrNull ??
    AppThemePreference.system;

abstract interface class LocalAppStateStore {
  Future<LocalAppState> read();

  Future<LocalAppState> update(
    LocalAppState Function(LocalAppState current) change,
  );
}

Map<String, Object?> _queryToJson(CardLibraryQuery query) => <String, Object?>{
  'searchText': query.searchText,
  'cardType': query.cardType,
  'city': query.city,
  'issuer': query.issuer,
  'year': query.year,
  'tagIds': query.tagIds,
  'tagMatchMode': query.tagMatchMode.name,
  'setMembership': query.setMembership.name,
  'duplicate': query.duplicate,
  'needsCompletion': query.needsCompletion,
  'setStatus': query.setStatus?.name,
  'sortField': query.sortField.name,
  'sortDirection': query.sortDirection.name,
};

CardLibraryQuery _queryFromJson(Map<String, Object?> json) {
  T enumValue<T extends Enum>(List<T> values, Object? name, T fallback) {
    return values.where((value) => value.name == name).firstOrNull ?? fallback;
  }

  return CardLibraryQuery(
    searchText: json['searchText'] as String?,
    cardType: json['cardType'] as String?,
    city: json['city'] as String?,
    issuer: json['issuer'] as String?,
    year: json['year'] as int?,
    tagIds: List<String>.unmodifiable(
      (json['tagIds'] as List<Object?>? ?? const <Object?>[])
          .whereType<String>(),
    ),
    tagMatchMode: enumValue(
      TagMatchMode.values,
      json['tagMatchMode'],
      TagMatchMode.any,
    ),
    setMembership: enumValue(
      SetMembershipFilter.values,
      json['setMembership'],
      SetMembershipFilter.any,
    ),
    duplicate: json['duplicate'] as bool?,
    needsCompletion: json['needsCompletion'] as bool?,
    setStatus: json['setStatus'] == null
        ? null
        : enumValue(
            CardSetStatusFilter.values,
            json['setStatus'],
            CardSetStatusFilter.unknown,
          ),
    sortField: enumValue(
      CardSortField.values,
      json['sortField'],
      CardSortField.createdAt,
    ),
    sortDirection: enumValue(
      SortDirection.values,
      json['sortDirection'],
      SortDirection.descending,
    ),
  ).normalized();
}

Map<String, Object?> _map(Object? value) {
  if (value is! Map<Object?, Object?>) return const <String, Object?>{};
  return value.map((key, value) => MapEntry('$key', value));
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
