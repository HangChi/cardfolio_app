import 'dart:convert';
import 'dart:typed_data';

const Set<String> syncEntityTypes = <String>{
  'cardDefinitions',
  'cardItems',
  'cardImages',
  'cardSets',
  'cardSetMembers',
  'tags',
  'cardTags',
  'seriesRecords',
  'seriesCards',
  'seriesSets',
  'customFieldDefinitions',
  'customFieldValues',
  'purchases',
  'purchaseItems',
  'exchangeRates',
  'recycleBinSettings',
};

enum SyncOperation { upsert, delete }

enum SyncMergeKind { merged, conflict }

enum SyncConflictResolution { keepLocal, useRemote, merge }

enum SyncPhase {
  localOnly,
  disabled,
  pending,
  syncing,
  synced,
  failed,
  conflicts,
}

final RegExp _uuidPattern = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-'
  r'[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
);

final class SyncMutation {
  SyncMutation({
    required this.operationId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.baseServerVersion,
    required Map<String, Object?>? payload,
    required Set<String> changedFields,
    required DateTime createdAt,
  }) : payload = payload == null
           ? null
           : Map<String, Object?>.unmodifiable(payload),
       changedFields = Set<String>.unmodifiable(changedFields),
       createdAt = createdAt.toUtc() {
    if (!_uuidPattern.hasMatch(operationId)) {
      throw ArgumentError.value(operationId, 'operationId', '必须是 UUID');
    }
    if (!syncEntityTypes.contains(entityType)) {
      throw ArgumentError.value(entityType, 'entityType', '不是可同步实体');
    }
    if (entityId.isEmpty) {
      throw ArgumentError.value(entityId, 'entityId', '不能为空');
    }
    if (baseServerVersion < 0) {
      throw ArgumentError.value(
        baseServerVersion,
        'baseServerVersion',
        '不能为负数',
      );
    }
    if (operation == SyncOperation.upsert && payload == null) {
      throw ArgumentError('upsert 必须包含 payload');
    }
    if (operation == SyncOperation.delete && payload != null) {
      throw ArgumentError('delete 不得包含 payload');
    }
  }

  factory SyncMutation.fromJson(Map<String, Object?> json) {
    return SyncMutation(
      operationId: _string(json, 'operationId'),
      entityType: _string(json, 'entityType'),
      entityId: _string(json, 'entityId'),
      operation: SyncOperation.values.byName(_string(json, 'operation')),
      baseServerVersion: _integer(json, 'baseServerVersion'),
      payload: _optionalMap(json['payload']),
      changedFields: _stringSet(json, 'changedFields'),
      createdAt: DateTime.parse(_string(json, 'createdAt')).toUtc(),
    );
  }

  final String operationId;
  final String entityType;
  final String entityId;
  final SyncOperation operation;
  final int baseServerVersion;
  final Map<String, Object?>? payload;
  final Set<String> changedFields;
  final DateTime createdAt;

  Map<String, Object?> toJson() => <String, Object?>{
    'operationId': operationId,
    'entityType': entityType,
    'entityId': entityId,
    'operation': operation.name,
    'baseServerVersion': baseServerVersion,
    'payload': payload,
    'changedFields': changedFields.toList()..sort(),
    'createdAt': createdAt.toIso8601String(),
  };
}

final class SyncAck {
  const SyncAck({
    required this.operationId,
    required this.entityType,
    required this.entityId,
    required this.serverVersion,
  });

  factory SyncAck.fromJson(Map<String, Object?> json) => SyncAck(
    operationId: _string(json, 'operationId'),
    entityType: _string(json, 'entityType'),
    entityId: _string(json, 'entityId'),
    serverVersion: _integer(json, 'serverVersion'),
  );

  final String operationId;
  final String entityType;
  final String entityId;
  final int serverVersion;

  Map<String, Object?> toJson() => <String, Object?>{
    'operationId': operationId,
    'entityType': entityType,
    'entityId': entityId,
    'serverVersion': serverVersion,
  };
}

final class RemoteSyncChange {
  RemoteSyncChange({
    required this.changeId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.serverVersion,
    required Map<String, Object?>? payload,
    required Set<String> changedFields,
    required DateTime occurredAt,
  }) : payload = payload == null
           ? null
           : Map<String, Object?>.unmodifiable(payload),
       changedFields = Set<String>.unmodifiable(changedFields),
       occurredAt = occurredAt.toUtc() {
    if (!syncEntityTypes.contains(entityType) ||
        entityId.isEmpty ||
        serverVersion <= 0) {
      throw ArgumentError('远端变更标识或版本无效');
    }
    if ((operation == SyncOperation.upsert) != (payload != null)) {
      throw ArgumentError('远端变更操作与 payload 不匹配');
    }
  }

  factory RemoteSyncChange.fromJson(Map<String, Object?> json) =>
      RemoteSyncChange(
        changeId: _string(json, 'changeId'),
        entityType: _string(json, 'entityType'),
        entityId: _string(json, 'entityId'),
        operation: SyncOperation.values.byName(_string(json, 'operation')),
        serverVersion: _integer(json, 'serverVersion'),
        payload: _optionalMap(json['payload']),
        changedFields: _stringSet(json, 'changedFields'),
        occurredAt: DateTime.parse(_string(json, 'occurredAt')).toUtc(),
      );

  final String changeId;
  final String entityType;
  final String entityId;
  final SyncOperation operation;
  final int serverVersion;
  final Map<String, Object?>? payload;
  final Set<String> changedFields;
  final DateTime occurredAt;

  Map<String, Object?> toJson() => <String, Object?>{
    'changeId': changeId,
    'entityType': entityType,
    'entityId': entityId,
    'operation': operation.name,
    'serverVersion': serverVersion,
    'payload': payload,
    'changedFields': changedFields.toList()..sort(),
    'occurredAt': occurredAt.toIso8601String(),
  };
}

final class SyncPushResult {
  SyncPushResult({
    required List<SyncAck> acknowledgements,
    required List<RemoteSyncChange> changes,
    required this.cursor,
  }) : acknowledgements = List<SyncAck>.unmodifiable(acknowledgements),
       changes = List<RemoteSyncChange>.unmodifiable(changes);

  final List<SyncAck> acknowledgements;
  final List<RemoteSyncChange> changes;
  final String? cursor;
}

final class SyncPullPage {
  SyncPullPage({
    required List<RemoteSyncChange> changes,
    required this.cursor,
    required this.hasMore,
  }) : changes = List<RemoteSyncChange>.unmodifiable(changes);

  final List<RemoteSyncChange> changes;
  final String? cursor;
  final bool hasMore;
}

final class AccountSession {
  AccountSession({
    required this.userId,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
    required DateTime expiresAt,
  }) : expiresAt = expiresAt.toUtc() {
    if (userId.isEmpty ||
        email.trim().isEmpty ||
        accessToken.isEmpty ||
        refreshToken.isEmpty) {
      throw ArgumentError('账号会话字段不能为空');
    }
  }

  factory AccountSession.fromJson(Map<String, Object?> json) => AccountSession(
    userId: _string(json, 'userId'),
    email: _string(json, 'email'),
    accessToken: _string(json, 'accessToken'),
    refreshToken: _string(json, 'refreshToken'),
    expiresAt: DateTime.parse(_string(json, 'expiresAt')).toUtc(),
  );

  final String userId;
  final String email;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  Map<String, Object?> toJson() => <String, Object?>{
    'userId': userId,
    'email': email,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresAt': expiresAt.toIso8601String(),
  };
}

final class AccountSummary {
  const AccountSummary({required this.userId, required this.email});

  final String userId;
  final String email;
}

final class SyncConflict {
  SyncConflict({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.localOperation,
    required Map<String, Object?>? localPayload,
    required this.remoteOperation,
    required Map<String, Object?>? remotePayload,
    required this.remoteServerVersion,
    required Set<String> conflictingFields,
    required DateTime detectedAt,
  }) : localPayload = localPayload == null
           ? null
           : Map<String, Object?>.unmodifiable(localPayload),
       remotePayload = remotePayload == null
           ? null
           : Map<String, Object?>.unmodifiable(remotePayload),
       conflictingFields = Set<String>.unmodifiable(conflictingFields),
       detectedAt = detectedAt.toUtc();

  final String id;
  final String entityType;
  final String entityId;
  final SyncOperation localOperation;
  final Map<String, Object?>? localPayload;
  final SyncOperation remoteOperation;
  final Map<String, Object?>? remotePayload;
  final int remoteServerVersion;
  final Set<String> conflictingFields;
  final DateTime detectedAt;
}

final class SyncOverview {
  const SyncOverview({
    required this.account,
    required this.enabled,
    required this.phase,
    required this.pendingCount,
    required this.conflictCount,
    required this.lastSyncedAt,
    required this.lastErrorCode,
  });

  const SyncOverview.localOnly()
    : account = null,
      enabled = false,
      phase = SyncPhase.localOnly,
      pendingCount = 0,
      conflictCount = 0,
      lastSyncedAt = null,
      lastErrorCode = null;

  final AccountSummary? account;
  final bool enabled;
  final SyncPhase phase;
  final int pendingCount;
  final int conflictCount;
  final DateTime? lastSyncedAt;
  final String? lastErrorCode;
}

final class CloudDataDownload {
  CloudDataDownload({
    required this.fileName,
    required Uint8List bytes,
    required this.sha256,
  }) : bytes = Uint8List.fromList(bytes);

  final String fileName;
  final Uint8List bytes;
  final String sha256;
}

final class SyncMergeResult {
  SyncMergeResult._({
    required this.kind,
    required this.operation,
    required Map<String, Object?>? payload,
    required Set<String> conflictingFields,
  }) : payload = payload == null
           ? null
           : Map<String, Object?>.unmodifiable(payload),
       conflictingFields = Set<String>.unmodifiable(conflictingFields);

  factory SyncMergeResult.merged(
    SyncOperation operation,
    Map<String, Object?>? payload,
  ) => SyncMergeResult._(
    kind: SyncMergeKind.merged,
    operation: operation,
    payload: payload,
    conflictingFields: const <String>{},
  );

  factory SyncMergeResult.conflict(Set<String> fields) => SyncMergeResult._(
    kind: SyncMergeKind.conflict,
    operation: SyncOperation.upsert,
    payload: null,
    conflictingFields: fields,
  );

  final SyncMergeKind kind;
  final SyncOperation operation;
  final Map<String, Object?>? payload;
  final Set<String> conflictingFields;
}

SyncMergeResult mergeSyncPayload({
  required Map<String, Object?>? basePayload,
  required Map<String, Object?>? localPayload,
  required Map<String, Object?>? remotePayload,
  required SyncOperation localOperation,
  required SyncOperation remoteOperation,
}) {
  if (localOperation == SyncOperation.delete &&
      remoteOperation == SyncOperation.delete) {
    return SyncMergeResult.merged(SyncOperation.delete, null);
  }

  if (localOperation != remoteOperation) {
    final upsertPayload = localOperation == SyncOperation.upsert
        ? localPayload
        : remotePayload;
    if (_jsonEquals(upsertPayload, basePayload)) {
      return SyncMergeResult.merged(SyncOperation.delete, null);
    }
    return SyncMergeResult.conflict(const <String>{r'$operation'});
  }

  final local = localPayload ?? const <String, Object?>{};
  final remote = remotePayload ?? const <String, Object?>{};
  final base = basePayload ?? const <String, Object?>{};
  final keys = <String>{...base.keys, ...local.keys, ...remote.keys};
  final localChanges = keys
      .where((key) => !_sameField(base, local, key))
      .toSet();
  final remoteChanges = keys
      .where((key) => !_sameField(base, remote, key))
      .toSet();
  final conflicts = localChanges.intersection(remoteChanges).where((key) {
    return !_sameField(local, remote, key);
  }).toSet();
  if (conflicts.isNotEmpty) return SyncMergeResult.conflict(conflicts);

  final merged = Map<String, Object?>.from(base);
  _applyChangedFields(merged, local, localChanges);
  _applyChangedFields(merged, remote, remoteChanges);
  return SyncMergeResult.merged(SyncOperation.upsert, merged);
}

Set<String> changedSyncFields(
  Map<String, Object?>? base,
  Map<String, Object?>? current,
) {
  final before = base ?? const <String, Object?>{};
  final after = current ?? const <String, Object?>{};
  return <String>{
    ...before.keys,
    ...after.keys,
  }.where((key) => !_sameField(before, after, key)).toSet();
}

String canonicalSyncJson(Map<String, Object?> value) =>
    jsonEncode(_canonicalize(value));

void _applyChangedFields(
  Map<String, Object?> merged,
  Map<String, Object?> source,
  Set<String> changed,
) {
  for (final key in changed) {
    if (source.containsKey(key)) {
      merged[key] = source[key];
    } else {
      merged.remove(key);
    }
  }
}

bool _sameField(
  Map<String, Object?> left,
  Map<String, Object?> right,
  String key,
) {
  if (left.containsKey(key) != right.containsKey(key)) return false;
  return _jsonEquals(left[key], right[key]);
}

bool _jsonEquals(Object? left, Object? right) =>
    jsonEncode(_canonicalize(left)) == jsonEncode(_canonicalize(right));

Object? _canonicalize(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return <String, Object?>{
      for (final key in keys) key: _canonicalize(value[key]),
    };
  }
  if (value is List) return value.map(_canonicalize).toList(growable: false);
  return value;
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty) {
    throw FormatException('$key 必须是非空字符串');
  }
  return value;
}

int _integer(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! int) throw FormatException('$key 必须是整数');
  return value;
}

Map<String, Object?>? _optionalMap(Object? value) {
  if (value == null) return null;
  if (value is! Map) throw const FormatException('payload 必须是对象');
  return <String, Object?>{
    for (final entry in value.entries) entry.key.toString(): entry.value,
  };
}

Set<String> _stringSet(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! List || value.any((item) => item is! String)) {
    throw FormatException('$key 必须是字符串数组');
  }
  return value.cast<String>().toSet();
}
