import 'dart:async';
import 'dart:convert';

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
    show ReadingQuestionLinks, ReadingSectionContent, RelatedReadingsCard;
import 'package:ukalab_core/ukalab_core.dart' show ChapterReading, parseChapterReadingsJsonl;

late List<ChapterReading> _readings;
late Map<String, Question> _questions;
late List<HazardScenario> _hazards;

/// core v0.87.0 は4文字以上の数字語に U+2060(見えない)を入れるため、除いて比べる。
String _plain(String t) => t.replaceAll('\u2060', '');

Finder _textPlain(String expected) => find.byWidgetPredicate(
  (w) => w is Text && w.data != null && _plain(w.data!) == expected,
);

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
    testWidgets('節を kind ごとに描画する(手順・表・本文)と、出典が出る。試作の注記は出ない', (tester) async {
      await _pump(tester, BikeReadingView(reading: _readings.single, hazardsFuture: Future.value(_hazards)));
      expect(find.text(_readings.single.title), findsOneWidget);
      expect(find.textContaining('試作'), findsNothing);
      expect(find.byType(ReadingSectionContent), findsNWidgets(_readings.single.sections.length));
      // 手順(番号付き)
      expect(find.text('交差点に近づくときの判断の手順'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      // 表(3列。列見出し)
      expect(find.byType(Table), findsOneWidget);
      for (final c in ['場面', '先に確かめること', '基本の動き']) {
        expect(find.text(c), findsOneWidget, reason: c);
      }
      expect(find.text('つまずきやすい点'), findsOneWidget); // 表の列ではなく、表の下の節の見出し
      expect(find.text('見通しの悪い交差点（信号や優先の指示がない）'), findsOneWidget);
      expect(find.textContaining('出典: 自作（AI下書き由来。体験コンテンツのため専門家確認は不要と判断）'), findsOneWidget);
      expect(find.textContaining('専門家確認済み'), findsNothing);
    });

    testWidgets('表の下に「つまずきやすい点」が箇条書きで出る', (tester) async {
      await _pump(tester, BikeReadingView(reading: _readings.single, hazardsFuture: Future.value(_hazards)));
      await tester.scrollUntilVisible(find.text('つまずきやすい点'), 300, scrollable: find.byType(Scrollable).first);
      expect(
        find.textContaining('・左折する：大回りして右側にふくらむ'),
        findsOneWidget,
      );
    });

    testWidgets('確認問題は最初の5件だけ出て、「すべて見る」で全件に広がり、戻せる', (tester) async {
      await _pump(tester, BikeReadingView(reading: _readings.single, hazardsFuture: Future.value(_hazards)));
      final ids = _readings.single.relatedQuestionIds;
      expect(ids.length, greaterThan(kReadingFirstQuestionLinks));
      final links = find.descendant(of: find.byType(ReadingQuestionLinks), matching: find.byType(OutlinedButton));

      await tester.scrollUntilVisible(find.byType(ReadingQuestionLinks), 400, scrollable: find.byType(Scrollable).first);
      expect(find.text('確認問題にもどる'), findsOneWidget);
      expect(links, findsNWidgets(kReadingFirstQuestionLinks));
      expect(_textPlain(_questions[ids.first]!.questionText), findsOneWidget);
      expect(_textPlain(_questions[ids.last]!.questionText), findsNothing);

      await tester.ensureVisible(find.text('すべて見る（${ids.length}問）'));
      await tester.tap(find.text('すべて見る（${ids.length}問）'));
      await _settle(tester);
      expect(links, findsNWidgets(ids.length));
      expect(_textPlain(_questions[ids.last]!.questionText), findsOneWidget);

      await tester.ensureVisible(find.text('最初の$kReadingFirstQuestionLinks問だけ表示'));
      await tester.tap(find.text('最初の$kReadingFirstQuestionLinks問だけ表示'));
      await _settle(tester);
      expect(links, findsNWidgets(kReadingFirstQuestionLinks));
    });

    testWidgets('確認問題リンクは問題文そのものを表示し(手前で切らない)、タップで問題・正解・解説を見られる', (tester) async {
      await _pump(tester, BikeReadingView(reading: _readings.single, hazardsFuture: Future.value(_hazards)));
      final q = _questions['x358']!;
      final label = _textPlain(q.questionText);
      await tester.scrollUntilVisible(label, 400, scrollable: find.byType(Scrollable).first);
      await tester.ensureVisible(label);
      await tester.tap(label);
      await _settle(tester);
      // リンクとシートの両方に問題文が出る
      expect(_textPlain(q.questionText), findsWidgets);
      expect(find.text(q.choices[q.answer]), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('危険予測への導線は relatedLinks の hazard から出て、一覧(無料枠・限定の扱いは一覧側)を開ける', (tester) async {
      await _pump(tester, BikeReadingView(reading: _readings.single, hazardsFuture: Future.value(_hazards)));
      await tester.scrollUntilVisible(find.text('危険予測シナリオを開く'), 400, scrollable: find.byType(Scrollable).first);
      for (final id in hazardLinkIds(_readings.single)) {
        final title = _hazards.firstWhere((s) => s.scenarioId == id).title;
        expect(find.text('・$title'), findsOneWidget);
      }
      await tester.tap(find.text('危険予測シナリオを開く'));
      await _settle(tester);
      expect(find.byType(HazardScenarioListView), findsOneWidget);
    });

    testWidgets('relatedLinks に hazard が無い読み物では、危険予測の導線は出ない', (tester) async {
      final r = parseChapterReadingsJsonl(jsonEncode({
        'readingId': 'x',
        'examId': 'bike_license',
        'subjectId': 'rules',
        'title': 'リンクなし',
        'sections': [
          {'heading': 'h', 'body': '説明'},
        ],
        'relatedLinks': [
          {'kind': 'story', 'id': 's1'},
        ],
        'source': 'original',
        'sourceRef': '自作',
        'contentVer': '1',
      })).items.single;
      await _pump(tester, BikeReadingView(reading: r, hazardsFuture: Future.value(_hazards)));
      expect(find.text('危険予測シナリオを開く'), findsNothing);
      expect(find.text('危険予測で試す'), findsNothing);
    });
  });

  group('役立つ情報からの入口', () {
    testWidgets('入口が先頭に出て、一覧→読み物へ進める(既存の記事も従来どおり出る)', (tester) async {
      await _pump(tester, const GuideListView());
      expect(find.text('読み物'), findsOneWidget);
      expect(find.byType(ReadingEntryCard), findsOneWidget);
      expect(find.text('技能試験のコツ'), findsOneWidget);
      // 先頭であること
      expect(
        tester.getTopLeft(find.byType(ReadingEntryCard)).dy,
        lessThan(tester.getTopLeft(find.text('技能試験のコツ')).dy),
      );
      await tester.tap(find.text('読み物'));
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

    testWidgets('関連する問題を間違えると、誤答原因の選択欄なしの単体カード(RelatedReadingsCard)が出て、読み物を開ける', (tester) async {
      await _pump(
        tester,
        overlay(correct: false, extra: BikeReadingFeedback(question: _questions['x358']!)),
      );
      expect(find.byType(RelatedReadingsCard), findsOneWidget);
      expect(find.text('読み物でおさらい'), findsOneWidget);
      // 誤答原因の選択欄は付かない
      expect(find.byType(ChoiceChip), findsNothing);
      expect(find.byType(FilterChip), findsNothing);
      expect(find.text(_readings.single.title), findsOneWidget);
      await tester.tap(find.text(_readings.single.title));
      await _settle(tester);
      expect(find.byType(BikeReadingView), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('正解のときは、関連する読み物があっても何も足されない', (tester) async {
      await _pump(
        tester,
        overlay(correct: true, extra: BikeReadingFeedback(question: _questions['x358']!)),
      );
      expect(find.byType(RelatedReadingsCard), findsNothing);
      expect(find.text('読み物でおさらい'), findsNothing);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('小さい画面でも、導線つきの誤答表示が溢れず、次へを押せる', (tester) async {
      tester.view.physicalSize = const Size(360, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        overrides: _overrides(),
        child: MaterialApp(
          home: Scaffold(body: overlay(correct: false, extra: BikeReadingFeedback(question: _questions['x358']!))),
        ),
      ));
      await _settle(tester);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('次へ'));
      expect(find.text('次へ'), findsOneWidget);
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
