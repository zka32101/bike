import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/license_category.dart';
import '../../viewmodels/cross_category_quiz.dart';
import '../../widgets/answer_result_overlay.dart';

/// 区分横断クイズ（ひっかけ問題専門クイズ／数字・距離クイズ）共通の画面。
///
/// 4択 → 選択直後に [AnswerResultOverlay] で正誤フィードバック →
/// 全問終了で正答数/出題数の結果画面、という流れ。
///
/// 【広告制御】出題中は Controller 側で AdBlockingContext.answeringQuestion を
/// 保持しており、広告は表示されない。
class CrossCategoryQuizScaffold extends ConsumerWidget {
  const CrossCategoryQuizScaffold({
    super.key,
    required this.title,
    required this.provider,
    required this.emptyMessage,
    this.resultIcon = Icons.emoji_events,
  });

  final String title;
  final AutoDisposeNotifierProvider<CrossCategoryQuizController,
      CrossCategoryQuizState> provider;

  /// 対象問題が1問もないときのメッセージ。
  final String emptyMessage;

  final IconData resultIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    final Widget body;
    switch (state.phase) {
      case CrossCategoryQuizPhase.loading:
        body = const Center(child: CircularProgressIndicator());
      case CrossCategoryQuizPhase.empty:
        body = Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(emptyMessage, textAlign: TextAlign.center),
          ),
        );
      case CrossCategoryQuizPhase.inProgress:
        final question = state.currentQuestion!;
        body = Stack(
          children: [
            _QuestionBody(state: state, controller: controller),
            if (state.hasAnsweredCurrent)
              AnswerResultOverlay(
                // key を問題ごとに変え、問題が切り替わるたびに演出を作り直す。
                key: ValueKey('${question.id}_${state.currentIndex}'),
                questionId: question.id,
                isCorrect: state.isCurrentCorrect,
                explanation: _feedbackText(state),
                onNext: controller.next,
              ),
          ],
        );
      case CrossCategoryQuizPhase.finished:
        body = _ResultView(
          correctCount: state.correctCount,
          total: state.totalCount,
          onRetry: controller.retry,
        );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(child: body),
    );
  }

  static String _feedbackText(CrossCategoryQuizState state) {
    final q = state.currentQuestion!;
    final correct = '正解: ${q.choices[q.answer]}';
    if (state.isCurrentCorrect) return q.displayExplanation;
    return q.explanation.isEmpty ? correct : '$correct\n\n${q.displayExplanation}';
  }
}

class _QuestionBody extends StatelessWidget {
  const _QuestionBody({required this.state, required this.controller});

  final CrossCategoryQuizState state;
  final CrossCategoryQuizController controller;

  @override
  Widget build(BuildContext context) {
    final question = state.currentQuestion!;
    final category = state.categoryByQuestionId[question.id];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: state.currentIndex / state.totalCount,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${state.currentIndex + 1} / ${state.totalCount}問'),
              const Spacer(),
              if (category != null)
                Text(
                  _categoryLabel(category),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                QuestionCard(text: question.questionText),
                const SizedBox(height: 16),
                for (var i = 0; i < question.choices.length; i++) ...[
                  ChoiceTile(
                    label: '${i + 1}',
                    text: question.choices[i],
                    state: _choiceState(i, question.answer),
                    onTap: state.hasAnsweredCurrent
                        ? null
                        : () => controller.answer(i),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  ChoiceState _choiceState(int i, int answer) {
    if (!state.hasAnsweredCurrent) return ChoiceState.idle;
    if (i == answer) return ChoiceState.correct;
    if (i == state.selectedAnswer) return ChoiceState.incorrect;
    return ChoiceState.idle;
  }

  static String _categoryLabel(String id) {
    for (final c in LicenseCategory.values) {
      if (c.name == id) return c.label;
    }
    return id;
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.correctCount,
    required this.total,
    required this.onRetry,
  });

  final int correctCount;
  final int total;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ResultSummary(
          correct: correctCount,
          total: total,
          onRetry: onRetry,
          retryLabel: 'もう一度挑戦する',
          onClose: () => Navigator.of(context).pop(),
          closeLabel: 'ホームに戻る',
        ),
      ),
    );
  }
}
