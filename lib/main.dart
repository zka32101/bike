import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/firebase_analytics_service.dart';
import 'services/firestore_data_service.dart';
import 'services/firestore_sync_service.dart';
import 'services/google_mobile_ads_service.dart';
import 'services/hybrid_data_service.dart';
import 'services/local_data_service.dart';
import 'viewmodels/providers.dart';

// RevenueCat API キー（iOS/Android）
// 設定方法: https://docs.revenuecat.com/docs/getting-started
// これらのキーは環境変数または FlutterFire Console から取得
// const String _revenueCatApiKeyiOS = 'TODO_IOS_API_KEY';
// const String _revenueCatApiKeyAndroid = 'TODO_ANDROID_API_KEY';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 初期化（google-services.json / GoogleService-Info.plist が必須）
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Google Mobile Ads SDK 初期化（テスト広告IDはAdMob側の実IDに差し替え予定）
  await GoogleMobileAdsService().initialize();

  // Firebase Auth が使えない場合（Firebase Console未設定等）のフォールバックUID。
  // 端末に永続化し、オフライン継続時も同一端末では常に同じIDを使う。
  final prefs = await SharedPreferences.getInstance();
  var localFallbackUid = prefs.getString('local_fallback_uid');
  if (localFallbackUid == null) {
    localFallbackUid =
        'local_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000000)}';
    await prefs.setString('local_fallback_uid', localFallbackUid);
  }

  // RevenueCat 初期化（API キーは RevenueCat Dashboard から取得）
  // TODO(revenuecat-setup): API キーを設定して Purchases.configure() を有効化
  // await Purchases.configure(
  //   PurchasesConfiguration(
  //     apiKey: Platform.isIOS ? _revenueCatApiKeyiOS : _revenueCatApiKeyAndroid,
  //   ),
  // );

  runApp(
    ProviderScope(
      overrides: [
        // ハイブリッドデータサービス：Firestore 優先、ローカルにフォールバック
        dataServiceProvider.overrideWithValue(
          HybridDataService(
            localDataService: LocalDataService(),
            firestoreSyncService: LocalFirestoreSyncService(),
          ),
        ),

        // Firebase Analytics を計測サービスとして使用
        analyticsServiceProvider
            .overrideWithValue(FirebaseAnalyticsService()),

        // RevenueCat を購入サービスとして使用
        // TODO(revenuecat-setup): Purchases.configure() 有効化後にコメント解除
        // purchaseServiceProvider.overrideWithValue(RevenueCatPurchaseService()),

        localFallbackUidProvider.overrideWithValue(localFallbackUid),
      ],
      child: const BikeLicenseKoreApp(),
    ),
  );
}
