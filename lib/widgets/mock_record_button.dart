import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/oshi_readiness.dart';
import '../viewmodels/providers.dart';
import 'oshi_card.dart' show shareCardImage;

/// 模擬試験で合格点を超えたときに出す「学習の記録カード」のボタン。
/// 本番の合格報告とは別で、コインも衣装も付かない。
class MockRecordButton extends ConsumerWidget {
  const MockRecordButton({
    super.key,
    required this.licenseCategory,
    required this.accuracy,
  });

  final String licenseCategory;

  /// 模擬試験の正答率（0〜1）。
  final double accuracy;

  Future<MascotStage> _stage(WidgetRef ref) async {
    try {
      final questions = await ref.read(
        questionsProvider(QuestionQuery(licenseCategory: licenseCategory)).future,
      );
      final logs = await ref.read(answerLogsProvider.future);
      final mastery = masteryFromLogs(
        questionIds: questions.map((q) => q.id).toSet(),
        logs: [for (final l in logs) (questionId: l.questionId, isCorrect: l.isCorrect)],
      );
      return MasteryModel.standard.stageOf(mastery);
    } catch (_) {
      return MascotStage.lv1;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.ios_share),
      label: const Text('学習の記録カードを見る'),
      onPressed: () async {
        final stage = await _stage(ref);
        if (!context.mounted) return;
        await showMockRecordDialog(
          context,
          ref,
          cert: UkalabCert.bikeLicense,
          stage: stage,
          scoreText: '正答率 ${(accuracy * 100).round()}%',
          onShare: shareCardImage,
        );
      },
    );
  }
}
