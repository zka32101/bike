import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/solve_coverage.dart';
import 'providers.dart';

/// 解答履歴（正誤不問）から得た「解いたことのある問題ID」。
final solvedQuestionIdsProvider = FutureProvider<Set<String>>((ref) async {
  final logs = await ref.watch(answerLogsProvider.future);
  return logs.map((l) => l.questionId).toSet();
});

/// 免許区分ごとの解いた割合。
final categoryCoverageProvider =
    FutureProvider.family<SolveCoverage, String>((ref, categoryId) async {
  final questions = await ref.watch(
    questionsProvider(QuestionQuery(licenseCategory: categoryId)).future,
  );
  final solved = await ref.watch(solvedQuestionIdsProvider.future);
  return aggregateCoverage(questions.map((q) => q.id), solved);
});
