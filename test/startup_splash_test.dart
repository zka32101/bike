import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bike_license_kore/widgets/startup_splash.dart';
import 'package:ukalab_core/ui.dart' show UkalabStartupSplash, contrastRatio;

Finder _imageByAsset(String assetName) => find.byWidgetPredicate(
      (w) => w is Image && w.image is AssetImage && (w.image as AssetImage).assetName == assetName,
    );

String _nativeSplashColor(String resPath) {
  final xml = File('android/app/src/main/res/$resPath/colors.xml').readAsStringSync();
  final m = RegExp(r'name="splash_background">#([0-9A-Fa-f]{6})<').firstMatch(xml);
  expect(m, isNotNull, reason: '$resPath/colors.xml に splash_background が必要');
  return m!.group(1)!.toUpperCase();
}

String _hex(Color c) => (c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();

void main() {
  testWidgets('起動画面は UkalabStartupSplash で、透過アイコン（角丸クリップなし）と組織ロゴと進行表示を出す', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: StartupSplash()));

    expect(find.byType(UkalabStartupSplash), findsOneWidget);
    final icon = _imageByAsset(StartupSplash.iconAsset);
    expect(icon, findsOneWidget);
    expect(find.ancestor(of: icon, matching: find.byType(ClipRRect)), findsNothing);
    expect(tester.getSize(icon), const Size(StartupSplash.iconSize, StartupSplash.iconSize));
    // 組織ロゴ（kit 同梱）
    final logos = tester.widgetList<Image>(find.byType(Image)).where((i) {
      final p = i.image;
      return p is AssetImage && p.assetName == 'assets/branding/yourwish_logo.png';
    });
    expect(logos.length, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.bySemanticsLabel('Your Wish'), findsOneWidget);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      StartupSplash.splashBackground,
    );
  });

  testWidgets('ダークモードでは暗い背景色になる', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpWidget(const MaterialApp(home: StartupSplash()));
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      StartupSplash.splashBackgroundDark,
    );
  });

  test('端末側の起動画面の背景色（colors.xml）と Flutter 側が一致する', () {
    expect(_nativeSplashColor('values'), _hex(StartupSplash.splashBackground));
    expect(_nativeSplashColor('values-night'), _hex(StartupSplash.splashBackgroundDark));
  });

  test('白いアイコンと進行表示が背景に対して 4.5:1 以上のコントラストになる', () {
    const white = Colors.white;
    expect(contrastRatio(white, StartupSplash.splashBackground), greaterThanOrEqualTo(4.5));
    expect(contrastRatio(white, StartupSplash.splashBackgroundDark), greaterThanOrEqualTo(4.5));
    expect(contrastRatio(StartupSplash.progressColor, StartupSplash.splashBackground),
        greaterThanOrEqualTo(4.5));
    expect(contrastRatio(StartupSplash.progressColorDark, StartupSplash.splashBackgroundDark),
        greaterThanOrEqualTo(4.5));
  });

  test('端末側の起動画面は、中央に ic_launcher_foreground を置く（空アイコンは使わない）', () {
    const base = 'android/app/src/main/res';
    for (final p in ['$base/drawable/launch_background.xml', '$base/drawable-v21/launch_background.xml']) {
      expect(File(p).readAsStringSync(), contains('@drawable/ic_launcher_foreground'), reason: p);
    }
    for (final p in ['$base/values-v31/styles.xml', '$base/values-night-v31/styles.xml']) {
      final xml = File(p).readAsStringSync();
      expect(xml, contains('windowSplashScreenAnimatedIcon">@drawable/ic_launcher_foreground'), reason: p);
      expect(xml, isNot(contains('splash_empty_icon')), reason: p);
    }
    expect(File('$base/drawable/splash_empty_icon.xml').existsSync(), isFalse);
  });
}
