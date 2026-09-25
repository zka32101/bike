import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/license_category.dart';
import '../viewmodels/providers.dart';
import '../widgets/pass_prediction_meter.dart';
import '../widgets/pass_rate_card.dart';
import 'analytics_dashboard_view.dart';
import 'daily_quota_view.dart';
import 'exam_date_setting_view.dart';
import 'settings_view.dart';
import 'study_mode_view.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('原付・バイク免許コレ！'),
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
                    PassPredictionMeter(
                      score: scoreAsync.valueOrNull,
                      answeredCount: answerLogsAsync.valueOrNull?.length ?? 0,
                    ),
                    const SizedBox(height: 16),
                    const PassRateCard(),
                    const SizedBox(height: 16),
                    _ExamCountdownCard(
                      examDate: user?.examDatesByCategory[primaryCategoryId],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.checklist_rtl, size: 32),
                        title: Text(
                          '問題を解く（${LicenseCategory.fromId(primaryCategoryId).label}）',
                        ),
                        subtitle: Text(
                          (user?.hasAccessToCategory(primaryCategoryId) ?? false)
                              ? '未習得問題からランダム出題'
                              : primaryCategoryId == LicenseCategory.gentsuki.name
                                  ? '無料版は最初の$freeGentsukiPreviewCount問だけ解けます'
                                  : 'パス購入で解放されます',
                        ),
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
                        title: const Text('学習モード'),
                        subtitle: const Text('問題・正解・解説を読んで学習'),
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
                        title: const Text('学習分析'),
                        subtitle: const Text('弱点と伸びを確認'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AnalyticsDashboardView(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
            const Text('免許区分が未設定です。設定から選んでください。'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsView()),
              ),
              child: const Text('区分を設定する'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamCountdownCard extends StatelessWidget {
  const _ExamCountdownCard({required this.examDate});
  final DateTime? examDate;

  @override
  Widget build(BuildContext context) {
    if (examDate == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.event_available),
          title: const Text('試験日を登録すると逆算ノルマを自動計算します'),
          trailing: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ExamDateSettingView(),
              ),
            ),
            child: const Text('設定'),
          ),
        ),
      );
    }
    final daysLeft = examDate!.difference(DateTime.now()).inDays;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.event_available),
        title: Text('試験日まであと$daysLeft日'),
        subtitle: const Text('残日数÷未習得問題数でノルマを逆算しています'),
      ),
    );
  }
}
