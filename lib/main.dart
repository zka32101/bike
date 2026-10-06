import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:app_common_kit/app_common_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'widgets/startup_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/firebase_analytics_service.dart';
import 'services/firestore_data_service.dart';
import 'services/firestore_sync_service.dart';
import 'services/ad_units.dart';
import 'services/prefs_key_value_store.dart';
import 'services/hybrid_data_service.dart';
import 'services/local_data_service.dart';
import 'viewmodels/providers.dart';

// RevenueCat API キー（iOS/Android）。
// Android: RevenueCat「Your WIsh」プロジェクト > Bikeアプリ（com.yourwish.bikelicense）の
// Public API Key（2026-09-28 発行）。公開APIキーはクライアントアプリへの埋め込みを
// 前提とした非秘匿情報のため、ソースに直接デフォルト値として持たせる
// （--dart-define=REVENUECAT_API_KEY_ANDROID=... で上書きも可能）。
// iOS用キーは未発行（iOSアプリをRevenueCatに追加後に設定すること）。
const String _revenueCatApiKeyiOS =
    String.fromEnvironment('REVENUECAT_API_KEY_IOS');
const String _revenueCatApiKeyAndroid = String.fromEnvironment(
  'REVENUECAT_API_KEY_ANDROID',
  defaultValue: 'goog_LjzTdMuZdNmzxihVbMgpNlTQWaQ',
);

/// Firebase を、まだ初期化されていなければ初期化する（二重初期化で落ちない）。
Future<void> ensureFirebaseInitialized() async {
  if (Firebase.apps.isNotEmpty) return;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初期化（Firebase・課金・広告・保存データの読み込み）には時間がかかる。その間、
  // 下部に組織ロゴを出した起動画面を先に出す。初期化が終わったら本来の画面に差し替える。
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: StartupSplash()));

  // 初期化（Firebase・課金・広告・保存データの読み込み）には時間がかかる。その間、
  // 下部に組織ロゴを出した起動画面を先に出す。初期化が終わったら本来の画面に差し替える。
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: StartupSplash()));

  // Firebase 初期化（google-services.json / GoogleService-Info.plist が必須）
  // Android は google-services プラグインがアプリ起動時に [DEFAULT] を先に初期化する。
  // そこへ再度 initializeApp すると duplicate-app で例外になり、main が止まって
  // 画面が出なくなる（リリース版でスプラッシュのまま進まなかった）。
  await ensureFirebaseInitialized();

  // Firebase Auth が使えない場合（Firebase Console未設定等）のフォールバックUID。
  // 端末に永続化し、オフライン継続時も同一端末では常に同じIDを使う。
  final prefs = await SharedPreferences.getInstance();
  var localFallbackUid = prefs.getString('local_fallback_uid');
  if (localFallbackUid == null) {
    localFallbackUid =
        'local_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000000)}';
    await prefs.setString('local_fallback_uid', localFallbackUid);
  }

  // 権利管理（app_common_kit）。RevenueCat の公開SDKキーがあるときだけ実際の
  // 購入に接続し、無い場合（iOSキー未発行など）は無料状態のフェイクで安全側に倒す。
  // 権利名は noads / premium（RevenueCat 側で作成し、Offering に商品を入れる）。
  final revenueCatApiKey =
      Platform.isIOS ? _revenueCatApiKeyiOS : _revenueCatApiKeyAndroid;
  final EntitlementService entitlement = revenueCatApiKey.isNotEmpty
      ? await RevenueCatEntitlementService.init(publicSdkKey: revenueCatApiKey)
      : FakeEntitlementService();

  // 広告ゲート（app_common_kit）。同意(UMP)・頻度制御・有料時の非初期化を担う。
  // 広告なし(noads)・プレミアムの間は広告SDKを初期化しない。ユニットIDが
  // 使えない場合（iOSの本番ID未発行など）は null で、広告なしで動作する。
  final adUnits = BikeAdUnits.resolve();
  final AdGate? adGate = adUnits == null
      ? null
      : await AdGate.init(
          config: AdConfig(unitIds: adUnits),
          adsHidden: () => entitlement.state.adsHidden,
        );

  // 学習コイン（app_common_kit）。財布はアプリごと。端末内に保存する。
  final coinService = CoinService(
    store: SharedPreferencesCoinStore('bike'),
    shop: OutfitCatalog.shopItems([UkalabCert.bikeLicense]),
  );
  await coinService.load();
  final outfitService =
      OutfitService(store: SharedPreferencesOutfitStore('bike'));
  await outfitService.load();

  // ProviderScope を先にコンテナとして作り、runApp前に復習リマインダー通知の
  // 初期化（プラグイン初期化・通知タップ時のコールバック登録）を行う。
  final container = ProviderContainer(
    overrides: [
      // 「オフラインで続ける」を選択済みなら復元する
      offlineModeAcceptedProvider.overrideWith(
          (ref) => prefs.getBool(offlineModeAcceptedPrefsKey) ?? false),

      // ハイブリッドデータサービス：Firestore 優先、ローカルにフォールバック
      dataServiceProvider.overrideWithValue(
        HybridDataService(
          localDataService: LocalDataService(),
          firestoreSyncService: LocalFirestoreSyncService(),
        ),
      ),

      // Firebase Analytics を計測サービスとして使用
      analyticsServiceProvider.overrideWithValue(FirebaseAnalyticsService()),

      coinServiceProvider.overrideWithValue(coinService),
      outfitServiceProvider.overrideWithValue(outfitService),
      entitlementServiceProvider.overrideWithValue(entitlement),
      adGateProvider.overrideWithValue(adGate),
      keyValueStoreProvider.overrideWithValue(PrefsKeyValueStore(prefs)),

      localFallbackUidProvider.overrideWithValue(localFallbackUid),
    ],
  );

  // 共通フィードバック(app_common_kit)の送信処理を注入。
  // ルールは自分のUIDのみ作成可のため、送信時点のログインUIDで上書きする。
  // 未ログイン時は例外にして、キュー(端末内)に残す。
  container.read(feedbackProvider.notifier).setSubmitHandler((report) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError('not signed in');
    final sent = report.copyWith(userId: uid);
    await FirebaseFirestore.instance
        .collection('feedback')
        .doc(sent.id)
        .set(sent.toJson());
  });
  unawaited(container.read(feedbackProvider.notifier).retryPendingReports());

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
