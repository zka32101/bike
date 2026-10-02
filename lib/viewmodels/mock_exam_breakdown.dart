import 'dart:math';

import 'package:yourwish_kentei/yourwish_kentei.dart' show requiredScore;

import 'mock_exam_providers.dart';

/// 模擬試験の分野別得点（プレミアム機能）。
class TopicScore {
  const TopicScore({
    required this.topicTag,
    required this.correct,
    required this.total,
  });

  final String topicTag;
  final int correct;
  final int total;

  /// 得点率（0.0〜1.0）。
  double get rate => total == 0 ? 0 : correct / total;
}

/// 分野（topicTag）ごとの正答数。得点率の低い順（苦手な順）に並べる。
/// topicTag が無い問題は 'other' にまとめる。
List<TopicScore> topicScoresOf(MockExamState state) {
  final correct = <String, int>{};
  final total = <String, int>{};
  for (var i = 0; i < state.questions.length; i++) {
    final tag = state.questions[i].topicTag ?? 'other';
    total[tag] = (total[tag] ?? 0) + 1;
    if (state.isCorrectAt(i)) correct[tag] = (correct[tag] ?? 0) + 1;
  }
  final scores = [
    for (final tag in total.keys)
      TopicScore(topicTag: tag, correct: correct[tag] ?? 0, total: total[tag]!),
  ]..sort((a, b) {
      final byRate = a.rate.compareTo(b.rate);
      return byRate != 0 ? byRate : a.topicTag.compareTo(b.topicTag);
    });
  return scores;
}

/// 合格ラインまであと何問か（到達済みなら 0）。「あと◯点」表示用。
/// 整数点で比較する（yourwish_kentei の `requiredScore`）。
int shortByOf(MockExamState state) {
  if (state.totalCount == 0) return 0;
  final need = requiredScore(mockExamPassRate * 100, state.totalCount);
  return max(0, need - state.correctCount);
}
