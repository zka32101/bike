import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mascot.dart';
import '../services/mascot_service.dart';

/// 推しの選択・表示設定。無料で全員選べる。選択は他のうかラボアプリと共通。
class MascotSelectView extends ConsumerWidget {
  const MascotSelectView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(mascotSettingsProvider);
    final n = ref.read(mascotSettingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('推しの設定')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final m in Mascot.values)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: s.selected == m
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ListTile(
                leading: ClipOval(
                  child: Image.asset(m.iconAsset, width: 48, height: 48,
                      errorBuilder: (_, __, ___) => const Icon(Icons.pets)),
                ),
                title: Text(m.displayName),
                subtitle: Text(m.role),
                trailing: s.selected == m ? const Icon(Icons.check_circle) : null,
                onTap: () => n.select(m),
              ),
            ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('ホームに推しを表示'),
            value: s.visible,
            onChanged: n.setVisible,
          ),
          SwitchListTile(
            title: const Text('バイク免許の衣装（ヘルメット）'),
            subtitle: const Text('オフにすると私服で表示します'),
            value: s.costume,
            onChanged: n.setCostume,
          ),
          if (s.selected != null)
            TextButton(
              onPressed: () => n.select(null),
              child: const Text('推しを外す'),
            ),
        ],
      ),
    );
  }
}
