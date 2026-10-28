import 'package:app_common_kit/app_common_kit.dart';
import 'package:ukalab_core/ui.dart';
import 'package:bike_license_kore/data/hazard_scenario.dart';
import 'package:bike_license_kore/views/hazard_scenario_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

late List<HazardScenario> _scenarios;

Future<void> _pumpList(WidgetTester tester, {required bool premium}) async {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      entitlementServiceProvider.overrideWithValue(
        FakeEntitlementService(
          initial: premium ? const EntitlementState(hasPremium: true) : EntitlementState.free,
        ),
      ),
    ],
    child: MaterialApp(
      home: HazardScenarioListView(scenariosFuture: Future.value(_scenarios)),
    ),
  ));
  // pumpAndSettle は使わず、一定回数だけ進める。
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _pumpFew(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    _scenarios = await loadHazardScenarios();
  });

  group('データ検証', () {
    test('シナリオは14本(既存4本+追加10本)で、最初の2本だけ無料', () {
      expect(_scenarios.length, 14);
      expect(_scenarios.where((s) => s.isFree).length, 2);
      expect(_scenarios.take(2).every((s) => s.isFree), isTrue);
      expect(_scenarios.skip(2).every((s) => !s.isFree), isTrue);
    });

    test('各シナリオは5場面・3択・推奨1つで、品質ゲートに通る', () {
      expect(validateHazardScenarios(_scenarios), isEmpty);
      for (final s in _scenarios) {
        expect(s.contentStatus, isEmpty);
        expect(s.sourceRef, contains('専門家確認は不要と判断'));
        expect(s.sourceRef, isNot(contains('専門家確認済み')));
        expect(s.source, 'original');
        expect(s.sourceRef, contains('自作'));
        expect(s.chapters.length, 5);
        for (final c in s.chapters) {
          expect(c.choices.length, 3);
          expect(c.choices.where((x) => x.isRecommended).length, 1);
        }
      }
    });

    test('禁止語を含むデータや不正な contentStatus を検出できる', () {
      const line = '{"scenarioId":"x","title":"過去問で学ぶ","description":"d",'
          '"chapters":[{"chapterId":"a","situation":"s","choices":['
          '{"choiceId":"1","text":"t","isRecommended":true,"feedback":"f"},'
          '{"choiceId":"2","text":"u","isRecommended":false,"feedback":"g"}]}],'
          '"source":"other","sourceRef":"出典","contentStatus":"bogus"}';
      final parsed = parseHazardScenarios(line);
      expect(parsed.issues, isEmpty);
      final codes = validateHazardScenarios(parsed.scenarios).map((i) => i.code).toSet();
      expect(
        codes,
        containsAll(['invalid-content-status', 'forbidden-word', 'not-original', 'no-self-made', 'choice-count']),
      );
    });

    test('壊れた行は issues に出る', () {
      final parsed = parseHazardScenarios('// コメント\n\n{broken');
      expect(parsed.scenarios, isEmpty);
      expect(parsed.issues, isNotEmpty);
    });
  });

  group('一覧画面', () {
    testWidgets('無料: 無料シナリオは開け、体験用の注記が出る(専門確認前の注記は出ない)', (tester) async {
      await _pumpList(tester, premium: false);
      expect(find.text(kHazardExperienceNotice), findsOneWidget);
      expect(find.textContaining('専門確認前'), findsNothing);
      await tester.tap(find.text(_scenarios[0].title));
      await _pumpFew(tester);
      expect(find.byType(HazardScenarioPlayView), findsOneWidget);
      expect(find.text(kHazardExperienceNotice), findsOneWidget);
      expect(find.text('場面 1 / 全5場面'), findsOneWidget);
    });

    testWidgets('無料: プレミアム限定は案内のSnackBarだけで、画面に入れない', (tester) async {
      await _pumpList(tester, premium: false);
      expect(find.byIcon(Icons.lock_outline), findsWidgets);
      await tester.tap(find.text(_scenarios[2].title));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(kHazardPremiumNotice), findsOneWidget);
      expect(find.byType(HazardScenarioPlayView), findsNothing);
    });

    testWidgets('プレミアム: 鍵が出ず、限定シナリオも開けて、判断→解説→次の場面へ進める', (tester) async {
      await _pumpList(tester, premium: true);
      expect(find.byIcon(Icons.lock_outline), findsNothing);
      await tester.tap(find.text(_scenarios[2].title));
      await _pumpFew(tester);
      expect(find.byType(HazardScenarioPlayView), findsOneWidget);
      expect(find.text(kHazardPremiumNotice), findsNothing);

      final first = _scenarios[2].chapters.first;
      await tester.tap(find.text(first.recommended.text));
      await tester.pump();
      expect(find.text('よい判断です'), findsOneWidget);
      expect(find.text(first.recommended.feedback), findsOneWidget);
      await tester.tap(find.text('次の場面へ'));
      await tester.pump();
      expect(find.text('場面 2 / 全5場面'), findsOneWidget);
    });
  });

  group('プレイ画面', () {
    testWidgets('最後の場面のあとに結果が出る', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final scenario = _scenarios[0];
      await tester.pumpWidget(MaterialApp(home: HazardScenarioPlayView(scenario: scenario)));
      for (var i = 0; i < scenario.chapters.length; i++) {
        await tester.tap(find.text(scenario.chapters[i].recommended.text));
        await tester.pump();
        final last = i == scenario.chapters.length - 1;
        await tester.tap(find.text(last ? '結果を見る' : '次の場面へ'));
        await tester.pump();
      }
      expect(find.text('結果'), findsOneWidget);
      expect(find.textContaining('5場面のうち、5場面でおすすめの判断'), findsOneWidget);
    });
  });
}
