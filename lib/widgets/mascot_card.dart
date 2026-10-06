import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mascot.dart';
import '../services/mascot_service.dart';
import '../views/mascot_select_view.dart';

/// ホーム上部の「推し」カード。励ましの一言と成長Lvを表示する。
/// 未選択のときは選択への入口を出す。非表示設定のときは何も出さない。
class MascotCard extends ConsumerStatefulWidget {
  const MascotCard({super.key, required this.score, required this.answeredCount});

  final double? score;
  final int answeredCount;

  @override
  ConsumerState<MascotCard> createState() => _MascotCardState();
}

class _MascotCardState extends ConsumerState<MascotCard> {
  int _tap = 0;
  int _reflected = 0;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(mascotSettingsProvider);
    if (!s.visible) return const SizedBox.shrink();
    final m = s.selected;
    if (m == null) return _picker(context);

    final earned = mascotLevelFromScore(widget.score, widget.answeredCount);
    if (earned > s.maxLevel && earned != _reflected) {
      _reflected = earned;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(mascotSettingsProvider.notifier).reachLevel(earned);
      });
    }
    final level = earned > s.maxLevel ? earned : s.maxLevel;
    final passed = level >= 5 && (widget.score ?? 0) >= 90;
    final joy = _tap.isOdd && !s.costume;
    final asset = joy
        ? m.joyAsset(level)
        : m.imageAsset(level, costume: s.costume, passed: passed);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _tap++),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 84,
                height: 128,
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  semanticLabel: m.displayName,
                  errorBuilder: (_, __, ___) => const Icon(Icons.pets, size: 48),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${m.displayName}  Lv$level',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(mascotLine(m, level, salt: _tap ~/ 2)),
                  ],
                ),
              ),
              IconButton(
                tooltip: '推しを変更',
                icon: const Icon(Icons.swap_horiz),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MascotSelectView()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _picker(BuildContext context) => Card(
        child: ListTile(
          leading: const Icon(Icons.favorite_border),
          title: const Text('推しを選ぼう'),
          subtitle: const Text('学習を応援してくれるキャラクターを選べます'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MascotSelectView()),
          ),
        ),
      );
}
