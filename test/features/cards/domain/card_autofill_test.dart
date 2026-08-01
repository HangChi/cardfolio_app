import 'package:cardfolio_app/features/cards/domain/card_autofill.dart';
import 'package:test/test.dart';

void main() {
  test('catalog match takes precedence while OCR fills missing fields', () {
    const recognized = RecognizedCardText(
      rawText: '上海交通卡\n编号 SH-2025\n2025',
      lines: <String>['上海交通卡', '编号 SH-2025', '2025'],
      name: '上海交通卡',
      city: '上海',
      code: 'SH-2025',
      issuedAt: '2025',
    );
    const match = TransportCardCatalogMatch(
      id: 'catalog-1',
      name: '上海公共交通卡 2025',
      city: '上海',
      issuer: '上海公共交通卡股份有限公司',
      confidence: 0.94,
    );

    final result = CardAutofillSuggestion.merge(
      recognized: recognized,
      catalog: match,
    );

    expect(result.name, match.name);
    expect(result.issuer, match.issuer);
    expect(result.code, recognized.code);
    expect(result.issuedAt, recognized.issuedAt);
  });

  test('extracts a likely code and year from OCR text', () {
    final result = RecognizedCardText.fromRawText(
      '北京一卡通\nBMAC-2024-001\n发行 2024',
    );

    expect(result.name, '北京一卡通');
    expect(result.code, 'BMAC-2024-001');
    expect(result.issuedAt, '2024');
  });
}
