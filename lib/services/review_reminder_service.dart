import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// 間違えた問題を数日後に再出題するための「スペースドリピティション通知」。
///
/// 忘却曲線を簡易的に模して、間違えた問題ごとに 1日後・3日後・7日後の
/// 3回、端末のローカル通知でリマインドする。
class ReviewReminderService {
  ReviewReminderService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'review_reminder';
  static const _channelName = '復習リマインダー';
  static const _channelDescription = '間違えた問題の復習タイミングをお知らせします';

  /// 忘却曲線を模した復習間隔（間違えた日からの経過日数）。
  static const List<int> reviewIntervalsDays = [1, 3, 7];

  bool _initialized = false;

  /// アプリ起動時に一度だけ呼ぶ。タイムゾーンDBとプラグインの初期化を行う。
  Future<void> initialize({
    void Function(String questionId)? onNotificationTapped,
  }) async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));
    } catch (e) {
      // タイムゾーンDBに見つからない場合はUTCのままにする（通知自体は動く）。
      debugPrint('ReviewReminderService: failed to set local location: $e');
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final questionId = response.payload;
        if (questionId != null && onNotificationTapped != null) {
          onNotificationTapped(questionId);
        }
      },
    );

    _initialized = true;
  }

  /// Android 13+ の通知権限をリクエストする。initialize() の後に呼ぶこと。
  Future<bool> requestPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return true;

    final granted = await androidPlugin.requestNotificationsPermission();
    await androidPlugin.requestExactAlarmsPermission();
    return granted ?? false;
  }

  /// 間違えた問題1問について、忘却曲線間隔（1日後・3日後・7日後）で
  /// 3回分の復習通知をスケジュールする。
  ///
  /// 同じ問題に対して再度呼ばれた場合は、前回分をキャンセルしてから
  /// 再スケジュールする（通知が重複しないように）。
  Future<void> scheduleReviewForQuestion({
    required String questionId,
    required String questionText,
    required DateTime answeredAt,
  }) async {
    if (!_initialized) return;

    for (final dayOffset in reviewIntervalsDays) {
      final notificationId = _notificationIdFor(questionId, dayOffset);
      await _plugin.cancel(notificationId);

      final scheduledDate = answeredAt.add(Duration(days: dayOffset));
      // 過去の日時は即時発火してしまうため、通知登録自体をスキップする。
      if (scheduledDate.isBefore(DateTime.now())) continue;

      final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

      await _plugin.zonedSchedule(
        notificationId,
        '復習の時間です',
        _truncate(questionText),
        tzDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: questionId,
      );
    }
  }

  /// 問題がマスター済みになった等で復習が不要になった場合に、
  /// スケジュール済みの通知をキャンセルする。
  Future<void> cancelReviewsForQuestion(String questionId) async {
    for (final dayOffset in reviewIntervalsDays) {
      await _plugin.cancel(_notificationIdFor(questionId, dayOffset));
    }
  }

  /// 通知IDはint型である必要があるため、questionId と間隔からハッシュ生成する。
  int _notificationIdFor(String questionId, int dayOffset) {
    return Object.hash(questionId, dayOffset) & 0x7fffffff;
  }

  String _truncate(String text, {int maxLength = 60}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}…';
  }
}
