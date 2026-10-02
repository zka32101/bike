import 'package:app_common_kit/app_common_kit.dart';
import 'package:bike_license_kore/widgets/oshi_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  situationTests();
  test('未回答は Lv1', () {
    expect(oshiStageFor(distinctAnswered: 0, totalQuestions: 100, correct: 0, answered: 0),
        MascotStage.lv1);
  });
  test('網羅率と正答率が上がると成長する', () {
    final low = oshiStageFor(distinctAnswered: 10, totalQuestions: 100, correct: 8, answered: 10);
    final high = oshiStageFor(distinctAnswered: 95, totalQuestions: 100, correct: 90, answered: 100);
    expect(high.index, greaterThan(low.index));
    expect(high, MascotStage.lv5);
  });
  test('全問題数0でも落ちない', () {
    expect(oshiStageFor(distinctAnswered: 3, totalQuestions: 0, correct: 3, answered: 3),
        MascotStage.lv1);
  });
}

void situationTests() {
  final now = DateTime(2026, 10, 3);
  test('試験当日・前日・直前が最優先', () {
    for (final (days, s) in [
      (0, MascotSituation.examToday),
      (1, MascotSituation.examEve),
      (5, MascotSituation.examClose),
      (20, MascotSituation.examApproaching),
    ]) {
      final d = oshiDayState(
          now: now, streakDays: 0, lastStudyDate: now, examDate: now.add(Duration(days: days)));
      expect(oshiSituation(d, now), s);
    }
  });
  test('3日以上空いたら おかえり（責めない）', () {
    final d = oshiDayState(
        now: now, streakDays: 0, lastStudyDate: DateTime(2026, 9, 28), examDate: null);
    expect(oshiSituation(d, now), MascotSituation.welcomeBack);
    expect(d.expression, MascotExpression.normal);
  });
  test('今日学習したら喜ぶ／連続3日はstreak', () {
    final a = oshiDayState(now: now, streakDays: 1, lastStudyDate: now, examDate: null);
    expect(oshiSituation(a, now), MascotSituation.studied);
    expect(a.expression, MascotExpression.joy);
    final b = oshiDayState(now: now, streakDays: 5, lastStudyDate: now, examDate: null);
    expect(oshiSituation(b, now), MascotSituation.streak);
  });
  test('学習履歴なしは あいさつ', () {
    final d = oshiDayState(now: now, streakDays: 0, lastStudyDate: null, examDate: null);
    expect(oshiSituation(d, now), MascotSituation.greeting);
  });
}
