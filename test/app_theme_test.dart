import 'package:app_common_kit/app_common_kit.dart';
import 'package:bike_license_kore/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('共通テーマ（技術・安全）を使い、色を直書きしていない', () {
    final l = AppTheme.light();
    final d = AppTheme.dark();
    expect(l.colorScheme.primary, const Color(0xFFC23D16));
    expect(d.colorScheme.primary, const Color(0xFFFF8A65));
    expect(l.colorScheme.onPrimary, Colors.white);
    expect(d.colorScheme.onPrimary, UkalabPalette.onFillDark);
    expect(l.scaffoldBackgroundColor, const Color(0xFFF6F8FB));
  });

  test('ボタンのタップ領域は 44pt 以上（従来どおり高さ48）', () {
    final s = AppTheme.light().elevatedButtonTheme.style!;
    expect(s.minimumSize!.resolve({})!.height, greaterThanOrEqualTo(44));
  });

  test('文字サイズは共通仕様（本文16・注釈13）', () {
    final t = AppTheme.light().textTheme;
    expect(t.bodyMedium!.fontSize, 16);
    expect(t.bodySmall!.fontSize, 13);
  });
}
