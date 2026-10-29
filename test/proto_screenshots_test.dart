// 一時テスト(試作確認用・確認後に削除する)
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_common_kit/app_common_kit.dart';
import 'package:bike_license_kore/data/chapter_readings.dart';
import 'package:bike_license_kore/data/hazard_scenario.dart';
import 'package:bike_license_kore/models/question.dart';
import 'package:bike_license_kore/services/sound_effects_service.dart';
import 'package:bike_license_kore/viewmodels/providers.dart';
import 'package:bike_license_kore/views/chapter_reading_view.dart';
import 'package:bike_license_kore/views/guide_view.dart';
import 'package:bike_license_kore/widgets/answer_result_overlay.dart';
import 'package:bike_license_kore/widgets/reading_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ukalab_core/ui.dart' show ReadingQuestionLinks;
import 'package:ukalab_core/ukalab_core.dart' show ChapterReading;

late List<ChapterReading> _readings;
late Map<String, Question> _questions;
late List<HazardScenario> _hazards;
final _key = GlobalKey();
String _fontStatus = 'none';

Future<void> _loadFont() async {
  for (final p in const [
    '/usr/share/fonts/opentype/ipafont-gothic/ipag.ttf',
    '/usr/share/fonts/truetype/fonts-japanese-gothic.ttf',
  ]) {
    final f = File(p);
    if (f.existsSync()) {
      final bytes = f.readAsBytesSync();
      final l = FontLoader('JP')..addFont(Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)));
      await l.load();
      _fontStatus = p;
      return;
    }
  }
}

Future<void> _pump(WidgetTester tester, Widget home, {double h = 844}) async {
  tester.view.physicalSize = Size(390 * 2, h * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      chapterReadingsProvider.overrideWith((ref) async => _readings),
      readingQuestionsProvider.overrideWith((ref) async => _questions),
      masteredQuestionsProvider.overrideWith((ref) async => []),
      soundEffectsServiceProvider.overrideWith((ref) => Completer<SoundEffectsService>().future),
      entitlementServiceProvider.overrideWithValue(FakeEntitlementService(initial: EntitlementState.free)),
    ],
    child: RepaintBoundary(
      key: _key,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, fontFamily: 'JP'),
        home: home,
      ),
    ),
  ));
  await _settle(tester);
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final b = _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await b.toImage(pixelRatio: 1);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory('build/shots').createSync(recursive: true);
    File('build/shots/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
  });
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadFont();
    Directory('build/shots').createSync(recursive: true);
    File('build/shots/font.txt').writeAsStringSync(_fontStatus);
    _readings = await loadChapterReadings();
    _questions = await loadReadingQuestions();
    _hazards = await loadHazardScenarios();
  });

  testWidgets('01 読み物 全体', (tester) async {
    await _pump(tester, BikeReadingView(reading: _readings.single, hazardsFuture: Future.value(_hazards)), h: 2600);
    await _shot(tester, '01_reading_full');
  });

  testWidgets('02 読み物 末尾の導線(画面高さ)', (tester) async {
    await _pump(tester, BikeReadingView(reading: _readings.single, hazardsFuture: Future.value(_hazards)));
    await tester.scrollUntilVisible(find.text('危険予測シナリオを開く'), 400, scrollable: find.byType(Scrollable).first);
    await _settle(tester);
    await _shot(tester, '02_reading_bottom_links');
  });

  testWidgets('03 確認問題リンクをタップ', (tester) async {
    await _pump(tester, BikeReadingView(reading: _readings.single, hazardsFuture: Future.value(_hazards)));
    await tester.scrollUntilVisible(find.byType(ReadingQuestionLinks), 400, scrollable: find.byType(Scrollable).first);
    final q = _questions['x358']!;
    final label = q.questionText.length <= 28 ? q.questionText : '${q.questionText.substring(0, 28)}…';
    await tester.ensureVisible(find.text(label));
    await tester.tap(find.text(label));
    await _settle(tester);
    await _shot(tester, '03_question_sheet');
  });

  testWidgets('04 危険予測への導線をタップ', (tester) async {
    await _pump(tester, BikeReadingView(reading: _readings.single, hazardsFuture: Future.value(_hazards)));
    await tester.scrollUntilVisible(find.text('危険予測シナリオを開く'), 400, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('危険予測シナリオを開く'));
    await _settle(tester);
    await _shot(tester, '04_hazard_list');
  });

  testWidgets('05 誤答の導線', (tester) async {
    await _pump(
      tester,
      AnswerResultOverlay(
        questionId: 'x358',
        isCorrect: false,
        explanation: '解説',
        onNext: () {},
        wrongAnswerExtra: BikeReadingFeedback(question: _questions['x358']!),
      ),
    );
    await _shot(tester, '05_wrong_answer_overlay');
    await tester.tap(find.text(_readings.single.title));
    await _settle(tester);
    await _shot(tester, '06_reading_from_feedback');
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('07 役立つ情報の入口', (tester) async {
    await _pump(tester, const GuideListView(showReadingPrototype: true));
    await _shot(tester, '07_guide_entry');
  });
}
