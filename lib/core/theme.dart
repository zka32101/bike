import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';

/// うかラボ共通テーマ（app_common_kit v0.2）。バイク免許は「技術・安全」の分野色。
///
/// 色・文字サイズ・角丸・タップ領域は共通デザイン仕様 v0.4 に従う。色を直書きしない。
/// ボタンは従来どおり横幅いっぱい（高さ48）にする。
class AppTheme {
  AppTheme._();

  static const UkalabField field = UkalabField.tech;

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final base = UkalabTheme.build(field: field, brightness: brightness);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(UkalabTheme.buttonRadius),
    );
    return base.copyWith(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48), // 44pt+ 確保
          shape: shape,
          backgroundColor: base.colorScheme.primary,
          foregroundColor: base.colorScheme.onPrimary,
        ),
      ),
    );
  }
}
