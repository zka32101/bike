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

  // 第2弾（16種）。標識令 別表第二の図と、備考一（三）の色の規定で確認。
  group('追加した16種（第2弾）', () {
    const warning = [
      'sign_y_junction_ahead', 'sign_roundabout_ahead', 'sign_bumpy_road',
      'sign_steep_up', 'sign_steep_down', 'sign_crosswind',
      'sign_merge_traffic', 'sign_lane_reduction',
    ];
    const regulatory1 = [
      'sign_no_large_buses', 'sign_no_dangerous_goods', 'sign_max_width',
      'sign_moped_small_right',
    ];
    const regulatory3 = [
      'sign_time_limit_parking', 'sign_pedestrian_only',
      'sign_moped_two_stage_right', 'sign_roundabout_circulation',
    ];

    test('全部で83種になった', () {
      expect(kTrafficSigns.length, 83);
    });

    test('警戒標識は黄色いひし形（縁線・記号は黒）', () {
      for (final id in warning) {
        final s = sign(id);
        expect(s.category, '警戒標識', reason: id);
        expect(s.shape, SignShape.diamond, reason: id);
        expect(s.backgroundColor, SignColors.yellow, reason: id);
        expect(s.borderColor, SignColors.black, reason: id);
      }
    });

    test('規制標識(1)は白地・赤い枠・青い文字と記号（備考一（三）３（１））', () {
      for (final id in regulatory1) {
        final s = sign(id);
        expect(s.category, '規制標識', reason: id);
        expect(s.backgroundColor, SignColors.white, reason: id);
        expect(s.borderColor, SignColors.red, reason: id);
        if (s.symbol != SignSymbol.none) {
          expect(s.symbolColor, SignColors.blue, reason: id);
        }
        if (s.centerText != null) {
          expect(s.centerTextColor, SignColors.blue, reason: id);
        }
      }
    });

    test('規制標識(3)は青地・白い文字と記号（備考一（三）３（３））', () {
      for (final id in regulatory3) {
        final s = sign(id);
        expect(s.category, '規制標識', reason: id);
        expect(s.backgroundColor, SignColors.blue, reason: id);
        expect(s.symbolColor, SignColors.white, reason: id);
        expect(s.slash, SignSlash.none, reason: id);
      }
    });

    test('原付の右折方法は、二段階が青地、小回りが白地・赤い斜めの帯で、取り違えていない', () {
      final two = sign('sign_moped_two_stage_right');
      final small = sign('sign_moped_small_right');
      expect(two.backgroundColor, isNot(small.backgroundColor));
      expect(two.hasDiagonalSlash, isFalse);
      expect(small.hasDiagonalSlash, isTrue);
      expect(two.symbol, small.symbol);
      expect(two.centerText, small.centerText);
    });

    test('ロータリーあり（警戒）と、環状の交差点における右回り通行（規制）は別の標識', () {
      final w = sign('sign_roundabout_ahead');
      final r = sign('sign_roundabout_circulation');
      expect(w.category, isNot(r.category));
      expect(w.symbol, r.symbol);
      expect(w.backgroundColor, isNot(r.backgroundColor));
    });

    test('最大幅(322)は左右の三角、高さ制限は上下の三角で、図柄が違う', () {
      expect(sign('sign_max_width').symbol, SignSymbol.widthMarkers);
      expect(sign('sign_height_limit').symbol, SignSymbol.heightMarkers);
    });

    test('上り急こう配と下り急こう配は、くさびの向きが逆', () {
      expect(sign('sign_steep_up').symbol, SignSymbol.slopeUp);
      expect(sign('sign_steep_down').symbol, SignSymbol.slopeDown);
    });

    test('選択肢の正解位置が偏りすぎていない（追加16種）', () {
      final counts = List.filled(4, 0);
      for (final id in [...warning, ...regulatory1, ...regulatory3]) {
        counts[sign(id).answer]++;
      }
      for (final c in counts) {
        expect(c, inInclusiveRange(2, 7));
      }
    });
  });
}
