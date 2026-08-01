import 'package:meta/meta.dart';

@immutable
final class RecognizedCardText {
  const RecognizedCardText({
    required this.rawText,
    required this.lines,
    this.name,
    this.city,
    this.issuer,
    this.code,
    this.issuedAt,
  });

  factory RecognizedCardText.fromRawText(String rawText) {
    final lines = rawText
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toSet()
        .toList(growable: false);
    final codePattern = RegExp(
      r'\b(?=[A-Z0-9-]*[A-Z])(?=[A-Z0-9-]*\d)[A-Z0-9][A-Z0-9-]{4,}\b',
      caseSensitive: false,
    );
    final yearPattern = RegExp(r'\b(19|20)\d{2}\b');
    String? code;
    String? year;
    String? issuer;
    for (final line in lines) {
      code ??= codePattern.firstMatch(line)?.group(0);
      year ??= yearPattern.firstMatch(line)?.group(0);
      if (issuer == null &&
          RegExp(r'(有限责任公司|有限公司|股份公司|集团|公司)$').hasMatch(line)) {
        issuer = line;
      }
    }
    final candidates =
        lines.where((line) {
          if (line == code || line == issuer || line == year) return false;
          if (line.length < 2 || line.length > 32) return false;
          return RegExp(r'[\u3400-\u9fffA-Za-z]').hasMatch(line);
        }).toList()..sort((left, right) {
          int score(String value) {
            var result = 0;
            if (RegExp(r'(交通|公交|地铁|一卡通|市民卡|纪念|通|卡)').hasMatch(value))
              result += 3;
            if (RegExp(r'^[\u3400-\u9fffA-Za-z0-9 ·•-]+$').hasMatch(value))
              result++;
            if (value.length <= 16) result++;
            return result;
          }

          return score(right).compareTo(score(left));
        });
    return RecognizedCardText(
      rawText: rawText,
      lines: lines,
      name: candidates.firstOrNull,
      issuer: issuer,
      code: code,
      issuedAt: year,
    );
  }

  final String rawText;
  final List<String> lines;
  final String? name;
  final String? city;
  final String? issuer;
  final String? code;
  final String? issuedAt;
}

@immutable
final class TransportCardCatalogMatch {
  const TransportCardCatalogMatch({
    required this.id,
    required this.name,
    required this.confidence,
    this.city,
    this.issuer,
    this.code,
    this.issuedAt,
    this.cardType,
    this.issueQuantity,
    this.issuePrice,
  });

  final String id;
  final String name;
  final double confidence;
  final String? city;
  final String? issuer;
  final String? code;
  final String? issuedAt;
  final String? cardType;
  final int? issueQuantity;
  final String? issuePrice;
}

@immutable
final class CardAutofillSuggestion {
  const CardAutofillSuggestion({
    this.name,
    this.city,
    this.issuer,
    this.code,
    this.issuedAt,
    this.cardType,
    this.issueQuantity,
    this.issuePrice,
  });

  factory CardAutofillSuggestion.merge({
    required RecognizedCardText recognized,
    TransportCardCatalogMatch? catalog,
  }) {
    return CardAutofillSuggestion(
      name: catalog?.name ?? recognized.name,
      city: catalog?.city ?? recognized.city,
      issuer: catalog?.issuer ?? recognized.issuer,
      code: catalog?.code ?? recognized.code,
      issuedAt: catalog?.issuedAt ?? recognized.issuedAt,
      cardType: catalog?.cardType,
      issueQuantity: catalog?.issueQuantity,
      issuePrice: catalog?.issuePrice,
    );
  }

  final String? name;
  final String? city;
  final String? issuer;
  final String? code;
  final String? issuedAt;
  final String? cardType;
  final int? issueQuantity;
  final String? issuePrice;
}

abstract interface class CardTextRecognizer {
  Future<RecognizedCardText> recognize(String imagePath);
}

abstract interface class TransportCardCatalog {
  bool get isConfigured;

  Future<List<TransportCardCatalogMatch>> search(String query);
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
