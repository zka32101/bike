import 'package:app_common_kit/app_common_kit.dart';
import 'package:bike_license_kore/services/ad_gate_service.dart';
import 'package:bike_license_kore/services/ad_units.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdGateService（禁止ゾーン）', () {
    test('初期状態では広告を出してよい', () {
      expect(AdGateService().isAdAllowedNow, isTrue);
    });

    test('出題中・ボス戦中・合格予測メーター直後は出さない', () {
      final gate = AdGateService();
      for (final context in [
        AdBlockingContext.answeringQuestion,
        AdBlockingContext.trapDojoBossBattle,
        AdBlockingContext.justShowedPredictionMeter,
      ]) {
        gate.enterContext(context);
        expect(gate.isAdAllowedNow, isFalse, reason: '$context');
      }
    });

    test('禁止ゾーンを出れば再び出してよい', () {
      final gate = AdGateService()
        ..enterContext(AdBlockingContext.answeringQuestion);
      expect(gate.isAdAllowedNow, isFalse);
      gate.exitContext();
      expect(gate.isAdAllowedNow, isTrue);
    });
  });

  group('BikeAdUnits（debug=テストID／release=本番ID）', () {
    test('debug ではAndroid・iOSともGoogle公式のテストID', () {
      for (final android in [true, false]) {
        final ids = BikeAdUnits.resolve(isRelease: false, isAndroid: android)!;
        expect(ids.usesTestIds, isTrue, reason: 'android=$android');
        expect(ids.banner, startsWith(AdUnitIds.testPublisherPrefix));
        expect(ids.interstitial, startsWith(AdUnitIds.testPublisherPrefix));
        expect(ids.rewarded, startsWith(AdUnitIds.testPublisherPrefix));
      }
    });

    test('release のAndroidは本番ID（テストIDを含まない）', () {
      final ids = BikeAdUnits.resolve(isRelease: true, isAndroid: true)!;
      expect(ids.usesTestIds, isFalse);
      // release でテストIDだとキットが例外にするので、ここを通ることが重要。
      ids.assertNoTestIdsInRelease(isRelease: true);
    });

    test('release のiOSは本番ID未発行のため null（広告なしで動作）', () {
      expect(BikeAdUnits.resolve(isRelease: true, isAndroid: false), isNull);
    });
  });
}
