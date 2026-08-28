import 'package:meta/meta.dart';

@immutable
final class CardCsvRow {
  const CardCsvRow({
    required this.name,
    this.city,
    this.issuer,
    this.issuedAt,
    this.code,
    this.quantity = 1,
    this.condition,
    this.itemNotes,
    this.issueQuantity,
    this.issuePrice,
    this.cardType,
    this.acquiredAt,
    this.tags = const <String>[],
    this.albums = const <String>[],
    this.cardSets = const <String>[],
    this.amount,
    this.shipping,
    this.notes,
  });

  final String name;
  final String? city;
  final String? issuer;
  final String? issuedAt;
  final String? code;
  final int quantity;
  final String? condition;
  final String? itemNotes;
  final int? issueQuantity;
  final String? issuePrice;
  final String? cardType;
  final String? acquiredAt;
  final List<String> tags;
  final List<String> albums;
  final List<String> cardSets;
  final String? amount;
  final String? shipping;
  final String? notes;
}

String encodeCardCsv(Iterable<CardCsvRow> rows) {
  const headers = <String>[
    '名称',
    '城市',
    '发行机构',
    '发行日期',
    '编号',
    '持有数量',
    '品相',
    '藏品实例备注',
    '发行数量',
    '发售价（元）',
    '卡片类型',
    '入手日期',
    '标签',
    '集卡册',
    '套卡',
    '入手价（元）',
    '运费（元）',
    '备注',
  ];
  final output = StringBuffer('\uFEFF')
    ..writeln(headers.map(_escape).join(','));
  for (final row in rows) {
    output.writeln(
      <Object?>[
        row.name,
        row.city,
        row.issuer,
        row.issuedAt,
        row.code,
        row.quantity,
        row.condition,
        row.itemNotes,
        row.issueQuantity,
        row.issuePrice,
        row.cardType,
        row.acquiredAt,
        row.tags.join('|'),
        row.albums.join('|'),
        row.cardSets.join('|'),
        row.amount,
        row.shipping,
        row.notes,
      ].map((value) => _escape(value?.toString() ?? '')).join(','),
    );
  }
  return output.toString();
}

String _escape(String value) {
  final safe = value.startsWith(RegExp(r'\s*[=+\-@]')) ? "'$value" : value;
  if (!safe.contains(RegExp('[,"\\r\\n]'))) return safe;
  return '"${safe.replaceAll('"', '""')}"';
}
