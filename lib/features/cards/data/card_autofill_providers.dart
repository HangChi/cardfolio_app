import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../domain/card_autofill.dart';
import 'china_regions.dart';

final class MethodChannelCardTextRecognizer implements CardTextRecognizer {
  const MethodChannelCardTextRecognizer();

  static const _channel = MethodChannel('cardfolio/text_recognition');

  @override
  Future<RecognizedCardText> recognize(String imagePath) async {
    final text = await _channel.invokeMethod<String>(
      'recognize',
      <String, Object?>{'imagePath': imagePath},
    );
    final parsed = RecognizedCardText.fromRawText(text ?? '');
    return RecognizedCardText(
      rawText: parsed.rawText,
      lines: parsed.lines,
      name: parsed.name,
      city: ChinaRegions.findBestPath(parsed.rawText),
      issuer: parsed.issuer,
      code: parsed.code,
      issuedAt: parsed.issuedAt,
    );
  }
}

final class RestTransportCardCatalog implements TransportCardCatalog {
  RestTransportCardCatalog({required this.baseUri, required this.client});

  final Uri? baseUri;
  final http.Client client;

  @override
  bool get isConfigured => baseUri != null;

  @override
  Future<List<TransportCardCatalogMatch>> search(String query) async {
    final base = baseUri;
    if (base == null || query.trim().isEmpty) {
      return const <TransportCardCatalogMatch>[];
    }
    final uri = base
        .resolve('cards/search')
        .replace(
          queryParameters: <String, String>{'q': query.trim(), 'limit': '8'},
        );
    final response = await client.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('公共资料库返回 ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    final items = decoded is List<Object?>
        ? decoded
        : decoded is Map<String, Object?>
        ? decoded['items'] as List<Object?>? ?? const <Object?>[]
        : const <Object?>[];
    return items
        .whereType<Map<Object?, Object?>>()
        .map((raw) {
          final value = raw.map((key, value) => MapEntry('$key', value));
          return TransportCardCatalogMatch(
            id: value['id'] as String? ?? value['name'] as String? ?? '',
            name: value['name'] as String? ?? '',
            confidence: (value['confidence'] as num?)?.toDouble() ?? 0,
            city: value['city'] as String?,
            issuer: value['issuer'] as String?,
            code: value['code'] as String?,
            issuedAt: value['issuedAt'] as String?,
            cardType: value['cardType'] as String?,
            issueQuantity: (value['issueQuantity'] as num?)?.toInt(),
            issuePrice: value['issuePrice']?.toString(),
          );
        })
        .where((value) => value.name.isNotEmpty)
        .toList(growable: false);
  }
}

final class BuiltInTransportCardCatalog implements TransportCardCatalog {
  const BuiltInTransportCardCatalog();

  static const _cards = <TransportCardCatalogMatch>[
    TransportCardCatalogMatch(
      id: 'cn-beijing-yikatong',
      name: '北京市政交通一卡通',
      city: '北京市 / 北京市 / 全市',
      issuer: '北京市政交通一卡通有限公司',
      cardType: '公共交通卡',
      confidence: 0,
    ),
    TransportCardCatalogMatch(
      id: 'cn-shanghai-t-union',
      name: '上海公共交通卡',
      city: '上海市 / 上海市 / 全市',
      issuer: '上海公共交通卡股份有限公司',
      cardType: '公共交通卡',
      confidence: 0,
    ),
    TransportCardCatalogMatch(
      id: 'cn-guangzhou-yangchengtong',
      name: '羊城通',
      city: '广东省 / 广州市 / 全市',
      issuer: '广州羊城通有限公司',
      cardType: '公共交通卡',
      confidence: 0,
    ),
    TransportCardCatalogMatch(
      id: 'cn-shenzhen-tong',
      name: '深圳通',
      city: '广东省 / 深圳市 / 全市',
      issuer: '深圳通有限公司',
      cardType: '公共交通卡',
      confidence: 0,
    ),
    TransportCardCatalogMatch(
      id: 'cn-wuhan-tong',
      name: '武汉通',
      city: '湖北省 / 武汉市 / 全市',
      issuer: '武汉城市一卡通有限公司',
      cardType: '公共交通卡',
      confidence: 0,
    ),
    TransportCardCatalogMatch(
      id: 'cn-nanjing-jinlingtong',
      name: '金陵通',
      city: '江苏省 / 南京市 / 全市',
      issuer: '南京市市民卡有限公司',
      cardType: '公共交通卡',
      confidence: 0,
    ),
    TransportCardCatalogMatch(
      id: 'cn-xian-changantong',
      name: '长安通',
      city: '陕西省 / 西安市 / 全市',
      issuer: '西安城市一卡通有限责任公司',
      cardType: '公共交通卡',
      confidence: 0,
    ),
    TransportCardCatalogMatch(
      id: 'cn-chengdu-tianfutong',
      name: '天府通',
      city: '四川省 / 成都市 / 全市',
      issuer: '成都天府通金融服务股份有限公司',
      cardType: '公共交通卡',
      confidence: 0,
    ),
    TransportCardCatalogMatch(
      id: 'cn-chongqing-changxingtong',
      name: '重庆交通卡',
      city: '重庆市 / 重庆市 / 全市',
      issuer: '重庆市轨道交通（集团）有限公司',
      cardType: '公共交通卡',
      confidence: 0,
    ),
    TransportCardCatalogMatch(
      id: 'cn-suzhou-citizen',
      name: '苏州市民卡',
      city: '江苏省 / 苏州市 / 全市',
      issuer: '苏州市民卡有限公司',
      cardType: '公共交通卡',
      confidence: 0,
    ),
  ];

  @override
  bool get isConfigured => true;

  @override
  Future<List<TransportCardCatalogMatch>> search(String query) async {
    final normalized = query.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    if (normalized.isEmpty) return const <TransportCardCatalogMatch>[];
    final matches = <TransportCardCatalogMatch>[];
    for (final card in _cards) {
      final terms = <String>[card.name, ?card.city, ?card.issuer];
      var score = 0.0;
      for (final term in terms) {
        final value = term.toLowerCase().replaceAll(RegExp(r'\s+'), '');
        if (normalized.contains(value) || value.contains(normalized)) {
          score = score < 0.92 ? 0.92 : score;
        } else {
          final characters = value.runes
              .where((character) => normalized.runes.contains(character))
              .length;
          score = score < characters / value.runes.length
              ? characters / value.runes.length
              : score;
        }
      }
      if (score >= 0.35) {
        matches.add(
          TransportCardCatalogMatch(
            id: card.id,
            name: card.name,
            confidence: score,
            city: card.city,
            issuer: card.issuer,
            cardType: card.cardType,
          ),
        );
      }
    }
    matches.sort((left, right) => right.confidence.compareTo(left.confidence));
    return matches.take(8).toList(growable: false);
  }
}

final class CompositeTransportCardCatalog implements TransportCardCatalog {
  CompositeTransportCardCatalog({required this.builtIn, required this.remote});

  final TransportCardCatalog builtIn;
  final TransportCardCatalog remote;

  @override
  bool get isConfigured => true;

  @override
  Future<List<TransportCardCatalogMatch>> search(String query) async {
    final local = await builtIn.search(query);
    if (!remote.isConfigured) return local;
    try {
      final online = await remote.search(query);
      final seen = <String>{};
      return <TransportCardCatalogMatch>[
        for (final value in <TransportCardCatalogMatch>[...online, ...local])
          if (seen.add(value.id)) value,
      ];
    } on Object {
      return local;
    }
  }
}

final Provider<CardTextRecognizer> cardTextRecognizerProvider =
    Provider<CardTextRecognizer>(
      (ref) => const MethodChannelCardTextRecognizer(),
    );

final Provider<TransportCardCatalog> transportCardCatalogProvider =
    Provider<TransportCardCatalog>((ref) {
      final client = http.Client();
      ref.onDispose(client.close);
      const baseUrl = String.fromEnvironment('CARD_FOLIO_CATALOG_BASE_URL');
      return CompositeTransportCardCatalog(
        builtIn: const BuiltInTransportCardCatalog(),
        remote: RestTransportCardCatalog(
          baseUri: baseUrl.isEmpty ? null : Uri.parse(baseUrl),
          client: client,
        ),
      );
    });
