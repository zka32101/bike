import 'package:bike_license_kore/services/exam_plan_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// 日次目標の計算式はコアの `dailyGoal` に移した。移行前の `ExamPlanService` の仕様
/// （未習得×1.3÷残り日数の切り上げ、当日は1日、過去は null、未習得0は0）が
/// 変わっていないことを固定する。
void main() {
  const service = ExamPlanService();
  final now = DateTime(2026, 10, 25, 15, 30);

  test('未習得×1.3÷残り日数を切り上げる', () {
    final plan = service.calculatePlan(
      examDate: DateTime(2026, 11, 4), // 10日後
      unmasteredCount: 100,
      now: now,
    );
    expect(plan, isNotNull);
    expect(plan!.daysLeft, 10);
    expect(plan.unmasteredCount, 100);
    expect(plan.dailyGoal, 13); // 100 * 1.3 / 10
  });

  test('割り切れないときは切り上げ', () {
    final plan = service.calculatePlan(
      examDate: DateTime(2026, 10, 28), // 3日後
      unmasteredCount: 10,
      now: now,
    );
    expect(plan!.dailyGoal, 5); // 13 / 3 = 4.33 -> 5
  });

  test('試験当日は残り0日だが1日として数える', () {
    final plan = service.calculatePlan(
      examDate: DateTime(2026, 10, 25, 9, 0),
      unmasteredCount: 20,
      now: now,
    );
    expect(plan!.daysLeft, 0);
    expect(plan.dailyGoal, 26);
  });

  test('試験日が過去なら null', () {
    expect(
      service.calculatePlan(
        examDate: DateTime(2026, 10, 24),
        unmasteredCount: 20,
        now: now,
      ),
      isNull,
    );
  });

  test('未習得0ならノルマ0', () {
    final plan = service.calculatePlan(
      examDate: DateTime(2026, 11, 4),
      unmasteredCount: 0,
      now: now,
    );
    expect(plan!.dailyGoal, 0);
  });
}
