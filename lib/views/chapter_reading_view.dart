import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ukalab_core/ui.dart'
    show ExplanationCard, ReadingQuestionLinks, ReadingSectionContent;
import 'package:ukalab_core/ukalab_core.dart' as core show ChapterReading;

import '../data/chapter_readings.dart';
import '../data/hazard_scenario.dart';
import '../models/question.dart';
import 'hazard_scenario_view.dart';

/// 確認問題リンクを最初に出す件数(「まず確認する問題」)。残りは「すべて見る」で開く。
const int kReadingFirstQuestionLinks = 5;

/// 「役立つ情報」一覧の先頭に置く、読み物への入口。
class ReadingEntryCard extends StatelessWidget {
  const ReadingEntryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const Icon(Icons.menu_book_outlined),
        title: const Text('読み物'),
        subtitle: const Text('表や手順で整理した、章ごとの読み物'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const BikeReadingListView()),
        ),
      ),
    );
  }
}

/// 読み物の一覧。
class BikeReadingListView extends ConsumerWidget {
  const BikeReadingListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(chapterReadingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('読み物')),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('読み込みに失敗しました: $e')),
          data: (readings) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final r in readings.where((r) => !r.disabled))
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(r.title),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => BikeReadingView(reading: r)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 読み物1本の画面。節は core の [ReadingSectionContent] で描画する(表・手順を含む)。
/// 末尾に確認問題への導線([ReadingQuestionLinks]、最初は数件、「すべて見る」で全件)と、
/// `relatedLinks` の hazard から危険予測への導線を出す。広告は置かない。
class BikeReadingView extends ConsumerStatefulWidget {
  const BikeReadingView({super.key, required this.reading, this.hazardsFuture});

  final core.ChapterReading reading;

  /// テスト用。省略時は assets から読み込む。
  final Future<List<HazardScenario>>? hazardsFuture;

  @override
  ConsumerState<BikeReadingView> createState() => _BikeReadingViewState();
}

class _BikeReadingViewState extends ConsumerState<BikeReadingView> {
  bool _showAllLinks = false;

  void _showQuestion(Question q) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _QuestionSheet(question: q),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reading = widget.reading;
    final theme = Theme.of(context);
    final questions = ref.watch(readingQuestionsProvider).valueOrNull ?? const <String, Question>{};
    final linked = reading.relatedQuestionIds.where(questions.containsKey).toList();
    final canCollapse = linked.length > kReadingFirstQuestionLinks;
    final shown = (canCollapse && !_showAllLinks)
        ? linked.take(kReadingFirstQuestionLinks).toList()
        : linked;
    final hazardIds = hazardLinkIds(reading);
    return Scaffold(
      appBar: AppBar(title: Text(reading.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (var i = 0; i < reading.sections.length; i++) ...[
              if (i > 0) const SizedBox(height: 20),
              ReadingSectionContent(section: reading.sections[i]),
            ],
            if (linked.isNotEmpty) ...[
              const SizedBox(height: 28),
              ReadingQuestionLinks(
                questionIds: shown,
                // 区別しやすいよう問題文をそのまま渡す(長いものは core が3行で折り返す)。
                labels: {for (final id in shown) id: questions[id]!.questionText},
                onOpenQuestion: (id) => _showQuestion(questions[id]!),
              ),
              if (canCollapse)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: Icon(_showAllLinks ? Icons.expand_less : Icons.expand_more),
                    label: Text(
                      _showAllLinks
                          ? '最初の$kReadingFirstQuestionLinks問だけ表示'
                          : 'すべて見る（${linked.length}問）',
                    ),
                    onPressed: () => setState(() => _showAllLinks = !_showAllLinks),
                  ),
                ),
            ],
            if (hazardIds.isNotEmpty) ...[
              const SizedBox(height: 20),
              _HazardLinks(scenarioIds: hazardIds, scenariosFuture: widget.hazardsFuture),
            ],
            const SizedBox(height: 24),
            Text('出典: ${reading.sourceRef}', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// 確認問題の表示(問題文・選択肢・正解・解説)。
class _QuestionSheet extends StatelessWidget {
  const _QuestionSheet({required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(question.questionText, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            for (var i = 0; i < question.choices.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      i == question.answer ? Icons.check_circle : Icons.circle_outlined,
                      size: 18,
                      color: i == question.answer ? Colors.green : theme.colorScheme.outline,
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
            const SizedBox(height: 12),
            ExplanationCard.fromPlain(question.explanation),
          ],
        ),
      ),
    );
  }
}

/// 関連する危険予測シナリオへの導線。無料枠・プレミアム限定の扱いは一覧画面に任せる。
class _HazardLinks extends StatelessWidget {
  const _HazardLinks({required this.scenarioIds, this.scenariosFuture});

  final List<String> scenarioIds;
  final Future<List<HazardScenario>>? scenariosFuture;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<HazardScenario>>(
      future: scenariosFuture ?? loadHazardScenarios(),
      builder: (context, snapshot) {
        final titles = [
          for (final s in snapshot.data ?? const <HazardScenario>[])
            if (scenarioIds.contains(s.scenarioId)) s.title,
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text('危険予測で試す', style: theme.textTheme.labelLarge),
            ),
            for (final t in titles)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('・$t', style: theme.textTheme.bodyMedium),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.two_wheeler),
              label: const Align(
                alignment: Alignment.centerLeft,
                child: Text('危険予測シナリオを開く'),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const HazardScenarioListView()),
              ),
            ),
          ],
        );
      },
    );
  }
}
