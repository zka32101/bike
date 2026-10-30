import 'dart:convert';
import 'dart:io';

import 'package:bike_license_kore/data/chapter_readings.dart';
import 'package:bike_license_kore/data/hazard_scenario.dart';
import 'package:bike_license_kore/views/chapter_reading_view.dart' show kReadingFirstQuestionLinks;
import 'package:flutter_test/flutter_test.dart';
import 'package:ukalab_core/ukalab_core.dart'
    show
        ChapterReading,
        QuestionSource,
        kReadingSectionSteps,
        kReadingSectionTable,
        kReadingSectionText,
        kReadingTableMaxColumns,
        kReadingTableMaxRows,
        parseChapterReadingsJsonl;

/// 読み物のデータ検証。
void main() {
  late List<ChapterReading> readings;
  late Map<String, dynamic> rawQuestions;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    readings = await loadChapterReadings();
    rawQuestions = {
      for (final p in kReadingQuestionAssets)
        for (final e in jsonDecode(File(p).readAsStringSync()) as List<dynamic>)
          (e as Map<String, dynamic>)['id'] as String: e,
    };
  });

  test('試作フラグは廃止済み(コードにも残っていない)', () {
    for (final path in [
      'lib/views/guide_view.dart',
      'lib/views/daily_quota_view.dart',
      'lib/views/chapter_reading_view.dart',
      'lib/widgets/reading_feedback.dart',
      'lib/data/chapter_readings.dart',
    ]) {
      final src = File(path).readAsStringSync();
      expect(src.contains('READING_PROTOTYPE'), isFalse, reason: path);
      expect(src.contains('kReadingPrototypeEnabled'), isFalse, reason: path);
      expect(src.contains('showReadingPrototype'), isFalse, reason: path);
    }
    expect(File('lib/core/constants/reading_prototype.dart').existsSync(), isFalse);
  });

  group('読み物コンテンツ', () {
    test('1章ぶん(交差点での右左折と優先関係)が品質ゲートに通る', () {
      expect(readings, hasLength(1));
      final r = readings.single;
      expect(r.readingId, 'bike_reading-0001');
      expect(r.title, '交差点での右左折と優先関係');
      expect(r.examId, 'bike_license');
      expect(r.disabled, isFalse);
      expect(
        validateBikeReadings(readings, questionIds: rawQuestions.keys.toList()),
        isEmpty,
      );
    });

    test('出典は自作(AI下書き由来。専門家確認は不要と判断)で、original。「専門家確認済み」とは書かない', () {
      final r = readings.single;
      expect(r.source, QuestionSource.original);
      expect(r.sourceRef, '自作（AI下書き由来。体験コンテンツのため専門家確認は不要と判断）');
      expect(r.sourceRef.contains('専門家確認済み'), isFalse);
      expect(r.contentVer, '1');
    });

    test('text・steps・table を使い、表は3列以下で各行のセル数が列数と同じ', () {
      final r = readings.single;
      final kinds = r.sections.map((s) => s.kind).toSet();
      expect(kinds, containsAll([kReadingSectionText, kReadingSectionSteps, kReadingSectionTable]));

      final steps = r.sections.firstWhere((s) => s.kind == kReadingSectionSteps).steps!;
      expect(steps.length, greaterThanOrEqualTo(4));

      final table = r.sections.firstWhere((s) => s.kind == kReadingSectionTable).table!;
      expect(table.columns.length, lessThanOrEqualTo(kReadingTableMaxColumns));
      // 長文セルが縦に長くなりすぎないよう、列は3つ(場面・先に確かめること・基本の動き)。
      expect(table.columns, ['場面', '先に確かめること', '基本の動き']);
      expect(table.rows.length, lessThanOrEqualTo(kReadingTableMaxRows));
      expect(table.rows.length, greaterThanOrEqualTo(6));
      for (final row in table.rows) {
        expect(row.length, table.columns.length);
      }
    });

    test('表から外した「つまずきやすい点」は、表の直後の箇条書きに残っている(場面と同数)', () {
      final r = readings.single;
      final ti = r.sections.indexWhere((s) => s.kind == kReadingSectionTable);
      final table = r.sections[ti].table!;
      final next = r.sections[ti + 1];
      expect(next.heading, 'つまずきやすい点');
      final bullets = next.body!.split('\n');
      expect(bullets, hasLength(table.rows.length));
      for (var i = 0; i < bullets.length; i++) {
        expect(bullets[i].startsWith('・${table.rows[i][0]}：'), isTrue, reason: bullets[i]);
      }
    });

    test('確認問題は最初の数件に絞れる件数があり、先頭5問は区分を問わず共通の問題', () {
      final r = readings.single;
      expect(r.relatedQuestionIds.length, greaterThan(kReadingFirstQuestionLinks));
      for (final id in r.relatedQuestionIds.take(kReadingFirstQuestionLinks)) {
        final cats = ((rawQuestions[id] as Map)['licenseCategory'] as List).cast<String>();
        expect(cats, containsAll(['gentsuki', 'futsuuNirin']), reason: id);
      }
    });

    test('関連問題はすべて実在し、原付・普通二輪のどちらの問題にもつながる', () {
      final r = readings.single;
      expect(r.relatedQuestionIds.length, greaterThanOrEqualTo(10));
      expect(r.relatedQuestionIds.toSet().length, r.relatedQuestionIds.length);
      final categories = <String>{};
      for (final id in r.relatedQuestionIds) {
        expect(rawQuestions.containsKey(id), isTrue, reason: id);
        categories.addAll(((rawQuestions[id] as Map)['licenseCategory'] as List).cast<String>());
      }
      expect(categories, containsAll(['gentsuki', 'futsuuNirin']));
    });

    test('危険予測への参照は relatedLinks(kind: hazard)で持ち、参照先が実在する', () async {
      final scenarios = await loadHazardScenarios();
      final ids = scenarios.map((s) => s.scenarioId).toSet();
      final r = readings.single;
      expect(r.relatedLinks, isNotEmpty);
      expect(r.relatedLinks.every((l) => l.kind == kReadingHazardLinkKind), isTrue);
      expect(hazardLinkIds(r), ['bike_hazard-0001', 'bike_hazard-0011', 'bike_hazard-0013']);
      expect(ids, containsAll(hazardLinkIds(r)));
    });

    test('資産ファイル全体に、使わない表現が入っていない', () {
      final text = File(kChapterReadingAsset).readAsStringSync();
      for (final w in [...kReadingForbiddenWords, '保証', '本番と同じ']) {
        expect(text.contains(w), isFalse, reason: w);
      }
    });

    test('問題から読み物を引ける(関連のない問題は空)', () {
      expect(readingsFor(readings, 'x358').map((r) => r.readingId), ['bike_reading-0001']);
      expect(readingsFor(readings, 'f001'), isEmpty);
    });
  });

  group('検証ゲート', () {
    List<ChapterReading> parse(String body, {String sourceRef = '自作（AI下書き由来。体験コンテンツのため専門家確認は不要と判断）', String source = 'original'}) {
      final line = jsonEncode({
        'readingId': 'x',
        'examId': 'bike_license',
        'subjectId': 'rules',
        'title': 't',
        'sections': [
          {'heading': 'h', 'body': body},
        ],
        'source': source,
        'sourceRef': sourceRef,
        'contentVer': '1',
      });
      final parsed = parseChapterReadingsJsonl(line);
      expect(parsed.issues, isEmpty);
      return parsed.items;
    }

    List<String> codes(List<String> issues) =>
        issues.map((e) => RegExp(r'\[(.+?)\]').firstMatch(e)!.group(1)!).toList();

    test('問題のない読み物は空', () {
      expect(validateBikeReadings(parse('ふつうの説明です。'), questionIds: const []), isEmpty);
    });

    test('禁止語・数値・条文番号・距離を検出する', () {
      expect(codes(validateBikeReadings(parse('これは公式の説明です。'), questionIds: const [])), contains('forbidden-word'));
      expect(codes(validateBikeReadings(parse('絶対に止まる。'), questionIds: const [])), contains('forbidden-word'));
      expect(codes(validateBikeReadings(parse('速度は30です。'), questionIds: const [])), contains('number-or-article'));
      expect(codes(validateBikeReadings(parse('第三十四条による。'), questionIds: const [])), contains('number-or-article'));
      expect(codes(validateBikeReadings(parse('十メートル手前。'), questionIds: const [])), contains('number-or-article'));
    });

    test('自作でない・AI下書き由来の記載がない出典を検出する', () {
      final c = codes(validateBikeReadings(parse('説明', sourceRef: '出典あり', source: 'statute'), questionIds: const []));
      expect(c, containsAll(['not-original', 'no-self-made', 'no-ai-draft-note']));
    });

    test('「専門家確認済み」と書いた出典を検出する', () {
      final c = codes(validateBikeReadings(
        parse('説明', sourceRef: '自作（AI下書き由来。専門家確認済み）'),
        questionIds: const [],
      ));
      expect(c, contains('claims-expert-review'));
    });

    test('存在しない危険予測への参照を検出する(渡したときだけ検査)', () {
      final line = jsonEncode({
        'readingId': 'x',
        'examId': 'bike_license',
        'subjectId': 'rules',
        'title': 't',
        'sections': [
          {'heading': 'h', 'body': '説明'},
        ],
        'relatedLinks': [
          {'kind': 'hazard', 'id': 'bike_hazard-0001'},
          {'kind': 'hazard', 'id': 'nothing'},
          {'kind': 'story', 'id': 'other-kind-is-ignored'},
        ],
        'source': 'original',
        'sourceRef': '自作（AI下書き由来。体験コンテンツのため専門家確認は不要と判断）',
        'contentVer': '1',
      });
      final items = parseChapterReadingsJsonl(line).items;
      final issues = validateBikeReadings(
        items,
        questionIds: const [],
        hazardScenarioIds: const ['bike_hazard-0001'],
      );
      expect(codes(issues), ['unknown-hazard-link']);
      expect(issues.single.contains('nothing'), isTrue);
      expect(validateBikeReadings(items, questionIds: const []), isEmpty);
    });

    test('存在しない関連問題を検出する', () {
      final line = jsonEncode({
        'readingId': 'x',
        'examId': 'bike_license',
        'subjectId': 'rules',
        'title': 't',
        'sections': [
          {'heading': 'h', 'body': '説明'},
        ],
        'relatedQuestionIds': ['nothing'],
        'source': 'original',
        'sourceRef': '自作（AI下書き由来。体験コンテンツのため専門家確認は不要と判断）',
        'contentVer': '1',
      });
      final items = parseChapterReadingsJsonl(line).items;
      expect(codes(validateBikeReadings(items, questionIds: const ['a'])), contains('unknown-related-question'));
    });
  });

  group('広告の配置ルール', () {
    test('読み物の画面・誤答時の導線に広告ウィジェットや広告制御を置かない', () {
      for (final path in [
        'lib/views/chapter_reading_view.dart',
        'lib/widgets/reading_feedback.dart',
        'lib/data/chapter_readings.dart',
      ]) {
        final src = File(path).readAsStringSync();
        expect(RegExp('Banner|AdWidget|Interstitial|Rewarded|adGate|AdBlockingContext').hasMatch(src), isFalse, reason: path);
      }
    });
  });
}
