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

/// 画像（共有カード）をOSの共有シートで共有する。
Future<void> shareCardImage(Uint8List png) async {
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(png, mimeType: 'image/png', name: 'ukalab_pass.png')],
      text: '#うかラボ #バイク免許',
    ),
  );
}


/// ホームの「推し」カード。共通キットの [UkalabOshiCard] に、バイク免許の成長段階・
/// 連続日数・試験日を渡す。推しの選択・着替え・合格報告・表示切替・コイン表示はキット側。
class OshiCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(answerLogsProvider).valueOrNull ?? const [];
    final ids = questions.map((q) => q.id).toSet();
    final inScope = logs.where((l) => ids.contains(l.questionId)).toList();
    final stage = oshiStageFor(
      distinctAnswered: inScope.map((l) => l.questionId).toSet().length,
      totalQuestions: ids.length,
      correct: inScope.where((l) => l.isCorrect).length,
      answered: inScope.length,
    );
    final at = now ?? DateTime.now();
    final day = oshiDayState(now: at, streakDays: streakDays, lastStudyDate: lastStudyDate, examDate: examDate);
    return UkalabOshiCard(
      cert: UkalabCert.bikeLicense,
      stage: stage,
      appId: 'bike',
      examDate: examDate,
      streakDays: streakDays,
      studiedToday: day.studiedToday,
      daysSinceLastStudy: day.daysSinceLastStudy,
      onShare: shareCardImage,
      now: now,
    );
  }
}
