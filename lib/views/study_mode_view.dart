import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/license_category.dart';
import '../models/question.dart';
import '../viewmodels/providers.dart';
import 'paywall_view.dart';

/// 学習モード：クイズ形式ではなく、問題文・選択肢・正解・解説を一覧で
/// 読んで学習できる画面。出題対象の範囲（無料/購入の制限）は
/// [DailyQuotaView] の練習モードと同じルールを適用する。
class StudyModeView extends ConsumerWidget {
  const StudyModeView({super.key, required this.licenseCategory});

  final String licenseCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(studyModeQuestionsProvider(licenseCategory));
    final categoryLabel = LicenseCategory.fromId(licenseCategory).label;

    return Scaffold(
      appBar: AppBar(title: Text('学習モード（$categoryLabel）')),
      body: SafeArea(
        child: resultAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('読み込みに失敗しました: $e')),
          data: (result) {
            if (result.locked) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline, size: 56),
                      const SizedBox(height: 16),
                      const Text(
                        'この区分はパス購入で解放されます',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PaywallView(categoryId: licenseCategory),
                          ),
                        ),
                        child: const Text('プランを見る'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (result.questions.isEmpty) {
              return const Center(child: Text('この区分の問題がまだありません'));
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: result.questions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) =>
                  _StudyQuestionCard(question: result.questions[i], index: i + 1),
            );
          },
        ),
      ),
    );
  }
}

class _StudyQuestionCard extends StatelessWidget {
  const _StudyQuestionCard({required this.question, required this.index});

  final Question question;
  final int index;

  @override
  Widget build(BuildContext context) {
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
        ],
      ),
    );
  }
}
