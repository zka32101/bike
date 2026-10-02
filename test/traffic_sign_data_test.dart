import 'package:bike_license_kore/models/traffic_sign.dart';
import 'package:flutter_test/flutter_test.dart';

TrafficSign sign(String id) => kTrafficSigns.firstWhere((s) => s.id == id);

void main() {
  test('標識クイズのデータが正しい（id重複なし・4択・正解が範囲内・解説あり）', () {
    final ids = kTrafficSigns.map((s) => s.id).toList();
    expect(ids.toSet().length, ids.length);
    for (final s in kTrafficSigns) {
      expect(s.choices, hasLength(4), reason: s.id);
      expect(s.answer, inInclusiveRange(0, 3), reason: s.id);
      expect(s.choices.toSet().length, 4, reason: '${s.id} の選択肢が重複');
      expect(s.explanation.trim(), isNotEmpty, reason: s.id);
    }
  });

  group('公式資料で確認できた標識の外見', () {
    test('徐行は白地・赤縁・青字の逆三角形（国土交通省 2017-04-13 報道発表）', () {
      final s = sign('sign_slow');
      expect(s.shape, SignShape.invertedTriangle);
      expect(s.backgroundColor, SignColors.white);
      expect(s.borderColor, SignColors.red);
      expect(s.centerTextColor, SignColors.blue);
      expect(s.centerText, '徐行');
    });

    test('一時停止は赤地・白縁の逆三角形で、徐行と取り違えていない', () {
      final stop = sign('sign_stop');
      expect(stop.shape, SignShape.invertedTriangle);
      expect(stop.backgroundColor, SignColors.red);
      expect(stop.rimColor, SignColors.white);
      expect(stop.backgroundColor, isNot(sign('sign_slow').backgroundColor));
    });
  });

  // 道路標識、区画線及び道路標示に関する命令 別表第二 備考一（三）３（１）:
  // 「文字及び記号を青色、斜めの帯及び枠を赤色、縁及び地を白色とする」
  group('規制標識（１）は 白地・赤い枠・青い記号（標識令 別表第二 備考）', () {
    const ids = [
      'sign_max_speed_40',
      'sign_min_speed_30',
      'sign_road_closed_all',
      'sign_road_closed_vehicles',
      'sign_no_tandem',
      'sign_no_u_turn',
      'sign_no_motorcycles',
      'sign_no_pedestrians',
      'sign_no_bicycles',
      'sign_no_crossing_vehicles',
    ];
    for (final id in ids) {
      test(id, () {
        final s = sign(id);
        expect(s.backgroundColor, SignColors.white);
        expect(s.borderColor, SignColors.red);
        if (s.symbol != SignSymbol.none) {
          expect(s.symbolColor, SignColors.blue);
        }
      });
    }
  });

  group('斜めの帯・×印（標識令の図で確認）', () {
    test('通行止め(301)は×印、車両通行止め(302)は斜めの帯', () {
      expect(sign('sign_road_closed_all').hasCrossSlash, isTrue);
      expect(sign('sign_road_closed_vehicles').hasDiagonalSlash, isTrue);
      expect(sign('sign_road_closed_vehicles').symbol, SignSymbol.none);
    });

    test('二輪(307)・自転車(309)・歩行者等(331)・二人乗り(310の2)は斜めの帯', () {
      for (final id in [
        'sign_no_motorcycles',
        'sign_no_bicycles',
        'sign_no_pedestrians',
        'sign_no_tandem',
      ]) {
        expect(sign(id).hasDiagonalSlash, isTrue, reason: id);
      }
    });

    test('歩行者等通行止め(331)は正方形', () {
      expect(sign('sign_no_pedestrians').shape, SignShape.square);
    });

    test('駐車禁止は斜めの帯1本、駐停車禁止は×印', () {
      expect(sign('sign_no_parking').hasDiagonalSlash, isTrue);
      expect(sign('sign_no_stopping').hasCrossSlash, isTrue);
    });
  });

  test('最低速度(324)は最高速度と同じ白地・赤枠で、数字の下に線がある', () {
    final min = sign('sign_min_speed_30');
    final max = sign('sign_max_speed_40');
    expect(min.backgroundColor, max.backgroundColor);
    expect(min.borderColor, max.borderColor);
    expect(min.symbol, SignSymbol.speedUnderline);
    expect(max.symbol, isNot(SignSymbol.speedUnderline));
  });

  test('描き直した2種が入っていて、公式どおりの色・形', () {
    final lane = sign('sign_vehicle_classification');
    expect(lane.shape, SignShape.wideRect);
    expect(lane.backgroundColor, SignColors.white);
    final ov = sign('sign_no_overtaking_protrusion');
    expect(ov.backgroundColor, SignColors.white);
    expect(ov.symbolColor, SignColors.blue);
    expect(ov.slash, SignSlash.single);
  });

  test('追加した7種が入っている（標識令 別表第二の図に基づく）', () {
    for (final id in [
      'sign_no_large_trucks',
      'sign_side_by_side_ok',
      'sign_tram_track_ok',
      'sign_parking_parallel',
      'sign_parking_right',
      'sign_parking_angled',
      'sign_bus_lane',
    ]) {
      expect(sign(id).name, isNotEmpty);
    }
    expect(sign('sign_no_large_trucks').backgroundColor, SignColors.white);
    expect(sign('sign_no_large_trucks').symbolColor, SignColors.blue);
    expect(sign('sign_no_large_trucks').slash, SignSlash.single);
    expect(sign('sign_parking_right').backgroundColor, SignColors.blue);
  });

  test('駐車の向きの標識(327の11〜13)は規制標識', () {
    for (final id in ['sign_parking_parallel', 'sign_parking_right', 'sign_parking_angled']) {
      expect(sign(id).category, sign('sign_stop').category, reason: id);
    }
  });
}
