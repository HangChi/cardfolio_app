import 'dart:io';

import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/core/id/id_generator.dart';
import 'package:cardfolio_app/core/time/clock.dart';
import 'package:cardfolio_app/features/cards/data/files/managed_image_store.dart';
import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:crypto/crypto.dart';
import 'package:cardfolio_app/features/sync/data/account_sync_repository_impl.dart';
import 'package:cardfolio_app/features/sync/data/local/sync_local_store.dart';
import 'package:cardfolio_app/features/sync/domain/sync_models.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  late AppDatabase database;
  late Directory imageRoot;
  late ManagedImageStore images;
  late FixedClock clock;
  late SyncLocalStore local;
  late MemorySecureSessionStore sessions;
  late FakeAccountSyncRemote remote;
  late AccountSyncRepositoryImpl repository;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    imageRoot = await Directory.systemTemp.createTemp('cardfolio-sync-images-');
    images = ManagedImageStore(imageRoot);
    clock = FixedClock(DateTime.utc(2026, 7, 29, 8));
    local = SyncLocalStore(
      database: database,
      idGenerator: _SequenceIdGenerator(),
      clock: clock,
    );
    sessions = MemorySecureSessionStore();
    remote = FakeAccountSyncRemote();
    repository = AccountSyncRepositoryImpl(
      remote: remote,
      sessions: sessions,
      local: local,
      images: images,
      clock: clock,
    );
    final session = remote.session();
    sessions.session = session;
    await local.setAccount(
      AccountSummary(userId: session.userId, email: session.email),
    );
    await local.setEnabled(true);
  });

  tearDown(() async {
    await database.close();
    if (imageRoot.existsSync()) await imageRoot.delete(recursive: true);
  });

  test('replays 20 offline creates with the same operation ids', () async {
    for (var index = 0; index < 20; index++) {
      await _insertDefinition(database, index + 1);
    }
    remote.failFirstPushAfterAccept = true;

    await expectLater(
      repository.syncNow(),
      throwsA(isA<SyncTransportFailure>()),
    );
    final firstIds = remote.pushCalls.single
        .map((item) => item.operationId)
        .toList();
    expect(remote.acceptedOperationVersions, hasLength(20));
    clock.advance(const Duration(seconds: 3));

    await repository.syncNow();

    final secondIds = remote.pushCalls[1]
        .map((item) => item.operationId)
        .toList();
    expect(secondIds, firstIds);
    expect(remote.acceptedOperationVersions, hasLength(20));
    expect(await local.pendingMutations(), isEmpty);
  });

  test('refreshes an expiring token before push and persists it', () async {
    sessions.session = remote.session(
      expiresAt: DateTime.utc(2026, 7, 29, 8, 0, 30),
    );
    await _insertDefinition(database, 1);

    await repository.syncNow();

    expect(remote.refreshCalls, 1);
    expect(sessions.session?.accessToken, 'refreshed-access');
  });

  test(
    'uploads original and derived attachments before image metadata',
    () async {
      final jpeg = <int>[
        0xff,
        0xd8,
        0xff,
        ...List<int>.filled(32, 1),
        0xff,
        0xd9,
      ];
      final source = File(
        '${imageRoot.path}${Platform.pathSeparator}source.jpg',
      );
      await source.writeAsBytes(jpeg);
      final imported = await images.importImage(
        sourcePath: source.path,
        cardItemId: _uuid(2),
        imageId: _uuid(3),
      );
      final now = DateTime.utc(2026, 7, 29, 8);
      await database.insertCardGraph(
        CardRowGraph(
          definition: CardDefinitionsCompanion.insert(
            id: _uuid(1),
            name: '带图卡片',
            createdAt: now,
            updatedAt: now,
          ),
          item: CardItemsCompanion.insert(
            id: _uuid(2),
            definitionId: _uuid(1),
            createdAt: now,
            updatedAt: now,
          ),
          images: <CardImagesCompanion>[
            CardImagesCompanion.insert(
              id: _uuid(3),
              cardItemId: _uuid(2),
              kind: CardImageKind.front,
              relativePath: imported.relativePath,
              checksum: imported.checksum,
              isCover: const Value(true),
              createdAt: now,
            ),
          ],
        ),
      );

      await repository.syncNow();

      expect(remote.attachments[imported.checksum], jpeg);
      final imageMutation = remote.pushCalls.single.singleWhere(
        (item) => item.entityType == 'cardImages',
      );
      final attachment =
          (imageMutation.payload!['_attachments']! as List).single
              as Map<String, Object?>;
      expect(attachment['relativePath'], imported.relativePath);
      expect(attachment['checksum'], sha256.convert(jpeg).toString());
    },
  );

  test('sign out succeeds locally when remote logout is offline', () async {
    await _insertDefinition(database, 1);
    remote.failLogout = true;

    await repository.signOut();

    expect(sessions.session, isNull);
    expect((await local.settings()).account, isNull);
    expect(await database.select(database.cardDefinitions).get(), hasLength(1));
  });

  test(
    'account deletion can remove all local rows after remote confirmation',
    () async {
      await _insertDefinition(database, 1);

      await repository.deleteAccount(deleteLocalCopy: true);

      expect(remote.deleteCalls, 1);
      expect(sessions.session, isNull);
      expect(await database.select(database.cardDefinitions).get(), isEmpty);
    },
  );
}

Future<void> _insertDefinition(AppDatabase database, int index) {
  final now = DateTime.utc(2026, 7, 29, 8);
  return database
      .into(database.cardDefinitions)
      .insert(
        CardDefinitionsCompanion.insert(
          id: _uuid(index),
          name: '离线卡 $index',
          createdAt: now,
          updatedAt: now,
        ),
      );
}

String _uuid(int value) =>
    '00000000-0000-4000-8000-${value.toString().padLeft(12, '0')}';

final class _SequenceIdGenerator implements IdGenerator {
  var _next = 2000;

  @override
  String newId() => _uuid(_next++);
}
