import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/question.dart';
import '../viewmodels/providers.dart';

/// 学習分析の「復習推奨」専用画面。
///
/// 区分単位で全問題を出す通常の「問題を解く」とは異なり、実際に
/// 間違えた問題（[questionIds]）だけを読んで復習できる一覧を表示する。
class ReviewQuestionsView extends ConsumerWidget {
  const ReviewQuestionsView({
    super.key,
    required this.title,
    required this.questionIds,
  });

  final String title;
  final List<String> questionIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(_reviewQuestionsProvider(questionIds));
    final masteredAsync = ref.watch(masteredQuestionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: questionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('読み込みに失敗しました: $e')),
          data: (questions) {
            if (questions.isEmpty) {
              return const Center(child: Text('復習対象の問題が見つかりませんでした'));
            }
            final masteredIds = masteredAsync.valueOrNull
                    ?.map((m) => m.questionId)
                    .toSet() ??
                const <String>{};

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Text(
                  '間違えた問題 ${questions.length}問だけを復習します',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < questions.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReviewQuestionCard(
                      question: questions[i],
                      index: i + 1,
                      isMastered: masteredIds.contains(questions[i].id),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

final _reviewQuestionsProvider =
    FutureProvider.family<List<Question>, List<String>>((ref, ids) {
  return ref.read(dataServiceProvider).loadQuestionsByIds(ids);
});

class _ReviewQuestionCard extends ConsumerWidget {
  const _ReviewQuestionCard({
    required this.question,
    required this.index,
    required this.isMastered,
  });

  final Question question;
  final int index;
  final bool isMastered;

  Future<void> _toggleMastery(WidgetRef ref) async {
    final uid = ref.read(currentUidProvider);
    final masteryService = ref.read(masteryServiceProvider);
    if (isMastered) {
      await masteryService.unmarkAsMastered(uid, question.id);
    } else {
      await masteryService.markAsMastered(uid, question.id);
    }
    ref.invalidate(masteredQuestionsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ExpansionTile(
        title: Text('$index. ${question.questionText}'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          for (var i = 0; i < question.choices.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    i == question.answer
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    size: 18,
                    color: i == question.answer
                        ? Colors.green
                        : Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.choices[i],
                      style: i == question.answer
                          ? const TextStyle(fontWeight: FontWeight.bold)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              question.explanation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _toggleMastery(ref),
              icon: Icon(
                isMastered ? Icons.check_circle : Icons.radio_button_unchecked,
              ),
              label: Text(isMastered ? '覚えた ✓' : '覚えた'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isMastered ? Theme.of(context).primaryColor : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
