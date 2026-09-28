import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/traffic_sign.dart';
import '../widgets/confetti_animation.dart';
import '../widgets/shake_animation.dart';
import '../widgets/traffic_sign_painter.dart';

/// 標識クイズ専用モード。
///
/// 全標識（[kTrafficSigns]）からランダムに [questionCount] 問を出題し、
/// 標識の絵（CustomPainterで描画）→4択→正誤フィードバック→次の問題、を繰り返す。
/// 最後に結果画面（正答数／出題数）を表示する。
///
/// 外部データ依存がないため、状態は StatefulWidget 内で完結させている。
class SignQuizView extends StatefulWidget {
  const SignQuizView({super.key, this.questionCount = 10});

  /// 1回のクイズで出題する問題数（標識データ数を上限とする）。
  final int questionCount;

  @override
  State<SignQuizView> createState() => _SignQuizViewState();
}

class _SignQuizViewState extends State<SignQuizView> {
  final math.Random _random = math.Random();

  late List<TrafficSign> _questions;
  int _index = 0;
  int? _selected;
  int _correctCount = 0;
  final List<TrafficSign> _mistakes = [];
  bool _finished = false;

  /// 演出（紙吹雪・シェイク）を問題ごとに作り直すためのキー
  int _feedbackSeq = 0;

  @override
  void initState() {
    super.initState();
    _startQuiz();
  }

  void _startQuiz() {
    final count = widget.questionCount.clamp(1, kTrafficSigns.length);
    _questions = (List<TrafficSign>.of(kTrafficSigns)..shuffle(_random))
        .take(count)
        .toList();
    _index = 0;
    _selected = null;
    _correctCount = 0;
    _mistakes.clear();
    _finished = false;
  }

  TrafficSign get _current => _questions[_index];
  bool get _answered => _selected != null;
  bool get _isCorrect => _selected == _current.answer;
  bool get _isLast => _index == _questions.length - 1;

  void _answer(int choice) {
    if (_answered) return;
    setState(() {
      _selected = choice;
      _feedbackSeq++;
      if (choice == _current.answer) {
        _correctCount++;
      } else {
        _mistakes.add(_current);
      }
    });
  }

  void _next() {
    setState(() {
      if (_isLast) {
        _finished = true;
      } else {
        _index++;
        _selected = null;
      }
    });
  }

  void _restart() {
    setState(_startQuiz);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('標識クイズ')),
      body: SafeArea(
        child: _finished
            ? _SignQuizResult(
                correctCount: _correctCount,
                total: _questions.length,
                mistakes: _mistakes,
                onRetry: _restart,
                onExit: () => Navigator.of(context).maybePop(),
              )
            : Stack(
                children: [
                  _buildQuestion(context),
                  if (_answered && _isCorrect)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ConfettiAnimation(key: ValueKey(_feedbackSeq)),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildQuestion(BuildContext context) {
    final sign = _current;
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final signSize = math.min<double>(width * 0.55, 220);

    Widget signView = TrafficSignWidget(sign: sign, size: signSize);
    if (_answered && !_isCorrect) {
      signView = ShakeAnimation(key: ValueKey(_feedbackSeq), child: signView);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_index + (_answered ? 1 : 0)) / _questions.length,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${_index + 1} / ${_questions.length}問'),
              const Spacer(),
              Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
              const SizedBox(width: 4),
              Text('$_correctCount'),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: signView,
            ),
          ),
          const SizedBox(height: 20),
          Text(sign.questionText, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          for (var i = 0; i < sign.choices.length; i++) ...[
            _ChoiceButton(
              label: sign.choices[i],
              index: i,
              state: _choiceState(i),
              onTap: _answered ? null : () => _answer(i),
            ),
            const SizedBox(height: 10),
          ],
          if (_answered) ...[
            const SizedBox(height: 6),
            _FeedbackCard(sign: sign, isCorrect: _isCorrect),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _next,
              child: Text(_isLast ? '結果を見る' : '次の問題へ'),
            ),
          ],
        ],
      ),
    );
  }

  _ChoiceState _choiceState(int i) {
    if (!_answered) return _ChoiceState.idle;
    if (i == _current.answer) return _ChoiceState.correct;
    if (i == _selected) return _ChoiceState.wrong;
    return _ChoiceState.dimmed;
  }
}

enum _ChoiceState { idle, correct, wrong, dimmed }

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.index,
    required this.state,
    required this.onTap,
  });

  final String label;
  final int index;
  final _ChoiceState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color borderColor = scheme.outline;
    Color? fill;
    IconData? trailing;
    Color? trailingColor;

    switch (state) {
      case _ChoiceState.idle:
      case _ChoiceState.dimmed:
        break;
      case _ChoiceState.correct:
        borderColor = Colors.green.shade600;
        fill = Colors.green.withValues(alpha: 0.12);
        trailing = Icons.circle_outlined;
        trailingColor = Colors.green.shade600;
      case _ChoiceState.wrong:
        borderColor = Colors.red.shade600;
        fill = Colors.red.withValues(alpha: 0.12);
        trailing = Icons.close;
        trailingColor = Colors.red.shade600;
    }

    return Opacity(
      opacity: state == _ChoiceState.dimmed ? 0.55 : 1,
      child: Material(
        color: fill ?? Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderColor, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(label)),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailing, color: trailingColor),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.sign, required this.isCorrect});

  final TrafficSign sign;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? Colors.green.shade600 : Colors.red.shade600;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isCorrect ? Icons.circle_outlined : Icons.close, color: color),
              const SizedBox(width: 8),
              Text(
                isCorrect ? '正解！' : '不正解',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${sign.name}（${sign.category}）',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(sign.explanation),
        ],
      ),
    );
  }
}

class _SignQuizResult extends StatelessWidget {
  const _SignQuizResult({
    required this.correctCount,
    required this.total,
    required this.mistakes,
    required this.onRetry,
    required this.onExit,
  });

  final int correctCount;
  final int total;
  final List<TrafficSign> mistakes;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  String get _message {
    final rate = total == 0 ? 0 : correctCount / total;
    if (rate == 1) return 'パーフェクト！標識はバッチリです';
    if (rate >= 0.8) return 'よくできました！あと少しで満点です';
    if (rate >= 0.5) return 'まずまずです。間違えた標識を復習しましょう';
    return '標識の形と色に注目してもう一度挑戦しましょう';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Icon(
          correctCount == total ? Icons.emoji_events : Icons.traffic,
          size: 72,
          color: Colors.amber,
        ),
        const SizedBox(height: 12),
        Text(
          '標識クイズ 結果',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          '$correctCount / $total 問正解',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(_message, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        if (mistakes.isNotEmpty) ...[
          Text('間違えた標識', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final sign in mistakes)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    TrafficSignWidget(sign: sign, size: 56),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sign.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sign.choices[sign.answer],
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('もう一度挑戦する'),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: onExit, child: const Text('ホームに戻る')),
      ],
    );
  }
}
