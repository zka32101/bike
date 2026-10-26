import 'package:ukalab_core/ukalab_core.dart' show dailyGoal, daysUntilExam;

/// 試験日から逆算した「1日あたりの学習ノルマ」を計算するサービス。
///
/// 計算式はコア（ukalab_core v0.84.0〜）の `dailyGoal` を使う（共通化は core 優先、CD-008）。
/// 式: 未習得問題数 × 1.3（解き直しの安全マージン）÷ 残り日数（当日は1日）を切り上げ。
class ExamPlanService {
  const ExamPlanService();

  /// 試験日までの残り日数と未習得問題数から、1日あたりに解くべき問題数を
  /// 計算する。
  ///
  /// - [examDate] が過去（残り日数が負）の場合は null
  ///   （プラン計算対象外、呼び出し側で「試験日を過ぎています」等を表示）
  /// - [unmasteredCount] が0の場合は0（もうやることがない）
  ExamPlan? calculatePlan({
    required DateTime examDate,
    required int unmasteredCount,
    required DateTime now,
  }) {
    final goal = dailyGoal(
      examDate: examDate,
      unmasteredCount: unmasteredCount,
      now: now,
    );
    if (goal == null) return null;

    return ExamPlan(
      daysLeft: daysUntilExam(examDate, now),
      unmasteredCount: unmasteredCount,
      dailyGoal: goal,
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
