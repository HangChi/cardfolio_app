import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

@immutable
final class SeriesCoverPreset {
  const SeriesCoverPreset({
    required this.name,
    required this.background,
    required this.accent,
    required this.foreground,
  });

  final String name;
  final Color background;
  final Color accent;
  final Color foreground;
}

const List<SeriesCoverPreset> seriesCoverPresets = <SeriesCoverPreset>[
  SeriesCoverPreset(
    name: '藏蓝票夹',
    background: Color(0xFF183153),
    accent: Color(0xFFEDB458),
    foreground: Color(0xFFF7F2E8),
  ),
  SeriesCoverPreset(
    name: '邮政墨绿',
    background: Color(0xFF244B3A),
    accent: Color(0xFFB6D7A8),
    foreground: Color(0xFFF3F4E9),
  ),
  SeriesCoverPreset(
    name: '朱砂票根',
    background: Color(0xFF9F3B32),
    accent: Color(0xFFF2C078),
    foreground: Color(0xFFFFF7E9),
  ),
  SeriesCoverPreset(
    name: '雾蓝站牌',
    background: Color(0xFF5A7894),
    accent: Color(0xFFD7E4EC),
    foreground: Color(0xFFFFFFFF),
  ),
  SeriesCoverPreset(
    name: '石墨编号',
    background: Color(0xFF343A40),
    accent: Color(0xFFCDD2D7),
    foreground: Color(0xFFF8F9FA),
  ),
];

Future<String> createSeriesPresetCover({
  required SeriesCoverPreset preset,
  required String title,
  required String outputId,
}) async {
  const size = Size(1200, 800);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(Offset.zero & size, Paint()..color = preset.background);
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, 86, 800),
    Paint()..color = preset.accent,
  );
  canvas.drawCircle(
    const Offset(1030, 132),
    66,
    Paint()
      ..color = preset.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10,
  );
  canvas.drawCircle(
    const Offset(1030, 132),
    12,
    Paint()..color = preset.accent,
  );

  final safeTitle = title.trim().isEmpty ? '我的集卡册' : title.trim();
  final titlePainter = TextPainter(
    text: TextSpan(
      text: safeTitle,
      style: TextStyle(
        color: preset.foreground,
        fontSize: 78,
        height: 1.14,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
      ),
    ),
    maxLines: 3,
    ellipsis: '…',
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: 820);
  titlePainter.paint(canvas, const Offset(164, 282));

  final captionPainter = TextPainter(
    text: TextSpan(
      text: 'CARDFOLIO  ·  COLLECTION',
      style: TextStyle(
        color: preset.foreground.withValues(alpha: 0.72),
        fontSize: 25,
        fontWeight: FontWeight.w600,
        letterSpacing: 4,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  captionPainter.paint(canvas, const Offset(168, 684));

  final image = await recorder.endRecording().toImage(
    size.width.toInt(),
    size.height.toInt(),
  );
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  if (bytes == null) throw StateError('默认封面生成失败。');
  final temporaryRoot = await getTemporaryDirectory();
  final file = File('${temporaryRoot.path}/series-cover-$outputId.png');
  await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
  return file.path;
}
