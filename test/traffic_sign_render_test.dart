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
    'sign_no_overtaking',
    'sign_no_overtaking_protrusion',
    'sign_vehicle_classification',
    'sign_crosswind',
    'sign_no_u_turn',
    'sign_pedestrian_crossing',
    'sign_bicycle_crossing',
    'sign_horn_zone',
    'sign_sound_horn',
    'sign_falling_rocks',
    'sign_bumpy_road',
    'sign_merge_traffic',
    'sign_lane_reduction',
    'sign_aux_distance',
    'sign_aux_except_holiday',
    'sign_aux_time',
    'sign_aux_large_truck',
    'sign_aux_except_moped',
    'sign_aux_start',
    'sign_aux_section',
    'sign_aux_end',
    'sign_aux_no_overtaking',
    'sign_aux_priority_ahead',
    'sign_aux_rail_caution',
    'sign_aux_animal_caution',
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
