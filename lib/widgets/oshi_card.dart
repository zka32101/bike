import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/question.dart';
import '../viewmodels/providers.dart';

/// 習得度から推しの成長段階を決める。網羅率＝解いた問題の種類÷全問題数、
/// 正答率＝全回答の正解率（端末内で計算）。
MascotStage oshiStageFor({
  required int distinctAnswered,
  required int totalQuestions,
  required int correct,
  required int answered,
}) {
  if (totalQuestions <= 0 || answered <= 0) return MascotStage.lv1;
  final coverage = (distinctAnswered / totalQuestions).clamp(0.0, 1.0);
  final accuracy = (correct / answered).clamp(0.0, 1.0);
  return MasteryModel.standard
      .stageOf(MasteryInput(coverage: coverage, accuracy: accuracy));
}

/// ホームの「推し」カード。学習が進むと成長し、学習コインの残高を控えめに出す。
class OshiCard extends ConsumerWidget {
  const OshiCard({super.key, required this.questions});

  /// 選択中の区分の問題一覧（網羅率の分母）。
  final List<Question> questions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(answerLogsProvider).valueOrNull ?? const [];
    final ids = questions.map((q) => q.id).toSet();
    final inScope = logs.where((l) => ids.contains(l.questionId)).toList();
    final stage = oshiStageFor(
      distinctAnswered: inScope.map((l) => l.questionId).toSet().length,
      totalQuestions: ids.length,
      correct: inScope.where((l) => l.isCorrect).length,
      answered: inScope.length,
    );
    final coin = ref.watch(coinProvider);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            MascotWidget(stage: stage, size: 88),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('あなたの推し  Lv${stage.index + 1}',
                      style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text('学習すると成長します', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text('学習コイン ${coin.balance}',
                      style: theme.textTheme.labelMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
