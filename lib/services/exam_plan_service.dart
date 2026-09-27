/// 試験日から逆算した「1日あたりの学習ノルマ」を計算するサービス。
class ExamPlanService {
  const ExamPlanService();

  /// 試験日までの残り日数と未習得問題数から、1日あたりに解くべき問題数を
  /// 計算する。
  ///
  /// - [examDate] が過去（試験当日を含め残り日数が0以下）の場合は null
  ///   （プラン計算対象外、呼び出し側で「試験日を過ぎています」等を表示）
  /// - [unmasteredCount] が0の場合は0（もうやることがない）
  ExamPlan? calculatePlan({
    required DateTime examDate,
    required int unmasteredCount,
    required DateTime now,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final examDay = DateTime(examDate.year, examDate.month, examDate.day);
    final daysLeft = examDay.difference(today).inDays;

    if (daysLeft < 0) return null;

    // 試験当日も学習できる1日として数える（0除算回避）。
    final effectiveDays = daysLeft == 0 ? 1 : daysLeft;
    final dailyGoal = unmasteredCount == 0
        ? 0
        : (unmasteredCount / effectiveDays).ceil();

    return ExamPlan(
      daysLeft: daysLeft,
      unmasteredCount: unmasteredCount,
      dailyGoal: dailyGoal,
    );
  }
}

class ExamPlan {
  const ExamPlan({
    required this.daysLeft,
    required this.unmasteredCount,
    required this.dailyGoal,
  });

  /// 試験日までの残り日数（当日は0）。
  final int daysLeft;

  /// 未習得（マスター未達成）の問題数。
  final int unmasteredCount;

  /// 1日あたりに解くべき目安の問題数。
  final int dailyGoal;
}
