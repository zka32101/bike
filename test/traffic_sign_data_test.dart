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
}
