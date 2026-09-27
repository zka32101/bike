import 'package:home_widget/home_widget.dart';

import '../models/question.dart';

/// ホーム画面ウィジェット「今日の1問」の更新を担当する。
///
/// ウィジェット自体（Androidネイティブ側）はロジックを持たず、
/// SharedPreferences 経由で渡された問題文を表示するだけ。日替わりの
/// 選出ロジックはこちら（Flutter側）で行う。
class DailyQuestionWidgetService {
  const DailyQuestionWidgetService();

  static const _widgetDataKey = 'daily_question_text';
  static const _androidProviderName = 'DailyQuestionWidgetProvider';

  /// [questions] の中から「今日の1問」を選んでウィジェットに反映する。
  /// 同じ日は同じ問題が表示され続けるよう、日付を種にして選出する。
  Future<void> updateWithQuestions(List<Question> questions) async {
    if (questions.isEmpty) return;

    final today = DateTime.now();
    final dayIndex = today.year * 372 + today.month * 31 + today.day;
    final question = questions[dayIndex % questions.length];

    await HomeWidget.saveWidgetData<String>(
      _widgetDataKey,
      question.questionText,
    );
    await HomeWidget.updateWidget(androidName: _androidProviderName);
  }
}
