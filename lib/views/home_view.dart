import 'package:app_common_kit/app_common_kit.dart' hide adGateProvider; // bike 自前の adGateProvider を使う
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/license_category.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/daily_question_widget_service.dart';
import '../viewmodels/mock_exam_providers.dart';
import '../viewmodels/providers.dart';
import '../widgets/pass_prediction_meter.dart';
import '../widgets/pass_rate_card.dart';
import 'analytics_dashboard_view.dart';
import 'daily_quota_view.dart';
import 'exam_date_setting_view.dart';
import 'mock_exam_view.dart';
import 'settings_view.dart';
import 'number_quiz_view.dart';
import 'paywall_view.dart';
import 'guide_view.dart';
import 'sign_quiz_view.dart';
import 'study_mode_view.dart';
import 'trap_quiz_view.dart';
import '../widgets/oshi_card.dart';
import '../widgets/oshi_readiness_card.dart';

/// ホーム画面：合格予測メーター／今日のノルマ。
/// ホーム→ノルマ→正誤演出＝3タップ以内でAhaに到達する動線の起点。
class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  /// 今日どの免許区分を練習するか。複数区分を選択しているユーザーのみ
  /// ホーム画面上部のチップから切り替え可能。画面遷移をまたいだ永続化は
  /// 行わず、ホームを開くたびに先頭の区分がデフォルトになる。
  String? _selectedCategoryId;

  /// ホームウィジェット更新の重複呼び出しを避けるための直近更新区分。
  String? _widgetUpdatedForCategoryId;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userControllerProvider);
    final scoreAsync = ref.watch(savedPredictionScoreProvider);
    final answerLogsAsync = ref.watch(answerLogsProvider);

    final user = userAsync.valueOrNull;
    final categories = user?.licenseCategories ?? const <String>[];
    if (categories.isNotEmpty &&
        (_selectedCategoryId == null ||
            !categories.contains(_selectedCategoryId))) {
      _selectedCategoryId = categories.first;
    }
    final primaryCategoryId =
        categories.isNotEmpty ? _selectedCategoryId : null;

    // ホーム画面ウィジェット「今日の1問」を、選択中区分の問題が読み込まれ
    // 次第（区分切り替え時も含め）更新する。ref.listenは登録時点で既に
    // 解決済みの値には反応しないため、現在値を直接読んで都度更新する
    // （区分が変わらない限り同じ問題一覧なので、呼び直しても実質no-op）。
    if (primaryCategoryId != null) {
      final questionsForWidget = ref
          .watch(questionsProvider(QuestionQuery(licenseCategory: primaryCategoryId)))
          .valueOrNull;
      if (questionsForWidget != null &&
          _widgetUpdatedForCategoryId != primaryCategoryId) {
        _widgetUpdatedForCategoryId = primaryCategoryId;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          DailyQuestionWidgetService().updateWithQuestions(questionsForWidget);
        });
      }
    }

    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsView()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: userAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(savedPredictionScoreProvider);
                ref.invalidate(answerLogsProvider);
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  if (primaryCategoryId == null)
                    _NoCategoryCard(context: context)
                  else ...[
                    if (categories.length > 1) ...[
                      _CategorySwitcher(
                        categories: categories,
                        selectedCategoryId: primaryCategoryId,
                        onSelected: (categoryId) {
                          setState(() => _selectedCategoryId = categoryId);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    if ((user?.streakCount ?? 0) > 0) ...[
                      _StreakBadge(streakCount: user!.streakCount),
                      const SizedBox(height: 16),
                    ],
                    OshiCard(
                      streakDays: user?.streakCount ?? 0,
                      lastStudyDate: user?.lastStudyDate,
                      examDate: user?.examDatesByCategory[primaryCategoryId],
                      questions: ref
                              .watch(questionsProvider(
                                  QuestionQuery(licenseCategory: primaryCategoryId)))
                              .valueOrNull ??
                          const [],
                    ),
                    const SizedBox(height: 16),
                    if (primaryCategoryId != null) ...[
                      OshiReadinessCard(
                        licenseCategory: primaryCategoryId,
                        questions: ref
                                .watch(questionsProvider(
                                    QuestionQuery(licenseCategory: primaryCategoryId)))
                                .valueOrNull ??
                            const [],
                      ),
                      const SizedBox(height: 16),
                    ],
                    PassPredictionMeter(
                      score: scoreAsync.valueOrNull,
                      answeredCount: answerLogsAsync.valueOrNull?.length ?? 0,
                    ),
                    const SizedBox(height: 16),
                    const PassRateCard(),
                    const SizedBox(height: 16),
                    _ExamCountdownCard(
                      examDate: user?.examDatesByCategory[primaryCategoryId],
                      licenseCategoryId: primaryCategoryId,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.checklist_rtl, size: 32),
                        title: Text(
                          l10n.homeAnswerQuestionsWithCategory(
                            LicenseCategory.fromId(primaryCategoryId).label,
                          ),
                        ),
                        subtitle: Text(l10n.homeAnswerQuestionsSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                DailyQuotaView(licenseCategory: primaryCategoryId),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.menu_book, size: 32),
                        title: Text(l10n.menuStudyMode),
                        subtitle: Text(l10n.homeStudyModeSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                StudyModeView(licenseCategory: primaryCategoryId),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.insights, size: 32),
                        title: Text(l10n.menuAnalytics),
                        subtitle: Text(l10n.homeAnalyticsSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AnalyticsDashboardView(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.timer, size: 32),
                        title: Text(l10n.menuMockExam),
                        subtitle: Text(
                          l10n.homeMockExamSubtitle(
                            mockExamQuestionCountFor(primaryCategoryId),
                            mockExamTimeLimitSecondsFor(primaryCategoryId) ~/ 60,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                MockExamView(licenseCategory: primaryCategoryId),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.signpost, size: 32),
                        title: Text(l10n.menuSignQuiz),
                        subtitle: Text(l10n.homeSignQuizSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SignQuizView(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.lightbulb_outline, size: 32),
                        title: const Text('役立つ情報'),
                        subtitle: const Text('黄色い線・二段階右折など、わかりにくい決まりを図で解説'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const GuideListView(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.warning_amber, size: 32),
                        title: Text(l10n.menuTrapQuiz),
                        subtitle: Text(l10n.homeTrapQuizSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TrapQuizView(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.pin, size: 32),
                        title: Text(l10n.menuNumberQuiz),
                        subtitle: Text(l10n.homeNumberQuizSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NumberQuizView(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
      ),
      bottomNavigationBar: ref.watch(adsHiddenProvider)
          ? null
          : SafeArea(
              child: ref.read(adGateProvider)?.banner(BannerPlacement.home) ??
                  const SizedBox.shrink(),
            ),
    );
  }
}

/// 複数の免許区分を選択しているユーザー向けの「今日はどの区分を練習するか」
/// 切り替えチップ。1区分のみのユーザーには表示されない（呼び出し側で制御）。
class _CategorySwitcher extends StatelessWidget {
  const _CategorySwitcher({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<String> categories;
  final String? selectedCategoryId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final categoryId in categories)
          ChoiceChip(
            label: Text(LicenseCategory.fromId(categoryId).label),
            selected: categoryId == selectedCategoryId,
            onSelected: (_) => onSelected(categoryId),
          ),
      ],
    );
  }
}

class _NoCategoryCard extends StatelessWidget {
  const _NoCategoryCard({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(AppLocalizations.of(context).homeNoCategory),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsView()),
              ),
              child: Text(AppLocalizations.of(context).homeSetCategory),
            ),
          ],
        ),
      ),
    );
  }
}

/// 連続学習日数（ストリーク）バッジ。streakCount が0のときは呼び出し側で
/// 非表示にするため、ここでは1以上のみ想定する。
class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streakCount});
  final int streakCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.deepOrange),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context).homeStreak(streakCount),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamCountdownCard extends ConsumerWidget {
  const _ExamCountdownCard({
    required this.examDate,
    required this.licenseCategoryId,
  });
  final DateTime? examDate;
  final String? licenseCategoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (examDate == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.event_available),
          title: Text(AppLocalizations.of(context).homeExamDatePrompt),
          trailing: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ExamDateSettingView(),
              ),
            ),
            child: Text(AppLocalizations.of(context).homeExamDateSet),
          ),
        ),
      );
    }

    final categoryId = licenseCategoryId;
    final planAsync = categoryId == null
        ? null
        : ref.watch(examPlanProvider(categoryId));

    final l10n = AppLocalizations.of(context);
    final subtitle = switch (planAsync) {
      null => Text(l10n.homeQuotaExplanation),
      AsyncData(:final value) when value == null =>
        Text(l10n.homeExamDatePassed),
      AsyncData(:final value) when value!.unmasteredCount == 0 =>
        Text(l10n.homeNoUnmastered),
      AsyncData(:final value) =>
        Text(l10n.homeDailyGoalPace(value!.dailyGoal)),
      AsyncError() => Text(l10n.homeQuotaExplanation),
      _ => Text(l10n.homeQuotaCalculating),
    };

    // 試験日のカウントダウンは無料。試験日までの学習計画（1日の目安）はプレミアム。
    final isPremium = ref.watch(hasPremiumProvider);
    final daysLeft = examDate!.difference(DateTime.now()).inDays;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.event_available),
        title: Text(l10n.homeExamCountdown(daysLeft)),
        subtitle: isPremium ? subtitle : const Text('試験日までの学習計画はプレミアムで見られます'),
        trailing: isPremium ? null : const Icon(Icons.lock_outline),
        onTap: isPremium
            ? null
            : () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PaywallView()),
                ),
      ),
    );
  }
}
