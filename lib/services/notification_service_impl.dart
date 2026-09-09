import 'package:flutter/foundation.dart';

import '../models/notification_models.dart';

/// 通知サービスのインターフェース
abstract class NotificationService {
  Future<void> initialize();
  Future<void> sendNotification(Notification notification);
  Future<void> sendNotificationToUser(String userId, Notification notification);
  Future<List<Notification>> getNotificationsForUser(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> deleteNotification(String notificationId);
  Future<bool> isNotificationEnabled();
  Future<bool> requestNotificationPermission();
  Future<void> sendTestNotification();
}

/// ローカル（メモリ内）の通知サービス実装
class LocalNotificationService implements NotificationService {
  final Map<String, List<Notification>> _userNotifications = {};

  @override
  Future<void> initialize() async {
    if (kDebugMode) {
      debugPrint('LocalNotificationService initialized');
    }
  }

  @override
  Future<void> sendNotification(Notification notification) async {
    if (kDebugMode) {
      debugPrint('Notification sent: ${notification.notificationId}');
    }
  }

  @override
  Future<void> sendNotificationToUser(
    String userId,
    Notification notification,
  ) async {
    if (!_userNotifications.containsKey(userId)) {
      _userNotifications[userId] = [];
    }
    _userNotifications[userId]!.add(notification);

    if (kDebugMode) {
      debugPrint('Notification sent to user $userId: ${notification.notificationId}');
    }
  }

  @override
  Future<List<Notification>> getNotificationsForUser(String userId) async {
    return _userNotifications[userId] ?? [];
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    if (kDebugMode) {
      debugPrint('Notification marked as read: $notificationId');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    if (kDebugMode) {
      debugPrint('Notification deleted: $notificationId');
    }
  }

  @override
  Future<bool> isNotificationEnabled() async {
    // Local service always returns true (no permission checks in memory)
    return true;
  }

  @override
  Future<bool> requestNotificationPermission() async {
    if (kDebugMode) {
      debugPrint('Notification permission requested');
    }
    return true;
  }

  @override
  Future<void> sendTestNotification() async {
    if (kDebugMode) {
      debugPrint('Test notification sent');
    }
  }
}
