import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/license_category.dart';
import '../core/constants/question_topic.dart';
import '../core/constants/topic_summaries.dart';
import '../models/question.dart';
import '../viewmodels/providers.dart';
import 'paywall_view.dart';

/// 学習モード：クイズ形式ではなく、問題文・選択肢・正解・解説を一覧で
/// 読んで学習できる画面。出題対象の範囲は [DailyQuotaView] の練習モードと
/// 同じルールを適用する。トピック別まとめと、未習得のみ表示するフィルタも
/// 備える。
class StudyModeView extends ConsumerStatefulWidget {
  const StudyModeView({super.key, required this.licenseCategory});

  final String licenseCategory;

  @override
  ConsumerState<StudyModeView> createState() => _StudyModeViewState();
}

class _StudyModeViewState extends ConsumerState<StudyModeView> {
  bool _unmasteredOnly = false;

  @override
  Widget build(BuildContext context) {
    final resultAsync = ref.watch(studyModeQuestionsProvider(widget.licenseCategory));
    final masteredAsync = ref.watch(masteredQuestionsProvider);
    final categoryLabel = LicenseCategory.fromId(widget.licenseCategory).label;

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
                            builder: (_) =>
                                PaywallView(categoryId: widget.licenseCategory),
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

            final masteredIds = masteredAsync.valueOrNull
                    ?.map((m) => m.questionId)
                    .toSet() ??
                const <String>{};
            final questions = _unmasteredOnly
                ? result.questions
                    .where((q) => !masteredIds.contains(q.id))
                    .toList()
                : result.questions;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _TopicSummarySection(questions: result.questions),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '問題一覧（${questions.length}問）',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        const Text('未習得のみ'),
                        Switch(
                          value: _unmasteredOnly,
                          onChanged: (v) => setState(() => _unmasteredOnly = v),
                        ),
                      ],
                    ),
                  ],
                ),
                if (questions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('すべて「覚えた」にチェック済みです。お疲れさまでした！'),
                  )
                else
                  for (var i = 0; i < questions.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _StudyQuestionCard(
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

/// トピック（標識・法規・運転操作など）ごとのまとめ解説。
/// 出題対象に含まれるトピックのみ表示する。
class _TopicSummarySection extends StatelessWidget {
  const _TopicSummarySection({required this.questions});

  final List<Question> questions;

  @override
  Widget build(BuildContext context) {
    final presentTopicIds = questions
        .map((q) => q.topicTag)
        .whereType<String>()
        .toSet();
    final topics = QuestionTopic.values
        .where((t) => presentTopicIds.contains(t.id))
        .toList();
    if (topics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('分野別まとめ', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              for (final topic in topics)
                ExpansionTile(
                  title: Text(topic.label),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        topicSummaries[topic] ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StudyQuestionCard extends ConsumerWidget {
  const _StudyQuestionCard({
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
