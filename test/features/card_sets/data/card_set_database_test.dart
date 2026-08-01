import 'package:cardfolio_app/features/card_sets/data/local/card_set_database.dart';
import 'package:cardfolio_app/features/card_sets/domain/card_set_models.dart';
import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 7, 28, 2, 3, 4);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  CardRowGraph ownedCard({
    required String suffix,
    required String name,
    int quantity = 1,
  }) {
    return CardRowGraph(
      definition: CardDefinitionsCompanion.insert(
        id: 'definition-$suffix',
        name: name,
        createdAt: now,
        updatedAt: now,
      ),
      item: CardItemsCompanion.insert(
        id: 'item-$suffix',
        definitionId: 'definition-$suffix',
        quantity: Value(quantity),
        createdAt: now,
        updatedAt: now,
      ),
      images: <CardImagesCompanion>[
        CardImagesCompanion.insert(
          id: 'image-$suffix',
          cardItemId: 'item-$suffix',
          kind: CardImageKind.front,
          relativePath: 'originals/item-$suffix/image-$suffix.jpg',
          checksum: 'sha256-$suffix',
          isCover: const Value(true),
          createdAt: now,
        ),
      ],
    );
  }

  Future<void> createSet({bool countKnown = true, int? expectedCount = 4}) {
    return db.createCardSet(
      request: CreateCardSetRequest(
        id: 'set-1',
        name: '四季纪念套卡',
        countKnown: countKnown,
        expectedCount: expectedCount,
        issueInfo: '2026 年发行',
      ).normalized(),
      now: now,
    );
  }

  test('creates and updates a set with a responsive summary', () async {
    await createSet();

    var summary = (await db.watchCardSetSummaries().first).single;
    expect(summary.name, '四季纪念套卡');
    expect(summary.expectedCount, 4);
    expect(summary.progress.ownedMemberCount, 0);
    expect(summary.progress.isComplete, isFalse);

    await db.updateCardSet(
      request: const UpdateCardSetRequest(
        id: 'set-1',
        name: '四季限定套卡',
        countKnown: false,
        expectedCount: 8,
        notes: '总数待考证',
      ).normalized(),
      now: now.add(const Duration(minutes: 1)),
    );

    summary = (await db.watchCardSetSummaries().first).single;
    expect(summary.name, '四季限定套卡');
    expect(summary.countKnown, isFalse);
    expect(summary.expectedCount, isNull);
    expect(summary.progress.fraction, isNull);
  });

  test('computes 3 of 4 despite one duplicate member', () async {
    await createSet();
    await db.insertCardGraph(ownedCard(suffix: '1', name: '春', quantity: 1));
    await db.insertCardGraph(ownedCard(suffix: '2', name: '夏', quantity: 2));
    await db.insertCardGraph(ownedCard(suffix: '3', name: '秋', quantity: 1));

    for (var index = 1; index <= 3; index++) {
      await db.addCardSetMember(
        request: AddCardSetMemberRequest.existing(
          id: 'member-$index',
          setId: 'set-1',
          definitionId: 'definition-$index',
          memberNo: '0$index',
        ).normalized(),
        now: now,
      );
    }
    await db.addCardSetMember(
      request: const AddCardSetMemberRequest.missing(
        id: 'member-4',
        setId: 'set-1',
        definitionId: 'definition-4',
        definitionName: '冬',
        memberNo: '04',
      ).normalized(),
      now: now,
    );

    final detail = await db.watchCardSetDetail('set-1').first;

    expect(detail, isNotNull);
    expect(detail!.members.map((member) => member.name), <String>[
      '春',
      '夏',
      '秋',
      '冬',
    ]);
    expect(detail.progress.ownedRequiredCount, 3);
    expect(detail.progress.requiredMemberCount, 4);
    expect(detail.progress.missingRequiredCount, 1);
    expect(detail.progress.duplicateMemberCount, 1);
    expect(detail.progress.fraction, 0.75);
    expect(detail.members[1].ownedQuantity, 2);
    expect(detail.members.last.isOwned, isFalse);
  });

  test(
    'rejects duplicate membership and incomplete reorder requests',
    () async {
      await createSet();
      await db.insertCardGraph(ownedCard(suffix: '1', name: '春'));
      await db.insertCardGraph(ownedCard(suffix: '2', name: '夏'));
      for (var index = 1; index <= 2; index++) {
        await db.addCardSetMember(
          request: AddCardSetMemberRequest.existing(
            id: 'member-$index',
            setId: 'set-1',
            definitionId: 'definition-$index',
          ).normalized(),
          now: now,
        );
      }

      await expectLater(
        db.addCardSetMember(
          request: const AddCardSetMemberRequest.existing(
            id: 'member-duplicate',
            setId: 'set-1',
            definitionId: 'definition-1',
          ).normalized(),
          now: now,
        ),
        throwsA(anything),
      );
      await expectLater(
        db.reorderCardSetMembers(
          setId: 'set-1',
          orderedMemberIds: const <String>['member-1', 'member-1'],
          now: now,
        ),
        throwsA(isA<StateError>()),
      );

      await db.reorderCardSetMembers(
        setId: 'set-1',
        orderedMemberIds: const <String>['member-2', 'member-1'],
        now: now,
      );
      expect(
        (await db.watchCardSetDetail('set-1').first)!.members.map(
          (member) => member.id,
        ),
        <String>['member-2', 'member-1'],
      );
    },
  );

  test('soft deletion and restoration recalculate progress', () async {
    await createSet(expectedCount: 1);
    await db.insertCardGraph(ownedCard(suffix: '1', name: '春'));
    await db.addCardSetMember(
      request: const AddCardSetMemberRequest.existing(
        id: 'member-1',
        setId: 'set-1',
        definitionId: 'definition-1',
      ).normalized(),
      now: now,
    );
    await db.setCardSetCover(setId: 'set-1', imageId: 'image-1', now: now);

    var detail = (await db.watchCardSetDetail('set-1').first)!;
    expect(detail.progress.fraction, 1);
    expect(detail.coverImageId, 'image-1');

    await db.setItemDeletedAtForTest('item-1', now);
    detail = (await db.watchCardSetDetail('set-1').first)!;
    expect(detail.progress.fraction, 0);
    expect(detail.coverImageId, isNull);

    await db.setItemDeletedAtForTest('item-1', null);
    detail = (await db.watchCardSetDetail('set-1').first)!;
    expect(detail.progress.fraction, 1);
    expect(detail.coverImageId, 'image-1');
  });

  test(
    'only accepts a cover from an active member and clears it on removal',
    () async {
      await createSet(expectedCount: 1);
      await db.insertCardGraph(ownedCard(suffix: '1', name: '春'));
      await db.insertCardGraph(ownedCard(suffix: '2', name: '非成员'));
      await db.addCardSetMember(
        request: const AddCardSetMemberRequest.existing(
          id: 'member-1',
          setId: 'set-1',
          definitionId: 'definition-1',
        ).normalized(),
        now: now,
      );

      await expectLater(
        db.setCardSetCover(setId: 'set-1', imageId: 'image-2', now: now),
        throwsA(isA<StateError>()),
      );

      await db.setCardSetCover(setId: 'set-1', imageId: 'image-1', now: now);
      expect(
        (await db.watchCardSetDetail('set-1').first)!.coverRelativePath,
        'originals/item-1/image-1.jpg',
      );

      await db.removeCardSetMember(
        setId: 'set-1',
        memberId: 'member-1',
        now: now,
      );
      final detail = (await db.watchCardSetDetail('set-1').first)!;
      expect(detail.coverImageId, isNull);
      expect(detail.members, isEmpty);
    },
  );

  test('removing the selected image also clears the set cover', () async {
    await createSet(expectedCount: 1);
    await db.insertCardGraph(ownedCard(suffix: '1', name: '春'));
    await db.addImages(
      cardItemId: 'item-1',
      images: <CardImagesCompanion>[
        CardImagesCompanion.insert(
          id: 'image-1-back',
          cardItemId: 'item-1',
          kind: CardImageKind.back,
          relativePath: 'originals/item-1/image-1-back.jpg',
          checksum: 'sha256-1-back',
          sortOrder: const Value(1),
          createdAt: now,
        ),
      ],
      updatedAt: now,
    );
    await db.addCardSetMember(
      request: const AddCardSetMemberRequest.existing(
        id: 'member-1',
        setId: 'set-1',
        definitionId: 'definition-1',
      ).normalized(),
      now: now,
    );
    await db.setCardSetCover(setId: 'set-1', imageId: 'image-1', now: now);
    final versionBeforeRemoval = await (db.select(
      db.cardSets,
    )..where((set) => set.id.equals('set-1'))).getSingle();

    await db.removeImage(
      cardItemId: 'item-1',
      imageId: 'image-1',
      keepOriginal: false,
      deletedAt: now.add(const Duration(minutes: 1)),
    );

    final detail = (await db.watchCardSetDetail('set-1').first)!;
    final storedSet = await (db.select(
      db.cardSets,
    )..where((set) => set.id.equals('set-1'))).getSingle();
    expect(detail.coverImageId, isNull);
    expect(detail.coverRelativePath, isNull);
    expect(storedSet.version, versionBeforeRemoval.version + 1);
  });

  test('a standalone cover overrides and can outlive a member cover', () async {
    await createSet(expectedCount: 1);
    await db.insertCardGraph(ownedCard(suffix: '1', name: '春'));
    await db.addCardSetMember(
      request: const AddCardSetMemberRequest.existing(
        id: 'member-1',
        setId: 'set-1',
        definitionId: 'definition-1',
      ).normalized(),
      now: now,
    );
    await db.setCardSetCover(setId: 'set-1', imageId: 'image-1', now: now);
    final before = await (db.select(
      db.cardSets,
    )..where((set) => set.id.equals('set-1'))).getSingle();

    await db.setCardSetStandaloneCover(
      setId: 'set-1',
      relativePath: 'originals/set-set-1/cover.jpg',
      now: now.add(const Duration(minutes: 1)),
    );

    var detail = (await db.watchCardSetDetail('set-1').first)!;
    final stored = await (db.select(
      db.cardSets,
    )..where((set) => set.id.equals('set-1'))).getSingle();
    expect(detail.coverImageId, isNull);
    expect(detail.coverRelativePath, 'originals/set-set-1/cover.jpg');
    expect(stored.version, before.version + 1);

    await db.removeCardSetMember(
      setId: 'set-1',
      memberId: 'member-1',
      now: now.add(const Duration(minutes: 2)),
    );
    detail = (await db.watchCardSetDetail('set-1').first)!;
    expect(detail.members, isEmpty);
    expect(detail.coverRelativePath, 'originals/set-set-1/cover.jpg');
  });

  test('selecting a member cover replaces the standalone cover', () async {
    await createSet(expectedCount: 1);
    await db.insertCardGraph(ownedCard(suffix: '1', name: '春'));
    await db.addCardSetMember(
      request: const AddCardSetMemberRequest.existing(
        id: 'member-1',
        setId: 'set-1',
        definitionId: 'definition-1',
      ).normalized(),
      now: now,
    );
    await db.setCardSetStandaloneCover(
      setId: 'set-1',
      relativePath: 'originals/set-set-1/cover.jpg',
      now: now,
    );

    await db.setCardSetCover(
      setId: 'set-1',
      imageId: 'image-1',
      now: now.add(const Duration(minutes: 1)),
    );

    final detail = (await db.watchCardSetDetail('set-1').first)!;
    expect(detail.coverImageId, 'image-1');
    expect(detail.coverRelativePath, 'originals/item-1/image-1.jpg');
  });

  test(
    'candidates include active owned styles not already in the set',
    () async {
      await createSet();
      await db.insertCardGraph(ownedCard(suffix: '1', name: '春'));
      await db.insertCardGraph(ownedCard(suffix: '2', name: '夏'));
      await db.addCardSetMember(
        request: const AddCardSetMemberRequest.existing(
          id: 'member-1',
          setId: 'set-1',
          definitionId: 'definition-1',
        ).normalized(),
        now: now,
      );

      final candidates = await db.watchCardSetCandidates('set-1').first;

      expect(candidates, hasLength(1));
      expect(candidates.single.definitionId, 'definition-2');
      expect(candidates.single.name, '夏');
      expect(candidates.single.ownedQuantity, 1);
      expect(candidates.single.coverImageId, 'image-2');
    },
  );
}
