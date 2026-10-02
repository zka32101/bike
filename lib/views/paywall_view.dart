import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart' show FreeTierLimits;

import '../core/constants/analytics_events.dart';
import '../viewmodels/providers.dart';

/// 購入できる商品（RevenueCat の現在の Offering）。取得できない場合は空。
final _offersProvider = FutureProvider.autoDispose<List<EntitlementOffer>>(
  (ref) => ref.watch(entitlementServiceProvider).offers(),
);

/// ペイウォール（うかラボ共通のプラン）。
/// - 広告なし（noads）：買い切り。広告が表示されなくなる
/// - プレミアム（premium）：30日／90日／買い切り。広告が表示されなくなる
///
/// 価格・商品名は RevenueCat の Offering から取得し、コードに埋め込まない。
/// 全問題・全解説は無料（購入は広告の非表示などのため）。
class PaywallView extends ConsumerWidget {
  const PaywallView({super.key, this.categoryId});

  /// 旧パス方式（区分ごとの解放）の名残。現在は全区分が無料のため使用しない。
  /// ロック画面（到達しない）からの遷移コードが渡すだけで、値は無視する。
  final String? categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(_offersProvider);
    final state = ref.watch(entitlementStateProvider).valueOrNull ??
        ref.read(entitlementServiceProvider).state;

    return Scaffold(
      appBar: AppBar(title: const Text('プランを選ぶ')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '広告なしで学習できます',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'すべての問題と解説は無料で使えます。',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const _PlanComparison(),
            if (state.adsHidden) ...[
              const SizedBox(height: 16),
              _CurrentPlan(state: state),
            ],
            const SizedBox(height: 24),
            offers.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const _Unavailable(),
              data: (list) => list.isEmpty
                  ? const _Unavailable()
                  : Column(
                      children: [
                        for (final offer in list)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PlanCard(
                              offer: offer,
                              onTap: () => _purchase(context, ref, offer),
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _restore(context, ref),
              child: const Text('購入を復元'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchase(
    BuildContext context,
    WidgetRef ref,
    EntitlementOffer offer,
  ) async {
    final outcome =
        await ref.read(entitlementServiceProvider).purchaseOffer(offer.id);

    if (outcome == PurchaseOutcome.success) {
      await ref.read(analyticsServiceProvider).logEvent(
        AnalyticsEvents.paywallConverted,
        parameters: {'plan': offer.productId},
      );
    }
    if (!context.mounted) return;

    switch (outcome) {
      case PurchaseOutcome.success:
        Navigator.of(context).pop();
      case PurchaseOutcome.cancelled:
        break; // ユーザーが自分で閉じたので何も出さない。
      case PurchaseOutcome.blockedByGate:
      case PurchaseOutcome.failed:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('購入できませんでした。時間をおいてもう一度お試しください')),
        );
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final state = await ref.read(entitlementServiceProvider).restore();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.adsHidden ? '購入を復元しました' : '復元できる購入が見つかりませんでした',
        ),
      ),
    );
  }
}

/// 広告なし／プレミアムでできること（FreeTierLimits の無料枠と対応）。
class _PlanComparison extends StatelessWidget {
  const _PlanComparison();

  @override
  Widget build(BuildContext context) {
    const limits = FreeTierLimits.standard;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('広告なし', style: Theme.of(context).textTheme.titleSmall),
            const Text('広告が表示されなくなります'),
            const SizedBox(height: 12),
            Text('プレミアム', style: Theme.of(context).textTheme.titleSmall),
            const Text('広告なし に加えて'),
            Text('・模擬テストが回数無制限（無料は月${limits.mockExamsPerMonth}回）'),
            const Text('・模擬テストの分野別得点と「合格まであと◯問」'),
            Text('・全分野の苦手分析（無料は上位${limits.weakTopicsShown}分野）'),
            const Text('・試験日までの学習計画（1日の目安）'),
          ],
        ),
      ),
    );
  }
}

class _CurrentPlan extends StatelessWidget {
  const _CurrentPlan({required this.state});

  final EntitlementState state;

  @override
  Widget build(BuildContext context) {
    final until = state.premiumExpiresAt;
    final label = state.hasPremium
        ? (until == null
            ? 'プレミアムをご利用中です'
            : 'プレミアムをご利用中です（${until.toLocal().year}/${until.toLocal().month}/${until.toLocal().day}まで）')
        : '広告なしをご利用中です';
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: Text(label),
      ),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '現在プランを取得できません。通信状態を確認して、しばらくしてから再度お試しください。',
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.offer, required this.onTap});

  final EntitlementOffer offer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  offer.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                offer.priceString,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
