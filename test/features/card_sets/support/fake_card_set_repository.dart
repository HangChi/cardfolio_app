import 'dart:async';

import 'package:cardfolio_app/features/card_sets/domain/card_set_models.dart';
import 'package:cardfolio_app/features/card_sets/domain/card_set_repository.dart';

final class FakeCardSetRepository implements CardSetRepository {
  FakeCardSetRepository({
    this._sets = const <CardSetSummary>[],
    this._details = const <String, CardSetDetail?>{},
    this._candidates = const <String, List<CardSetCandidate>>{},
    this.listError,
  });

  final List<CardSetSummary> _sets;
  final Map<String, CardSetDetail?> _details;
  final Map<String, List<CardSetCandidate>> _candidates;
  final Object? listError;

  final List<CreateCardSetRequest> created = <CreateCardSetRequest>[];
  final List<UpdateCardSetRequest> updated = <UpdateCardSetRequest>[];
  final List<AddCardSetMemberRequest> added = <AddCardSetMemberRequest>[];
  final List<UpdateCardSetMemberRequest> updatedMembers =
      <UpdateCardSetMemberRequest>[];
  final List<List<String>> reordered = <List<String>>[];
  final List<String> removed = <String>[];
  final List<String?> covers = <String?>[];

  @override
  Stream<List<CardSetMembership>> watchMemberships(String definitionId) =>
      Stream<List<CardSetMembership>>.value(const <CardSetMembership>[]);

  @override
  Stream<List<CardSetSummary>> watchSets() {
    final error = listError;
    return error == null
        ? Stream<List<CardSetSummary>>.value(_sets)
        : Stream<List<CardSetSummary>>.error(error);
  }

  @override
  Stream<CardSetDetail?> watchSet(String setId) =>
      Stream<CardSetDetail?>.value(_details[setId]);

  @override
  Stream<List<CardSetCandidate>> watchCandidates(String setId) =>
      Stream<List<CardSetCandidate>>.value(
        _candidates[setId] ?? const <CardSetCandidate>[],
      );

  @override
  Future<String> createSet(CreateCardSetRequest request) async {
    final normalized = request.normalized();
    created.add(normalized);
    return normalized.id;
  }

  @override
  Future<void> updateSet(UpdateCardSetRequest request) async {
    updated.add(request.normalized());
  }

  @override
  Future<void> addMember(AddCardSetMemberRequest request) async {
    added.add(request.normalized());
  }

  @override
  Future<void> updateMember(UpdateCardSetMemberRequest request) async {
    updatedMembers.add(request.normalized());
  }

  @override
  Future<void> reorderMembers({
    required String setId,
    required List<String> orderedMemberIds,
  }) async {
    reordered.add(List<String>.of(orderedMemberIds));
  }

  @override
  Future<void> removeMember({
    required String setId,
    required String memberId,
  }) async {
    removed.add(memberId);
  }

  @override
  Future<void> setCover({required String setId, String? imageId}) async {
    covers.add(imageId);
  }
}
