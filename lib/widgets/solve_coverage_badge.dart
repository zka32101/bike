import 'package:flutter/material.dart';

import '../data/app_cert.dart';
import '../data/solve_coverage.dart';

/// 「解いた割合」を資格色の濃淡と「12/40問」で示す小さなバッジ。
class SolveCoverageBadge extends StatelessWidget {
  const SolveCoverageBadge({
    super.key,
    required this.coverage,
    required this.name,
  });

  final SolveCoverage coverage;

  /// 読み上げ用の対象名（例: 普通二輪）。
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fill = coverageFill(
      bikeCertColor(theme),
      coverage.level,
      scheme.surface,
    );
    final fg = coverageForeground(
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
