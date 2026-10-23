import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/hazard_scenario.dart';
import '../viewmodels/providers.dart';
import 'guide_view.dart';

/// プレミアム限定シナリオを未購読でタップしたときの案内。
const String kHazardPremiumNotice = 'このシナリオはプレミアムの機能です。設定から購入できます。';

/// 「危険予測シナリオ」の一覧。最初の2本は無料、残りはプレミアム限定
/// （[freeHazardScenarioIds]）。未購読でロック中のシナリオをタップしても画面には入らず、案内だけ出す。
class HazardScenarioListView extends ConsumerStatefulWidget {
  const HazardScenarioListView({super.key, this.scenariosFuture});

  /// テスト用。省略時は assets から読み込む。
  final Future<List<HazardScenario>>? scenariosFuture;

  @override
  ConsumerState<HazardScenarioListView> createState() => _HazardScenarioListViewState();
}

class _HazardScenarioListViewState extends ConsumerState<HazardScenarioListView> {
  late final Future<List<HazardScenario>> _future =
      widget.scenariosFuture ?? loadHazardScenarios();

  void _open(HazardScenario scenario) {
    if (!scenario.isFree && !ref.read(hasPremiumProvider)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(kHazardPremiumNotice)),
      );
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => HazardScenarioPlayView(scenario: scenario),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // 購入状態の変化に追従させる。
    ref.watch(hasPremiumProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('危険予測シナリオ')),
      body: SafeArea(
        child: FutureBuilder<List<HazardScenario>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('読み込みに失敗しました: ${snapshot.error}'));
            }
            final scenarios = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '二輪ならではの場面で、どう判断するかを選びます。選んだあとに理由の解説が出ます。',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  kHazardDraftNotice,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                ),
                const SizedBox(height: 12),
                for (final s in scenarios) ...[
                  Card(
                    child: ListTile(
                      title: Text(s.title),
                      subtitle: Text(
                        '全${s.chapters.length}場面 ・ ${s.isFree ? '無料' : 'プレミアム'}',
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: s.isFree
                          ? const Icon(Icons.chevron_right)
                          : Icon(Icons.lock_outline, color: theme.colorScheme.outline),
                      onTap: () => _open(s),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 1シナリオを遊ぶ画面：状況提示→3択の判断→解説→（最後に）結果。
class HazardScenarioPlayView extends StatefulWidget {
  const HazardScenarioPlayView({super.key, required this.scenario});

  final HazardScenario scenario;

  @override
  State<HazardScenarioPlayView> createState() => _HazardScenarioPlayViewState();
}

class _HazardScenarioPlayViewState extends State<HazardScenarioPlayView> {
  int _index = 0;
  int _good = 0;
  HazardChoice? _selected;
  bool _finished = false;

  HazardChapter get _chapter => widget.scenario.chapters[_index];

  void _choose(HazardChoice choice) {
    if (_selected != null) return;
    setState(() {
      _selected = choice;
      if (choice.isRecommended) _good++;
    });
  }

  void _next() {
    setState(() {
      if (_index + 1 >= widget.scenario.chapters.length) {
        _finished = true;
      } else {
        _index++;
        _selected = null;
      }
    });
  }

  void _restart() {
    setState(() {
      _index = 0;
      _good = 0;
      _selected = null;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.scenario.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.scenario.isAiDraft) ...[
                Text(
                  kHazardDraftNotice,
                  style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline),
                ),
                const SizedBox(height: 8),
              ],
              if (_finished) ..._resultChildren(theme) else ..._chapterChildren(theme),
              const SizedBox(height: 24),
              Text('関連', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.lightbulb_outline, size: 18),
                    label: const Text('役立つ情報'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const GuideListView()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _chapterChildren(ThemeData theme) {
    final total = widget.scenario.chapters.length;
    final selected = _selected;
    return [
      Text('場面 ${_index + 1} / 全$total場面', style: theme.textTheme.labelLarge),
      const SizedBox(height: 8),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(_chapter.situation, style: theme.textTheme.bodyLarge),
        ),
      ),
      const SizedBox(height: 12),
      Text('どう判断しますか？', style: theme.textTheme.titleSmall),
      const SizedBox(height: 8),
      for (final c in _chapter.choices) ...[
        OutlinedButton(
          onPressed: selected == null ? () => _choose(c) : null,
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(12),
          ),
          child: Text(c.text),
        ),
        const SizedBox(height: 8),
      ],
      if (selected != null) ...[
        const SizedBox(height: 8),
        Card(
          color: selected.isRecommended
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selected.isRecommended ? 'よい判断です' : 'もう一度考えてみましょう',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(selected.feedback),
                if (!selected.isRecommended) ...[
                  const SizedBox(height: 12),
                  Text('おすすめの判断', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(_chapter.recommended.text),
                  const SizedBox(height: 4),
                  Text(_chapter.recommended.feedback),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _next,
          child: Text(_index + 1 >= total ? '結果を見る' : '次の場面へ'),
        ),
      ],
    ];
  }

  List<Widget> _resultChildren(ThemeData theme) {
    final total = widget.scenario.chapters.length;
    return [
      Text('結果', style: theme.textTheme.titleLarge),
      const SizedBox(height: 8),
      Text('$total場面のうち、$_good場面でおすすめの判断を選べました。'),
      const SizedBox(height: 8),
      const Text('正解・不正解を競うものではありません。死角を意識して速度を落とす、余裕を持った間隔をとる、といった考え方を振り返りましょう。'),
      const SizedBox(height: 16),
      Row(
        children: [
          OutlinedButton(onPressed: _restart, child: const Text('もう一度')),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('一覧へ戻る'),
          ),
        ],
      ),
    ];
  }
}
