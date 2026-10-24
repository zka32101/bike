import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../views/trap_dojo_view.dart';

/// ホームから「ひっかけ道場」を開く導線カード。
///
/// 広告は一切扱わない（CD-007）。道場画面側が AdBlockingContext.trapDojoBossBattle
/// を保持し、バナーはホーム(BannerPlacement.home)にのみ存在するため、
/// 道場の画面にはバナー/インタースティシャルが出ない。課金状態による出し分けもしない。
class TrapDojoEntryCard extends StatelessWidget {
  const TrapDojoEntryCard({super.key, required this.licenseCategory});

  final String licenseCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const Icon(Icons.sports_martial_arts, size: 32),
        title: Text(l10n.trapDojoTitle),
        subtitle: const Text('間違えやすい数字のひっかけ問題をボス戦形式で反復'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TrapDojoView(licenseCategory: licenseCategory),
          ),
        ),
      ),
    );
  }
}
