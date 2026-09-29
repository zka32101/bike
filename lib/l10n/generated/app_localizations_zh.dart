// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '原付·摩托车驾照通关！';

  @override
  String get navHome => '首页';

  @override
  String get navSettings => '设置';

  @override
  String get menuAnswerQuestions => '做题';

  @override
  String get menuStudyMode => '学习模式';

  @override
  String get menuAnalytics => '学习分析';

  @override
  String get menuMockExam => '模拟考试';

  @override
  String get menuSignQuiz => '交通标志测验';

  @override
  String get menuTrapQuiz => '陷阱题测验';

  @override
  String get menuNumberQuiz => '数字·距离测验';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsPlan => '套餐';

  @override
  String get settingsHelp => '使用说明';

  @override
  String get commonBack => '返回';

  @override
  String get commonCancel => '取消';

  @override
  String get commonConfirm => '确认';

  @override
  String get commonRetry => '再试一次';

  @override
  String get commonClose => '关闭';

  @override
  String get commonNext => '下一步';

  @override
  String get commonStart => '开始';

  @override
  String get commonHome => '返回首页';

  @override
  String commonLoadError(String error) {
    return '加载失败：$error';
  }

  @override
  String get commonNoQuestionsInCategory => '该类别暂无题目';

  @override
  String get commonCategoryLocked => '购买通行证即可解锁该类别';

  @override
  String get commonViewPlans => '查看套餐';

  @override
  String get commonMarkMastered => '已掌握';

  @override
  String get commonMastered => '已掌握 ✓';

  @override
  String homeAnswerQuestionsWithCategory(String category) {
    return '做题（$category）';
  }

  @override
  String get homeAnswerQuestionsSubtitle => '从未掌握的题目中随机出题';

  @override
  String homeFreePreviewLimit(int count) {
    return '免费版仅可练习前$count道题';
  }

  @override
  String get homeUnlockWithPass => '购买通行证后解锁';

  @override
  String get homeStudyModeSubtitle => '阅读题目、答案和解析进行学习';

  @override
  String get homeAnalyticsSubtitle => '查看薄弱环节和进步情况';

  @override
  String homeMockExamSubtitle(int count, int minutes) {
    return '$count题·$minutes分钟·合格线90%（购买通行证后可用）';
  }

  @override
  String get homeSignQuizSubtitle => '看标志图片，猜名称和含义';

  @override
  String get homeTrapQuizSubtitle => '集中练习陷阱题';

  @override
  String get homeNumberQuizSubtitle => '练习限速、制动距离、车距等数值';

  @override
  String get homeNoCategory => '尚未设置驾照类别，请在设置中选择。';

  @override
  String get homeSetCategory => '设置类别';

  @override
  String homeStreak(int days) {
    return '已连续学习$days天！';
  }

  @override
  String get homeExamDatePrompt => '设置考试日期后将自动倒推计算每日目标';

  @override
  String get homeExamDateSet => '设置';

  @override
  String get homeQuotaExplanation => '根据剩余天数、未掌握题数，并预留重做错题的时间来倒推每日目标';

  @override
  String get homeExamDatePassed => '考试日期已过，请重新设置';

  @override
  String get homeNoUnmastered => '没有未掌握的题目了，继续保持！';

  @override
  String homeDailyGoalPace(int count) {
    return '每天做$count道题即可在考试日前完成';
  }

  @override
  String get homeQuotaCalculating => '正在计算每日目标…';

  @override
  String homeExamCountdown(int days) {
    return '距离考试还有$days天';
  }

  @override
  String dailyQuotaProgress(int current, int total) {
    return '第$current / $total题';
  }

  @override
  String get dailyQuotaAhaTitle => '🎉 答对3题！';

  @override
  String get dailyQuotaContinue => '继续';

  @override
  String get dailyQuotaSeeAdFreePlans => '查看无广告套餐';

  @override
  String get dailyQuotaCompleted => '练习完成！';

  @override
  String dailyQuotaCorrectCount(int correct, int total) {
    return '答对 $correct / $total 题';
  }

  @override
  String studyModeTitleWithCategory(String category) {
    return '学习模式（$category）';
  }

  @override
  String studyModeQuestionList(int count) {
    return '题目列表（$count题）';
  }

  @override
  String get studyModeUnmasteredOnly => '仅未掌握';

  @override
  String get studyModeAllMastered => '所有题目都已标记为\"已掌握\"，辛苦了！';

  @override
  String get studyModeTopicSummaries => '分领域总结';

  @override
  String get analyticsRecalculate => '重新计算';

  @override
  String get analyticsCalculating => '正在计算分析数据...';

  @override
  String get analyticsLoadFailed => '分析数据加载失败';

  @override
  String get analyticsRetry => '请重试';

  @override
  String get analyticsInsufficientData => '分析数据不足';

  @override
  String analyticsRemainingQuestions(int count) {
    return '再做$count道题即可查看分析。\n继续加油学习吧！';
  }

  @override
  String get analyticsByTopic => '按出题领域';

  @override
  String get analyticsByCategory => '按类别';

  @override
  String get analyticsCategoryNote => '※部分题目属于多个类别，\n因此合计可能与总题数不同';

  @override
  String analyticsWeakTop(int count) {
    return '薄弱环节TOP$count';
  }

  @override
  String get analyticsRecommendedReview => '推荐复习';

  @override
  String get passRateTitle => '合格率分析';

  @override
  String get passRateNoData => '答题数据尚不足';

  @override
  String get passRateNoDataHint => '请至少回答10道题后查看分析。';

  @override
  String get passRatePredictionScore => '合格预测分数';

  @override
  String get passRateAccuracyStats => '正确率统计';

  @override
  String get passRateCorrectCount => '答对数';

  @override
  String get passRateAccuracy => '正确率';

  @override
  String get passRateByCategory => '按类别分析';

  @override
  String get passRateByStage => '按阶段分析';

  @override
  String get passRateByTopic => '按领域分析';

  @override
  String get passRateAlmostThere => '离合格只差一步！';

  @override
  String get passRateOnTrack => '进展顺利';

  @override
  String get passRateNeedPractice => '还需要多加练习';

  @override
  String get passRateKeepGoing => '坚持一点一点积累吧';

  @override
  String get trapDojoTitle => '陷阱题道场';

  @override
  String get trapDojoNotReady => '该类别的陷阱题正在准备中';

  @override
  String get trapDojoCompleted => '今天的道场修炼完成！';

  @override
  String trapDojoBossProgress(int current, int total) {
    return 'BOSS $current / $total';
  }

  @override
  String get trapDojoNextBoss => '挑战下一个BOSS';

  @override
  String get reviewNotFound => '未找到需要复习的题目';

  @override
  String reviewHeader(int count) {
    return '仅复习答错的$count道题';
  }
}
