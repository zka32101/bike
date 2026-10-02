import 'package:app_common_kit/app_common_kit.dart';
import 'package:bike_license_kore/models/analytics_snapshot.dart';
import 'package:bike_license_kore/models/question.dart';
import 'package:bike_license_kore/viewmodels/analytics_limits.dart';
import 'package:bike_license_kore/viewmodels/mock_exam_breakdown.dart';
import 'package:bike_license_kore/viewmodels/mock_exam_providers.dart';
import 'package:bike_license_kore/viewmodels/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart' show InMemoryKeyValueStore;

Question q(String id, String topic) => Question(
      id: id,
      licenseCategory: const ['gentsuki'],
      stageTag: '第一段階',
      difficulty: 1,
      questionText: '問題$id',
      choices: const ['a', 'b', 'c', 'd'],
      answer: 0,
      explanation: '解説',
      topicTag: topic,
    );

/// [correctIds] の問題だけ正解（選択肢0）、他は不正解（選択肢1）にした状態。
MockExamState examState(List<Question> qs, Set<String> correctIds) {
  return MockExamState(
    phase: MockExamPhase.finished,
    questions: qs,
    selectedAnswers: [for (final x in qs) correctIds.contains(x.id) ? 0 : 1],
  );
}

CategoryPerformance perf(String id, int attempts, int correct) =>
    CategoryPerformance(
      categoryId: id,
      stat: AccuracyStat(attempts: attempts, correctCount: correct),
    );

void main() {
  group('模擬試験の分野別得点と「あと◯問」', () {
    final qs = [
      for (var i = 0; i < 5; i++) q('s$i', 'signs'),
      for (var i = 0; i < 5; i++) q('r$i', 'rules'),
    ];

    test('分野ごとに集計し、得点率の低い順に並ぶ', () {
      final state = examState(qs, {'s0', 's1', 's2', 's3', 'r0', 'r1'});
      final scores = topicScoresOf(state);
      expect(scores.map((s) => s.topicTag), ['rules', 'signs']);
      expect(scores.first.correct, 2);
      expect(scores.first.total, 5);
      expect(scores.last.rate, closeTo(0.8, 1e-9));
    });

    test('合格ライン(90%)まであと何問か（10問中: 9問必要）', () {
      expect(shortByOf(examState(qs, {for (final x in qs.take(6)) x.id})), 3);
      expect(shortByOf(examState(qs, {for (final x in qs.take(9)) x.id})), 0);
      expect(shortByOf(examState(qs, {for (final x in qs) x.id})), 0);
    });

    test('問題が無いときは0問', () {
      expect(shortByOf(const MockExamState()), 0);
    });

    test('topicTag が無い問題は other にまとめる', () {
      final noTag = Question(
        id: 'n',
        licenseCategory: const ['gentsuki'],
        stageTag: '',
        difficulty: 1,
        questionText: 'p',
        choices: const ['a', 'b'],
        answer: 0,
        explanation: '',
      );
      expect(topicScoresOf(examState([noTag], {'n'})).single.topicTag, 'other');
    });
  });

  group('苦手分析の表示数（無料は苦手上位3分野）', () {
    final topics = [
      perf('signs', 10, 9), // 90%
      perf('rules', 10, 5), // 50%
      perf('hazard', 10, 7), // 70%
      perf('operation', 10, 3), // 30%
      perf('parking', 0, 0), // 未回答
    ];

    test('無料: 回答のある分野を苦手な順に3件', () {
      final shown = visibleTopics(topics, 3);
      expect(shown.map((t) => t.categoryId), ['operation', 'rules', 'hazard']);
    });

    test('プレミアム(limit=null): 全分野をそのまま', () {
      expect(visibleTopics(topics, null), same(topics));
    });

    test('回答のある分野が少なければ、あるだけ返す', () {
      expect(visibleTopics([perf('signs', 5, 5)], 3), hasLength(1));
      expect(visibleTopics(const [], 3), isEmpty);
    });
  });

  group('模擬試験の無料枠（月1回）', () {
    late InMemoryKeyValueStore store;

    ProviderContainer container({required bool premium}) {
      final c = ProviderContainer(
        overrides: [
          keyValueStoreProvider.overrideWithValue(store),
          entitlementServiceProvider.overrideWithValue(
            FakeEntitlementService(
              initial: premium
                  ? const EntitlementState(hasPremium: true)
                  : EntitlementState.free,
            ),
          ),
          questionsProvider.overrideWith(
            (ref, query) async => [for (var i = 0; i < 60; i++) q('x$i', 'signs')],
          ),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    setUp(() => store = InMemoryKeyValueStore());

    test('無料: 1回目は開始でき、開始で枠を消費し、2回目はロックされる', () async {
      final c = container(premium: false);
      final notifier = c.read(mockExamControllerProvider('gentsuki').notifier);

      await notifier.load();
      var state = c.read(mockExamControllerProvider('gentsuki'));
      expect(state.phase, MockExamPhase.ready);
      expect(state.quotaRemaining, 1);

      notifier.start();
      await Future<void>.delayed(Duration.zero);
      notifier.abandon();

      await notifier.load();
      state = c.read(mockExamControllerProvider('gentsuki'));
      expect(state.phase, MockExamPhase.locked);
      expect(state.quotaRemaining, 0);
    });

    test('無料: 読み込んだだけ(開始しない)では枠を消費しない', () async {
      final c = container(premium: false);
      final notifier = c.read(mockExamControllerProvider('gentsuki').notifier);
      await notifier.load();
      await notifier.load();
      expect(c.read(mockExamControllerProvider('gentsuki')).phase,
          MockExamPhase.ready);
    });

    test('プレミアム: 何度でも開始でき、残り回数は null（無制限）', () async {
      final c = container(premium: true);
      final notifier = c.read(mockExamControllerProvider('gentsuki').notifier);
      for (var i = 0; i < 3; i++) {
        await notifier.load();
        final state = c.read(mockExamControllerProvider('gentsuki'));
        expect(state.phase, MockExamPhase.ready);
        expect(state.quotaRemaining, isNull);
        notifier.start();
        notifier.abandon();
      }
    });

    test('noads のみの人は無料と同じ（機能制限は残る）', () async {
      final c = ProviderContainer(
        overrides: [
          keyValueStoreProvider.overrideWithValue(store),
          entitlementServiceProvider.overrideWithValue(
            FakeEntitlementService(
              initial: const EntitlementState(hasNoAds: true),
            ),
          ),
          questionsProvider.overrideWith(
            (ref, query) async => [for (var i = 0; i < 60; i++) q('y$i', 'signs')],
          ),
        ],
      );
      addTearDown(c.dispose);
      expect(c.read(hasPremiumProvider), isFalse);
      final notifier = c.read(mockExamControllerProvider('gentsuki').notifier);
      await notifier.load();
      expect(c.read(mockExamControllerProvider('gentsuki')).quotaRemaining, 1);
    });
  });
}
