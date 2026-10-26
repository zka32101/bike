import 'package:flutter/material.dart';
import 'package:ukalab_core/ui.dart' show UkalabCert, UkalabStartupSplash;

/// 起動中の読み込み画面。ukalab_core の [UkalabStartupSplash] を使う
/// （資格色の背景＋中央に透過 foreground アイコン＋下部に組織ロゴ）。
///
/// 端末側（Android）の起動画面は、同じ背景色に `ic_launcher_foreground` を中央に置いたもの
/// （`launch_background.xml` / `values-v31`）。Flutter 側を同じ背景色にして、
/// 切り替わりが一枚の画面として見えるようにする。
/// 初期化（Firebase・課金・広告・examData など）が終わる前に出す。広告は出さない（CD-007）。
///
/// 背景色:
/// - ライト: [UkalabCert.bikeLicense] のライト色（colors.xml の `splash_background` と同じ）。
///   白い foreground アイコンとのコントラストは 5.2:1。
/// - ダーク: 既存の `#121A24`（values-night/colors.xml と同じ）。資格色のダーク色（淡い橙）に
///   白いアイコンを載せると 2.1:1 で読めないため、`UkalabStartupSplash.cert` は使わない。
class StartupSplash extends StatelessWidget {
  const StartupSplash({super.key});

  /// 透過の foreground 画像（白）。アプリのランチャーアイコンの前景と同じ。
  static const iconAsset = 'assets/icon/app_icon_fg.png';

  /// アイコンの一辺（core の既定）。
  static const iconSize = 160.0;

  /// ライトの背景色（colors.xml の `splash_background` と同じ値）。
  static final Color splashBackground = UkalabCert.bikeLicense.light;

  /// ダークの背景色（values-night/colors.xml の `splash_background` と同じ値）。
  static const Color splashBackgroundDark = Color(0xFF121A24);

  /// 進行表示の色。背景に対して 4.5:1 以上になる色にする。
  static final Color progressColor = Colors.white;
  static final Color progressColorDark = UkalabCert.bikeLicense.dark;

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    return Theme(
      data: Theme.of(context).copyWith(
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: dark ? progressColorDark : progressColor,
        ),
      ),
      child: UkalabStartupSplash(
        backgroundColor: dark ? splashBackgroundDark : splashBackground,
        iconAsset: iconAsset,
        iconSize: iconSize,
      ),
    );
  }
}
