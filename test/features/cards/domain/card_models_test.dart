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
  String sourceImagePath = '/tmp/source.jpg',
  String? city,
  String? issuer,
  String? code,
  String? notes,
  String? issuedAt,
  int quantity = 1,
  List<PendingCardImage> additionalImages = const <PendingCardImage>[],
}) {
  return CreateCardRequest(
    ids: const CardDraftIds(
      definitionId: 'definition-1',
      cardItemId: 'item-1',
      imageId: 'image-1',
    ),
    sourceImagePath: sourceImagePath,
    additionalImages: additionalImages,
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
    test('keeps an ordered multi-image request with all supported kinds', () {
      final normalized = request(
        name: '樱花纪念卡',
        additionalImages: const <PendingCardImage>[
          PendingCardImage(
            id: 'image-2',
            sourcePath: '/tmp/back.jpg',
            kind: CardImageKind.back,
          ),
          PendingCardImage(
            id: 'image-3',
            sourcePath: '/tmp/package.jpg',
            kind: CardImageKind.packaging,
          ),
          PendingCardImage(
            id: 'image-4',
            sourcePath: '/tmp/number.jpg',
            kind: CardImageKind.number,
          ),
          PendingCardImage(
            id: 'image-5',
            sourcePath: '/tmp/detail.jpg',
            kind: CardImageKind.detail,
          ),
          PendingCardImage(
            id: 'image-6',
            sourcePath: '/tmp/other.jpg',
            kind: CardImageKind.other,
          ),
        ],
      ).normalized();

      expect(
        normalized.images.map((image) => image.kind),
        CardImageKind.values,
      );
      expect(normalized.images.map((image) => image.id), <String>[
        'image-1',
        'image-2',
        'image-3',
        'image-4',
        'image-5',
        'image-6',
      ]);
    });

    test(
      'normalizes an optional derived source without replacing the original',
      () {
        final normalized = const PendingCardImage(
          id: ' image-2 ',
          sourcePath: ' /tmp/original.heic ',
          derivedSourcePath: ' /tmp/processed.jpg ',
        ).normalized();

        expect(normalized.id, 'image-2');
        expect(normalized.sourcePath, '/tmp/original.heic');
        expect(normalized.derivedSourcePath, '/tmp/processed.jpg');
      },
    );

    test('rejects more than twenty images', () {
      final additional = List<PendingCardImage>.generate(
        CreateCardRequest.maxImages,
        (index) => PendingCardImage(
          id: 'image-${index + 2}',
          sourcePath: '/tmp/${index + 2}.jpg',
        ),
      );

      expect(
        () => request(name: '樱花纪念卡', additionalImages: additional).normalized(),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('rejects blank paths and duplicate image ids', () {
      expect(
        () => request(
          name: '樱花纪念卡',
          additionalImages: const <PendingCardImage>[
            PendingCardImage(id: 'image-2', sourcePath: '  '),
          ],
        ).normalized(),
        throwsA(isA<ValidationFailure>()),
      );
      expect(
        () => request(
          name: '樱花纪念卡',
          additionalImages: const <PendingCardImage>[
            PendingCardImage(id: 'image-1', sourcePath: '/tmp/back.jpg'),
          ],
        ).normalized(),
        throwsA(isA<ValidationFailure>()),
      );
    });

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

    test('normalizes a blank name to the untitled display name', () {
      final normalized = request(name: '  ').normalized();

      expect(normalized.name, '未命名卡片');
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

    test('allows a card without front or back images', () {
      final normalized = request(name: '', sourceImagePath: '   ').normalized();

      expect(normalized.images, isEmpty);
      expect(normalized.name, '未命名卡片');
    });

    test('is idempotent', () {
      final once = request(name: ' 樱花纪念卡 ', city: ' 东京 ').normalized();

      expect(once.normalized(), once);
    });
  });

  group('AddCardImagesRequest.normalized', () {
    test('requires one to twenty unique images', () {
      expect(
        () => const AddCardImagesRequest(
          cardItemId: 'item-1',
          images: <PendingCardImage>[],
        ).normalized(),
        throwsA(isA<ValidationFailure>()),
      );

      final request = const AddCardImagesRequest(
        cardItemId: ' item-1 ',
        images: <PendingCardImage>[
          PendingCardImage(
            id: 'image-2',
            sourcePath: ' /tmp/back.jpg ',
            kind: CardImageKind.back,
          ),
        ],
      ).normalized();

      expect(request.cardItemId, 'item-1');
      expect(request.images.single.sourcePath, '/tmp/back.jpg');
      expect(request.images.single.kind, CardImageKind.back);
    });
  });

  group('UpdateCardRequest.normalized', () {
    test('normalizes optional fields and keeps a positive quantity', () {
      final normalized = UpdateCardRequest(
        cardItemId: ' item-1 ',
        name: ' ',
        city: ' 上海 ',
        quantity: 2,
      ).normalized();

      expect(normalized.cardItemId, 'item-1');
      expect(normalized.name, '未命名卡片');
      expect(normalized.city, '上海');
      expect(normalized.quantity, 2);
    });
  });
}
