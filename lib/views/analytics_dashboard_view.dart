import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/analytics_events.dart';
import '../core/constants/license_category.dart';
import '../core/constants/question_topic.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/analytics_snapshot.dart';
import '../viewmodels/analytics_limits.dart';
import '../viewmodels/providers.dart';
import '../widgets/analytics/accuracy_bar_list.dart';
import '../widgets/analytics/overall_summary_card.dart';
import '../widgets/analytics/period_filter_selector.dart';
import 'paywall_view.dart';

/// 学習分析ダッシュボード
/// ユーザーの全体成績、ステージ別・カテゴリ別パフォーマンス、
/// 弱点分析、復習推奨を一つの画面で確認できます。
class AnalyticsDashboardView extends ConsumerWidget {
  const AnalyticsDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(analyticsSnapshotProvider);
    final isLoading = snapshot.isLoading;
    final hasError = snapshot.isRefreshing || snapshot.hasError;

    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.menuAnalytics),
        actions: [
          // 再読み込みボタン
          if (!isLoading)
            IconButton(
              onPressed: () {
                ref
                    .read(analyticsSnapshotProvider.notifier)
                    .refresh(force: true);
              },
              icon: const Icon(Icons.refresh),
              tooltip: l10n.analyticsRecalculate,
            ),
        ],
      ),
      body: snapshot.when(
        data: (data) => _buildContent(context, ref, data),
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.analyticsCalculating),
            ],
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(l10n.analyticsLoadFailed),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(analyticsSnapshotProvider);
                  },
                  child: Text(l10n.analyticsRetry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AnalyticsSnapshot data,
  ) {
    // 分析ダッシュボード表示イベントを記録
    Future.microtask(() {
      final user = ref.read(userControllerProvider).valueOrNull;
      final categories =
          user?.licenseCategories.join(',') ?? 'unknown';
      ref.read(analyticsServiceProvider).logEvent(
            AnalyticsEvents.analyticsDashboardOpened,
            parameters: {'license_category': categories},
          );
    });

    final l10n = AppLocalizations.of(context);

    // 無料は苦手な上位3分野まで。プレミアムは全分野（FreeTierLimits）。
    final topicLimit = ref
        .watch(freeTierLimitsProvider)
        .weakTopicLimit(isPremium: ref.watch(hasPremiumProvider));
    final shownTopics = visibleTopics(data.topics, topicLimit);

    // データ不足の場合の案内
    if (data.overall.attempts < 10) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.analyticsInsufficientData,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.analyticsRemainingQuestions(10 - data.overall.attempts),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: Text(l10n.commonHome),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(analyticsSnapshotProvider.notifier)
            .refresh(force: true);
      },
      child: CustomScrollView(
        slivers: [
          // 期間フィルター
          SliverToBoxAdapter(
            child: PeriodFilterSelector(),
          ),

          // 全体統計カード
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: OverallSummaryCard(snapshot: data),
            ),
          ),

          // 出題分野別パフォーマンス
          // （教習段階「第一段階」等での区分はデータが薄く実用性が低いため、
          // 標識・法規・運転操作などの出題分野別で表示する）
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.analyticsByTopic,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  AccuracyBarList(
                    items: shownTopics
                        .map((t) => AccuracyBarItem(
                          label: QuestionTopic.labelFor(t.categoryId),
                          accuracy: t.stat.accuracy,
                          attempts: t.stat.attempts,
                          correctCount: t.stat.correctCount,
                        ))
                        .toList(),
                  ),
                  if (topicLimit != null)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.lock_outline),
                        title: Text('苦手な上位$topicLimit分野を表示中'),
                        subtitle: const Text('全分野の分析はプレミアムで見られます'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PaywallView()),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(top: 20)),

          // カテゴリ別パフォーマンス
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.analyticsByCategory,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        l10n.analyticsCategoryNote,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AccuracyBarList(
                    items: data.categories
                        .map((c) => AccuracyBarItem(
                          label: LicenseCategory.fromId(c.categoryId).label,
                          accuracy: c.stat.accuracy,
                          attempts: c.stat.attempts,
                          correctCount: c.stat.correctCount,
                        ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          // 弱点TOP5・おすすめ復習は判定条件が厳しく実用的な精度で
          // 表示できないケースが多かったため無効化（2026-09-29）。
          // データ自体（data.weakAreas / data.recommendations）は
          // StudyAnalyticsService側にまだ残っており、判定ロジックの
          // 精度を改善できたら表示を復活させる想定。

          // 下部余白
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }
}
