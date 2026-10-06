import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/license_category.dart';
import '../viewmodels/providers.dart';
import 'exam_date_setting_view.dart';
import 'exam_info_view.dart';
import 'help_view.dart';
import 'license_category_select_view.dart';
import 'mascot_select_view.dart';
import 'paywall_view.dart';

/// 設定(区分管理／通知／サブスク・パス管理)。
class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userControllerProvider);
    final user = userAsync.valueOrNull;
    final categories = user?.licenseCategories ?? const <String>[];

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.checklist),
            title: const Text('免許区分の管理'),
            subtitle: Text(
              categories.isNotEmpty
                  ? categories
                      .map((id) => LicenseCategory.fromId(id).label)
                      .join(' / ')
                  : '未設定',
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LicenseCategorySelectView()),
            ),
          ),
          if (categories.length <= 1)
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('教習段階・試験日'),
              subtitle: Text(
                categories.isEmpty || user?.examDatesByCategory[categories.first] == null
                    ? '未設定'
                    : _formatDate(user!.examDatesByCategory[categories.first]!),
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ExamDateSettingView()),
              ),
            )
          else ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text('教習段階・試験日（区分ごと）', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            for (final categoryId in categories)
              ListTile(
                leading: const Icon(Icons.event),
                title: Text(LicenseCategory.fromId(categoryId).label),
                subtitle: Text(
                  user?.examDatesByCategory[categoryId] == null
                      ? '未設定'
                      : _formatDate(user!.examDatesByCategory[categoryId]!),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ExamDateSettingView(categoryId: categoryId),
                  ),
                ),
              ),
          ],
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('推し（キャラクター）'),
            subtitle: const Text('学習を応援するキャラを選ぶ'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MascotSelectView()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.volume_up),
            title: const Text('効果音'),
            trailing: Consumer(
              builder: (context, ref, _) {
                final isMuted = ref.watch(soundMutedProvider);
                return Switch(
                  value: !isMuted,
                  onChanged: (value) async {
                    ref.read(soundMutedProvider.notifier).state = !value;
                    // サウンドサービスの状態も更新
                    try {
                      final soundService = await ref.read(soundEffectsServiceProvider.future);
                      await soundService.setMuted(!value);
                    } catch (_) {
                      // Ignore errors during sound service update
                    }
                  },
                );
              },
            ),
          ),
          Consumer(
            builder: (context, ref, _) {
              return ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('通知'),
                trailing: Switch(
                  value: true,
                  onChanged: (_) async {
                    // 通知許可プレプロンプト：価値説明 → OS許可リクエスト
                    _showNotificationPrePrompt(context, ref);
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: const Text('プラン'),
            subtitle: Text(_planLabel(ref.watch(entitlementStateProvider).valueOrNull ??
                ref.read(entitlementServiceProvider).state)),
            trailing: ref.watch(adsHiddenProvider)
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PaywallView()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('ご意見・不具合報告'),
            subtitle: const Text('バグ報告や改善要望をお寄せください'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FeedbackFormPage(
                  appName: 'bike-license',
                  appVersion: '1.0.1',
                  userId: user?.uid,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('アプリの使い方'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HelpView()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text('本番試験について'),
            subtitle: const Text('出題数・制限時間・合格ラインなどの詳細'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExamInfoView()),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.year}/${date.month}/${date.day}';

  String _planLabel(EntitlementState state) {
    if (state.hasPremium) {
      final until = state.premiumExpiresAt;
      return until == null ? 'プレミアム' : 'プレミアム（${_formatDate(until.toLocal())}まで）';
    }
    if (state.hasNoAds) return '広告なし';
    return '無料版';
  }

  void _showNotificationPrePrompt(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('毎日の学習をサポート'),
        content: const Text(
          '通知をオンにすると、毎日のノルマ開始時刻に\nリマインダーが届きます。\n\nより効果的に学習を継続できます。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('後で'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // OS許可をリクエスト（復習リマインダー通知の権限と共通）
              final granted =
                  await ref.read(reviewReminderServiceProvider).requestPermission();

              if (granted && dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('通知がオンになりました')),
                );
              }
            },
            child: const Text('有効にする'),
          ),
        ],
      ),
    );
  }
}
