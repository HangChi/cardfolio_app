import 'package:test/test.dart';
import 'package:cardfolio_app/features/export/domain/csv_export.dart';

void main() {
  test('encodes UTF-8 CSV fields with commas quotes and new lines', () {
    final csv = encodeCardCsv(<CardCsvRow>[
      const CardCsvRow(
        name: '城市卡,纪念版',
        issuer: '发行"机构"',
        notes: '第一行\n第二行',
        quantity: 2,
      ),
    ]);

    expect(csv.startsWith('\uFEFF'), isTrue);
    expect(csv, contains('"城市卡,纪念版"'));
    expect(csv, contains('"发行""机构"""'));
    expect(csv, contains('"第一行\n第二行"'));
    expect(csv, contains(',2,'));
  });
}
