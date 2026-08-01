import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/core/time/clock.dart';
import 'package:cardfolio_app/features/card_sets/data/card_set_repository_impl.dart';
import 'package:cardfolio_app/features/card_sets/domain/card_set_models.dart';
import 'package:cardfolio_app/features/card_sets/domain/card_set_repository.dart';
import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late CardSetRepository repository;
  final now = DateTime.utc(2026, 7, 28, 6);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = CardSetRepositoryImpl(database: db, clock: FixedClock(now));
  });

  tearDown(() => db.close());

  Future<void> insertOwnedCard() {
    return db.insertCardGraph(
      CardRowGraph(
        definition: CardDefinitionsCompanion.insert(
          id: 'definition-1',
          name: '春',
          createdAt: now,
          updatedAt: now,
        ),
        item: CardItemsCompanion.insert(
          id: 'item-1',
          definitionId: 'definition-1',
          quantity: const Value(2),
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
  }

  const createRequest = CreateCardSetRequest(
    id: ' set-1 ',
    name: ' 四季套卡 ',
    countKnown: true,
    expectedCount: 2,
  );

  test('normalizes and creates a set idempotently', () async {
    final first = await repository.createSet(createRequest);
    final second = await repository.createSet(createRequest);

    expect(first, 'set-1');
    expect(second, 'set-1');
    final sets = await repository.watchSets().first;
    expect(sets, hasLength(1));
    expect(sets.single.name, '四季套卡');
    expect(sets.single.createdAt, now);
  });

  test('adds owned and missing members through one stable contract', () async {
    await insertOwnedCard();
    await repository.createSet(createRequest);

    await repository.addMember(
      const AddCardSetMemberRequest.existing(
        id: 'member-1',
        setId: 'set-1',
        definitionId: 'definition-1',
      ),
    );
    await repository.addMember(
      const AddCardSetMemberRequest.missing(
        id: 'member-2',
        setId: 'set-1',
        definitionId: 'definition-2',
        definitionName: ' 夏 ',
      ),
    );

    final detail = await repository.watchSet('set-1').first;
    expect(detail!.members.map((member) => member.name), <String>['春', '夏']);
    expect(detail.progress.ownedRequiredCount, 1);
    expect(detail.progress.duplicateMemberCount, 1);
    expect(detail.progress.fraction, 0.5);
    expect(await repository.watchCandidates('set-1').first, isEmpty);
  });

  test('maps relationship conflicts to a member-scoped failure', () async {
    await insertOwnedCard();
    await repository.createSet(createRequest);
    const member = AddCardSetMemberRequest.existing(
      id: 'member-1',
      setId: 'set-1',
      definitionId: 'definition-1',
    );
    await repository.addMember(member);

    await expectLater(
      repository.addMember(
        const AddCardSetMemberRequest.existing(
          id: 'member-2',
          setId: 'set-1',
          definitionId: 'definition-1',
        ),
      ),
      throwsA(
        isA<CardSetValidationFailure>().having(
          (failure) => failure.field,
          'field',
          CardSetField.member,
        ),
      ),
    );
  });

  test('maps an expected-count conflict to the count field', () async {
    await insertOwnedCard();
    await repository.createSet(createRequest);
    await repository.addMember(
      const AddCardSetMemberRequest.existing(
        id: 'member-1',
        setId: 'set-1',
        definitionId: 'definition-1',
      ),
    );

    await expectLater(
      repository.updateSet(
        const UpdateCardSetRequest(
          id: 'set-1',
          name: '四季套卡',
          countKnown: true,
          expectedCount: 0,
        ),
      ),
      throwsA(
        isA<CardSetValidationFailure>().having(
          (failure) => failure.field,
          'field',
          CardSetField.expectedCount,
        ),
      ),
    );
  });

  test('normalizes standalone cover paths and clears blank paths', () async {
    await repository.createSet(createRequest);

    await repository.setStandaloneCover(
      setId: ' set-1 ',
      relativePath: ' originals/set-set-1/cover.jpg ',
    );

    var detail = await repository.watchSet('set-1').first;
    expect(detail?.coverImageId, isNull);
    expect(detail?.coverRelativePath, 'originals/set-set-1/cover.jpg');

    await repository.setStandaloneCover(setId: 'set-1', relativePath: '   ');

    detail = await repository.watchSet('set-1').first;
    expect(detail?.coverRelativePath, isNull);
  });
}
