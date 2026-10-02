import 'dart:io';

import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/foundation.dart';

/// 広告ユニットID（debug はGoogle公式のテストID、release は本番ID）。
///
/// 本番IDは「原付・バイク免許コレ！」用に AdMob で発行済み
/// （2026-09-28、App ID: ca-app-pub-5058227312086483~9215678835）。
/// 広告ユニットIDはアプリ識別用の公開情報のためデフォルト値として持ち、
/// --dart-define=ADMOB_BANNER_AD_UNIT_ID_ANDROID=... 等で上書きもできる。
/// iOS用IDは未発行（iOSアプリをAdMobに追加後に設定すること）。
///
/// debug ビルドで本番IDを使うと、開発中の表示・クリックが無効トラフィックに
/// なるため、必ずテストIDに切り替える。release でテストIDを使うと
/// app_common_kit が起動時に例外にする。
class BikeAdUnits {
  BikeAdUnits._();

  static const _bannerAndroid = String.fromEnvironment(
    'ADMOB_BANNER_AD_UNIT_ID_ANDROID',
    defaultValue: 'ca-app-pub-5058227312086483/6564630614',
  );
  static const _interstitialAndroid = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_AD_UNIT_ID_ANDROID',
    defaultValue: 'ca-app-pub-5058227312086483/8853725911',
  );
  static const _rewardedAndroid = String.fromEnvironment(
    'ADMOB_REWARDED_AD_UNIT_ID_ANDROID',
    defaultValue: 'ca-app-pub-5058227312086483/3963352158',
  );
  static const _bannerIos = String.fromEnvironment('ADMOB_BANNER_AD_UNIT_ID_IOS');
  static const _interstitialIos =
      String.fromEnvironment('ADMOB_INTERSTITIAL_AD_UNIT_ID_IOS');
  static const _rewardedIos =
      String.fromEnvironment('ADMOB_REWARDED_AD_UNIT_ID_IOS');

  /// 使うIDを返す。release で本番IDが未発行（iOS）の場合は null（広告なしで動作）。
  static AdUnitIds? resolve({bool? isRelease, bool? isAndroid}) {
    final release = isRelease ?? kReleaseMode;
    final android = isAndroid ?? Platform.isAndroid;

    if (!release) {
      return android
          ? const AdUnitIds(
              banner: 'ca-app-pub-3940256099942544/6300978111',
              interstitial: 'ca-app-pub-3940256099942544/1033173712',
              rewarded: 'ca-app-pub-3940256099942544/5224354917',
            )
          : const AdUnitIds(
              banner: 'ca-app-pub-3940256099942544/2934735716',
              interstitial: 'ca-app-pub-3940256099942544/4411468910',
              rewarded: 'ca-app-pub-3940256099942544/1712485313',
            );
    }

    final banner = android ? _bannerAndroid : _bannerIos;
    final interstitial = android ? _interstitialAndroid : _interstitialIos;
    final rewarded = android ? _rewardedAndroid : _rewardedIos;
    if (banner.isEmpty || interstitial.isEmpty || rewarded.isEmpty) return null;
    return AdUnitIds(
      banner: banner,
      interstitial: interstitial,
      rewarded: rewarded,
    );
  }
}
