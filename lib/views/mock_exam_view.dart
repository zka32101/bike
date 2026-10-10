import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/question_topic.dart';
import '../models/question.dart';
import '../viewmodels/mock_exam_breakdown.dart';
import '../viewmodels/mock_exam_providers.dart';
import '../viewmodels/providers.dart';
import '../widgets/mock_record_button.dart';
import 'paywall_view.dart';
import '../data/question_signs.dart';

/// 本番模擬テスト：30問・制限時間20分・正答率90%以上で合格。
///
/// 途中の正誤フィードバックは出さず、全問回答後（または時間切れ時）に
/// 一括採点して結果画面を表示する。
///
/// 【広告制御】試験中は AdBlockingContext.answeringQuestion を保持する
/// （MockExamController.start で設定、採点時・画面離脱時に解除）。
class MockExamView extends ConsumerStatefulWidget {
  const MockExamView({super.key, required this.licenseCategory});

  final String licenseCategory;

  @override
  ConsumerState<MockExamView> createState() => _MockExamViewState();
}

class _MockExamViewState extends ConsumerState<MockExamView> {
  late final MockExamController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        ref.read(mockExamControllerProvider(widget.licenseCategory).notifier);
    // 画面を開くたびに新しい30問を選び直す。
    Future.microtask(_controller.load);
  }

  @override
  void dispose() {
    _controller.abandon();
    ref.read(adGateServiceProvider).exitContext();
    super.dispose();
  }

  Future<bool> _confirmQuit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('模擬テストを中断しますか？'),
        content: const Text('ここまでの回答は採点されません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('続ける'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('中断する'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mockExamControllerProvider(widget.licenseCategory));
    final inProgress = state.phase == MockExamPhase.inProgress;

    return PopScope(
      canPop: !inProgress,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _confirmQuit()) {
          _controller.abandon();
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('本番模擬テスト'),
          actions: [
            if (inProgress)
              _TimerChip(remainingSeconds: state.remainingSeconds),
          ],
        ),
        body: SafeArea(child: _buildBody(state)),
      ),
    );
  }

  Widget _buildBody(MockExamState state) {
    switch (state.phase) {
      case MockExamPhase.loading:
        return const Center(child: CircularProgressIndicator());
      case MockExamPhase.locked:
        return _LockedView(licenseCategory: widget.licenseCategory);
      case MockExamPhase.empty:
        return const Center(child: Text('この区分の問題がまだありません'));
      case MockExamPhase.ready:
        return _IntroView(
          questionCount: state.totalCount,
          timeLimitSeconds: state.remainingSeconds,
          quotaRemaining: state.quotaRemaining,
          onStart: _controller.start,
        );
      case MockExamPhase.inProgress:
        return _ExamQuestionBody(state: state, onAnswer: _controller.answer);
      case MockExamPhase.finished:
        return _MockExamResultView(
          state: state,
          licenseCategory: widget.licenseCategory,
          isPremium: ref.watch(hasPremiumProvider),
          onRetry: _controller.retry,
          onHome: () => Navigator.of(context).pop(),
        );
    }
  }
}

String _formatSeconds(int seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

class _TimerChip extends StatelessWidget {
  const _TimerChip({required this.remainingSeconds});

  final int remainingSeconds;

  @override
  Widget build(BuildContext context) {
    final urgent = remainingSeconds <= 60;
    final warning = remainingSeconds <= 5 * 60;
    final color = urgent
        ? Colors.red
        : warning
            ? Colors.orange
            : Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_outlined, size: 18, color: color),
              const SizedBox(width: 4),
              Text(
                _formatSeconds(remainingSeconds),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroView extends StatelessWidget {
  const _IntroView({
    required this.questionCount,
    required this.timeLimitSeconds,
    required this.onStart,
    this.quotaRemaining,
  });

  final int questionCount;
  final int timeLimitSeconds;
  final VoidCallback onStart;

  /// 今月の無料枠の残り。プレミアム（無制限）は null で、案内を出さない。
  final int? quotaRemaining;

  @override
  Widget build(BuildContext context) {
    final passLine = (questionCount * mockExamPassRate).ceil();
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.assignment_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              '本番模擬テスト',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            _RuleRow(icon: Icons.format_list_numbered, text: '出題数：$questionCount問'),
            _RuleRow(
              icon: Icons.timer_outlined,
              text: '制限時間：${timeLimitSeconds ~/ 60}分',
            ),
            _RuleRow(
              icon: Icons.flag_outlined,
              text: '合格ライン：${(mockExamPassRate * 100).round()}%以上'
                  '（$passLine問以上正解）',
            ),
            const _RuleRow(
              icon: Icons.info_outline,
              text: '正誤は全問回答後にまとめて表示されます。\n'
                  '選択すると自動で次の問題へ進みます。\n'
                  '時間切れの場合、未回答は不正解になります。',
            ),
            if (quotaRemaining != null)
              _RuleRow(
                icon: Icons.event_repeat,
                text: '今月の無料枠：あと$quotaRemaining回\n'
                    '（プレミアムなら回数無制限）',
              ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('試験開始'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _ExamQuestionBody extends StatelessWidget {
  const _ExamQuestionBody({required this.state, required this.onAnswer});

  final MockExamState state;
  final void Function(int choiceIndex) onAnswer;

  @override
  Widget build(BuildContext context) {
    final question = state.currentQuestion!;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: state.currentIndex / state.totalCount,
          ),
          const SizedBox(height: 8),
          Text('${state.currentIndex + 1} / ${state.totalCount}問'),
          const SizedBox(height: 20),
          Text(
            question.questionText,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          QuestionSignView(questionId: question.id, size: 120),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              // 問題ごとに別のリストとして扱い、スクロール位置等を持ち越さない。
              key: ValueKey(question.id),
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: question.choices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => onAnswer(i),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text(question.choices[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MockExamResultView extends ConsumerWidget {
  const _MockExamResultView({
    required this.state,
    required this.licenseCategory,
    required this.isPremium,
    required this.onRetry,
    required this.onHome,
  });

  final MockExamState state;
  final String licenseCategory;

  /// プレミアムのときだけ分野別得点と「あと◯点」を表示する。
  final bool isPremium;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passed = state.passed;
    final color = passed ? Colors.green : Colors.red;
    final wrong = state.wrongIndices;
    final percent = (state.accuracy * 100).toStringAsFixed(1);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (state.timedOut)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              '時間切れです。未回答の問題は不正解として採点しました。',
              textAlign: TextAlign.center,
            ),
          ),
        Icon(
          passed ? Icons.emoji_events : Icons.close_rounded,
          size: 72,
          color: passed ? Colors.amber : color,
        ),
        const SizedBox(height: 8),
        Text(
          passed ? '合格' : '不合格',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          '${state.correctCount} / ${state.totalCount} 問正解',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          '正答率 $percent%（合格ライン ${(mockExamPassRate * 100).round()}%）',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        CoinBreakdownCard(grants: ref.watch(coinProvider).recent),
        if (ref.watch(coinProvider).recent.isNotEmpty) const SizedBox(height: 16),
        if (passed) ...[
          MockRecordButton(
              licenseCategory: licenseCategory, accuracy: state.accuracy),
          const SizedBox(height: 16),
        ],
        if (isPremium)
          _PremiumBreakdown(state: state)
        else
          const _PremiumTeaser(),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onHome,
                child: const Text('ホームに戻る'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onRetry,
                child: const Text('もう一度挑戦'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          wrong.isEmpty ? '全問正解です！' : '間違えた問題（${wrong.length}問）',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final i in wrong)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${i + 1}')),
              title: Text(
                state.questions[i].questionText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                state.selectedAnswers[i] == null ? '未回答' : '不正解',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showExplanation(
                context,
                number: i + 1,
                question: state.questions[i],
                selected: state.selectedAnswers[i],
              ),
            ),
          ),
      ],
    );
  }

  void _showExplanation(
    BuildContext context, {
    required int number,
    required Question question,
    required int? selected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            Text('第$number問', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(
              question.questionText,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            QuestionSignView(questionId: question.id, size: 72, answered: true),
            const SizedBox(height: 16),
            for (var c = 0; c < question.choices.length; c++)
              _ChoiceLine(
                text: question.choices[c],
                isCorrect: c == question.answer,
                isSelected: c == selected,
              ),
            if (selected == null)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('あなたの回答：未回答'),
              ),
            const SizedBox(height: 16),
            Text('解説', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(
              question.explanation.isEmpty ? '解説はありません。' : question.displayExplanation,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceLine extends StatelessWidget {
  const _ChoiceLine({
    required this.text,
    required this.isCorrect,
    required this.isSelected,
  });

  final String text;
  final bool isCorrect;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final Color? color = isCorrect
        ? Colors.green
        : isSelected
            ? Colors.red
            : null;
    final label = isCorrect
        ? '正解'
        : isSelected
            ? 'あなたの回答'
            : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect
                ? Icons.check_circle
                : isSelected
                    ? Icons.cancel
                    : Icons.radio_button_unchecked,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label == null ? text : '$text（$label）',
              style: TextStyle(
                color: color,
                fontWeight:
                    isCorrect || isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 無料枠（月1回）を使い切ったときの入口。
class _LockedView extends StatelessWidget {
  const _LockedView({required this.licenseCategory});

  final String licenseCategory;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 56),
            const SizedBox(height: 16),
            const Text(
              '今月の無料の模擬テストは使い切りました',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '来月になるとまた1回受けられます。\n'
              'プレミアムなら、回数の制限なく何度でも受けられます。',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PaywallView(categoryId: licenseCategory),
                ),
              ),
              child: const Text('プレミアムを見る'),
            ),
          ],
        ),
      ),
    );
  }
}

/// プレミアム：分野別得点と「合格まであと◯問」。
class _PremiumBreakdown extends StatelessWidget {
  const _PremiumBreakdown({required this.state});

  final MockExamState state;

  @override
  Widget build(BuildContext context) {
    final shortBy = shortByOf(state);
    final scores = topicScoresOf(state);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.passed ? '合格ラインを超えています' : '合格まであと$shortBy問',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text('分野別の得点', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            for (final s in scores)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(QuestionTopic.labelFor(s.topicTag)),
                    ),
                    Expanded(
                      flex: 4,
                      child: LinearProgressIndicator(value: s.rate),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 64,
                      child: Text(
                        '${s.correct}/${s.total}問',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 無料：分野別得点と「あと◯問」はプレミアムで見られる。
class _PremiumTeaser extends StatelessWidget {
  const _PremiumTeaser();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.lock_outline),
        title: const Text('分野別の得点と「合格まであと◯問」'),
        subtitle: const Text('プレミアムで見られます'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PaywallView()),
        ),
      ),
    );
  }
}
