import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/license_category.dart';
import '../viewmodels/providers.dart';
import '../viewmodels/solve_coverage_providers.dart';
import '../widgets/solve_coverage_badge.dart';
import 'exam_date_setting_view.dart';

/// 免許区分選択（複数選択可）。
///
/// 【差別化の重心】表示順は普通二輪・大型二輪を先頭に置き、原付は
/// 入口として残しつつ主役にしない（企画設計書 v1.1）。
/// 区分の選択自体は制限しない。全区分の全問題と解説は無料で使える（購入は広告の非表示とプレミアム機能のため）。
class LicenseCategorySelectView extends ConsumerStatefulWidget {
  const LicenseCategorySelectView({super.key});

  @override
  ConsumerState<LicenseCategorySelectView> createState() =>
      _LicenseCategorySelectViewState();
}

class _LicenseCategorySelectViewState
    extends ConsumerState<LicenseCategorySelectView> {
  final Set<LicenseCategory> _selected = {};
  bool _selectionInitialized = false;

  static const _displayOrder = [
    LicenseCategory.futsuuNirin,
    LicenseCategory.ogataNirin,
    LicenseCategory.atGentei,
    LicenseCategory.kogataGentsukiNirin,
    LicenseCategory.gentsuki,
  ];

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userControllerProvider);
    final user = userAsync.valueOrNull;

    // 設定画面から再度この画面を開いたとき、既存の選択状態を引き継ぐ。
    // これをしないと、ここで保存した時点で未チェックの既存区分が
    // 選択解除されたものとして扱われ、既に選んでいた区分が消えてしまう。
    if (!_selectionInitialized && user != null) {
      _selectionInitialized = true;
      for (final id in user.licenseCategories) {
        final category = LicenseCategory.fromId(id);
        _selected.add(category);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('免許区分を選ぶ')),
      body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今、対策したい免許区分を選んでください（複数選択可）',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  for (final category in _displayOrder)
                    _CategoryTile(
                      category: category,
                      selected: _selected.contains(category),
                      onChanged: (checked) {
                        setState(() {
                          if (checked) {
                            _selected.add(category);
                          } else {
                            _selected.remove(category);
                          }
                        });
                      },
                    ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected.isEmpty
                    ? null
                    : () async {
                        await ref
                            .read(userControllerProvider.notifier)
                            .setLicenseCategories(
                              _selected.map((e) => e.name).toList(),
                            );
                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ExamDateSettingView(
                                isOnboardingFlow: true,
                              ),
                            ),
                          );
                        }
                      },
                child: const Text('次へ'),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onChanged,
  });

  final LicenseCategory category;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coverage = ref.watch(categoryCoverageProvider(category.name)).valueOrNull;
    return Card(
      child: CheckboxListTile(
        value: selected,
        onChanged: (v) => onChanged(v ?? false),
        title: Text(category.label),
        secondary: coverage == null || coverage.total == 0
            ? null
            : SolveCoverageBadge(coverage: coverage, name: category.label),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
