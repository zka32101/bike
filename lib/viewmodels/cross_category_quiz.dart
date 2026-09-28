import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/license_category.dart';
import '../models/question.dart';
import '../models/user_answer_log.dart';
import '../services/ad_gate_service.dart';
import '../services/sync_queue_service.dart';
import 'providers.dart';

// ---------------------------------------------------------------------------
// 区分横断クイズ（ひっかけ問題専門クイズ／数字・距離クイズ）の共通基盤。
//
// - 全免許区分（LicenseCategory.values）の問題を questionsProvider で読み込み、
//   ユーザーがアクセス権を持つ問題だけを結合する
//   （フルアクセスがない区分は除外。原付のみ無料プレビュー分を対象にする）。
// - 派生クラスが [filterPool] で出題対象を絞り込み、その中から
//   [crossCategoryQuizQuestionCount] 問をランダム出題する。
// - 制限時間なし・1問ごとに即時正誤フィードバック。
// ---------------------------------------------------------------------------

/// 区分横断クイズ1回あたりの出題数（母集団がこれ未満なら全問）。
const int crossCategoryQuizQuestionCount = 10;

enum CrossCategoryQuizPhase {
  /// 問題読み込み中。
  loading,

  /// アクセス可能な対象問題が1問もない。
  empty,

  /// 出題中。
  inProgress,

  /// 全問回答済み（結果画面）。
  finished,
}

class CrossCategoryQuizState {
  const CrossCategoryQuizState({
    this.phase = CrossCategoryQuizPhase.loading,
    this.questions = const [],
    this.categoryByQuestionId = const {},
    this.currentIndex = 0,
    this.selectedAnswer,
    this.correctCount = 0,
  });

  final CrossCategoryQuizPhase phase;
  final List<Question> questions;

  /// 各問題をどの免許区分として出題したか（回答ログの licenseCategory 用）。
  final Map<String, String> categoryByQuestionId;

  final int currentIndex;

  /// 現在の問題で選んだ選択肢。null の間は未回答（フィードバック非表示）。
  final int? selectedAnswer;

  final int correctCount;

  int get totalCount => questions.length;

  Question? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  bool get hasAnsweredCurrent => selectedAnswer != null;

  bool get isCurrentCorrect =>
      selectedAnswer != null && selectedAnswer == currentQuestion?.answer;

  CrossCategoryQuizState copyWith({
    CrossCategoryQuizPhase? phase,
    List<Question>? questions,
    Map<String, String>? categoryByQuestionId,
    int? currentIndex,
    int? Function()? selectedAnswer,
    int? correctCount,
  }) {
    return CrossCategoryQuizState(
      phase: phase ?? this.phase,
      questions: questions ?? this.questions,
      categoryByQuestionId: categoryByQuestionId ?? this.categoryByQuestionId,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswer:
          selectedAnswer != null ? selectedAnswer() : this.selectedAnswer,
      correctCount: correctCount ?? this.correctCount,
    );
  }
}

/// 区分横断クイズの Controller 基底クラス。
///
/// autoDispose のため、画面を開くたびに新しい10問が選び直される。
abstract class CrossCategoryQuizController
    extends AutoDisposeNotifier<CrossCategoryQuizState> {
  /// 読み込み世代。retry 中に古い load が完了しても state を上書きしないため。
  int _loadGeneration = 0;
  bool _disposed = false;

  /// 回答ログ書き込みの直列化用（SharedPreferences の read-modify-write 競合と、
  /// 完走時の同期キュー登録より前に全ログが書き込まれていることを保証する）。
  Future<void> _pendingLogWrite = Future.value();

  /// 出題対象の絞り込み。アクセス可能な全区分の問題（ID重複排除済み）を受け取る。
  Future<List<Question>> filterPool(List<Question> accessibleQuestions);

  @override
  CrossCategoryQuizState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      ref.read(adGateServiceProvider).exitContext();
    });
    Future.microtask(load);
    return const CrossCategoryQuizState();
  }

  /// 問題を読み込み、出題を開始する。
  Future<void> load() async {
    final generation = ++_loadGeneration;
    state = const CrossCategoryQuizState();

    final categoryById = <String, String>{};
    final accessible = <Question>[];
    try {
      final user = ref.read(userControllerProvider).valueOrNull;
      for (final category in LicenseCategory.values) {
        if (_disposed || generation != _loadGeneration) return;
        final id = category.name;
        final hasAccess = user?.hasAccessToCategory(id) ?? false;
        List<Question> questions;
        if (hasAccess) {
          questions = await ref.read(
            questionsProvider(QuestionQuery(licenseCategory: id)).future,
          );
        } else if (category == LicenseCategory.gentsuki) {
          // 無料版：原付の先頭固定プレビュー分のみ（DailyQuotaController と同じルール）。
          final all = await ref.read(
            questionsProvider(QuestionQuery(licenseCategory: id)).future,
          );
          questions = all.take(freeGentsukiPreviewCount).toList();
        } else {
          // 無料版：原付以外の区分は購入するまで対象外。
          continue;
        }
        for (final q in questions) {
          // 複数区分で共通出題される問題は最初に見つかった区分で1回だけ採用。
          if (categoryById.containsKey(q.id)) continue;
          categoryById[q.id] = id;
          accessible.add(q);
        }
      }
    } catch (e) {
      debugPrint('Failed to load cross-category quiz questions: $e');
    }

    final pool = List.of(await filterPool(accessible));
    if (_disposed || generation != _loadGeneration) return;

    if (pool.isEmpty) {
      state = state.copyWith(phase: CrossCategoryQuizPhase.empty);
      return;
    }

    pool.shuffle();
    final questions = pool.take(crossCategoryQuizQuestionCount).toList();
    ref
        .read(adGateServiceProvider)
        .enterContext(AdBlockingContext.answeringQuestion);
    state = CrossCategoryQuizState(
      phase: CrossCategoryQuizPhase.inProgress,
      questions: questions,
      categoryByQuestionId: {
        for (final q in questions) q.id: categoryById[q.id]!,
      },
    );
  }

  /// 選択肢を選ぶ。即座に正誤を確定し、回答ログを保存する。
  void answer(int choiceIndex) {
    if (state.phase != CrossCategoryQuizPhase.inProgress) return;
    if (state.hasAnsweredCurrent) return;
    final question = state.currentQuestion;
    if (question == null) return;

    final isCorrect = choiceIndex == question.answer;
    state = state.copyWith(
      selectedAnswer: () => choiceIndex,
      correctCount: state.correctCount + (isCorrect ? 1 : 0),
    );

    try {
      if (isCorrect) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    } catch (_) {
      // Haptics not available on this device
    }

    // ref は画面離脱（dispose）後に使えないため、必要な値は同期的に確保しておく。
    final log = UserAnswerLog(
      uid: ref.read(currentUidProvider),
      questionId: question.id,
      isCorrect: isCorrect,
      answeredAt: DateTime.now(),
      licenseCategory: state.categoryByQuestionId[question.id],
      userAnswer: question.choices[choiceIndex],
      correctAnswer: question.choices[question.answer],
      stage: question.stageTag.isEmpty ? null : question.stageTag,
    );
    final dataService = ref.read(dataServiceProvider);
    _pendingLogWrite = _pendingLogWrite.then((_) async {
      try {
        await dataService.appendAnswerLog(log);
      } catch (e) {
        debugPrint('Failed to save cross-category quiz answer log: $e');
      }
    });
  }

  /// 次の問題へ。最後の問題なら結果画面へ遷移する。
  void next() {
    if (state.phase != CrossCategoryQuizPhase.inProgress) return;
    if (!state.hasAnsweredCurrent) return;
    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.questions.length) {
      state = state.copyWith(phase: CrossCategoryQuizPhase.finished);
      ref.read(adGateServiceProvider).exitContext();
      unawaited(_enqueueSyncAndRefresh());
    } else {
      state = state.copyWith(
        currentIndex: nextIndex,
        selectedAnswer: () => null,
      );
    }
  }

  /// もう一度挑戦：新しい10問を選び直す。
  Future<void> retry() => load();

  /// 完走時に Firestore 同期キューへ登録し、分析系キャッシュを無効化する。
  Future<void> _enqueueSyncAndRefresh() async {
    final uid = ref.read(currentUidProvider);
    final dataService = ref.read(dataServiceProvider);
    final queueServiceFuture = ref.read(syncQueueServiceProvider.future);
    await _pendingLogWrite;
    try {
      final allLogs = await dataService.loadAnswerLogs(uid);
      final queueService = await queueServiceFuture;
      await queueService.enqueue(
        QueuedOperation(
          id: 'answerLogs_${uid}_${DateTime.now().millisecondsSinceEpoch}',
          type: 'saveAnswerLogs',
          data: {
            'uid': uid,
            'logs': allLogs.map((l) => l.toJson()).toList(),
          },
          queuedAt: DateTime.now(),
          lastAttemptAt: DateTime.now(),
          retryCount: 0,
        ),
      );
    } catch (e) {
      debugPrint('Failed to queue cross-category quiz answer logs: $e');
    }
    if (_disposed) return;
    ref.invalidate(answerLogsProvider);
    ref.invalidate(analyticsSnapshotProvider);
  }
}
