import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ukalab_core/ui.dart' hide SolveCoverageBadge;
import 'package:ukalab_core/ukalab_core.dart' show SolveCoverage;

import '../data/app_cert.dart';

/// 「解いた割合」を資格色の濃淡と「12/40問」で示す小さなバッジ。
///
/// 集計（[SolveCoverage]）と色の導出はコア（ukalab_core v0.84.0〜）を使う。
/// コアにも同名の `SolveCoverageBadge` があるが、枠線が資格色ではなくテーマの
/// outline のため、見た目を変えないようアプリ側の薄い表示ラッパーを残している。
class SolveCoverageBadge extends ConsumerWidget {
  const SolveCoverageBadge({
    super.key,
    required this.coverage,
    required this.name,
  });

  final SolveCoverage coverage;

  /// 読み上げ用の対象名（例: 普通二輪）。
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fill = solveCoverageFill(
      ref.watch(appCertProvider),
      theme.brightness,
      coverage.level,
      scheme.surface,
    );
    final fg = solveCoverageForeground(
      fill,
      onSurface: scheme.onSurface,
      surface: scheme.surface,
    );
    return Semantics(
      label: coverage.semanticsLabel(name),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outline),
        ),
        child: Text(
          coverage.label,
          style: theme.textTheme.labelMedium?.copyWith(color: fg),
        ),
      ),
    );
  }
}
