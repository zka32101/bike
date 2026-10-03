import 'package:app_common_kit/app_common_kit.dart';
import 'package:bike_license_kore/models/question.dart';
import 'package:bike_license_kore/services/oshi_readiness.dart';
import 'package:bike_license_kore/viewmodels/providers.dart';
import 'package:bike_license_kore/widgets/oshi_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Question _q(String id) => Question(
      id: id,
      licenseCategory: const ['gentsuki'],
      stageTag: '第一段階',
      difficulty: 1,
      questionText: '問題$id',
      choices: const ['a', 'b', 'c', 'd'],
      answer: 0,
      explanation: '解説',
    );

ProviderContainer _container() {
  final coin = CoinService(
    store: InMemoryCoinStore(),
    shop: OutfitCatalog.shopItems([UkalabCert.bikeLicense]),
  );
  final c = ProviderContainer(overrides: [
    coinServiceProvider.overrideWithValue(coin),
    outfitServiceProvider.overrideWithValue(OutfitService(store: InMemoryOutfitStore())),
    answerLogsProvider.overrideWith((ref) async => []),
  ]);
  addTearDown(c.dispose);
  return c;
}

/// 推しが常に動いている（アニメーション）ため、pumpAndSettle は終わらない。時間を区切って進める。
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  group('masteryFromLogs（準備完了の判定に使う習得度）', () {
    test('回答がなければ0', () {
      final m = masteryFromLogs(questionIds: {'a', 'b'}, logs: const []);
      expect(m.coverage, 0);
      expect(m.accuracy, 0);
    });

    test('区分の問題だけを数え、網羅率と正答率を出す', () {
      final m = masteryFromLogs(
        questionIds: {'a', 'b', 'c', 'd'},
        logs: [
          (questionId: 'a', isCorrect: true),
          (questionId: 'a', isCorrect: false), // 同じ問題の2回目（網羅率は増えない）
          (questionId: 'b', isCorrect: true),
          (questionId: 'zzz', isCorrect: true), // 別区分の問題は数えない
        ],
      );
      expect(m.coverage, 0.5);
      expect(m.accuracy, closeTo(2 / 3, 1e-9));
    });

    test('ほぼ全問を解いて正答率も高ければ、準備完了の条件を満たす', () {
      final ids = {for (var i = 0; i < 20; i++) 'q$i'};
      final m = masteryFromLogs(
        questionIds: ids,
        logs: [for (final id in ids) (questionId: id, isCorrect: true)],
      );
      expect(ReadinessRule.standard.isReady(mastery: m, mockPassed: true), isTrue);
      expect(ReadinessRule.standard.isReady(mastery: m, mockPassed: false), isFalse);
    });
  });

  group('OshiCard のメニュー', () {
    Future<ProviderContainer> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final c = _container();
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          home: Scaffold(
            body: OshiCard(questions: [_q('a'), _q('b')], now: DateTime(2026, 10, 3)),
          ),
        ),
      ));
      await tester.pump();
      return c;
    }

    testWidgets('「着替え・ショップ」で共通の着替え画面が開く', (tester) async {
      await pump(tester);
      await tester.tap(find.byType(PopupMenuButton<Object>));
      await _settle(tester);
      await tester.tap(find.text('着替え・ショップ'));
      await _settle(tester);
      expect(find.byType(WardrobeScreen), findsOneWidget);
      expect(find.text('合格したときに解放されます'), findsOneWidget);
    });

    testWidgets('「試験の結果を報告」で合格を選ぶと、コインと合格記念の衣装が付く', (tester) async {
      final c = await pump(tester);
      await tester.tap(find.byType(PopupMenuButton<Object>));
      await _settle(tester);
      await tester.tap(find.text('試験の結果を報告'));
      await _settle(tester);
      expect(find.text('${UkalabCert.bikeLicense.label}の結果を教えてください'), findsOneWidget);
      await tester.tap(find.text('合格しました'));
      await _settle(tester);
      expect(find.text('合格おめでとうございます'), findsOneWidget);
      expect(find.text('共有する'), findsOneWidget); // 共有ボタンが出る
      await tester.tap(find.text('閉じる'));
      await _settle(tester);
      expect(c.read(coinProvider).balance, CoinRules.standard.passReport);
      expect(c.read(outfitServiceProvider).passedCerts, contains('bike_license'));
    });
  });
}
