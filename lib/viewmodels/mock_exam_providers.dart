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
// 本番模擬テスト（制限時間・合格ライン判定つきの通し試験モード）
//
// 出題数・制限時間は実際の学科試験の仕様に合わせている。
// - 原付: 48問（文章46問＋イラスト2問相当）、30分
// - 二輪（普通・大型・AT限定・小型限定）: 95問（文章90問＋イラスト5問相当）、50分
// 合格ラインはいずれも正答率90%以上。
// パス未購入（無料）ユーザーは一切利用できない（原付の無料プレビューも対象外）。
// ---------------------------------------------------------------------------

/// 区分ごとの模擬テスト出題数。
int mockExamQuestionCountFor(String licenseCategory) {
  return licenseCategory == LicenseCategory.gentsuki.name ? 48 : 95;
}

/// 区分ごとの模擬テスト制限時間（秒）。
int mockExamTimeLimitSecondsFor(String licenseCategory) {
  return licenseCategory == LicenseCategory.gentsuki.name ? 30 * 60 : 50 * 60;
}

/// 合格ライン（正答率）。90%以上で合格。
const double mockExamPassRate = 0.9;

enum MockExamPhase {
  /// 問題読み込み中。
  loading,

  /// 無料版でフルアクセス権のない区分。
  locked,

  /// 対象区分に問題が存在しない。
  empty,

  /// 読み込み完了・開始待ち（ルール説明画面）。
  ready,

  /// 試験中（タイマー作動中）。
  inProgress,

  /// 採点済み（結果画面）。
  finished,
}

class MockExamState {
  const MockExamState({
    this.phase = MockExamPhase.loading,
    this.questions = const [],
    this.selectedAnswers = const [],
    this.currentIndex = 0,
    this.remainingSeconds = 0,
    this.timedOut = false,
  });

  final MockExamPhase phase;
  final List<Question> questions;

  /// [questions] と同じ長さ。未回答は null。
  final List<int?> selectedAnswers;
  final int currentIndex;
  final int remainingSeconds;

  /// 時間切れで採点された場合 true。
  final bool timedOut;

  int get totalCount => questions.length;

  Question? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  int get answeredCount => selectedAnswers.where((a) => a != null).length;

  bool isCorrectAt(int index) =>
      selectedAnswers[index] != null &&
      selectedAnswers[index] == questions[index].answer;

  /// 正答数（未回答は不正解扱い）。
  int get correctCount {
    var count = 0;
    for (var i = 0; i < questions.length; i++) {
      if (isCorrectAt(i)) count++;
    }
    return count;
  }

  /// 正答率（0.0〜1.0）。
  double get accuracy => totalCount == 0 ? 0 : correctCount / totalCount;

  bool get passed => totalCount > 0 && accuracy >= mockExamPassRate;

  /// 不正解（未回答含む）の問題インデックス一覧。
  List<int> get wrongIndices => [
        for (var i = 0; i < questions.length; i++)
          if (!isCorrectAt(i)) i,
      ];

  MockExamState copyWith({
    MockExamPhase? phase,
    List<Question>? questions,
    List<int?>? selectedAnswers,
    int? currentIndex,
    int? remainingSeconds,
    bool? timedOut,
  }) {
    return MockExamState(
      phase: phase ?? this.phase,
      questions: questions ?? this.questions,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      currentIndex: currentIndex ?? this.currentIndex,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      timedOut: timedOut ?? this.timedOut,
    );
  }
}

class MockExamController extends FamilyNotifier<MockExamState, String> {
  late String _licenseCategory;
  Timer? _timer;

  @override
  MockExamState build(String licenseCategory) {
    _licenseCategory = licenseCategory;
    ref.onDispose(_cancelTimer);
    // 読み込みは View 側（MockExamView.initState）から [load] を呼んで行う。
    // family は autoDispose ではないため、画面を開くたびに新しい30問を
    // 選び直す必要があるため。
    return const MockExamState();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// 問題を読み込み、開始待ち（[MockExamPhase.ready]）状態にする。
  /// 区分内の全問題（マスター済み・未習得を問わず、段階フィルタなし）から
  /// ランダムに出題数分を選出する。
  ///
  /// 全問題が無料のため、区分によるロックはない。
  Future<void> load() async {
    _cancelTimer();
    state = const MockExamState();

    final all = await ref.read(
      questionsProvider(QuestionQuery(licenseCategory: _licenseCategory)).future,
    );
    final pool = List.of(all);

    if (pool.isEmpty) {
      state = state.copyWith(phase: MockExamPhase.empty);
      return;
    }

    pool.shuffle();
    final questionCount = mockExamQuestionCountFor(_licenseCategory);
    final questions = pool.take(questionCount).toList();
    state = MockExamState(
      phase: MockExamPhase.ready,
      questions: questions,
      selectedAnswers: List<int?>.filled(questions.length, null),
      remainingSeconds: mockExamTimeLimitSecondsFor(_licenseCategory),
    );
  }

  /// 試験を開始し、カウントダウンタイマーを起動する。
  void start() {
    if (state.phase != MockExamPhase.ready) return;
    ref
        .read(adGateServiceProvider)
        .enterContext(AdBlockingContext.answeringQuestion);
    state = state.copyWith(
      phase: MockExamPhase.inProgress,
      currentIndex: 0,
      remainingSeconds: mockExamTimeLimitSecondsFor(_licenseCategory),
      timedOut: false,
    );
    _cancelTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  /// もう一度挑戦：新しい30問を選び直して即座に開始する。
  Future<void> retry() async {
    await load();
    start();
  }

  void _tick() {
    if (state.phase != MockExamPhase.inProgress) {
      _cancelTimer();
      return;
    }
    final next = state.remainingSeconds - 1;
    if (next <= 0) {
      state = state.copyWith(remainingSeconds: 0);
      _finish(timedOut: true);
    } else {
      state = state.copyWith(remainingSeconds: next);
    }
  }

  /// 選択肢を選ぶ。正誤は表示せず、自動的に次の問題へ進む。
  /// 最後の問題に回答したら一括採点する。
  void answer(int choiceIndex) {
    if (state.phase != MockExamPhase.inProgress) return;
    final index = state.currentIndex;
    if (index >= state.questions.length) return;

    final answers = List<int?>.of(state.selectedAnswers);
    answers[index] = choiceIndex;

    try {
      HapticFeedback.selectionClick();
    } catch (_) {
      // Haptics not available on this device
    }

    if (index + 1 >= state.questions.length) {
      state = state.copyWith(selectedAnswers: answers);
      _finish(timedOut: false);
    } else {
      state = state.copyWith(
        selectedAnswers: answers,
        currentIndex: index + 1,
      );
    }
  }

  /// 画面離脱時（中断）にタイマーだけ止める。state は変更しない。
  void abandon() {
    _cancelTimer();
  }

  void _finish({required bool timedOut}) {
    if (state.phase != MockExamPhase.inProgress) return;
    _cancelTimer();
    state = state.copyWith(phase: MockExamPhase.finished, timedOut: timedOut);
    ref.read(adGateServiceProvider).exitContext();
    unawaited(_saveAnswerLogs(state));
  }

  /// 回答済みの問題を通常の学習ログと同様に保存する（未回答分は実際に
  /// 回答していないためログには残さず、採点上のみ不正解扱いとする）。
  Future<void> _saveAnswerLogs(MockExamState finished) async {
    final uid = ref.read(currentUidProvider);
    final dataService = ref.read(dataServiceProvider);
    final now = DateTime.now();

    try {
      for (var i = 0; i < finished.questions.length; i++) {
        final selected = finished.selectedAnswers[i];
        if (selected == null) continue;
        final q = finished.questions[i];
        await dataService.appendAnswerLog(
          UserAnswerLog(
            uid: uid,
            questionId: q.id,
            isCorrect: selected == q.answer,
            answeredAt: now,
            licenseCategory: _licenseCategory,
            userAnswer: q.choices[selected],
            correctAnswer: q.choices[q.answer],
            stage: q.stageTag.isEmpty ? null : q.stageTag,
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to save mock exam answer logs: $e');
      return;
    }

    // Firestore 同期キューに登録（失敗してもアプリは続行）
    try {
      final allLogs = await dataService.loadAnswerLogs(uid);
      final queueService = await ref.read(syncQueueServiceProvider.future);
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
      debugPrint('Failed to queue mock exam answer logs: $e');
    }

    // 既存の分析機能・ホーム画面に最新ログが反映されるようキャッシュを無効化。
    ref.invalidate(answerLogsProvider);
    ref.invalidate(analyticsSnapshotProvider);
  }
}

final mockExamControllerProvider =
    NotifierProvider.family<MockExamController, MockExamState, String>(
  MockExamController.new,
);
