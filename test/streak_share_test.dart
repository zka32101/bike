import 'package:bike_license_kore/widgets/streak_share_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ukalab_core/ui.dart' hide SolveCoverageBadge;

const _forbidden = ['合格保証', '公式', '絶対', '本試験相当', '過去問'];

void main() {
  final now = DateTime(2026, 10, 25);

  test('共有データに禁止語・個人情報の欄がない', () {
    final d = streakShareData(7, now);
    final all = [d.certLabel, d.headline, d.metricText, d.dateLabel].join('|');
    for (final w in _forbidden) {
      expect(all.contains(w), isFalse, reason: w);
    }
    expect(d.headline, '7日連続で学習中');
    expect(d.metricText, '連続7日');
    expect(d.dateLabel, '2026年10月25日');
  });

  testWidgets('ダイアログにカードとシェアボタンが出る（個人情報の注記つき）', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showStreakShareDialog(context, streakDays: 3, now: now),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(AchievementShareCard), findsOneWidget);
    expect(find.text('3日連続で学習中'), findsOneWidget);
    expect(find.text('シェア'), findsOneWidget);
    expect(find.text('名前などの個人情報は入りません。'), findsOneWidget);
  });
}
