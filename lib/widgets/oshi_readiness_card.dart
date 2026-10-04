import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/question.dart';
import '../services/oshi_readiness.dart';
import '../viewmodels/providers.dart';

/// この区分の模擬試験に合格したことがあるか（学習コインの台帳から分かる）。
bool mockPassedInLedger(CoinLedger ledger, String licenseCategory) => ledger.entries
    .any((e) => e.kind == 'mockPass' && e.id.startsWith('mockPass|$licenseCategory'));

/// ホームの「準備完了まで」カード。習得度と模擬試験の合格から進み具合を見せる。
class OshiReadinessCard extends ConsumerWidget {
  const OshiReadinessCard({
    super.key,
    required this.licenseCategory,
    required this.questions,
  });

  final String licenseCategory;
  final List<Question> questions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(answerLogsProvider).valueOrNull ?? const [];
    var mockPassed = false;
    try {
      ref.watch(coinProvider); // 合格のコインが付いたら再描画する
      mockPassed = mockPassedInLedger(ref.read(coinServiceProvider).ledger, licenseCategory);
    } catch (_) {}
    final mastery = masteryFromLogs(
      questionIds: questions.map((q) => q.id).toSet(),
      logs: [for (final l in logs) (questionId: l.questionId, isCorrect: l.isCorrect)],
    );
    return ReadinessProgressCard(
      progress: ReadinessRule.standard.progress(mastery: mastery, mockPassed: mockPassed),
    );
  }
}
