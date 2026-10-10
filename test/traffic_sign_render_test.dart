import 'dart:io';
import 'dart:ui' as ui;

import 'package:bike_license_kore/models/traffic_sign.dart';
import 'package:bike_license_kore/widgets/traffic_sign_painter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// 修正した標識を PNG に書き出す（環境変数 SIGN_OUT_DIR が指定されたときだけ）。
void main() {
  final out = Platform.environment['SIGN_OUT_DIR'];
  const ids = [
    'sign_priority_road',
    'sign_road_closed_all',
    'sign_no_dangerous_goods',
    'sign_moped_small_right',
  ];
  test('render fixed signs', () async {
    final font = File(Platform.environment['SIGN_FONT'] ?? 'C:/Windows/Fonts/NotoSansJP-VF.ttf');
    final loader = FontLoader('NotoSansJP')
      ..addFont(Future.value(ByteData.view(font.readAsBytesSync().buffer)));
    await loader.load();
    for (final id in ids) {
      final i = kTrafficSigns.indexWhere((s) => s.id == id);
      expect(i, greaterThanOrEqualTo(0));
      final rec = ui.PictureRecorder();
      final c = ui.Canvas(rec);
      c.drawRect(const ui.Rect.fromLTWH(0, 0, 256, 256), ui.Paint()..color = const ui.Color(0xFFFFFFFF));
      TrafficSignPainter(kTrafficSigns[i], fontFamily: 'NotoSansJP')
          .paint(c, const ui.Size(256, 256));
      final img = await rec.endRecording().toImage(256, 256);
      final bytes = (await img.toByteData(format: ui.ImageByteFormat.png))!;
      if (out != null) {
        Directory(out).createSync(recursive: true);
        File('$out/${(i + 1).toString().padLeft(2, '0')}_$id.png')
            .writeAsBytesSync(bytes.buffer.asUint8List());
      }
    }
  });
}
