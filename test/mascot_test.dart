import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:bike_license_kore/models/mascot.dart';

void main() {
  test('Lv は習熟度で上がり、回答数が少ないと1', () {
    expect(mascotLevelFromScore(null, 0), 1);
    expect(mascotLevelFromScore(95, 5), 1);
    expect(mascotLevelFromScore(25, 30), 2);
    expect(mascotLevelFromScore(45, 30), 3);
    expect(mascotLevelFromScore(65, 30), 4);
    expect(mascotLevelFromScore(85, 30), 5);
  });

  test('全キャラ・全Lvの画像ファイルが存在する', () {
    for (final m in Mascot.values) {
      expect(File(m.iconAsset).existsSync(), true, reason: m.iconAsset);
      for (var lv = 1; lv <= 5; lv++) {
        for (final costume in [false, true]) {
          final a = m.imageAsset(lv, costume: costume);
          expect(File(a).existsSync(), true, reason: a);
        }
        expect(File(m.joyAsset(lv)).existsSync(), true, reason: m.joyAsset(lv));
      }
      final pass = m.imageAsset(5, costume: true, passed: true);
      expect(File(pass).existsSync(), true, reason: pass);
    }
  });

  test('励ましの言葉は全Lv用意され、責める語を含まない', () {
    for (final m in Mascot.values) {
      expect(m.lines.length, 5);
      for (final l in m.lines) {
        expect(l, isNotEmpty);
        for (final t in l) {
          expect(RegExp('だめ|ダメ|ちゃんと|なぜ').hasMatch(t), false, reason: t);
        }
      }
      expect(mascotLine(m, 3), isNotEmpty);
    }
  });
}
