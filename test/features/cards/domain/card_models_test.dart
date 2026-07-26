import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/core/id/id_generator.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:flutter_test/flutter_test.dart';

/// 固定序列 ID 生成器，用于断言草稿 ID 只生成一次且互不相同。
class SequenceIdGenerator implements IdGenerator {
  int _next = 0;
  final List<String> issued = <String>[];

  @override
  String newId() {
    final id = 'id-${_next++}';
    issued.add(id);
    return id;
  }
}

CreateCardRequest request({
  required String name,
  String? city,
  String? issuer,
  String? code,
  String? notes,
  String? issuedAt,
  int quantity = 1,
}) {
  return CreateCardRequest(
    ids: const CardDraftIds(
      definitionId: 'definition-1',
      cardItemId: 'item-1',
      imageId: 'image-1',
    ),
    sourceImagePath: '/tmp/source.jpg',
    name: name,
    city: city,
    issuer: issuer,
    issuedAt: issuedAt == null ? null : PartialDate.tryParse(issuedAt),
    code: code,
    notes: notes,
    quantity: quantity,
  );
}

void main() {
  group('PartialDate', () {
    test('supports year, year-month, and full precision', () {
      expect(PartialDate.tryParse('2025')?.toIsoString(), '2025');
      expect(PartialDate.tryParse('2025-07')?.toIsoString(), '2025-07');
      expect(PartialDate.tryParse('2025-07-26')?.toIsoString(), '2025-07-26');
    });

    test('records the precision it was parsed at', () {
      expect(PartialDate.tryParse('2025')?.precision, DatePrecision.year);
      expect(
        PartialDate.tryParse('2025-07')?.precision,
        DatePrecision.yearMonth,
      );
      expect(PartialDate.tryParse('2025-07-26')?.precision, DatePrecision.day);
    });

    test('rejects out-of-range and malformed input', () {
      expect(PartialDate.tryParse('2025-13'), isNull);
      expect(PartialDate.tryParse('2025-00'), isNull);
      expect(PartialDate.tryParse('2025-02-30'), isNull);
      expect(PartialDate.tryParse('25-07'), isNull);
      expect(PartialDate.tryParse('2025/07'), isNull);
      expect(PartialDate.tryParse(''), isNull);
      expect(PartialDate.tryParse('  '), isNull);
    });

    test('tolerates surrounding whitespace', () {
      expect(PartialDate.tryParse(' 2025-07 ')?.toIsoString(), '2025-07');
    });

    test('compares by value', () {
      expect(PartialDate.tryParse('2025-07'), PartialDate.tryParse('2025-07'));
      expect(
        PartialDate.tryParse('2025-07'),
        isNot(PartialDate.tryParse('2025')),
      );
    });
  });

  group('CardDraftIds', () {
    test('generates three distinct ids exactly once', () {
      final generator = SequenceIdGenerator();

      final ids = CardDraftIds.create(generator);

      expect(generator.issued, hasLength(3));
      expect(<String>{
        ids.definitionId,
        ids.cardItemId,
        ids.imageId,
      }, hasLength(3));
    });
  });

  group('CreateCardRequest.normalized', () {
    test('trims the required name and optional text fields', () {
      final normalized = request(
        name: '  樱花纪念卡  ',
        city: ' 东京 ',
        issuer: ' Tokyo Metro ',
        code: ' 01 / 08 ',
        notes: ' 首发 ',
      ).normalized();

      expect(normalized.name, '樱花纪念卡');
      expect(normalized.city, '东京');
      expect(normalized.issuer, 'Tokyo Metro');
      expect(normalized.code, '01 / 08');
      expect(normalized.notes, '首发');
    });

    test('converts blank optional fields to null', () {
      final normalized = request(
        name: '樱花纪念卡',
        city: '   ',
        issuer: '',
        code: '',
        notes: '  ',
      ).normalized();

      expect(normalized.city, isNull);
      expect(normalized.issuer, isNull);
      expect(normalized.code, isNull);
      expect(normalized.notes, isNull);
    });

    test('rejects a blank name with a field-scoped validation failure', () {
      Object? thrown;
      try {
        request(name: '  ').normalized();
      } catch (error) {
        thrown = error;
      }

      expect(thrown, isA<ValidationFailure>());
      expect((thrown! as ValidationFailure).field, CardField.name);
      expect((thrown as ValidationFailure).userMessage, '名称不能为空');
    });

    test('rejects a non-positive quantity', () {
      expect(
        () => request(name: '樱花纪念卡', quantity: 0).normalized(),
        throwsA(
          isA<ValidationFailure>().having(
            (failure) => failure.field,
            'field',
            CardField.quantity,
          ),
        ),
      );
    });

    test('rejects a name longer than the persisted limit', () {
      expect(
        () => request(
          name: 'A' * (CreateCardRequest.maxNameLength + 1),
        ).normalized(),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('rejects a blank source image path', () {
      final blankSource = CreateCardRequest(
        ids: const CardDraftIds(
          definitionId: 'definition-1',
          cardItemId: 'item-1',
          imageId: 'image-1',
        ),
        sourceImagePath: '   ',
        name: '樱花纪念卡',
      );

      expect(blankSource.normalized, throwsA(isA<ValidationFailure>()));
    });

    test('is idempotent', () {
      final once = request(name: ' 樱花纪念卡 ', city: ' 东京 ').normalized();

      expect(once.normalized(), once);
    });
  });
}
