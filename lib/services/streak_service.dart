/// 連続学習日数（ストリーク）の計算ロジック。
///
/// 「学習した」の定義は DailyQuotaController.answer() が呼ばれた（1問でも
/// 回答した）こと。日付の比較は端末のローカル日付（時刻は無視）で行う。
class StreakService {
  const StreakService();

  /// 直近の学習日 [lastStudyDate] と現在時刻 [now] から、更新後の
  /// ストリーク日数を計算する。
  ///
  /// - 今日すでに学習済み（[lastStudyDate] が今日）: [currentStreak] を維持
  /// - 前回が昨日: [currentStreak] + 1
  /// - それ以外（2日以上空いた、または初回）: 1 から再スタート
  int calculateNextStreak({
    required int currentStreak,
    required DateTime? lastStudyDate,
    required DateTime now,
  }) {
    final today = _dateOnly(now);

    if (lastStudyDate == null) return 1;

    final lastDate = _dateOnly(lastStudyDate);
    final dayDiff = today.difference(lastDate).inDays;

    if (dayDiff == 0) return currentStreak == 0 ? 1 : currentStreak;
    if (dayDiff == 1) return currentStreak + 1;
    return 1;
  }

  /// 今日すでに学習記録があるか（同日中の2回目以降の回答で無駄な書き込みを
  /// 避けるために使う）。
  bool isAlreadyStudiedToday({
    required DateTime? lastStudyDate,
    required DateTime now,
  }) {
    if (lastStudyDate == null) return false;
    return _dateOnly(lastStudyDate) == _dateOnly(now);
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
