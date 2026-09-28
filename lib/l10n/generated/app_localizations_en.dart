// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Moped & Motorcycle License Master!';

  @override
  String get navHome => 'Home';

  @override
  String get navSettings => 'Settings';

  @override
  String get menuAnswerQuestions => 'Practice Questions';

  @override
  String get menuStudyMode => 'Study Mode';

  @override
  String get menuAnalytics => 'Study Analytics';

  @override
  String get menuMockExam => 'Mock Exam';

  @override
  String get menuSignQuiz => 'Road Sign Quiz';

  @override
  String get menuTrapQuiz => 'Trick Question Quiz';

  @override
  String get menuNumberQuiz => 'Numbers & Distances Quiz';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPlan => 'Plan';

  @override
  String get settingsHelp => 'How to Use';

  @override
  String get commonBack => 'Back';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonRetry => 'Try Again';

  @override
  String get commonClose => 'Close';

  @override
  String get commonNext => 'Next';

  @override
  String get commonStart => 'Start';

  @override
  String get commonHome => 'Back to Home';

  @override
  String commonLoadError(String error) {
    return 'Failed to load: $error';
  }

  @override
  String get commonNoQuestionsInCategory =>
      'No questions are available for this category yet';

  @override
  String get commonCategoryLocked => 'Purchase a pass to unlock this category';

  @override
  String get commonViewPlans => 'View Plans';

  @override
  String get commonMarkMastered => 'Got it';

  @override
  String get commonMastered => 'Got it ✓';

  @override
  String homeAnswerQuestionsWithCategory(String category) {
    return 'Practice Questions ($category)';
  }

  @override
  String get homeAnswerQuestionsSubtitle =>
      'Random questions from the ones you haven\'t mastered';

  @override
  String homeFreePreviewLimit(int count) {
    return 'The free version includes only the first $count questions';
  }

  @override
  String get homeUnlockWithPass => 'Unlock by purchasing a pass';

  @override
  String get homeStudyModeSubtitle =>
      'Learn by reading questions, answers and explanations';

  @override
  String get homeAnalyticsSubtitle => 'Check your weak points and progress';

  @override
  String homeMockExamSubtitle(int count, int minutes) {
    return '$count questions · $minutes min · 90% to pass (pass required)';
  }

  @override
  String get homeSignQuizSubtitle =>
      'Guess the name and meaning from the sign image';

  @override
  String get homeTrapQuizSubtitle => 'Focus on practicing trick questions only';

  @override
  String get homeNumberQuizSubtitle =>
      'Practice numbers like speed limits, braking distance and following distance';

  @override
  String get homeNoCategory =>
      'No license category selected. Please choose one in Settings.';

  @override
  String get homeSetCategory => 'Choose Category';

  @override
  String homeStreak(int days) {
    return '$days-day study streak!';
  }

  @override
  String get homeExamDatePrompt =>
      'Set your exam date to get an automatic daily goal';

  @override
  String get homeExamDateSet => 'Set';

  @override
  String get homeQuotaExplanation =>
      'Your daily goal is based on days left and unmastered questions';

  @override
  String get homeExamDatePassed =>
      'Your exam date has passed. Please update your settings';

  @override
  String get homeNoUnmastered => 'You\'ve mastered every question. Keep it up!';

  @override
  String homeDailyGoalPace(int count) {
    return 'Solve $count questions a day to be ready by your exam date';
  }

  @override
  String get homeQuotaCalculating => 'Calculating your daily goal…';

  @override
  String homeExamCountdown(int days) {
    return '$days days until your exam';
  }

  @override
  String dailyQuotaProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String get dailyQuotaAhaTitle => '🎉 3 correct in a row!';

  @override
  String get dailyQuotaContinue => 'Continue';

  @override
  String get dailyQuotaSeeAdFreePlans => 'See ad-free plans';

  @override
  String get dailyQuotaCompleted => 'Practice complete!';

  @override
  String dailyQuotaCorrectCount(int correct, int total) {
    return '$correct / $total correct';
  }

  @override
  String studyModeTitleWithCategory(String category) {
    return 'Study Mode ($category)';
  }

  @override
  String studyModeQuestionList(int count) {
    return 'Questions ($count)';
  }

  @override
  String get studyModeUnmasteredOnly => 'Unmastered only';

  @override
  String get studyModeAllMastered =>
      'You\'ve marked every question as \"Got it\". Great work!';

  @override
  String get studyModeTopicSummaries => 'Summary by Topic';

  @override
  String get analyticsRecalculate => 'Recalculate';

  @override
  String get analyticsCalculating => 'Calculating analytics...';

  @override
  String get analyticsLoadFailed => 'Failed to load analytics data';

  @override
  String get analyticsRetry => 'Try Again';

  @override
  String get analyticsInsufficientData => 'Not enough data to analyze yet';

  @override
  String analyticsRemainingQuestions(int count) {
    return 'Answer $count more questions to see your analytics.\nKeep studying!';
  }

  @override
  String get analyticsByTopic => 'By Topic';

  @override
  String get analyticsByCategory => 'By Category';

  @override
  String get analyticsCategoryNote =>
      '* Some questions belong to multiple categories,\nso totals may differ from the overall question count';

  @override
  String analyticsWeakTop(int count) {
    return 'Top $count Weak Areas';
  }

  @override
  String get analyticsRecommendedReview => 'Recommended Review';

  @override
  String get passRateTitle => 'Pass Rate Analysis';

  @override
  String get passRateNoData => 'Not enough answer data yet';

  @override
  String get passRateNoDataHint =>
      'Answer at least 10 questions to see your analysis.';

  @override
  String get passRatePredictionScore => 'Predicted Pass Score';

  @override
  String get passRateAccuracyStats => 'Accuracy Stats';

  @override
  String get passRateCorrectCount => 'Correct Answers';

  @override
  String get passRateAccuracy => 'Accuracy';

  @override
  String get passRateByCategory => 'Analysis by Category';

  @override
  String get passRateByStage => 'Analysis by Stage';

  @override
  String get passRateByTopic => 'Analysis by Topic';

  @override
  String get passRateAlmostThere => 'You\'re almost ready to pass!';

  @override
  String get passRateOnTrack => 'You\'re on track';

  @override
  String get passRateNeedPractice => 'More practice needed';

  @override
  String get passRateKeepGoing => 'Keep at it, step by step';

  @override
  String get trapDojoTitle => 'Trick Question Dojo';

  @override
  String get trapDojoNotReady =>
      'Trick questions for this category are coming soon';

  @override
  String get trapDojoCompleted => 'Today\'s dojo complete!';

  @override
  String trapDojoBossProgress(int current, int total) {
    return 'Boss $current / $total';
  }

  @override
  String get trapDojoNextBoss => 'Next Boss';

  @override
  String get reviewNotFound => 'No questions to review were found';

  @override
  String reviewHeader(int count) {
    return 'Review only the $count questions you got wrong';
  }
}
