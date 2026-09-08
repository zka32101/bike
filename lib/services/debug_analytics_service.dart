import 'package:flutter/foundation.dart';

import 'analytics_service.dart';

/// デバッグ用のAnalyticsService実装
/// コンソール出力のみで、実際のFirebaseへの送信は行わない
class DebugAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?>? parameters,
  }) async {
    if (kDebugMode) {
      debugPrint('[Analytics] Event: $name, Params: $parameters');
    }
  }

  @override
  Future<void> setUserId(String userId) async {
    if (kDebugMode) {
      debugPrint('[Analytics] SetUserId: $userId');
    }
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    if (kDebugMode) {
      debugPrint('[Analytics] SetUserProperty: $name = $value');
    }
  }

  @override
  Future<void> logScreenView(String screenName) async {
    if (kDebugMode) {
      debugPrint('[Analytics] ScreenView: $screenName');
    }
  }
}
