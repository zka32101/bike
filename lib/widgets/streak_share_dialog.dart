import 'package:flutter/material.dart';
import 'package:ukalab_core/ui.dart';

import '../data/app_cert.dart';

/// 連続学習の「達成」共有カードに載せる内容を作る。
///
/// 個人情報（名前・ID・メール）は一切入れない。資格名・連続日数・日付だけ。
/// 合格を示す表現や、公式・過去問などを思わせる表現は使わない（事実だけを書く）。
AchievementShareData streakShareData(int streakDays, DateTime now) {
  return AchievementShareData(
    certLabel: kAppCert.label,
    headline: '$streakDays日連続で学習中',
    metricText: '連続$streakDays日',
    dateLabel: '${now.year}年${now.month}月${now.day}日',
  );
}

/// ホームの連続学習バッジから開く、達成シェアのダイアログ。
///
/// プレビュー（[AchievementShareCard]）と「シェア」ボタンだけの画面で、広告は出さない。
Future<void> showStreakShareDialog(
  BuildContext context, {
  required int streakDays,
  DateTime? now,
  FileSaver? saver,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => StreakShareDialog(
      streakDays: streakDays,
      now: now ?? DateTime.now(),
      saver: saver,
    ),
  );
}

class StreakShareDialog extends StatefulWidget {
  const StreakShareDialog({
    super.key,
    required this.streakDays,
    required this.now,
    this.saver,
  });

  final int streakDays;
  final DateTime now;

  /// テスト用。省略時はコアの既定（OS の共有シート）。
  final FileSaver? saver;

  @override
  State<StreakShareDialog> createState() => _StreakShareDialogState();
}

class _StreakShareDialogState extends State<StreakShareDialog> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _busy = false;

  Future<void> _share() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final box = context.findRenderObject() as RenderBox?;
      final origin =
          box != null && box.hasSize ? box.localToGlobal(Offset.zero) & box.size : null;
      await shareAchievementCard(
        _boundaryKey,
        fileName: 'bike_license_streak.png',
        saver: widget.saver,
        sharePositionOrigin: origin,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('シェアできませんでした')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('連続学習をシェア'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RepaintBoundary(
              key: _boundaryKey,
              child: AchievementShareCard(
                data: streakShareData(widget.streakDays, widget.now),
                cert: kAppCert,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '名前などの個人情報は入りません。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
        FilledButton.icon(
          onPressed: _busy ? null : _share,
          icon: const Icon(Icons.ios_share),
          label: const Text('シェア'),
        ),
      ],
    );
  }
}
