import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/license_category.dart';
import '../models/user.dart';
import '../viewmodels/providers.dart';
import 'home_view.dart';

/// 教習段階入力(任意・スキップ可) ＋ 免許区分ごとの試験日設定。
/// 逆算ノルマ = 残日数 ÷ 未習得問題数（実装は HomeView 側の集計で行う）。
class ExamDateSettingView extends ConsumerStatefulWidget {
  const ExamDateSettingView({
    super.key,
    this.isOnboardingFlow = false,
    this.categoryId,
  });

  /// 初回オンボーディング経由かどうか（trueならHomeへ、falseなら戻るだけ）。
  final bool isOnboardingFlow;

  /// 編集対象を1区分に絞る場合に指定（設定画面からの個別編集用）。
  /// null の場合はユーザーが選択している全区分をまとめて表示する。
  final String? categoryId;

  @override
  ConsumerState<ExamDateSettingView> createState() =>
      _ExamDateSettingViewState();
}

class _ExamDateSettingViewState extends ConsumerState<ExamDateSettingView> {
  String? _trainingStage;
  final Map<String, DateTime?> _examDates = {};
  bool _initialized = false;

  static const _stages = ['第一段階', '第二段階', '卒業検定前', '未定'];

  void _ensureInitialized(AppUser user) {
    if (_initialized) return;
    _initialized = true;
    _trainingStage = user.trainingStage;
    for (final categoryId in _targetCategories(user)) {
      _examDates[categoryId] = user.examDatesByCategory[categoryId];
    }
  }

  List<String> _targetCategories(AppUser user) {
    if (widget.categoryId != null) return [widget.categoryId!];
    return user.licenseCategories;
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userControllerProvider);
    final user = userAsync.valueOrNull;
    if (user != null) _ensureInitialized(user);
    final categories = user != null ? _targetCategories(user) : const <String>[];

    return Scaffold(
      appBar: AppBar(title: const Text('教習の状況（任意）')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('今の教習段階', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final stage in _stages)
                  ChoiceChip(
                    label: Text(stage),
                    selected: _trainingStage == stage,
                    onSelected: (_) => setState(() => _trainingStage = stage),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '試験・検定日（任意・区分ごとに設定可）',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  for (final categoryId in categories)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.event),
                        label: Text(
                          '${LicenseCategory.fromId(categoryId).label}: '
                          '${_examDates[categoryId] == null ? '日付を選ぶ' : _formatDate(_examDates[categoryId]!)}',
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 14)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() => _examDates[categoryId] = picked);
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final notifier = ref.read(userControllerProvider.notifier);
                  if (_trainingStage != null) {
                    await notifier.setTrainingStage(_trainingStage);
                  }
                  for (final categoryId in categories) {
                    await notifier.setExamDateForCategory(
                      categoryId,
                      _examDates[categoryId],
                    );
                  }
                  if (!context.mounted) return;
                  if (widget.isOnboardingFlow) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeView()),
                      (route) => false,
                    );
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(widget.isOnboardingFlow ? '保存してホームへ' : '保存'),
              ),
            ),
            if (widget.isOnboardingFlow)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeView()),
                    (route) => false,
                  );
                },
                child: const Text('あとで設定する'),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.year}/${date.month}/${date.day}';
}
