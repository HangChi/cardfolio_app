import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/features/card_sets/domain/card_set_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreateCardSetRequest.normalized', () {
    test('trims known-count set data and preserves a positive total', () {
      const raw = CreateCardSetRequest(
        id: ' set-1 ',
        name: ' 东京地铁开业纪念 ',
        countKnown: true,
        expectedCount: 4,
        issueInfo: ' 2025 年发行 ',
        notes: ' 逐张补齐 ',
      );

      final result = raw.normalized();

      expect(result.id, 'set-1');
      expect(result.name, '东京地铁开业纪念');
      expect(result.expectedCount, 4);
      expect(result.issueInfo, '2025 年发行');
      expect(result.notes, '逐张补齐');
    });

    test('clears an expected total when the count is unknown', () {
      const raw = CreateCardSetRequest(
        id: 'set-1',
        name: '交通卡交换会',
        countKnown: false,
        expectedCount: 8,
      );

      final result = raw.normalized();

      expect(result.countKnown, isFalse);
      expect(result.expectedCount, isNull);
    });

    test('rejects blank names and non-positive known totals', () {
      expect(
        () => const CreateCardSetRequest(
          id: 'set-1',
          name: '  ',
          countKnown: true,
          expectedCount: 4,
        ).normalized(),
        throwsA(
          isA<CardSetValidationFailure>().having(
            (failure) => failure.field,
            'field',
            CardSetField.name,
          ),
        ),
      );
      expect(
        () => const CreateCardSetRequest(
          id: 'set-1',
          name: '纪念套卡',
          countKnown: true,
          expectedCount: 0,
        ).normalized(),
        throwsA(
          isA<CardSetValidationFailure>().having(
            (failure) => failure.field,
            'field',
            CardSetField.expectedCount,
          ),
        ),
      );
    });
  });

  group('AddCardSetMemberRequest.normalized', () {
    test('supports an existing owned definition', () {
      const raw = AddCardSetMemberRequest.existing(
        id: ' member-1 ',
        setId: ' set-1 ',
        definitionId: ' definition-1 ',
        memberNo: ' 01 / 04 ',
      );

      final result = raw.normalized();

      expect(result.id, 'member-1');
      expect(result.setId, 'set-1');
      expect(result.definitionId, 'definition-1');
      expect(result.definitionName, isNull);
      expect(result.memberNo, '01 / 04');
      expect(result.required, isTrue);
      expect(result.createsDefinition, isFalse);
    });

    test('requires a name when defining a missing member', () {
      expect(
        () => const AddCardSetMemberRequest.missing(
          id: 'member-1',
          setId: 'set-1',
          definitionId: 'definition-1',
          definitionName: '  ',
        ).normalized(),
        throwsA(
          isA<CardSetValidationFailure>().having(
            (failure) => failure.field,
            'field',
            CardSetField.member,
          ),
        ),
      );
    });
  });

  group('CardSetProgress.calculate', () {
    const members = <CardSetMemberDetail>[
      CardSetMemberDetail(
        id: 'member-1',
        definitionId: 'definition-1',
        name: '一号卡',
        required: true,
        sortOrder: 0,
        ownedQuantity: 1,
      ),
      CardSetMemberDetail(
        id: 'member-2',
        definitionId: 'definition-2',
        name: '二号卡',
        required: true,
        sortOrder: 1,
        ownedQuantity: 2,
      ),
      CardSetMemberDetail(
        id: 'member-3',
        definitionId: 'definition-3',
        name: '三号卡',
        required: true,
        sortOrder: 2,
        ownedQuantity: 1,
      ),
      CardSetMemberDetail(
        id: 'member-4',
        definitionId: 'definition-4',
        name: '四号卡',
        required: true,
        sortOrder: 3,
        ownedQuantity: 0,
      ),
    ];

    test('counts distinct owned members and not duplicate quantities', () {
      final progress = CardSetProgress.calculate(
        countKnown: true,
        members: members,
      );

      expect(progress.ownedMemberCount, 3);
      expect(progress.ownedRequiredCount, 3);
      expect(progress.requiredMemberCount, 4);
      expect(progress.missingRequiredCount, 1);
      expect(progress.duplicateMemberCount, 1);
      expect(progress.fraction, 0.75);
      expect(progress.isComplete, isFalse);
    });

    test('hides percentage and completion when total is unknown', () {
      final progress = CardSetProgress.calculate(
        countKnown: false,
        members: members,
      );

      expect(progress.ownedMemberCount, 3);
      expect(progress.fraction, isNull);
      expect(progress.isComplete, isNull);
    });

    test('does not mark an empty known set as complete', () {
      final progress = CardSetProgress.calculate(
        countKnown: true,
        members: const <CardSetMemberDetail>[],
      );

      expect(progress.fraction, 0);
      expect(progress.isComplete, isFalse);
    });

    test('excludes optional missing members from completion', () {
      final progress = CardSetProgress.calculate(
        countKnown: true,
        members: const <CardSetMemberDetail>[
          CardSetMemberDetail(
            id: 'required',
            definitionId: 'definition-required',
            name: '必需款',
            required: true,
            sortOrder: 0,
            ownedQuantity: 1,
          ),
          CardSetMemberDetail(
            id: 'optional',
            definitionId: 'definition-optional',
            name: '可选款',
            required: false,
            sortOrder: 1,
            ownedQuantity: 0,
          ),
        ],
      );

      expect(progress.ownedRequiredCount, 1);
      expect(progress.requiredMemberCount, 1);
      expect(progress.missingRequiredCount, 0);
      expect(progress.fraction, 1);
      expect(progress.isComplete, isTrue);
    });
  });
}
