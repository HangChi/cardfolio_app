import 'package:meta/meta.dart';

@immutable
final class RecognizedCardText {
  const RecognizedCardText({
    required this.rawText,
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
        .toList(growable: false);
    final codePattern = RegExp(
      r'\b(?=[A-Z0-9-]*[A-Z])(?=[A-Z0-9-]*\d)[A-Z0-9][A-Z0-9-]{4,}\b',
      caseSensitive: false,
    );
    final yearPattern = RegExp(r'\b(19|20)\d{2}\b');
    String? code;
    String? year;
    for (final line in lines) {
      code ??= codePattern.firstMatch(line)?.group(0);
      year ??= yearPattern.firstMatch(line)?.group(0);
    }
    return RecognizedCardText(
      rawText: rawText,
      name: lines.firstOrNull,
      code: code,
      issuedAt: year,
    );
  }

  final String rawText;
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
