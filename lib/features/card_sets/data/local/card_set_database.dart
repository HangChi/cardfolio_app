import 'dart:collection';

import 'package:drift/drift.dart';

import '../../../cards/data/local/card_database.dart';
import '../../domain/card_set_models.dart';

extension CardSetDatabase on AppDatabase {
  Stream<List<CardSetSummary>> watchCardSetSummaries() {
    return _watchCardSetAggregates(this).map(
      (aggregates) => aggregates
          .map((aggregate) => aggregate.toSummary())
          .toList(growable: false),
    );
  }

  Stream<CardSetDetail?> watchCardSetDetail(String setId) {
    return _watchCardSetAggregates(this, setId: setId).map(
      (aggregates) => aggregates.isEmpty ? null : aggregates.single.toDetail(),
    );
  }

  Stream<List<CardSetCandidate>> watchCardSetCandidates(String setId) {
    final memberCover = alias(cardImages, 'candidate_cover');
    final query =
        select(cardDefinitions).join(<Join<HasResultSet, dynamic>>[
            innerJoin(
              cardItems,
              cardItems.definitionId.equalsExp(cardDefinitions.id) &
                  cardItems.deletedAt.isNull(),
            ),
            leftOuterJoin(
              memberCover,
              memberCover.cardItemId.equalsExp(cardItems.id) &
                  memberCover.isCover.equals(true) &
                  memberCover.deletedAt.isNull(),
            ),
            leftOuterJoin(
              cardSetMembers,
              cardSetMembers.definitionId.equalsExp(cardDefinitions.id) &
                  cardSetMembers.setId.equals(setId) &
                  cardSetMembers.deletedAt.isNull(),
            ),
          ])
          ..where(
            cardDefinitions.deletedAt.isNull() & cardSetMembers.id.isNull(),
          )
          ..orderBy(<OrderingTerm>[
            OrderingTerm.desc(cardDefinitions.createdAt),
            OrderingTerm.desc(cardDefinitions.id),
            OrderingTerm.asc(cardItems.createdAt),
            OrderingTerm.asc(cardItems.id),
          ]);

    return query.watch().map((rows) {
      final candidates = <String, _CandidateBuilder>{};
      for (final row in rows) {
        final definition = row.readTable(cardDefinitions);
        final item = row.readTable(cardItems);
        final cover = row.readTableOrNull(memberCover);
        candidates
            .putIfAbsent(
              definition.id,
              () => _CandidateBuilder(
                definitionId: definition.id,
                name: definition.name,
              ),
            )
            .addItem(item, cover);
      }
      return candidates.values
          .map((candidate) => candidate.build())
          .toList(growable: false);
    });
  }

  Future<void> createCardSet({
    required CreateCardSetRequest request,
    required DateTime now,
  }) {
    return into(cardSets).insert(
      CardSetsCompanion.insert(
        id: request.id,
        name: request.name,
        expectedCount: Value<int?>(request.expectedCount),
        countKnown: request.countKnown,
        issueInfo: Value<String?>(request.issueInfo),
        notes: Value<String?>(request.notes),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> updateCardSet({
    required UpdateCardSetRequest request,
    required DateTime now,
  }) {
    return transaction(() async {
      final current = await _activeCardSet(this, request.id);
      if (current == null) throw StateError('套卡不存在。');
      final memberCount = await _activeCardSetMembers(
        this,
        request.id,
      ).then((members) => members.length);
      if (request.countKnown && request.expectedCount! < memberCount) {
        throw StateError('预计成员数不能少于当前成员数。');
      }
      final changed =
          await (update(
            cardSets,
          )..where((set) => set.id.equals(request.id))).write(
            CardSetsCompanion(
              name: Value(request.name),
              expectedCount: Value<int?>(request.expectedCount),
              countKnown: Value(request.countKnown),
              issueInfo: Value<String?>(request.issueInfo),
              notes: Value<String?>(request.notes),
              updatedAt: Value(now),
              version: Value(current.version + 1),
            ),
          );
      if (changed != 1) throw StateError('套卡不存在。');
    });
  }

  Future<void> addCardSetMember({
    required AddCardSetMemberRequest request,
    required DateTime now,
  }) {
    return transaction(() async {
      final set = await _activeCardSet(this, request.setId);
      if (set == null) throw StateError('套卡不存在。');
      final currentMembers = await _activeCardSetMembers(this, request.setId);
      if (set.countKnown && currentMembers.length >= (set.expectedCount ?? 0)) {
        throw StateError('成员数已达到预计总数，请先调整套卡资料。');
      }

      final duplicate =
          await (select(cardSetMembers)..where(
                (member) =>
                    member.setId.equals(request.setId) &
                    member.definitionId.equals(request.definitionId) &
                    member.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (duplicate != null) throw StateError('这款卡已经在套卡中。');

      if (request.createsDefinition) {
        await into(cardDefinitions).insert(
          CardDefinitionsCompanion.insert(
            id: request.definitionId,
            name: request.definitionName!,
            createdAt: now,
            updatedAt: now,
          ),
        );
      } else {
        final definition =
            await (select(cardDefinitions)..where(
                  (definition) =>
                      definition.id.equals(request.definitionId) &
                      definition.deletedAt.isNull(),
                ))
                .getSingleOrNull();
        if (definition == null) throw StateError('卡片款式不存在。');
      }

      await into(cardSetMembers).insert(
        CardSetMembersCompanion.insert(
          id: request.id,
          setId: request.setId,
          definitionId: request.definitionId,
          memberNo: Value<String?>(request.memberNo),
          required: Value(request.required),
          sortOrder: Value(currentMembers.length),
          createdAt: now,
          updatedAt: now,
        ),
      );
      await _touchCardSet(this, set, now);
    });
  }

  Future<void> updateCardSetMember({
    required UpdateCardSetMemberRequest request,
    required DateTime now,
  }) {
    return transaction(() async {
      final member = await _activeCardSetMember(
        this,
        request.setId,
        request.memberId,
      );
      if (member == null) throw StateError('套卡成员不存在。');
      final changed =
          await (update(cardSetMembers)..where(
                (entry) =>
                    entry.id.equals(request.memberId) &
                    entry.setId.equals(request.setId) &
                    entry.deletedAt.isNull(),
              ))
              .write(
                CardSetMembersCompanion(
                  memberNo: Value<String?>(request.memberNo),
                  required: Value(request.required),
                  updatedAt: Value(now),
                  version: Value(member.version + 1),
                ),
              );
      if (changed != 1) throw StateError('套卡成员不存在。');
      final set = await _activeCardSet(this, request.setId);
      if (set == null) throw StateError('套卡不存在。');
      await _touchCardSet(this, set, now);
    });
  }

  Future<void> reorderCardSetMembers({
    required String setId,
    required List<String> orderedMemberIds,
    required DateTime now,
  }) {
    return transaction(() async {
      final set = await _activeCardSet(this, setId);
      if (set == null) throw StateError('套卡不存在。');
      final members = await _activeCardSetMembers(this, setId);
      final activeIds = members.map((member) => member.id).toSet();
      if (orderedMemberIds.length != members.length ||
          orderedMemberIds.toSet().length != orderedMemberIds.length ||
          !orderedMemberIds.every(activeIds.contains)) {
        throw StateError('成员顺序已变化，请刷新后重试。');
      }
      for (var index = 0; index < orderedMemberIds.length; index++) {
        final member = members.firstWhere(
          (entry) => entry.id == orderedMemberIds[index],
        );
        await (update(
          cardSetMembers,
        )..where((entry) => entry.id.equals(member.id))).write(
          CardSetMembersCompanion(
            sortOrder: Value(index),
            updatedAt: Value(now),
            version: Value(member.version + 1),
          ),
        );
      }
      await _touchCardSet(this, set, now);
    });
  }

  Future<void> removeCardSetMember({
    required String setId,
    required String memberId,
    required DateTime now,
  }) {
    return transaction(() async {
      final set = await _activeCardSet(this, setId);
      final target = await _activeCardSetMember(this, setId, memberId);
      if (set == null || target == null) throw StateError('套卡成员不存在。');

      var removesCover = false;
      if (set.coverImageId case final imageId?) {
        final coverDefinitionId = await _definitionIdForImage(this, imageId);
        removesCover = coverDefinitionId == target.definitionId;
      }

      await (update(
        cardSetMembers,
      )..where((entry) => entry.id.equals(memberId))).write(
        CardSetMembersCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          version: Value(target.version + 1),
        ),
      );
      final remaining = await _activeCardSetMembers(this, setId);
      for (var index = 0; index < remaining.length; index++) {
        final member = remaining[index];
        await (update(
          cardSetMembers,
        )..where((entry) => entry.id.equals(member.id))).write(
          CardSetMembersCompanion(
            sortOrder: Value(index),
            updatedAt: Value(now),
            version: Value(member.version + 1),
          ),
        );
      }
      await (update(cardSets)..where((entry) => entry.id.equals(setId))).write(
        CardSetsCompanion(
          coverImageId: removesCover
              ? const Value<String?>(null)
              : const Value.absent(),
          updatedAt: Value(now),
          version: Value(set.version + 1),
        ),
      );
    });
  }

  Future<void> setCardSetCover({
    required String setId,
    required String? imageId,
    required DateTime now,
  }) {
    return transaction(() async {
      final set = await _activeCardSet(this, setId);
      if (set == null) throw StateError('套卡不存在。');
      if (imageId != null) {
        final image = await _activeMemberImage(this, setId, imageId);
        if (image == null) throw StateError('请选择套卡成员的有效图片。');
      }
      await (update(cardSets)..where((entry) => entry.id.equals(setId))).write(
        CardSetsCompanion(
          coverImageId: Value<String?>(imageId),
          updatedAt: Value(now),
          version: Value(set.version + 1),
        ),
      );
    });
  }
}

Stream<List<_CardSetAggregate>> _watchCardSetAggregates(
  AppDatabase db, {
  String? setId,
}) {
  final setCover = db.alias(db.cardImages, 'set_cover');
  final memberCover = db.alias(db.cardImages, 'member_cover');
  final query =
      db.select(db.cardSets).join(<Join<HasResultSet, dynamic>>[
          leftOuterJoin(
            db.cardSetMembers,
            db.cardSetMembers.setId.equalsExp(db.cardSets.id) &
                db.cardSetMembers.deletedAt.isNull(),
          ),
          leftOuterJoin(
            db.cardDefinitions,
            db.cardDefinitions.id.equalsExp(db.cardSetMembers.definitionId),
          ),
          leftOuterJoin(
            db.cardItems,
            db.cardItems.definitionId.equalsExp(db.cardDefinitions.id) &
                db.cardItems.deletedAt.isNull(),
          ),
          leftOuterJoin(
            memberCover,
            memberCover.cardItemId.equalsExp(db.cardItems.id) &
                memberCover.isCover.equals(true) &
                memberCover.deletedAt.isNull(),
          ),
          leftOuterJoin(
            setCover,
            setCover.id.equalsExp(db.cardSets.coverImageId) &
                setCover.cardItemId.equalsExp(db.cardItems.id) &
                setCover.deletedAt.isNull(),
          ),
        ])
        ..where(
          db.cardSets.deletedAt.isNull() &
              (setId == null
                  ? const Constant(true)
                  : db.cardSets.id.equals(setId)),
        )
        ..orderBy(<OrderingTerm>[
          OrderingTerm.desc(db.cardSets.createdAt),
          OrderingTerm.desc(db.cardSets.id),
          OrderingTerm.asc(db.cardSetMembers.sortOrder),
          OrderingTerm.asc(db.cardSetMembers.id),
          OrderingTerm.asc(db.cardItems.createdAt),
          OrderingTerm.asc(db.cardItems.id),
        ]);

  return query.watch().map((rows) {
    final sets = <String, _CardSetAggregateBuilder>{};
    for (final row in rows) {
      final set = row.readTable(db.cardSets);
      final builder = sets.putIfAbsent(
        set.id,
        () => _CardSetAggregateBuilder(set: set),
      );
      builder.addSetCover(row.readTableOrNull(setCover));
      final member = row.readTableOrNull(db.cardSetMembers);
      final definition = row.readTableOrNull(db.cardDefinitions);
      if (member == null || definition == null) continue;
      builder.addMemberRow(
        member: member,
        definition: definition,
        item: row.readTableOrNull(db.cardItems),
        cover: row.readTableOrNull(memberCover),
      );
    }
    return sets.values
        .map((builder) => builder.build())
        .toList(growable: false);
  });
}

final class _CardSetAggregateBuilder {
  _CardSetAggregateBuilder({required this.set});

  final CardSet set;
  CardImage? cover;
  final LinkedHashMap<String, _MemberBuilder> members =
      LinkedHashMap<String, _MemberBuilder>();

  void addSetCover(CardImage? candidate) {
    cover ??= candidate;
  }

  void addMemberRow({
    required CardSetMember member,
    required CardDefinition definition,
    required CardItem? item,
    required CardImage? cover,
  }) {
    members
        .putIfAbsent(
          member.id,
          () => _MemberBuilder(member: member, definition: definition),
        )
        .addItem(item, cover);
  }

  _CardSetAggregate build() {
    final builtMembers =
        members.values.map((member) => member.build()).toList(growable: false)
          ..sort((left, right) {
            final order = left.sortOrder.compareTo(right.sortOrder);
            return order != 0 ? order : left.id.compareTo(right.id);
          });
    return _CardSetAggregate(
      set: set,
      coverImageId: cover?.id,
      coverRelativePath: _displayPath(cover),
      members: builtMembers,
    );
  }
}

final class _MemberBuilder {
  _MemberBuilder({required this.member, required this.definition});

  final CardSetMember member;
  final CardDefinition definition;
  final Set<String> _itemIds = <String>{};
  int quantity = 0;
  String? cardItemId;
  CardImage? cover;

  void addItem(CardItem? item, CardImage? candidateCover) {
    if (item == null || !_itemIds.add(item.id)) return;
    quantity += item.quantity;
    cardItemId ??= item.id;
    cover ??= candidateCover;
  }

  CardSetMemberDetail build() {
    return CardSetMemberDetail(
      id: member.id,
      definitionId: definition.id,
      name: definition.name,
      memberNo: member.memberNo,
      required: member.required,
      sortOrder: member.sortOrder,
      ownedQuantity: quantity,
      cardItemId: cardItemId,
      coverImageId: cover?.id,
      coverRelativePath: _displayPath(cover),
    );
  }
}

final class _CardSetAggregate {
  const _CardSetAggregate({
    required this.set,
    required this.coverImageId,
    required this.coverRelativePath,
    required this.members,
  });

  final CardSet set;
  final String? coverImageId;
  final String? coverRelativePath;
  final List<CardSetMemberDetail> members;

  CardSetProgress get progress =>
      CardSetProgress.calculate(countKnown: set.countKnown, members: members);

  CardSetSummary toSummary() {
    return CardSetSummary(
      id: set.id,
      name: set.name,
      countKnown: set.countKnown,
      expectedCount: set.expectedCount,
      coverRelativePath: coverRelativePath,
      createdAt: set.createdAt.toUtc(),
      updatedAt: set.updatedAt.toUtc(),
      progress: progress,
    );
  }

  CardSetDetail toDetail() {
    return CardSetDetail(
      id: set.id,
      name: set.name,
      countKnown: set.countKnown,
      expectedCount: set.expectedCount,
      issueInfo: set.issueInfo,
      notes: set.notes,
      coverImageId: coverImageId,
      coverRelativePath: coverRelativePath,
      createdAt: set.createdAt.toUtc(),
      updatedAt: set.updatedAt.toUtc(),
      members: List<CardSetMemberDetail>.unmodifiable(members),
      progress: progress,
    );
  }
}

final class _CandidateBuilder {
  _CandidateBuilder({required this.definitionId, required this.name});

  final String definitionId;
  final String name;
  final Set<String> _itemIds = <String>{};
  int quantity = 0;
  String? cardItemId;
  CardImage? cover;

  void addItem(CardItem item, CardImage? candidateCover) {
    if (!_itemIds.add(item.id)) return;
    quantity += item.quantity;
    cardItemId ??= item.id;
    cover ??= candidateCover;
  }

  CardSetCandidate build() {
    return CardSetCandidate(
      definitionId: definitionId,
      name: name,
      ownedQuantity: quantity,
      cardItemId: cardItemId,
      coverImageId: cover?.id,
      coverRelativePath: _displayPath(cover),
    );
  }
}

String? _displayPath(CardImage? image) =>
    image?.derivedRelativePath ?? image?.relativePath;

Future<CardSet?> _activeCardSet(AppDatabase db, String setId) {
  final query = db.select(db.cardSets)
    ..where((set) => set.id.equals(setId) & set.deletedAt.isNull());
  return query.getSingleOrNull();
}

Future<List<CardSetMember>> _activeCardSetMembers(
  AppDatabase db,
  String setId,
) {
  final query = db.select(db.cardSetMembers)
    ..where((member) => member.setId.equals(setId) & member.deletedAt.isNull())
    ..orderBy(<OrderingTerm Function(CardSetMembers)>[
      (member) => OrderingTerm.asc(member.sortOrder),
      (member) => OrderingTerm.asc(member.id),
    ]);
  return query.get();
}

Future<CardSetMember?> _activeCardSetMember(
  AppDatabase db,
  String setId,
  String memberId,
) {
  final query = db.select(db.cardSetMembers)
    ..where(
      (member) =>
          member.id.equals(memberId) &
          member.setId.equals(setId) &
          member.deletedAt.isNull(),
    );
  return query.getSingleOrNull();
}

Future<void> _touchCardSet(AppDatabase db, CardSet set, DateTime now) async {
  final changed =
      await (db.update(
        db.cardSets,
      )..where((entry) => entry.id.equals(set.id))).write(
        CardSetsCompanion(
          updatedAt: Value(now),
          version: Value(set.version + 1),
        ),
      );
  if (changed != 1) throw StateError('套卡不存在。');
}

Future<String?> _definitionIdForImage(AppDatabase db, String imageId) async {
  final query = db.select(db.cardImages).join(<Join<HasResultSet, dynamic>>[
    innerJoin(
      db.cardItems,
      db.cardItems.id.equalsExp(db.cardImages.cardItemId),
    ),
  ])..where(db.cardImages.id.equals(imageId));
  return (await query.getSingleOrNull())?.readTable(db.cardItems).definitionId;
}

Future<CardImage?> _activeMemberImage(
  AppDatabase db,
  String setId,
  String imageId,
) async {
  final query = db.select(db.cardImages).join(
    <Join<HasResultSet, dynamic>>[
      innerJoin(
        db.cardItems,
        db.cardItems.id.equalsExp(db.cardImages.cardItemId) &
            db.cardItems.deletedAt.isNull(),
      ),
      innerJoin(
        db.cardSetMembers,
        db.cardSetMembers.definitionId.equalsExp(db.cardItems.definitionId) &
            db.cardSetMembers.setId.equals(setId) &
            db.cardSetMembers.deletedAt.isNull(),
      ),
    ],
  )..where(db.cardImages.id.equals(imageId) & db.cardImages.deletedAt.isNull());
  return (await query.getSingleOrNull())?.readTable(db.cardImages);
}
