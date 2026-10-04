import 'dart:typed_data';

import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
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
  return MasteryModel.standard.stageOf(MasteryInput.fromCounts(
    distinctAnswered: distinctAnswered,
    totalQuestions: totalQuestions,
    correct: correct,
    answered: answered,
  ));
}

/// 今の状況に合うセリフの場面。責める表現は使わない（セリフ集側で検査済み）。
MascotSituation oshiSituation(MascotDayState day, DateTime now) {
  switch (day.examPhase(now)) {
    case ExamPhase.today:
      return MascotSituation.examToday;
    case ExamPhase.eve:
      return MascotSituation.examEve;
    case ExamPhase.close:
      return MascotSituation.examClose;
    case ExamPhase.approaching:
      return MascotSituation.examApproaching;
    case ExamPhase.none:
      break;
  }
  if (day.isWelcomeBack) return MascotSituation.welcomeBack;
  if (day.streakDays >= 3) return MascotSituation.streak;
  if (day.studiedToday) return MascotSituation.studied;
  return MascotSituation.greeting;
}

MascotDayState oshiDayState({
  required DateTime now,
  required int streakDays,
  required DateTime? lastStudyDate,
  required DateTime? examDate,
}) {
  final today = DateTime(now.year, now.month, now.day);
  int? since;
  if (lastStudyDate != null) {
    since = today
        .difference(DateTime(lastStudyDate.year, lastStudyDate.month, lastStudyDate.day))
        .inDays;
  }
  return MascotDayState(
    studiedToday: since == 0,
    streakDays: streakDays,
    daysSinceLastStudy: since,
    examDate: examDate,
  );
}

const _kDisplayKey = 'oshi_display';

/// 推しの表示設定（通常／小さく／非表示）。端末内に保存する。
class OshiDisplayNotifier extends Notifier<MascotDisplay> {
  @override
  MascotDisplay build() {
    final v = ref.read(keyValueStoreProvider).read(_kDisplayKey);
    return MascotDisplay.values.firstWhere((e) => e.name == v,
        orElse: () => MascotDisplay.normal);
  }

  Future<void> set(MascotDisplay d) async {
    state = d;
    await ref.read(keyValueStoreProvider).write(_kDisplayKey, d.name);
  }
}

final oshiDisplayProvider =
    NotifierProvider<OshiDisplayNotifier, MascotDisplay>(OshiDisplayNotifier.new);

/// ホームの「推し」カード。学習が進むと成長し、状況に合ったひとことを話す。
/// タップでひとことが変わる。メニューから小さく／非表示にできる。
class OshiCard extends ConsumerStatefulWidget {
  const OshiCard({
    super.key,
    required this.questions,
    this.streakDays = 0,
    this.lastStudyDate,
    this.examDate,
    this.now,
  });

  /// 選択中の区分の問題一覧（網羅率の分母）。
  final List<Question> questions;
  final int streakDays;
  final DateTime? lastStudyDate;
  final DateTime? examDate;

  /// テスト用に現在時刻を差し替える。
  final DateTime? now;

  @override
  ConsumerState<OshiCard> createState() => _OshiCardState();
}

/// ホームの推しカードのメニュー操作。
enum _OshiAction { wardrobe, passReport }

/// 画像（共有カード）をOSの共有シートで共有する。
Future<void> shareCardImage(Uint8List png) async {
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(png, mimeType: 'image/png', name: 'ukalab_pass.png')],
      text: '#うかラボ #バイク免許',
    ),
  );
}

class _OshiCardState extends ConsumerState<OshiCard> {
  int _seed = 0;

  ExamPhase _examPhase(DateTime? d) =>
      MascotDayState(examDate: d).examPhase(widget.now ?? DateTime.now());

  MascotStage _stageNow() {
    final logs = ref.read(answerLogsProvider).valueOrNull ?? const [];
    final ids = widget.questions.map((q) => q.id).toSet();
    final inScope = logs.where((l) => ids.contains(l.questionId)).toList();
    return oshiStageFor(
      distinctAnswered: inScope.map((l) => l.questionId).toSet().length,
      totalQuestions: ids.length,
      correct: inScope.where((l) => l.isCorrect).length,
      answered: inScope.length,
    );
  }

  void _onMenu(Object value) {
    if (value is MascotDisplay) {
      ref.read(oshiDisplayProvider.notifier).set(value);
      return;
    }
    switch (value as _OshiAction) {
      case _OshiAction.wardrobe:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => WardrobeScreen(
            cert: UkalabCert.bikeLicense,
            examPhase: _examPhase(widget.examDate),
            stage: _stageNow(),
          ),
        ));
      case _OshiAction.passReport:
        showPassReportDialog(
          context,
          ref,
          cert: UkalabCert.bikeLicense,
          stage: _stageNow(),
          onShare: shareCardImage,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final display = ref.watch(oshiDisplayProvider);
    final theme = Theme.of(context);
    final menu = PopupMenuButton<Object>(
      tooltip: '推しのメニュー',
      icon: const Icon(Icons.more_vert),
      onSelected: _onMenu,
      itemBuilder: (_) => const [
        PopupMenuItem(value: _OshiAction.wardrobe, child: Text('着替え・ショップ')),
        PopupMenuItem(value: _OshiAction.passReport, child: Text('試験の結果を報告')),
        PopupMenuDivider(),
        PopupMenuItem(value: MascotDisplay.normal, child: Text('通常')),
        PopupMenuItem(value: MascotDisplay.small, child: Text('小さく表示')),
        PopupMenuItem(value: MascotDisplay.hidden, child: Text('表示しない')),
      ],
    );
    final coin = ref.watch(coinProvider);
    if (display == MascotDisplay.hidden) {
      return Card(
        child: ListTile(
          title: Text('学習コイン ${coin.balance}', style: theme.textTheme.labelLarge),
          subtitle: const Text('推しは非表示です'),
          trailing: menu,
        ),
      );
    }

    final logs = ref.watch(answerLogsProvider).valueOrNull ?? const [];
    final ids = widget.questions.map((q) => q.id).toSet();
    final inScope = logs.where((l) => ids.contains(l.questionId)).toList();
    final stage = oshiStageFor(
      distinctAnswered: inScope.map((l) => l.questionId).toSet().length,
      totalQuestions: ids.length,
      correct: inScope.where((l) => l.isCorrect).length,
      answered: inScope.length,
    );
    final now = widget.now ?? DateTime.now();
    final day = oshiDayState(
      now: now,
      streakDays: widget.streakDays,
      lastStudyDate: widget.lastStudyDate,
      examDate: widget.examDate,
    );
    final line = MascotLines.gentle.pick(oshiSituation(day, now), seed: _seed);
    final small = display == MascotDisplay.small;

    final mascot = MascotWidget(
      stage: stage,
      outfit: ref.watch(equippedOutfitProvider),
      expression: day.expression,
      examPhase: day.examPhase(now),
      display: display,
      size: small ? 56 : 88,
      line: small ? null : line,
      onTap: () => setState(() => _seed++),
    );
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('あなたの推し  Lv${stage.index + 1}', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(small ? line : '推しをタップすると、ひとこと話します',
            style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        Text('学習コイン ${coin.balance}', style: theme.textTheme.labelMedium),
      ],
    );

    // 通常表示は吹き出し（最大200dp）が横幅を取るので、推しを上、説明を下の行に置く。
    // 小さい表示は吹き出しが無いので、横並びのまま。
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
        child: small
            ? Row(
                children: [
                  mascot,
                  const SizedBox(width: 12),
                  Expanded(child: info),
                  menu,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: mascot),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: info),
                      menu,
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
