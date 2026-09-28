import 'dart:io';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/firebase_analytics_service.dart';
import 'services/firestore_data_service.dart';
import 'services/firestore_sync_service.dart';
import 'services/google_mobile_ads_service.dart';
import 'services/hybrid_data_service.dart';
import 'services/local_data_service.dart';
import 'services/revenuecat_purchase_service.dart';
import 'viewmodels/providers.dart';

// RevenueCat API キー（iOS/Android）。--dart-define で渡す（未指定なら
// 空文字列のまま＝StubPurchaseServiceにフォールバックし、課金は一切発生しない）。
// 設定方法: https://docs.revenuecat.com/docs/getting-started
// 例: flutter build apk --release \
//       --dart-define=REVENUECAT_API_KEY_ANDROID=goog_xxxxxxxx
// build-flutter-apk スキルの build.ps1 はこのフラグを渡さないため、
// RevenueCatダッシュボードでAPIキーを取得できたら上記コマンドで手動ビルドすること。
const String _revenueCatApiKeyiOS =
    String.fromEnvironment('REVENUECAT_API_KEY_IOS');
const String _revenueCatApiKeyAndroid =
    String.fromEnvironment('REVENUECAT_API_KEY_ANDROID');

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

  // RevenueCat 初期化。APIキーが渡されている場合のみ有効化する
  // （未設定時はStubPurchaseServiceのままで課金は一切発生しない＝安全側）。
  final revenueCatApiKey =
      Platform.isIOS ? _revenueCatApiKeyiOS : _revenueCatApiKeyAndroid;
  final revenueCatEnabled = revenueCatApiKey.isNotEmpty;
  if (revenueCatEnabled) {
    await Purchases.configure(PurchasesConfiguration(revenueCatApiKey));
  }

  // ProviderScope を先にコンテナとして作り、runApp前に復習リマインダー通知の
  // 初期化（プラグイン初期化・通知タップ時のコールバック登録）を行う。
  final container = ProviderContainer(
    overrides: [
      // ハイブリッドデータサービス：Firestore 優先、ローカルにフォールバック
      dataServiceProvider.overrideWithValue(
        HybridDataService(
          localDataService: LocalDataService(),
          firestoreSyncService: LocalFirestoreSyncService(),
        ),
      ),

      // Firebase Analytics を計測サービスとして使用
      analyticsServiceProvider.overrideWithValue(FirebaseAnalyticsService()),

      // RevenueCat APIキーが設定されている場合のみ、実際の購入サービスに切り替える。
      if (revenueCatEnabled)
        purchaseServiceProvider.overrideWithValue(RevenueCatPurchaseService()),

      localFallbackUidProvider.overrideWithValue(localFallbackUid),
    ],
  );

  final navigatorKey = container.read(navigatorKeyProvider);
  try {
    await container.read(reviewReminderServiceProvider).initialize(
          onNotificationTapped: (questionId) =>
              openReviewQuestionFromNotification(navigatorKey, questionId),
        );
    await container.read(reviewReminderServiceProvider).requestPermission();
  } catch (e) {
    debugPrint('Failed to initialize review reminder notifications: $e');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const BikeLicenseKoreApp(),
    ),
  );
}
