import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Google Mobile Ads の統合サービス。
///
/// Production環境ではこのサービスでバナー・インタースティシャル・リワード広告を制御する。
/// AdGateService と連携して、広告表示ガードポリシーを強制。
///
/// Ad Unit ID: 実装環境に応じて適切な ID を設定（テスト ID は初期化時に設定）
class GoogleMobileAdsService {
  static final GoogleMobileAdsService _instance =
      GoogleMobileAdsService._internal();

  factory GoogleMobileAdsService() {
    return _instance;
  }

  GoogleMobileAdsService._internal();

  // 本番 Ad Unit ID（Android）。「原付・バイク免許コレ！」用に AdMob で発行済み
  // （2026-09-28、App ID: ca-app-pub-5058227312086483~9215678835）。
  // 広告ユニットIDはアプリ識別用の公開情報のためデフォルト値として埋め込み、
  // --dart-define=ADMOB_BANNER_AD_UNIT_ID_ANDROID=... 等で上書きも可能にしておく。
  // iOS用IDは未発行（iOSアプリをAdMobに追加後に設定すること）。
  static const String _bannerAdUnitIdAndroid = String.fromEnvironment(
    'ADMOB_BANNER_AD_UNIT_ID_ANDROID',
    defaultValue: 'ca-app-pub-5058227312086483/6564630614',
  );
  static const String _bannerAdUnitIdIos =
      String.fromEnvironment('ADMOB_BANNER_AD_UNIT_ID_IOS');
  static const String _interstitialAdUnitIdAndroid = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_AD_UNIT_ID_ANDROID',
    defaultValue: 'ca-app-pub-5058227312086483/8853725911',
  );
  static const String _interstitialAdUnitIdIos =
      String.fromEnvironment('ADMOB_INTERSTITIAL_AD_UNIT_ID_IOS');
  static const String _rewardedAdUnitIdAndroid = String.fromEnvironment(
    'ADMOB_REWARDED_AD_UNIT_ID_ANDROID',
    defaultValue: 'ca-app-pub-5058227312086483/3963352158',
  );
  static const String _rewardedAdUnitIdIos =
      String.fromEnvironment('ADMOB_REWARDED_AD_UNIT_ID_IOS');

  static final String _testBannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static final String _testInterstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  static final String _testRewardedAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  static String get _bannerAdUnitId {
    final id = Platform.isAndroid ? _bannerAdUnitIdAndroid : _bannerAdUnitIdIos;
    return id.isNotEmpty ? id : _testBannerAdUnitId;
  }

  static String get _interstitialAdUnitId {
    final id = Platform.isAndroid
        ? _interstitialAdUnitIdAndroid
        : _interstitialAdUnitIdIos;
    return id.isNotEmpty ? id : _testInterstitialAdUnitId;
  }

  static String get _rewardedAdUnitId {
    final id =
        Platform.isAndroid ? _rewardedAdUnitIdAndroid : _rewardedAdUnitIdIos;
    return id.isNotEmpty ? id : _testRewardedAdUnitId;
  }

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool get isBannerAdLoaded => _bannerAd != null;
  bool get isInterstitialAdLoaded => _interstitialAd != null;
  bool get isRewardedAdLoaded => _rewardedAd != null;

  /// Google Mobile Ads SDK の初期化
  /// main.dart で最初に呼び出す
  Future<void> initialize({
    String? bannerAdUnitId,
    String? interstitialAdUnitId,
    String? rewardedAdUnitId,
  }) async {
    // 初期化（テスト Ad Unit ID が自動的に使用される）
    await MobileAds.instance.initialize();

    // アプリレベルのログを設定（オプション）
    MobileAds.instance.setAppVolume(1.0);
    MobileAds.instance.setAppMuted(false);
  }

  /// バナー広告を読み込む
  /// AdGateService でチェック済みの場合のみ呼び出す
  Future<void> loadBannerAd({
    String? customAdUnitId,
    required void Function(BannerAd) onAdLoaded,
  }) async {
    try {
      final bannerAd = BannerAd(
        adUnitId: customAdUnitId ?? _bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _bannerAd = ad as BannerAd;
            onAdLoaded(ad);
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            if (kDebugMode) {
              debugPrint('Banner Ad failed to load: $error');
            }
          },
        ),
      );

      await bannerAd.load();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading banner ad: $e');
      }
    }
  }

  /// インタースティシャル広告を読み込む
  /// AdGateService で確認後、"ノルマ完走時"のみ表示する
  Future<void> loadInterstitialAd({
    String? customAdUnitId,
    required void Function() onAdLoaded,
    required void Function(AdError) onAdFailedToLoad,
  }) async {
    try {
      await InterstitialAd.load(
        adUnitId: customAdUnitId ?? _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            onAdLoaded();
          },
          onAdFailedToLoad: (error) {
            onAdFailedToLoad(error);
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading interstitial ad: $e');
      }
    }
  }

  /// インタースティシャル広告を表示
  /// AdGateService.canShowInterstitial == true の場合のみ呼び出す
  Future<void> showInterstitialAd({
    required void Function() onAdDismissed,
  }) async {
    if (_interstitialAd == null) {
      if (kDebugMode) {
        debugPrint('Interstitial ad not loaded');
      }
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        if (kDebugMode) {
          debugPrint('Interstitial ad failed to show: $error');
        }
      },
    );

    _interstitialAd!.show();
  }

  /// リワード広告を読み込む
  /// ユーザーが "広告を見て報酬獲得" ボタンを押した時のみ読み込む
  Future<void> loadRewardedAd({
    String? customAdUnitId,
    required void Function() onAdLoaded,
    required void Function(AdError) onAdFailedToLoad,
  }) async {
    try {
      await RewardedAd.load(
        adUnitId: customAdUnitId ?? _rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            onAdLoaded();
          },
          onAdFailedToLoad: (error) {
            onAdFailedToLoad(error);
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading rewarded ad: $e');
      }
    }
  }

  /// リワード広告を表示
  /// AdGateService.canShowRewardedAd == true の場合のみ呼び出す
  /// ユーザーが報酬を見るまで視聴した場合、onUserEarnedReward が呼ばれる
  Future<void> showRewardedAd({
    required void Function(AdWithoutView, RewardItem) onUserEarnedReward,
    required void Function() onAdDismissed,
  }) async {
    if (_rewardedAd == null) {
      if (kDebugMode) {
        debugPrint('Rewarded ad not loaded');
      }
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        if (kDebugMode) {
          debugPrint('Rewarded ad failed to show: $error');
        }
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onUserEarnedReward(ad, reward);
      },
    );
  }

  /// 全広告のクリーンアップ（アプリ終了時）
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
