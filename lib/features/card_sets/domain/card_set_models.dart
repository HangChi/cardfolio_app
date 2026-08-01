import 'package:meta/meta.dart';

import '../../../core/errors/app_failure.dart';

@immutable
final class CreateCardSetRequest {
  const CreateCardSetRequest({
    required this.id,
    required this.name,
    required this.countKnown,
    this.expectedCount,
    this.issueInfo,
    this.notes,
    this.isNormalized = false,
  });

  static const int maxNameLength = 100;
  static const int maxLongTextLength = 1000;

  final String id;
  final String name;
  final bool countKnown;
  final int? expectedCount;
  final String? issueInfo;
  final String? notes;
  final bool isNormalized;

  CreateCardSetRequest normalized() {
    if (isNormalized) return this;
    final normalizedId = _requiredId(id);
    final normalizedName = _requiredName(name);
    final normalizedExpectedCount = _expectedCount(countKnown, expectedCount);
    return CreateCardSetRequest(
      id: normalizedId,
      name: normalizedName,
      countKnown: countKnown,
      expectedCount: normalizedExpectedCount,
      issueInfo: _optional(
        issueInfo,
        CardSetField.issueInfo,
        maxLongTextLength,
      ),
      notes: _optional(notes, CardSetField.notes, maxLongTextLength),
      isNormalized: true,
    );
  }
}

@immutable
final class UpdateCardSetRequest {
  const UpdateCardSetRequest({
    required this.id,
    required this.name,
    required this.countKnown,
    this.expectedCount,
    this.issueInfo,
    this.notes,
    this.isNormalized = false,
  });

  final String id;
  final String name;
  final bool countKnown;
  final int? expectedCount;
  final String? issueInfo;
  final String? notes;
  final bool isNormalized;

  UpdateCardSetRequest normalized() {
    if (isNormalized) return this;
    final normalized = CreateCardSetRequest(
      id: id,
      name: name,
      countKnown: countKnown,
      expectedCount: expectedCount,
      issueInfo: issueInfo,
      notes: notes,
    ).normalized();
    return UpdateCardSetRequest(
      id: normalized.id,
      name: normalized.name,
      countKnown: normalized.countKnown,
      expectedCount: normalized.expectedCount,
      issueInfo: normalized.issueInfo,
      notes: normalized.notes,
      isNormalized: true,
    );
  }
}

@immutable
final class AddCardSetMemberRequest {
  const AddCardSetMemberRequest.existing({
    required this.id,
    required this.setId,
    required this.definitionId,
    this.memberNo,
    this.required = true,
    this.isNormalized = false,
  }) : definitionName = null,
       createsDefinition = false;

  const AddCardSetMemberRequest.missing({
    required this.id,
    required this.setId,
    required this.definitionId,
    required this.definitionName,
    this.memberNo,
    this.required = true,
    this.isNormalized = false,
  }) : createsDefinition = true;

  static const int maxMemberNumberLength = 100;

  final String id;
  final String setId;
  final String definitionId;
  final String? definitionName;
  final String? memberNo;
  final bool required;
  final bool createsDefinition;
  final bool isNormalized;

  AddCardSetMemberRequest normalized() {
    if (isNormalized) return this;
    final normalizedName = createsDefinition
        ? _requiredName(definitionName ?? '', field: CardSetField.member)
        : null;
    final normalizedMemberNo = _optional(
      memberNo,
      CardSetField.member,
      maxMemberNumberLength,
    );
    if (createsDefinition) {
      return AddCardSetMemberRequest.missing(
        id: _requiredId(id, field: CardSetField.member),
        setId: _requiredId(setId, field: CardSetField.member),
        definitionId: _requiredId(definitionId, field: CardSetField.member),
        definitionName: normalizedName!,
        memberNo: normalizedMemberNo,
        required: required,
        isNormalized: true,
      );
    }
    return AddCardSetMemberRequest.existing(
      id: _requiredId(id, field: CardSetField.member),
      setId: _requiredId(setId, field: CardSetField.member),
      definitionId: _requiredId(definitionId, field: CardSetField.member),
      memberNo: normalizedMemberNo,
      required: required,
      isNormalized: true,
    );
  }
}

@immutable
final class UpdateCardSetMemberRequest {
  const UpdateCardSetMemberRequest({
    required this.setId,
    required this.memberId,
    required this.required,
    this.memberNo,
    this.isNormalized = false,
  });

  final String setId;
  final String memberId;
  final String? memberNo;
  final bool required;
  final bool isNormalized;

  UpdateCardSetMemberRequest normalized() {
    if (isNormalized) return this;
    return UpdateCardSetMemberRequest(
      setId: _requiredId(setId, field: CardSetField.member),
      memberId: _requiredId(memberId, field: CardSetField.member),
      memberNo: _optional(
        memberNo,
        CardSetField.member,
        AddCardSetMemberRequest.maxMemberNumberLength,
      ),
      required: required,
      isNormalized: true,
    );
  }
}

@immutable
final class CardSetMemberDetail {
  const CardSetMemberDetail({
    required this.id,
    required this.definitionId,
    required this.name,
    required this.required,
    required this.sortOrder,
    required this.ownedQuantity,
    this.memberNo,
    this.cardItemId,
    this.coverImageId,
    this.coverRelativePath,
  });

  final String id;
  final String definitionId;
  final String name;
  final String? memberNo;
  final bool required;
  final int sortOrder;
  final int ownedQuantity;
  final String? cardItemId;
  final String? coverImageId;
  final String? coverRelativePath;

  bool get isOwned => ownedQuantity > 0;

  bool get isDuplicate => ownedQuantity > 1;
}

@immutable
final class CardSetProgress {
  const CardSetProgress({
    required this.ownedMemberCount,
    required this.ownedRequiredCount,
    required this.requiredMemberCount,
    required this.missingRequiredCount,
    required this.duplicateMemberCount,
    required this.fraction,
    required this.isComplete,
  });

  factory CardSetProgress.calculate({
    required bool countKnown,
    int? expectedCount,
    required List<CardSetMemberDetail> members,
  }) {
    final ownedMemberCount = members.where((member) => member.isOwned).length;
    final requiredMembers = members
        .where((member) => member.required)
        .toList(growable: false);
    final ownedRequiredCount = requiredMembers
        .where((member) => member.isOwned)
        .length;
    final requiredMemberCount = requiredMembers.length;
    final duplicateMemberCount = members.fold<int>(
      0,
      (total, member) =>
          total + (member.ownedQuantity > 1 ? member.ownedQuantity - 1 : 0),
    );

    if (!countKnown) {
      return CardSetProgress(
        ownedMemberCount: ownedMemberCount,
        ownedRequiredCount: ownedRequiredCount,
        requiredMemberCount: requiredMemberCount,
        missingRequiredCount: requiredMemberCount - ownedRequiredCount,
        duplicateMemberCount: duplicateMemberCount,
        fraction: null,
        isComplete: null,
      );
    }

    final totalCount = expectedCount ?? requiredMemberCount;
    final hasRequiredMembers = totalCount > 0;
    return CardSetProgress(
      ownedMemberCount: ownedMemberCount,
      ownedRequiredCount: ownedRequiredCount,
      requiredMemberCount: totalCount,
      missingRequiredCount: totalCount - ownedRequiredCount,
      duplicateMemberCount: duplicateMemberCount,
      fraction: hasRequiredMembers ? ownedRequiredCount / totalCount : 0,
      isComplete: hasRequiredMembers && ownedRequiredCount == totalCount,
    );
  }

  final int ownedMemberCount;
  final int ownedRequiredCount;
  final int requiredMemberCount;
  final int missingRequiredCount;
  final int duplicateMemberCount;
  final double? fraction;
  final bool? isComplete;
}

@immutable
final class CardSetSummary {
  const CardSetSummary({
    required this.id,
    required this.name,
    required this.countKnown,
    required this.createdAt,
    required this.updatedAt,
    required this.progress,
    this.expectedCount,
    this.coverRelativePath,
  });

  final String id;
  final String name;
  final bool countKnown;
  final int? expectedCount;
  final String? coverRelativePath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CardSetProgress progress;
}

@immutable
final class CardSetMembership {
  const CardSetMembership({required this.setId, required this.memberId});

  final String setId;
  final String memberId;
}

@immutable
final class CardSetDetail {
  const CardSetDetail({
    required this.id,
    required this.name,
    required this.countKnown,
    required this.createdAt,
    required this.updatedAt,
    required this.members,
    required this.progress,
    this.expectedCount,
    this.issueInfo,
    this.notes,
    this.coverImageId,
    this.coverRelativePath,
  });

  final String id;
  final String name;
  final bool countKnown;
  final int? expectedCount;
  final String? issueInfo;
  final String? notes;
  final String? coverImageId;
  final String? coverRelativePath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CardSetMemberDetail> members;
  final CardSetProgress progress;
}

@immutable
final class CardSetCandidate {
  const CardSetCandidate({
    required this.definitionId,
    required this.name,
    required this.ownedQuantity,
    this.cardItemId,
    this.coverImageId,
    this.coverRelativePath,
  });

  final String definitionId;
  final String name;
  final int ownedQuantity;
  final String? cardItemId;
  final String? coverImageId;
  final String? coverRelativePath;
}

String _requiredId(String value, {CardSetField field = CardSetField.name}) {
  final result = value.trim();
  if (result.isEmpty) {
    throw CardSetValidationFailure(field, '目标不存在，请返回后重试。');
  }
  return result;
}

String _requiredName(String value, {CardSetField field = CardSetField.name}) {
  final result = value.trim();
  if (result.isEmpty) {
    throw CardSetValidationFailure(
      field,
      field == CardSetField.name ? '套卡名称不能为空。' : '成员名称不能为空。',
    );
  }
  if (result.length > CreateCardSetRequest.maxNameLength) {
    throw CardSetValidationFailure(field, '名称最多 100 个字符。');
  }
  return result;
}

int? _expectedCount(bool countKnown, int? expectedCount) {
  if (!countKnown) return null;
  if (expectedCount == null || expectedCount < 1) {
    throw const CardSetValidationFailure(
      CardSetField.expectedCount,
      '整套张数必须大于 0。',
    );
  }
  return expectedCount;
}

String? _optional(String? value, CardSetField field, int maxLength) {
  final result = value?.trim() ?? '';
  if (result.isEmpty) return null;
  if (result.length > maxLength) {
    throw CardSetValidationFailure(field, '内容最多 $maxLength 个字符。');
  }
  return result;
}
