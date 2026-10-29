import 'dart:async';

import 'package:app_common_kit/app_common_kit.dart';
import 'package:bike_license_kore/data/chapter_readings.dart';
import 'package:bike_license_kore/data/hazard_scenario.dart';
import 'package:bike_license_kore/models/question.dart';
import 'package:bike_license_kore/services/sound_effects_service.dart';
import 'package:bike_license_kore/viewmodels/providers.dart';
import 'package:bike_license_kore/views/chapter_reading_view.dart';
import 'package:bike_license_kore/views/guide_view.dart';
import 'package:bike_license_kore/views/hazard_scenario_view.dart';
import 'package:bike_license_kore/widgets/answer_result_overlay.dart';
import 'package:bike_license_kore/widgets/reading_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ukalab_core/ui.dart'
    show ReadingQuestionLinks, ReadingSectionContent;
import 'package:ukalab_core/ukalab_core.dart' show ChapterReading;

late List<ChapterReading> _readings;
late Map<String, Question> _questions;
late List<HazardScenario> _hazards;

List<Override> _overrides({bool premium = false}) => [
  chapterReadingsProvider.overrideWith((ref) async => _readings),
  readingQuestionsProvider.overrideWith((ref) async => _questions),
  masteredQuestionsProvider.overrideWith((ref) async => []),
  soundEffectsServiceProvider.overrideWith((ref) => Completer<SoundEffectsService>().future),
  entitlementServiceProvider.overrideWithValue(
    FakeEntitlementService(
      initial: premium ? const EntitlementState(hasPremium: true) : EntitlementState.free,
    ),
  ),
];

Future<void> _pump(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: _overrides(),
    child: MaterialApp(home: home),
  ));
  await _settle(tester);
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    _readings = await loadChapterReadings();
    _questions = await loadReadingQuestions();
    _hazards = await loadHazardScenarios();
  });

  group('読み物画面', () {
    testWidgets('節を kind ごとに描画する(手順・表・本文)と、注記・出典が出る', (tester) async {
      await _pump(tester, BikeReadingView(reading: _readings.single, hazardsFuture: Future.value(_hazards)));
      expect(find.text(_readings.single.title), findsOneWidget);
      expect(find.text(kReadingPrototypeNotice), findsOneWidget);
      expect(find.byType(ReadingSectionContent), findsNWidgets(_readings.single.sections.length));
      // 手順(番号付き)
      expect(find.text('交差点に近づくときの判断の手順'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      // 表(列見出し)
      expect(find.byType(Table), findsOneWidget);
      expect(find.text('つまずきやすい点'), findsOneWidget);
      expect(find.text('見通しの悪い交差点（信号や優先の指示がない）'), findsOneWidget);
      expect(find.textContaining('出典: 自作（AI下書き由来。試作・専門家確認は未実施）'), findsOneWidget);
    });

    testWidgets('確認問題への導線が出て、タップで問題・正解・解説を見られる', (tester) async {
      await _pump(tester, BikeReadingView(reading: _readings.single, hazardsFuture: Future.value(_hazards)));
      await tester.scrollUntilVisible(find.byType(ReadingQuestionLinks), 400, scrollable: find.byType(Scrollable).first);
      expect(find.text('確認問題にもどる'), findsOneWidget);
      final q = _questions['x358']!;
      final label = q.questionText.length <= 28 ? q.questionText : '${q.questionText.substring(0, 28)}…';
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await _settle(tester);
      expect(find.text(q.questionText), findsOneWidget);
      expect(find.text(q.choices[q.answer]), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('危険予測への導線から一覧(無料枠・限定の扱いは一覧側)を開ける', (tester) async {
      await _pump(tester, BikeReadingView(reading: _readings.single, hazardsFuture: Future.value(_hazards)));
      await tester.scrollUntilVisible(find.text('危険予測シナリオを開く'), 400, scrollable: find.byType(Scrollable).first);
      for (final id in kReadingHazardLinks['bike_reading-0001']!) {
        final title = _hazards.firstWhere((s) => s.scenarioId == id).title;
        expect(find.text('・$title'), findsOneWidget);
      }
      await tester.tap(find.text('危険予測シナリオを開く'));
      await _settle(tester);
      expect(find.byType(HazardScenarioListView), findsOneWidget);
    });
  });

  group('役立つ情報からの入口(フラグ)', () {
    testWidgets('既定では読み物(試作)の入口は出ない', (tester) async {
      await _pump(tester, const GuideListView());
      expect(find.text('読み物（試作）'), findsNothing);
      expect(find.byType(ReadingPrototypeEntryCard), findsNothing);
      expect(find.text('技能試験のコツ'), findsOneWidget);
    });

    testWidgets('有効にすると入口が先頭に出て、一覧→読み物へ進める', (tester) async {
      await _pump(tester, const GuideListView(showReadingPrototype: true));
      expect(find.text('読み物（試作）'), findsOneWidget);
      expect(find.text('技能試験のコツ'), findsOneWidget);
      await tester.tap(find.text('読み物（試作）'));
      await _settle(tester);
      expect(find.byType(BikeReadingListView), findsOneWidget);
      await tester.tap(find.text(_readings.single.title));
      await _settle(tester);
      expect(find.byType(BikeReadingView), findsOneWidget);
    });
  });

  group('誤答後の導線', () {
    Widget overlay({required bool correct, Widget? extra}) => AnswerResultOverlay(
      questionId: 'x358',
      isCorrect: correct,
      explanation: '解説',
      onNext: () {},
      wrongAnswerExtra: extra,
    );

    testWidgets('追加表示を渡さなければ、従来どおり(正誤・解説・次へだけ)', (tester) async {
      await _pump(tester, overlay(correct: false));
      expect(find.text('不正解'), findsOneWidget);
      expect(find.text('読み物でおさらい'), findsNothing);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('追加表示は不正解のときだけ出る', (tester) async {
      const extra = Text('追加の導線');
      await _pump(tester, overlay(correct: true, extra: extra));
      expect(find.text('追加の導線'), findsNothing);
      await _pump(tester, overlay(correct: false, extra: extra));
      expect(find.text('追加の導線'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('関連する問題を間違えると「読み物でおさらい」が出て、読み物を開ける', (tester) async {
      await _pump(
        tester,
        overlay(correct: false, extra: BikeReadingFeedback(question: _questions['x358']!)),
      );
      expect(find.text('読み物でおさらい'), findsOneWidget);
      expect(find.text(_readings.single.title), findsOneWidget);
      await tester.tap(find.text(_readings.single.title));
      await _settle(tester);
      expect(find.byType(BikeReadingView), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('関連する読み物がない問題では、何も足されない', (tester) async {
      await _pump(
        tester,
        overlay(correct: false, extra: BikeReadingFeedback(question: _questions['f001']!)),
      );
      expect(find.text('読み物でおさらい'), findsNothing);
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
