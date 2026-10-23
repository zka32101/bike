import 'dart:io';

import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/foundation.dart';

/// 広告ユニットID（debug はGoogle公式のテストID、release は --dart-define 注入）。
///
/// 本番IDはソースに置かない。release ビルドでは次を --dart-define で渡す:
/// AD_BANNER_ID / AD_INTERSTITIAL_ID / AD_REWARDED_ID（Android）、
/// AD_BANNER_ID_IOS / AD_INTERSTITIAL_ID_IOS / AD_REWARDED_ID_IOS（iOS、未発行なら空で広告なし）。
/// Android の release で未注入なら起動時に StateError で失敗する。
/// release でテストIDを使うと app_common_kit が起動時に例外にする（既存挙動）。
///
/// debug ビルドで本番IDを使うと無効トラフィックになるため、debug は必ずテストID。
class BikeAdUnits {
  BikeAdUnits._();

  static const _bannerAndroid = String.fromEnvironment('AD_BANNER_ID');
  static const _interstitialAndroid =
      String.fromEnvironment('AD_INTERSTITIAL_ID');
  static const _rewardedAndroid = String.fromEnvironment('AD_REWARDED_ID');
  static const _bannerIos = String.fromEnvironment('AD_BANNER_ID_IOS');
  static const _interstitialIos =
      String.fromEnvironment('AD_INTERSTITIAL_ID_IOS');
  static const _rewardedIos = String.fromEnvironment('AD_REWARDED_ID_IOS');

  /// 使うIDを返す。release の iOS で未注入（未発行）なら null（広告なしで動作）。
  /// release の Android で未注入なら StateError。
  /// [banner]/[interstitial]/[rewarded] はテスト用の注入口（省略時は dart-define 値）。
  static AdUnitIds? resolve({
    bool? isRelease,
    bool? isAndroid,
    String? banner,
    String? interstitial,
    String? rewarded,
  }) {
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

    final b = banner ?? (android ? _bannerAndroid : _bannerIos);
    final i = interstitial ?? (android ? _interstitialAndroid : _interstitialIos);
    final r = rewarded ?? (android ? _rewardedAndroid : _rewardedIos);
    if (b.isEmpty || i.isEmpty || r.isEmpty) {
      if (android) {
        throw StateError(
          'release ビルドに広告ユニットIDが注入されていません。'
          '--dart-define=AD_BANNER_ID / AD_INTERSTITIAL_ID / AD_REWARDED_ID を指定してください。',
        );
      }
      return null;
    }
    return AdUnitIds(banner: b, interstitial: i, rewarded: r);
  }
}
