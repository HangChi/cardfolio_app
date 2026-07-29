import 'dart:io';

import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/core/time/clock.dart';
import 'package:cardfolio_app/features/cards/data/files/managed_image_store.dart';
import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:cardfolio_app/features/recycle_bin/data/local/recycle_bin_database.dart';
import 'package:cardfolio_app/features/recycle_bin/data/recycle_bin_repository_impl.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late AppDatabase db;
  late Directory root;
  late FixedClock clock;

  final now = DateTime.utc(2026, 7, 31, 12);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    root = await Directory.systemTemp.createTemp('cardfolio-trash-');
    clock = FixedClock(now);
  });

  tearDown(() async {
    await db.close();
    if (root.existsSync()) await root.delete(recursive: true);
  });

  Future<void> seedCard({String itemId = 'item-1', DateTime? deletedAt}) async {
    await db.insertCardGraph(
      CardRowGraph(
        definition: CardDefinitionsCompanion.insert(
          id: 'definition-$itemId',
          name: '樱花纪念卡',
          createdAt: now,
          updatedAt: now,
        ),
        item: CardItemsCompanion.insert(
          id: itemId,
          definitionId: 'definition-$itemId',
          createdAt: now,
          updatedAt: now,
          deletedAt: Value(deletedAt),
        ),
        images: <CardImagesCompanion>[
          CardImagesCompanion.insert(
            id: 'image-$itemId',
            cardItemId: itemId,
            kind: CardImageKind.front,
            relativePath: 'originals/$itemId/front.jpg',
            checksum: 'sha256-$itemId',
            isCover: const Value(true),
            createdAt: now,
          ),
        ],
      ),
    );
    final file = File(p.join(root.path, 'originals', itemId, 'front.jpg'));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(<int>[1, 2, 3], flush: true);
  }

  test('soft delete and restore expose the same card id', () async {
    await seedCard();
    final repository = RecycleBinRepositoryImpl(
      database: db,
      imageStore: ManagedImageStore(root),
      clock: clock,
    );

    await repository.deleteCard('item-1');
    expect((await repository.watchEntries().first).single.cardItemId, 'item-1');
    expect(await db.watchCardSummaries().first, isEmpty);

    await repository.restoreCard('item-1');
    expect(await repository.watchEntries().first, isEmpty);
    expect((await db.watchCardSummaries().first).single.cardItemId, 'item-1');
  });

  test('permanent deletion removes files and completed queue rows', () async {
    await seedCard(deletedAt: now.subtract(const Duration(days: 1)));
    final repository = RecycleBinRepositoryImpl(
      database: db,
      imageStore: ManagedImageStore(root),
      clock: clock,
    );
    final file = File(p.join(root.path, 'originals', 'item-1', 'front.jpg'));

    await repository.permanentlyDelete('item-1');

    expect(file.existsSync(), isFalse);
    expect(await db.pendingFileCleanup(), isEmpty);
    expect(await db.countItems(), 0);
  });

  test('failed file deletion stays queued and records an attempt', () async {
    await seedCard(deletedAt: now.subtract(const Duration(days: 1)));
    final repository = RecycleBinRepositoryImpl(
      database: db,
      imageStore: _FailingImageStore(root),
      clock: clock,
    );

    await repository.permanentlyDelete('item-1');

    final queued = (await db.pendingFileCleanup()).single;
    expect(queued.relativePath, 'originals/item-1/front.jpg');
    expect(queued.attemptCount, 1);
    expect(queued.lastAttemptAt?.toUtc(), now);
  });

  test('purge expired removes only cards at or before the cutoff', () async {
    await seedCard(
      itemId: 'old',
      deletedAt: now.subtract(const Duration(days: 30)),
    );
    await seedCard(
      itemId: 'new',
      deletedAt: now.subtract(const Duration(days: 29, hours: 23)),
    );
    final repository = RecycleBinRepositoryImpl(
      database: db,
      imageStore: ManagedImageStore(root),
      clock: clock,
    );

    final count = await repository.purgeExpired();

    expect(count, 1);
    expect(
      (await repository.watchEntries().first).map((entry) => entry.cardItemId),
      <String>['new'],
    );
  });
}

final class _FailingImageStore extends ManagedImageStore {
  _FailingImageStore(super.root);

  @override
  Future<void> delete(String relativePath) {
    throw const ImageImportFailure('模拟文件占用');
  }
}
