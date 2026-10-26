import 'package:app_common_kit/app_common_kit.dart';
import 'package:bike_license_kore/services/bike_ad_rules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('kBikeAdRules（インタースティシャル1日1回 / CD-007）', () {
    late DateTime now;
    late AdFrequencyController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      now = DateTime(2026, 10, 24, 9, 0);
      controller = AdFrequencyController(prefs, clock: () => now);
    });

    test('日次上限は1回', () {
      expect(kBikeAdRules.interstitialDailyCap, 1);
    });

    test('AdConfig に渡すとルールが反映される', () {
      const config = AdConfig(
        unitIds: AdUnitIds(banner: 'b', interstitial: 'i', rewarded: 'r'),
        rules: kBikeAdRules,
      );
      expect(config.rules.interstitialDailyCap, 1);
    });

    test('その日の1回目は許可される', () {
      expect(controller.canShowInterstitial(kBikeAdRules), isTrue);
    });

    test('1回表示した後は、直後（同一セッション2回目）も拒否される', () async {
      await controller.recordInterstitialShown();
      expect(controller.canShowInterstitial(kBikeAdRules), isFalse);
      now = now.add(const Duration(seconds: 1));
      expect(controller.canShowInterstitial(kBikeAdRules), isFalse);
    });

    test('最短間隔（3分）を過ぎても同じ日は拒否される', () async {
      await controller.recordInterstitialShown();
      now = now.add(const Duration(hours: 5));
      expect(controller.canShowInterstitial(kBikeAdRules), isFalse);
    });

    test('日付が変われば再び許可される', () async {
      await controller.recordInterstitialShown();
      now = DateTime(2026, 10, 25, 0, 5);
      expect(controller.canShowInterstitial(kBikeAdRules), isTrue);
    });

    test('kit 既定ルールでは同日に複数回出せる（上書きの効果の確認）', () async {
      const defaults = AdRules();
      await controller.recordInterstitialShown();
      now = now.add(const Duration(minutes: 4));
      expect(controller.canShowInterstitial(defaults), isTrue);
      expect(controller.canShowInterstitial(kBikeAdRules), isFalse);
    });
  });
}
