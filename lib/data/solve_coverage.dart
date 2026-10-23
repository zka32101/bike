import 'package:flutter/material.dart';

/// 「解いた割合」の段階（頑張りの量。正誤は問わない）。
enum SolveLevel { none, low, mid, high, complete }

/// 解いた問題数と総数。
@immutable
class SolveCoverage {
  const SolveCoverage({required this.solved, required this.total});

  static const empty = SolveCoverage(solved: 0, total: 0);

  final int solved;
  final int total;

  /// 0.0〜1.0。総数 0 のときは 0。
  double get ratio => solveRatio(solved, total);

  SolveLevel get level => solveLevel(solved, total);

  /// 例: 「12/40問」
  String get label => '$solved/$total問';

  /// 読み上げ用。例: 「40問中12問解答済み、30パーセント」
  String semanticsLabel(String name) =>
      '$name、$total問中$solved問解答済み、${(ratio * 100).floor()}パーセント';

  @override
  bool operator ==(Object other) =>
      other is SolveCoverage && other.solved == solved && other.total == total;

  @override
  int get hashCode => Object.hash(solved, total);
}

/// 解答済み問題数 / 問題数。範囲外は 0〜1 に丸める。
double solveRatio(int solved, int total) {
  if (total <= 0 || solved <= 0) return 0;
  if (solved >= total) return 1;
  return solved / total;
}

/// 0% → none / 〜33% → low / 〜66% → mid / 99%まで → high / 100% → complete
SolveLevel solveLevel(int solved, int total) {
  final r = solveRatio(solved, total);
  if (r <= 0) return SolveLevel.none;
  if (r >= 1) return SolveLevel.complete;
  if (r <= 1 / 3) return SolveLevel.low;
  if (r <= 2 / 3) return SolveLevel.mid;
  return SolveLevel.high;
}

/// 解答済み ID 集合と問題 ID 一覧から集計する（重複回答は 1 問として数える）。
SolveCoverage aggregateCoverage(
  Iterable<String> questionIds,
  Set<String> solvedIds,
) {
  final ids = questionIds.toSet();
  return SolveCoverage(
    solved: ids.where(solvedIds.contains).length,
    total: ids.length,
  );
}

/// 段階ごとの背景の不透明度（資格色を面の色に重ねる）。
const Map<SolveLevel, double> _alpha = {
  SolveLevel.none: 0,
  SolveLevel.low: 0.18,
  SolveLevel.mid: 0.38,
  SolveLevel.high: 0.6,
  SolveLevel.complete: 0.85,
};

/// 資格色 [cert] を [surface] に重ねた背景色。0% は無色（surface のまま）。
Color coverageFill(Color cert, SolveLevel level, Color surface) =>
    Color.alphaBlend(cert.withValues(alpha: _alpha[level]!), surface);

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// [fill] 上で 4.5:1 以上になる文字色。テーマ色を優先し、満たさなければ白黒。
Color coverageForeground(
  Color fill, {
  required Color onSurface,
  required Color surface,
}) {
  for (final c in [onSurface, surface]) {
    if (_contrast(c, fill) >= 4.5) return c;
  }
  return _contrast(Colors.black, fill) >= _contrast(Colors.white, fill)
      ? Colors.black
      : Colors.white;
}
