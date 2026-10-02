import 'package:app_common_kit/app_common_kit.dart';
import 'package:bike_license_kore/widgets/oshi_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
