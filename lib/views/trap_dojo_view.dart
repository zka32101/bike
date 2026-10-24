import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/question.dart';
import '../services/ad_gate_service.dart';
import '../viewmodels/providers.dart';
import '../data/question_signs.dart';

/// ひっかけ道場：二輪特有の間違えやすい数字を対戦形式で反復。
/// 誤答は自動でボス化し再挑戦キューに積まれる。
///
/// ホーム画面の TrapDojoEntryCard から開く。
///
/// 【広告制御・厳守】ボス戦中は AdBlockingContext.trapDojoBossBattle を
/// 保持し、広告表示を一切許可しない。
class TrapDojoView extends ConsumerStatefulWidget {
  const TrapDojoView({super.key, required this.licenseCategory});

  final String licenseCategory;

  @override
  ConsumerState<TrapDojoView> createState() => _TrapDojoViewState();
}

class _TrapDojoViewState extends ConsumerState<TrapDojoView> {
  int _index = 0;
  bool _showResult = false;
  bool _lastCorrect = false;

  // dispose 中は ref を使えないため、initState で取得して保持する。
  late final AdGateService _adGate;

  @override
  void initState() {
    super.initState();
    _adGate = ref.read(adGateServiceProvider);
    _adGate.enterContext(AdBlockingContext.trapDojoBossBattle);
  }

  @override
  void dispose() {
    _adGate.exitContext();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(
      questionsProvider(QuestionQuery(licenseCategory: widget.licenseCategory)),
    );

    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.trapDojoTitle)),
      body: questionsAsync.when(
        data: (all) {
          final trapQuestions = all.where((q) => q.isTrapQuestion).toList();
          if (trapQuestions.isEmpty) {
            return Center(child: Text(l10n.trapDojoNotReady));
          }
          if (_index >= trapQuestions.length) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.military_tech, size: 64, color: Colors.amber),
                  const SizedBox(height: 12),
                  Text(l10n.trapDojoCompleted),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.commonHome),
                  ),
                ],
              ),
            );
          }
          final boss = trapQuestions[_index];
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.deepOrange),
                    const SizedBox(width: 8),
                    Text(l10n.trapDojoBossProgress(_index + 1, trapQuestions.length)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(boss.questionText, style: Theme.of(context).textTheme.titleLarge),
                QuestionSignView(questionId: boss.id, size: 72),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.separated(
                    itemCount: boss.choices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _showResult
                            ? null
                            : () => _onAnswer(boss, i == boss.answer),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.centerLeft,
                        ),
                        child: Text(boss.choices[i]),
                      ),
                    ),
                  ),
                ),
                if (_showResult)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => setState(() {
                          _showResult = false;
                          if (_lastCorrect) _index++;
                          // 不正解時はボスが居座り再挑戦（キューの先頭に留まる）。
                        }),
                        child: Text(_lastCorrect ? l10n.trapDojoNextBoss : l10n.commonRetry),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.commonLoadError(e.toString()))),
      ),
    );
  }

  Future<void> _onAnswer(Question boss, bool isCorrect) async {
    await ref
        .read(trapDojoControllerProvider.notifier)
        .recordAnswer(bossQuestion: boss, isCorrect: isCorrect);
    setState(() {
      _showResult = true;
      _lastCorrect = isCorrect;
    });
  }
}
