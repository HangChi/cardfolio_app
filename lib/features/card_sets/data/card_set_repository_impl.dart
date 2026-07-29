import '../../../core/errors/app_failure.dart';
import '../../../core/time/clock.dart';
import '../../cards/data/local/card_database.dart';
import '../domain/card_set_models.dart';
import '../domain/card_set_repository.dart';
import 'local/card_set_database.dart';

final class CardSetRepositoryImpl implements CardSetRepository {
  const CardSetRepositoryImpl({
    required AppDatabase database,
    required this.clock,
  }) : _db = database;

  final AppDatabase _db;
  final Clock clock;

  @override
  Stream<List<CardSetSummary>> watchSets() => _db.watchCardSetSummaries();

  @override
  Stream<List<CardSetMembership>> watchMemberships(String definitionId) =>
      _db.watchCardSetMemberships(
        _requiredId(definitionId, CardSetField.member),
      );

  @override
  Stream<CardSetDetail?> watchSet(String setId) =>
      _db.watchCardSetDetail(setId);

  @override
  Stream<List<CardSetCandidate>> watchCandidates(String setId) =>
      _db.watchCardSetCandidates(setId);

  @override
  Future<String> createSet(CreateCardSetRequest request) async {
    final normalized = request.normalized();
    try {
      final existing = await (_db.select(
        _db.cardSets,
      )..where((set) => set.id.equals(normalized.id))).getSingleOrNull();
      if (existing != null) return normalized.id;
      await _db.createCardSet(request: normalized, now: clock.nowUtc());
      return normalized.id;
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw PersistenceFailure('创建套卡失败，请重试。', error);
    }
  }

  @override
  Future<void> updateSet(UpdateCardSetRequest request) async {
    final normalized = request.normalized();
    await _write(
      action: () => _db.updateCardSet(request: normalized, now: clock.nowUtc()),
      field: CardSetField.expectedCount,
      failureMessage: '更新套卡失败，请重试。',
    );
  }

  @override
  Future<void> addMember(AddCardSetMemberRequest request) async {
    final normalized = request.normalized();
    await _write(
      action: () =>
          _db.addCardSetMember(request: normalized, now: clock.nowUtc()),
      field: CardSetField.member,
      failureMessage: '添加成员失败，请重试。',
    );
  }

  @override
  Future<void> updateMember(UpdateCardSetMemberRequest request) async {
    final normalized = request.normalized();
    await _write(
      action: () =>
          _db.updateCardSetMember(request: normalized, now: clock.nowUtc()),
      field: CardSetField.member,
      failureMessage: '更新成员失败，请重试。',
    );
  }

  @override
  Future<void> reorderMembers({
    required String setId,
    required List<String> orderedMemberIds,
  }) async {
    final normalizedSetId = _requiredId(setId, CardSetField.member);
    final normalizedIds = orderedMemberIds
        .map((id) => _requiredId(id, CardSetField.member))
        .toList(growable: false);
    await _write(
      action: () => _db.reorderCardSetMembers(
        setId: normalizedSetId,
        orderedMemberIds: normalizedIds,
        now: clock.nowUtc(),
      ),
      field: CardSetField.member,
      failureMessage: '调整成员顺序失败，请重试。',
    );
  }

  @override
  Future<void> removeMember({
    required String setId,
    required String memberId,
  }) async {
    await _write(
      action: () => _db.removeCardSetMember(
        setId: _requiredId(setId, CardSetField.member),
        memberId: _requiredId(memberId, CardSetField.member),
        now: clock.nowUtc(),
      ),
      field: CardSetField.member,
      failureMessage: '移除成员失败，请重试。',
    );
  }

  @override
  Future<void> setCover({required String setId, String? imageId}) async {
    final normalizedImageId = imageId == null
        ? null
        : _requiredId(imageId, CardSetField.cover);
    await _write(
      action: () => _db.setCardSetCover(
        setId: _requiredId(setId, CardSetField.cover),
        imageId: normalizedImageId,
        now: clock.nowUtc(),
      ),
      field: CardSetField.cover,
      failureMessage: '更新套卡封面失败，请重试。',
    );
  }

  Future<void> _write({
    required Future<void> Function() action,
    required CardSetField field,
    required String failureMessage,
  }) async {
    try {
      await action();
    } on AppFailure {
      rethrow;
    } on StateError catch (error) {
      throw CardSetValidationFailure(field, error.message);
    } catch (error) {
      throw PersistenceFailure(failureMessage, error);
    }
  }
}

String _requiredId(String value, CardSetField field) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw CardSetValidationFailure(field, '目标不存在，请刷新后重试。');
  }
  return normalized;
}
