import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/providers.dart';

/// 習得度（網羅率×正答率）を、回答ログと問題数から求める。
///
/// 網羅率＝解いた問題の種類÷区分の全問題数、正答率＝その区分の回答の正解率。
MasteryInput masteryFromLogs({
  required Set<String> questionIds,
  required List<({String questionId, bool isCorrect})> logs,
}) =>
    MasteryInput.fromLogs(questionIds: questionIds, logs: logs);

/// 模擬試験で合格点を超えたあとに呼ぶ。準備完了の条件（[ReadinessRule]）を満たしたら、
/// 「準備完了」の装いを解放する。初めて解放したら true。
///
/// 回答ログの保存と前後するため、判定はやや控えめになることがある（次の機会に満たせばよい）。
Future<bool> checkReadinessAfterMock(
  Ref ref, {
  required String licenseCategory,
}) async {
  try {
    final questions = await ref.read(
      questionsProvider(QuestionQuery(licenseCategory: licenseCategory)).future,
    );
    final uid = ref.read(currentUidProvider);
    final logs = await ref.read(dataServiceProvider).loadAnswerLogs(uid);
    final mastery = masteryFromLogs(
      questionIds: questions.map((q) => q.id).toSet(),
      logs: [for (final l in logs) (questionId: l.questionId, isCorrect: l.isCorrect)],
    );
    if (!ReadinessRule.standard.isReady(mastery: mastery, mockPassed: true)) {
      return false;
    }
    return ref.read(outfitProvider.notifier).markReady(UkalabCert.bikeLicense);
  } catch (_) {
    return false;
  }
}
