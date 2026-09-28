// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '原付・バイク免許コレ！';

  @override
  String get navHome => 'ホーム';

  @override
  String get navSettings => '設定';

  @override
  String get menuAnswerQuestions => '問題を解く';

  @override
  String get menuStudyMode => '学習モード';

  @override
  String get menuAnalytics => '学習分析';

  @override
  String get menuMockExam => '本番模擬テスト';

  @override
  String get menuSignQuiz => '標識クイズ';

  @override
  String get menuTrapQuiz => 'ヒッかけ問題クイズ';

  @override
  String get menuNumberQuiz => '数字・距離クイズ';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsPlan => 'プラン';

  @override
  String get settingsHelp => 'アプリの使い方';

  @override
  String get commonBack => '戻る';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonConfirm => '確認';

  @override
  String get commonRetry => 'もう一度挑戦';

  @override
  String get commonClose => '閉じる';

  @override
  String get commonNext => '次へ';

  @override
  String get commonStart => '開始';

  @override
  String get commonHome => 'ホームに戻る';

  @override
  String commonLoadError(String error) {
    return '読み込みに失敗しました: $error';
  }

  @override
  String get commonNoQuestionsInCategory => 'この区分の問題がまだありません';

  @override
  String get commonCategoryLocked => 'この区分はパス購入で解放されます';

  @override
  String get commonViewPlans => 'プランを見る';

  @override
  String get commonMarkMastered => '覚えた';

  @override
  String get commonMastered => '覚えた ✓';

  @override
  String homeAnswerQuestionsWithCategory(String category) {
    return '問題を解く（$category）';
  }

  @override
  String get homeAnswerQuestionsSubtitle => '未習得問題からランダム出題';

  @override
  String homeFreePreviewLimit(int count) {
    return '無料版は最初の$count問だけ解けます';
  }

  @override
  String get homeUnlockWithPass => 'パス購入で解放されます';

  @override
  String get homeStudyModeSubtitle => '問題・正解・解説を読んで学習';

  @override
  String get homeAnalyticsSubtitle => '弱点と伸びを確認';

  @override
  String homeMockExamSubtitle(int count, int minutes) {
    return '$count問・$minutes分・合格ライン90%（パス購入で利用可）';
  }

  @override
  String get homeSignQuizSubtitle => '標識の絵を見て名称・意味を当てる';

  @override
  String get homeTrapQuizSubtitle => '引っかけ問題だけを集中的に練習';

  @override
  String get homeNumberQuizSubtitle => '制限速度・制動距離・車間距離などの数値を練習';

  @override
  String get homeNoCategory => '免許区分が未設定です。設定から選んでください。';

  @override
  String get homeSetCategory => '区分を設定する';

  @override
  String homeStreak(int days) {
    return '$days日連続学習中！';
  }

  @override
  String get homeExamDatePrompt => '試験日を登録すると逆算ノルマを自動計算します';

  @override
  String get homeExamDateSet => '設定';

  @override
  String get homeQuotaExplanation => '残日数÷未習得問題数でノルマを逆算しています';

  @override
  String get homeExamDatePassed => '試験日を過ぎています。設定を見直してください';

  @override
  String get homeNoUnmastered => '未習得問題はありません。この調子で維持しましょう！';

  @override
  String homeDailyGoalPace(int count) {
    return '1日$count問解けば試験日までに間に合うペースです';
  }

  @override
  String get homeQuotaCalculating => 'ノルマを計算しています…';

  @override
  String homeExamCountdown(int days) {
    return '試験日まであと$days日';
  }

  @override
  String dailyQuotaProgress(int current, int total) {
    return '$current / $total問';
  }

  @override
  String get dailyQuotaAhaTitle => '🎉 3問正解！';

  @override
  String get dailyQuotaContinue => '続ける';

  @override
  String get dailyQuotaSeeAdFreePlans => '広告なしで続けるプランを見る';

  @override
  String get dailyQuotaCompleted => '練習完了！';

  @override
  String dailyQuotaCorrectCount(int correct, int total) {
    return '$correct / $total 問正解';
  }

  @override
  String studyModeTitleWithCategory(String category) {
    return '学習モード（$category）';
  }

  @override
  String studyModeQuestionList(int count) {
    return '問題一覧（$count問）';
  }

  @override
  String get studyModeUnmasteredOnly => '未習得のみ';

  @override
  String get studyModeAllMastered => 'すべて「覚えた」にチェック済みです。お疲れさまでした！';

  @override
  String get studyModeTopicSummaries => '分野別まとめ';

  @override
  String get analyticsRecalculate => '再計算';

  @override
  String get analyticsCalculating => '分析データを計算中...';

  @override
  String get analyticsLoadFailed => '分析データの読み込みに失敗しました';

  @override
  String get analyticsRetry => '再度お試しください';

  @override
  String get analyticsInsufficientData => '分析データが不足しています';

  @override
  String analyticsRemainingQuestions(int count) {
    return 'あと$count問で分析が表示されます。\nもう少し学習を進めてください！';
  }

  @override
  String get analyticsByTopic => '出題分野別';

  @override
  String get analyticsByCategory => '区分別';

  @override
  String get analyticsCategoryNote => '※複数区分に該当する問題があるため、\n合計は全問題数と異なる場合があります';

  @override
  String analyticsWeakTop(int count) {
    return '弱点TOP$count';
  }

  @override
  String get analyticsRecommendedReview => 'おすすめ復習';

  @override
  String get passRateTitle => '合格率分析';

  @override
  String get passRateNoData => 'まだ十分な回答データがありません';

  @override
  String get passRateNoDataHint => '10問以上回答して、分析を確認してください。';

  @override
  String get passRatePredictionScore => '合格予測スコア';

  @override
  String get passRateAccuracyStats => '正答率統計';

  @override
  String get passRateCorrectCount => '正答数';

  @override
  String get passRateAccuracy => '正答率';

  @override
  String get passRateByCategory => '区分別分析';

  @override
  String get passRateByStage => '段階別分析';

  @override
  String get passRateByTopic => '分野別分析';

  @override
  String get passRateAlmostThere => '合格まであと一歩！';

  @override
  String get passRateOnTrack => '順調に進んでいます';

  @override
  String get passRateNeedPractice => 'もっと練習が必要です';

  @override
  String get passRateKeepGoing => 'コツコツ続けましょう';

  @override
  String get trapDojoTitle => 'ひっかけ道場';

  @override
  String get trapDojoNotReady => 'この区分のひっかけ問題は準備中です';

  @override
  String get trapDojoCompleted => '今日の道場は完了！';

  @override
  String trapDojoBossProgress(int current, int total) {
    return 'ボス $current / $total';
  }

  @override
  String get trapDojoNextBoss => '次のボスへ';

  @override
  String get reviewNotFound => '復習対象の問題が見つかりませんでした';

  @override
  String reviewHeader(int count) {
    return '間違えた問題 $count問だけを復習します';
  }
}
