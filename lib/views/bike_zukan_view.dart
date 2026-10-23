import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/license_category.dart';
import '../models/bike_zukan_entry.dart';
import '../viewmodels/providers.dart';

/// 図鑑の解放判定に使う、免許区分ごとの正解済み割合（0〜1）。
final bikeZukanCoverageProvider =
    FutureProvider<Map<LicenseCategory, double>>((ref) async {
  final logs = await ref.watch(answerLogsProvider.future);
  final correctIds = {for (final l in logs) if (l.isCorrect) l.questionId};
  final result = <LicenseCategory, double>{};
  for (final c in kBikeZukanEntries.map((e) => e.category).toSet()) {
    try {
      final qs = await ref
          .read(questionsProvider(QuestionQuery(licenseCategory: c.name)).future);
      final ids = qs.map((q) => q.id).toSet();
      result[c] = zukanCoverage(
        correctDistinct: ids.where(correctIds.contains).length,
        total: ids.length,
      );
    } catch (_) {
      result[c] = 0;
    }
  }
  return result;
});

/// 憧れバイク図鑑。免許区分ごとの学習到達度で解放される（すべて無料）。
class BikeZukanView extends ConsumerWidget {
  const BikeZukanView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coverage = ref.watch(bikeZukanCoverageProvider).valueOrNull ?? const {};
    return Scaffold(
      appBar: AppBar(title: const Text('憧れバイク図鑑')),
      body: BikeZukanBody(coverageByCategory: coverage),
    );
  }
}

/// 図鑑の本体（テストしやすいよう状態を引数で受ける）。
class BikeZukanBody extends StatelessWidget {
  const BikeZukanBody({super.key, required this.coverageByCategory});

  final Map<LicenseCategory, double> coverageByCategory;

  @override
  Widget build(BuildContext context) {
    final unlocked = kBikeZukanEntries
        .where((e) => isZukanUnlocked(e, coverageByCategory[e.category] ?? 0))
        .length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(kZukanNotice, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(kZukanDisclaimer, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Text('解放 $unlocked / ${kBikeZukanEntries.length}',
            key: const Key('zukanCount'),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final e in kBikeZukanEntries)
          _ZukanCard(
            entry: e,
            unlocked: isZukanUnlocked(e, coverageByCategory[e.category] ?? 0),
            coverage: coverageByCategory[e.category] ?? 0,
          ),
      ],
    );
  }
}

class _ZukanCard extends StatelessWidget {
  const _ZukanCard({required this.entry, required this.unlocked, required this.coverage});

  final BikeZukanEntry entry;
  final bool unlocked;
  final double coverage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      key: Key('zukan_${entry.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 72,
                  height: 44,
                  child: CustomPaint(
                    painter: _BikeSilhouettePainter(
                        unlocked ? scheme.primary : scheme.outlineVariant),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(unlocked ? entry.name : '？？？',
                          style: text.titleMedium),
                      Text('${entry.category.label}（目安）', style: text.bodySmall),
                    ],
                  ),
                ),
                Icon(unlocked ? Icons.lock_open : Icons.lock_outline,
                    color: unlocked ? scheme.primary : scheme.outline),
              ],
            ),
            const SizedBox(height: 8),
            if (unlocked) ...[
              _Line('タイプ', entry.type),
              _Line('乗り味の特徴', entry.feel),
              _Line('向いている人', entry.suitedFor),
              _Line('乗る前に知っておくこと', entry.beforeRiding),
              _Line('免許区分（目安）', entry.category.label),
            ] else ...[
              Text(entry.unlockHint, style: text.bodyMedium),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                  value: (coverage / entry.requiredCoverage).clamp(0.0, 1.0)),
            ],
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.body);

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.labelMedium),
          Text(body, style: text.bodyMedium),
        ],
      ),
    );
  }
}

/// 簡易なバイクのシルエット（車輪2つ＋フレーム）。実在車は模していない。
class _BikeSilhouettePainter extends CustomPainter {
  _BikeSilhouettePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final r = size.height * 0.28;
    final y = size.height - r - 2;
    final rear = Offset(size.width * 0.2, y);
    final front = Offset(size.width * 0.8, y);
    canvas.drawCircle(rear, r, p);
    canvas.drawCircle(front, r, p);
    final seat = Offset(size.width * 0.4, size.height * 0.35);
    final bar = Offset(size.width * 0.72, size.height * 0.25);
    canvas.drawLine(rear, seat, p);
    canvas.drawLine(seat, bar, p);
    canvas.drawLine(bar, front, p);
    canvas.drawLine(seat, Offset(size.width * 0.5, y), p);
  }

  @override
  bool shouldRepaint(_BikeSilhouettePainter old) => old.color != color;
}
