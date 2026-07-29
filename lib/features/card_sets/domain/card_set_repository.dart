import 'card_set_models.dart';

abstract interface class CardSetRepository {
  Stream<List<CardSetSummary>> watchSets();

  Stream<List<CardSetMembership>> watchMemberships(String definitionId);

  Stream<CardSetDetail?> watchSet(String setId);

  Stream<List<CardSetCandidate>> watchCandidates(String setId);

  Future<String> createSet(CreateCardSetRequest request);

  Future<void> updateSet(UpdateCardSetRequest request);

  Future<void> addMember(AddCardSetMemberRequest request);

  Future<void> updateMember(UpdateCardSetMemberRequest request);

  Future<void> reorderMembers({
    required String setId,
    required List<String> orderedMemberIds,
  });

  Future<void> removeMember({required String setId, required String memberId});

  Future<void> setCover({required String setId, String? imageId});
}
