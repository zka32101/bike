package com.yourwish.bikelicense

import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/// ホーム画面ウィジェット「今日の1問」。
///
/// 表示するテキストは Flutter 側（DailyQuestionWidgetService）が
/// HomeWidget.saveWidgetData で書き込んだ SharedPreferences の値を読むだけ。
/// ウィジェット自体はロジックを持たず、タップでアプリを起動するだけの
/// シンプルな作りにしている。
class DailyQuestionWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.daily_question_widget)

            val questionText = widgetData.getString("daily_question_text", null)
                ?: "タップして今日の問題に挑戦しよう"
            views.setTextViewText(R.id.widget_question_text, questionText)

            // タップでアプリを開く
            val pendingIntent =
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            views.setOnClickPendingIntent(R.id.widget_question_text, pendingIntent)
            views.setOnClickPendingIntent(R.id.widget_title, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
