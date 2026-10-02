import 'package:app_common_kit/app_common_kit.dart';
import 'package:bike_license_kore/views/paywall_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _noAds = EntitlementState(hasNoAds: true);

const _offers = [
  EntitlementOffer(
    id: 'noads',
    productId: 'noads_480',
    title: '広告なし',
    priceString: '¥480',
  ),
  EntitlementOffer(
    id: 'p30',
    productId: 'premium_30d',
    title: 'プレミアム 30日',
    priceString: '¥600',
  ),
];

Future<void> _pump(WidgetTester tester, FakeEntitlementService service) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [entitlementServiceProvider.overrideWithValue(service)],
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const PaywallView()),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('商品と価格をOfferingから表示する', (tester) async {
    await _pump(tester, FakeEntitlementService(availableOffers: _offers));
    // 「広告なし」は商品名と比較表の見出しの両方に出る。
    expect(find.text('広告なし'), findsNWidgets(2));
    expect(find.text('¥480'), findsOneWidget);
    expect(find.text('プレミアム 30日'), findsOneWidget);
    expect(find.text('¥600'), findsOneWidget);
    // 比較表に、実装済みのプレミアム特典が出る。
    expect(find.textContaining('模擬テストが回数無制限（無料は月1回）'), findsOneWidget);
    expect(find.textContaining('無料は上位3分野'), findsOneWidget);
    expect(find.textContaining('すべての問題と解説は無料'), findsOneWidget);
  });

  testWidgets('商品が取得できないときは案内を出す', (tester) async {
    await _pump(tester, FakeEntitlementService());
    expect(find.textContaining('現在プランを取得できません'), findsOneWidget);
  });

  testWidgets('購入に成功すると画面を閉じ、権利が反映される', (tester) async {
    final service = FakeEntitlementService(
      availableOffers: _offers,
      grantOnPurchase: {'noads_480': _noAds},
    );
    await _pump(tester, service);
    await tester.tap(find.text('¥480'));
    await tester.pumpAndSettle();

    expect(service.state.hasNoAds, isTrue);
    expect(find.byType(PaywallView), findsNothing);
  });

  testWidgets('購入に失敗するとメッセージを出して画面に残る', (tester) async {
    await _pump(tester, FakeEntitlementService(availableOffers: _offers));
    await tester.tap(find.text('¥600'));
    await tester.pumpAndSettle();

    expect(find.textContaining('購入できませんでした'), findsOneWidget);
    expect(find.byType(PaywallView), findsOneWidget);
  });

  testWidgets('購入済みなら現在のプランを表示する', (tester) async {
    await _pump(
      tester,
      FakeEntitlementService(initial: _noAds, availableOffers: _offers),
    );
    expect(find.text('広告なしをご利用中です'), findsOneWidget);
  });

  testWidgets('復元で購入が見つかる／見つからない', (tester) async {
    final found = FakeEntitlementService(availableOffers: _offers)
      ..restorable = _noAds;
    await _pump(tester, found);
    await tester.tap(find.text('購入を復元'));
    await tester.pumpAndSettle();
    expect(find.text('購入を復元しました'), findsOneWidget);
  });

  testWidgets('復元できる購入が無いときの案内', (tester) async {
    await _pump(tester, FakeEntitlementService(availableOffers: _offers));
    await tester.tap(find.text('購入を復元'));
    await tester.pumpAndSettle();
    expect(find.text('復元できる購入が見つかりませんでした'), findsOneWidget);
  });
}
