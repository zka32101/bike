import 'package:flutter_test/flutter_test.dart';

import 'package:bike_license_kore/models/analytics_snapshot.dart';
import 'package:bike_license_kore/models/question.dart';
import 'package:bike_license_kore/models/user_answer_log.dart';
import 'package:bike_license_kore/services/question_index.dart';
import 'package:bike_license_kore/services/study_analytics_service.dart';

QuestionMeta _meta(String id, {required String topicTag}) => QuestionMeta(
  id: id,
  licenseCategory: const ['gentsuki'],
  stageTag: '第一段階',
  difficulty: 1,
  isTrapQuestion: false,
  trapNumberType: TrapNumberType.none,
  topicTag: topicTag,
);

UserAnswerLog _log(String uid, String questionId, bool isCorrect, DateTime at) =>
    UserAnswerLog(
      uid: uid,
      questionId: questionId,
      isCorrect: isCorrect,
      answeredAt: at,
    );

void main() {
  group('DefaultStudyAnalyticsService topic aggregation', () {
    late DefaultStudyAnalyticsService service;

    setUp(() {
      service = DefaultStudyAnalyticsService();
    });

    test('集計結果の topics にトピック別正答率が反映される', () {
      final index = QuestionIndex({
        'q1': _meta('q1', topicTag: 'rules'),
        'q2': _meta('q2', topicTag: 'rules'),
        'q3': _meta('q3', topicTag: 'operation'),
      });

      final now = DateTime(2026, 9, 24);
      final logs = [
        _log('u1', 'q1', true, now),
        _log('u1', 'q1', false, now),
        _log('u1', 'q2', true, now),
        _log('u1', 'q3', true, now),
      ];

      final snapshot = service.aggregate(
        uid: 'u1',
        logs: logs,
        index: index,
        now: now,
      );

      final rules = snapshot.topics.firstWhere((t) => t.categoryId == 'rules');
      expect(rules.stat.attempts, 3);
      expect(rules.stat.correctCount, 2);

      final operation =
          snapshot.topics.firstWhere((t) => t.categoryId == 'operation');
      expect(operation.stat.attempts, 1);
      expect(operation.stat.correctCount, 1);
    });

    test('topicTag が null の問題は topics 集計から除外される', () {
      final index = QuestionIndex({
        'q1': _meta('q1', topicTag: 'rules'),
        'q2': QuestionMeta(
          id: 'q2',
          licenseCategory: const ['gentsuki'],
          stageTag: '第一段階',
          difficulty: 1,
          isTrapQuestion: false,
          trapNumberType: TrapNumberType.none,
          // topicTag omitted -> null
        ),
      });

      final now = DateTime(2026, 9, 24);
      final logs = [
        _log('u1', 'q1', true, now),
        _log('u1', 'q2', true, now),
      ];

      final snapshot = service.aggregate(
        uid: 'u1',
        logs: logs,
        index: index,
        now: now,
      );

      expect(snapshot.topics.length, 1);
      expect(snapshot.topics.single.categoryId, 'rules');
    });

    test('正答率が閾値を下回るトピックは WeakAreaKind.topic として検出される', () {
      final index = <String, QuestionMeta>{};
      for (var i = 0; i < 10; i++) {
        index['q$i'] = _meta('q$i', topicTag: 'hazard_prediction');
      }

      final now = DateTime(2026, 9, 24);
      // 10問中2問だけ正解 = 20%の正答率（弱点閾値80%を大幅に下回る）
      final logs = List.generate(
        10,
        (i) => _log('u1', 'q$i', i < 2, now),
      );

      final snapshot = service.aggregate(
        uid: 'u1',
        logs: logs,
        index: QuestionIndex(index),
        now: now,
      );

      final topicWeakArea = snapshot.weakAreas.firstWhere(
        (w) => w.kind == WeakAreaKind.topic,
        orElse: () => throw StateError('topic weak area not found'),
      );
      expect(topicWeakArea.key, 'topic:hazard_prediction');
      expect(topicWeakArea.label, '危険予測・安全確認');
      expect(topicWeakArea.stat.attempts, 10);
      expect(topicWeakArea.stat.correctCount, 2);
    });

    test('AnalyticsSnapshot の topics は toJson/fromJson を往復できる', () {
      final index = QuestionIndex({
        'q1': _meta('q1', topicTag: 'signs'),
      });
      final now = DateTime(2026, 9, 24);
      final snapshot = service.aggregate(
        uid: 'u1',
        logs: [_log('u1', 'q1', true, now)],
        index: index,
        now: now,
      );

      final roundTripped = AnalyticsSnapshot.fromJson(snapshot.toJson());
      expect(roundTripped.topics.length, 1);
      expect(roundTripped.topics.single.categoryId, 'signs');
      expect(roundTripped.topics.single.stat.attempts, 1);
    });
  });
}
