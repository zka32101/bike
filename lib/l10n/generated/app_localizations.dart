import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('pt'),
    Locale('vi'),
    Locale('zh')
  ];

  /// アプリ名（ホーム画面AppBarタイトル等）
  ///
  /// In ja, this message translates to:
  /// **'原付・バイク免許コレ！'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In ja, this message translates to:
  /// **'ホーム'**
  String get navHome;

  /// No description provided for @navSettings.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get navSettings;

  /// No description provided for @menuAnswerQuestions.
  ///
  /// In ja, this message translates to:
  /// **'問題を解く'**
  String get menuAnswerQuestions;

  /// No description provided for @menuStudyMode.
  ///
  /// In ja, this message translates to:
  /// **'学習モード'**
  String get menuStudyMode;

  /// No description provided for @menuAnalytics.
  ///
  /// In ja, this message translates to:
  /// **'学習分析'**
  String get menuAnalytics;

  /// No description provided for @menuMockExam.
  ///
  /// In ja, this message translates to:
  /// **'本番模擬テスト'**
  String get menuMockExam;

  /// No description provided for @menuSignQuiz.
  ///
  /// In ja, this message translates to:
  /// **'標識クイズ'**
  String get menuSignQuiz;

  /// No description provided for @menuTrapQuiz.
  ///
  /// In ja, this message translates to:
  /// **'ヒッかけ問題クイズ'**
  String get menuTrapQuiz;

  /// No description provided for @menuNumberQuiz.
  ///
  /// In ja, this message translates to:
  /// **'数字・距離クイズ'**
  String get menuNumberQuiz;

  /// No description provided for @settingsTitle.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get settingsTitle;

  /// No description provided for @settingsNotifications.
  ///
  /// In ja, this message translates to:
  /// **'通知'**
  String get settingsNotifications;

  /// No description provided for @settingsPlan.
  ///
  /// In ja, this message translates to:
  /// **'プラン'**
  String get settingsPlan;

  /// No description provided for @settingsHelp.
  ///
  /// In ja, this message translates to:
  /// **'アプリの使い方'**
  String get settingsHelp;

  /// No description provided for @commonBack.
  ///
  /// In ja, this message translates to:
  /// **'戻る'**
  String get commonBack;

  /// No description provided for @commonCancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In ja, this message translates to:
  /// **'確認'**
  String get commonConfirm;

  /// No description provided for @commonRetry.
  ///
  /// In ja, this message translates to:
  /// **'もう一度挑戦'**
  String get commonRetry;

  /// No description provided for @commonClose.
  ///
  /// In ja, this message translates to:
  /// **'閉じる'**
  String get commonClose;

  /// No description provided for @commonNext.
  ///
  /// In ja, this message translates to:
  /// **'次へ'**
  String get commonNext;

  /// No description provided for @commonStart.
  ///
  /// In ja, this message translates to:
  /// **'開始'**
  String get commonStart;

  /// No description provided for @commonHome.
  ///
  /// In ja, this message translates to:
  /// **'ホームに戻る'**
  String get commonHome;

  /// No description provided for @commonLoadError.
  ///
  /// In ja, this message translates to:
  /// **'読み込みに失敗しました: {error}'**
  String commonLoadError(String error);

  /// No description provided for @commonNoQuestionsInCategory.
  ///
  /// In ja, this message translates to:
  /// **'この区分の問題がまだありません'**
  String get commonNoQuestionsInCategory;

  /// No description provided for @commonCategoryLocked.
  ///
  /// In ja, this message translates to:
  /// **'この区分はパス購入で解放されます'**
  String get commonCategoryLocked;

  /// No description provided for @commonViewPlans.
  ///
  /// In ja, this message translates to:
  /// **'プランを見る'**
  String get commonViewPlans;

  /// No description provided for @commonMarkMastered.
  ///
  /// In ja, this message translates to:
  /// **'覚えた'**
  String get commonMarkMastered;

  /// No description provided for @commonMastered.
  ///
  /// In ja, this message translates to:
  /// **'覚えた ✓'**
  String get commonMastered;

  /// No description provided for @homeAnswerQuestionsWithCategory.
  ///
  /// In ja, this message translates to:
  /// **'問題を解く（{category}）'**
  String homeAnswerQuestionsWithCategory(String category);

  /// No description provided for @homeAnswerQuestionsSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'未習得問題からランダム出題'**
  String get homeAnswerQuestionsSubtitle;

  /// No description provided for @homeFreePreviewLimit.
  ///
  /// In ja, this message translates to:
  /// **'無料版は最初の{count}問だけ解けます'**
  String homeFreePreviewLimit(int count);

  /// No description provided for @homeUnlockWithPass.
  ///
  /// In ja, this message translates to:
  /// **'パス購入で解放されます'**
  String get homeUnlockWithPass;

  /// No description provided for @homeStudyModeSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'問題・正解・解説を読んで学習'**
  String get homeStudyModeSubtitle;

  /// No description provided for @homeAnalyticsSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'弱点と伸びを確認'**
  String get homeAnalyticsSubtitle;

  /// No description provided for @homeMockExamSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'{count}問・{minutes}分・合格ライン90%（パス購入で利用可）'**
  String homeMockExamSubtitle(int count, int minutes);

  /// No description provided for @homeSignQuizSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'標識の絵を見て名称・意味を当てる'**
  String get homeSignQuizSubtitle;

  /// No description provided for @homeTrapQuizSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'引っかけ問題だけを集中的に練習'**
  String get homeTrapQuizSubtitle;

  /// No description provided for @homeNumberQuizSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'制限速度・制動距離・車間距離などの数値を練習'**
  String get homeNumberQuizSubtitle;

  /// No description provided for @homeNoCategory.
  ///
  /// In ja, this message translates to:
  /// **'免許区分が未設定です。設定から選んでください。'**
  String get homeNoCategory;

  /// No description provided for @homeSetCategory.
  ///
  /// In ja, this message translates to:
  /// **'区分を設定する'**
  String get homeSetCategory;

  /// No description provided for @homeStreak.
  ///
  /// In ja, this message translates to:
  /// **'{days}日連続学習中！'**
  String homeStreak(int days);

  /// No description provided for @homeExamDatePrompt.
  ///
  /// In ja, this message translates to:
  /// **'試験日を登録すると逆算ノルマを自動計算します'**
  String get homeExamDatePrompt;

  /// No description provided for @homeExamDateSet.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get homeExamDateSet;

  /// No description provided for @homeQuotaExplanation.
  ///
  /// In ja, this message translates to:
  /// **'残日数÷未習得問題数でノルマを逆算しています'**
  String get homeQuotaExplanation;

  /// No description provided for @homeExamDatePassed.
  ///
  /// In ja, this message translates to:
  /// **'試験日を過ぎています。設定を見直してください'**
  String get homeExamDatePassed;

  /// No description provided for @homeNoUnmastered.
  ///
  /// In ja, this message translates to:
  /// **'未習得問題はありません。この調子で維持しましょう！'**
  String get homeNoUnmastered;

  /// No description provided for @homeDailyGoalPace.
  ///
  /// In ja, this message translates to:
  /// **'1日{count}問解けば試験日までに間に合うペースです'**
  String homeDailyGoalPace(int count);

  /// No description provided for @homeQuotaCalculating.
  ///
  /// In ja, this message translates to:
  /// **'ノルマを計算しています…'**
  String get homeQuotaCalculating;

  /// No description provided for @homeExamCountdown.
  ///
  /// In ja, this message translates to:
  /// **'試験日まであと{days}日'**
  String homeExamCountdown(int days);

  /// No description provided for @dailyQuotaProgress.
  ///
  /// In ja, this message translates to:
  /// **'{current} / {total}問'**
  String dailyQuotaProgress(int current, int total);

  /// No description provided for @dailyQuotaAhaTitle.
  ///
  /// In ja, this message translates to:
  /// **'🎉 3問正解！'**
  String get dailyQuotaAhaTitle;

  /// No description provided for @dailyQuotaContinue.
  ///
  /// In ja, this message translates to:
  /// **'続ける'**
  String get dailyQuotaContinue;

  /// No description provided for @dailyQuotaSeeAdFreePlans.
  ///
  /// In ja, this message translates to:
  /// **'広告なしで続けるプランを見る'**
  String get dailyQuotaSeeAdFreePlans;

  /// No description provided for @dailyQuotaCompleted.
  ///
  /// In ja, this message translates to:
  /// **'練習完了！'**
  String get dailyQuotaCompleted;

  /// No description provided for @dailyQuotaCorrectCount.
  ///
  /// In ja, this message translates to:
  /// **'{correct} / {total} 問正解'**
  String dailyQuotaCorrectCount(int correct, int total);

  /// No description provided for @studyModeTitleWithCategory.
  ///
  /// In ja, this message translates to:
  /// **'学習モード（{category}）'**
  String studyModeTitleWithCategory(String category);

  /// No description provided for @studyModeQuestionList.
  ///
  /// In ja, this message translates to:
  /// **'問題一覧（{count}問）'**
  String studyModeQuestionList(int count);

  /// No description provided for @studyModeUnmasteredOnly.
  ///
  /// In ja, this message translates to:
  /// **'未習得のみ'**
  String get studyModeUnmasteredOnly;

  /// No description provided for @studyModeAllMastered.
  ///
  /// In ja, this message translates to:
  /// **'すべて「覚えた」にチェック済みです。お疲れさまでした！'**
  String get studyModeAllMastered;

  /// No description provided for @studyModeTopicSummaries.
  ///
  /// In ja, this message translates to:
  /// **'分野別まとめ'**
  String get studyModeTopicSummaries;

  /// No description provided for @analyticsRecalculate.
  ///
  /// In ja, this message translates to:
  /// **'再計算'**
  String get analyticsRecalculate;

  /// No description provided for @analyticsCalculating.
  ///
  /// In ja, this message translates to:
  /// **'分析データを計算中...'**
  String get analyticsCalculating;

  /// No description provided for @analyticsLoadFailed.
  ///
  /// In ja, this message translates to:
  /// **'分析データの読み込みに失敗しました'**
  String get analyticsLoadFailed;

  /// No description provided for @analyticsRetry.
  ///
  /// In ja, this message translates to:
  /// **'再度お試しください'**
  String get analyticsRetry;

  /// No description provided for @analyticsInsufficientData.
  ///
  /// In ja, this message translates to:
  /// **'分析データが不足しています'**
  String get analyticsInsufficientData;

  /// No description provided for @analyticsRemainingQuestions.
  ///
  /// In ja, this message translates to:
  /// **'あと{count}問で分析が表示されます。\nもう少し学習を進めてください！'**
  String analyticsRemainingQuestions(int count);

  /// No description provided for @analyticsByTopic.
  ///
  /// In ja, this message translates to:
  /// **'出題分野別'**
  String get analyticsByTopic;

  /// No description provided for @analyticsByCategory.
  ///
  /// In ja, this message translates to:
  /// **'区分別'**
  String get analyticsByCategory;

  /// No description provided for @analyticsCategoryNote.
  ///
  /// In ja, this message translates to:
  /// **'※複数区分に該当する問題があるため、\n合計は全問題数と異なる場合があります'**
  String get analyticsCategoryNote;

  /// No description provided for @analyticsWeakTop.
  ///
  /// In ja, this message translates to:
  /// **'弱点TOP{count}'**
  String analyticsWeakTop(int count);

  /// No description provided for @analyticsRecommendedReview.
  ///
  /// In ja, this message translates to:
  /// **'おすすめ復習'**
  String get analyticsRecommendedReview;

  /// No description provided for @passRateTitle.
  ///
  /// In ja, this message translates to:
  /// **'合格率分析'**
  String get passRateTitle;

  /// No description provided for @passRateNoData.
  ///
  /// In ja, this message translates to:
  /// **'まだ十分な回答データがありません'**
  String get passRateNoData;

  /// No description provided for @passRateNoDataHint.
  ///
  /// In ja, this message translates to:
  /// **'10問以上回答して、分析を確認してください。'**
  String get passRateNoDataHint;

  /// No description provided for @passRatePredictionScore.
  ///
  /// In ja, this message translates to:
  /// **'合格予測スコア'**
  String get passRatePredictionScore;

  /// No description provided for @passRateAccuracyStats.
  ///
  /// In ja, this message translates to:
  /// **'正答率統計'**
  String get passRateAccuracyStats;

  /// No description provided for @passRateCorrectCount.
  ///
  /// In ja, this message translates to:
  /// **'正答数'**
  String get passRateCorrectCount;

  /// No description provided for @passRateAccuracy.
  ///
  /// In ja, this message translates to:
  /// **'正答率'**
  String get passRateAccuracy;

  /// No description provided for @passRateByCategory.
  ///
  /// In ja, this message translates to:
  /// **'区分別分析'**
  String get passRateByCategory;

  /// No description provided for @passRateByStage.
  ///
  /// In ja, this message translates to:
  /// **'段階別分析'**
  String get passRateByStage;

  /// No description provided for @passRateByTopic.
  ///
  /// In ja, this message translates to:
  /// **'分野別分析'**
  String get passRateByTopic;

  /// No description provided for @passRateAlmostThere.
  ///
  /// In ja, this message translates to:
  /// **'合格まであと一歩！'**
  String get passRateAlmostThere;

  /// No description provided for @passRateOnTrack.
  ///
  /// In ja, this message translates to:
  /// **'順調に進んでいます'**
  String get passRateOnTrack;

  /// No description provided for @passRateNeedPractice.
  ///
  /// In ja, this message translates to:
  /// **'もっと練習が必要です'**
  String get passRateNeedPractice;

  /// No description provided for @passRateKeepGoing.
  ///
  /// In ja, this message translates to:
  /// **'コツコツ続けましょう'**
  String get passRateKeepGoing;

  /// No description provided for @trapDojoTitle.
  ///
  /// In ja, this message translates to:
  /// **'ひっかけ道場'**
  String get trapDojoTitle;

  /// No description provided for @trapDojoNotReady.
  ///
  /// In ja, this message translates to:
  /// **'この区分のひっかけ問題は準備中です'**
  String get trapDojoNotReady;

  /// No description provided for @trapDojoCompleted.
  ///
  /// In ja, this message translates to:
  /// **'今日の道場は完了！'**
  String get trapDojoCompleted;

  /// No description provided for @trapDojoBossProgress.
  ///
  /// In ja, this message translates to:
  /// **'ボス {current} / {total}'**
  String trapDojoBossProgress(int current, int total);

  /// No description provided for @trapDojoNextBoss.
  ///
  /// In ja, this message translates to:
  /// **'次のボスへ'**
  String get trapDojoNextBoss;

  /// No description provided for @reviewNotFound.
  ///
  /// In ja, this message translates to:
  /// **'復習対象の問題が見つかりませんでした'**
  String get reviewNotFound;

  /// No description provided for @reviewHeader.
  ///
  /// In ja, this message translates to:
  /// **'間違えた問題 {count}問だけを復習します'**
  String reviewHeader(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'pt', 'vi', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
