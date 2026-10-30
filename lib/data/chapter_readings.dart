import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ukalab_core/ukalab_core.dart' as core
    show
        ChapterReading,
        QuestionSource,
        linksOfKind,
        parseChapterReadingsJsonl,
        readingsForQuestion,
        validateChapterReadings;

import '../models/question.dart';
import 'hazard_scenario.dart';

/// 読み物のデータ。ukalab_core の `ChapterReading` 形式(JSONL)。
const String kChapterReadingAsset = 'assets/experience/chapter_readings_bike.jsonl';

/// 読み物の確認問題を引くための問題ファイル(区分ごとに1ファイル、共通問題は重複して入る)。
const List<String> kReadingQuestionAssets = [
  'assets/questions/futsuu_nirin.json',
  'assets/questions/gentsuki.json',
];

/// 読み物から危険予測へ参照するときの `ChapterReading.relatedLinks` の kind。
/// id は `HazardScenario.scenarioId`。
const String kReadingHazardLinkKind = 'hazard';

/// 読み物に使わない表現。
const List<String> kReadingForbiddenWords = [
  '合格保証',
  '公式',
  '絶対',
  '本試験相当',
  '過去問',
];

/// 読み物の本文に入れない、条文番号・数値の表現(一次情報の確認ができないため)。
final RegExp kReadingNumberPattern = RegExp(r'[0-9０-９]|第[一二三四五六七八九十]+条|メートル|キロ|センチ');

/// 読み物の `relatedLinks` のうち、危険予測(kind: hazard)への参照 id(`scenarioId`)。
List<String> hazardLinkIds(core.ChapterReading reading) => [
  for (final l in core.linksOfKind(reading, kReadingHazardLinkKind)) l.id,
];

/// 配信前の品質ゲート。core の検証に、アプリ側の約束(自作・禁止語・数値なし・危険予測への参照が実在)を足す。
/// 問題が無ければ空。[hazardScenarioIds] を渡すと、`relatedLinks` の hazard が実在するかも検査する。
List<String> validateBikeReadings(
  List<core.ChapterReading> readings, {
  required List<String> questionIds,
  Iterable<String>? hazardScenarioIds,
}) {
  final issues = <String>[
    for (final i in core.validateChapterReadings(readings, questionIds: questionIds))
      '${i.qid} [${i.code}] ${i.message}',
  ];
  for (final r in readings) {
    void add(String code, String message) => issues.add('${r.readingId} [$code] $message');
    if (r.source != core.QuestionSource.original) {
      add('not-original', 'source は original(自作)である必要があります');
    }
    if (!r.sourceRef.contains('自作')) add('no-self-made', 'sourceRef に自作である旨がありません');
    if (!r.sourceRef.contains('AI下書き由来')) {
      add('no-ai-draft-note', 'sourceRef に AI下書き由来である旨がありません');
    }
    // 専門家確認は実施していないため、確認済みと読める表記は使わない。
    if (r.sourceRef.contains('専門家確認済み')) {
      add('claims-expert-review', 'sourceRef に「専門家確認済み」と書けません');
    }
    if (hazardScenarioIds != null) {
      final known = hazardScenarioIds.toSet();
      for (final l in core.linksOfKind(r, kReadingHazardLinkKind)) {
        if (!known.contains(l.id)) {
          add('unknown-hazard-link', '存在しない危険予測シナリオを参照しています: ${l.id}');
        }
      }
    }
    final body = jsonEncode([
      r.title,
      for (final s in r.sections) ...[
        s.heading,
        s.body,
        ...?s.steps,
        if (s.table != null) ...[...s.table!.columns, for (final row in s.table!.rows) ...row],
      ],
    ]);
    for (final w in kReadingForbiddenWords) {
      if (body.contains(w) || r.sourceRef.contains(w)) {
        add('forbidden-word', '使わない表現が含まれています: $w');
      }
    }
    if (kReadingNumberPattern.hasMatch(body)) {
      add('number-or-article', '数値・条文番号・距離の表現が含まれています');
    }
  }
  return issues;
}

/// assets から読み物を読む。不備があれば [StateError]。
Future<List<core.ChapterReading>> loadChapterReadings({AssetBundle? bundle}) async {
  final b = bundle ?? rootBundle;
  final parsed = core.parseChapterReadingsJsonl(await b.loadString(kChapterReadingAsset));
  final questionIds = (await _loadReadingQuestions(b)).keys.toList();
  final hazardIds = (await loadHazardScenarios()).map((s) => s.scenarioId);
  final issues = [
    for (final i in parsed.issues) '${i.qid} [${i.code}] ${i.message}',
    ...validateBikeReadings(
      parsed.items,
      questionIds: questionIds,
      hazardScenarioIds: hazardIds,
    ),
  ];
  if (issues.isNotEmpty) {
    throw StateError('読み物のデータに不備があります: ${issues.first}');
  }
  return parsed.items;
}

Future<Map<String, Question>> _loadReadingQuestions(AssetBundle bundle) async {
  final byId = <String, Question>{};
  for (final path in kReadingQuestionAssets) {
    final list = jsonDecode(await bundle.loadString(path)) as List<dynamic>;
    for (final e in list) {
      final q = Question.fromJson(e as Map<String, dynamic>);
      byId.putIfAbsent(q.id, () => q);
    }
  }
  return byId;
}

/// 読み物の確認問題を id で引く(読み物画面で問題を見せるため)。
Future<Map<String, Question>> loadReadingQuestions({AssetBundle? bundle}) =>
    _loadReadingQuestions(bundle ?? rootBundle);

/// 問題に関連する読み物(`disabled` を除く)。
List<core.ChapterReading> readingsFor(
  Iterable<core.ChapterReading> readings,
  String questionId,
) => core.readingsForQuestion(readings, questionId);

final chapterReadingsProvider = FutureProvider<List<core.ChapterReading>>(
  (ref) => loadChapterReadings(),
);

final readingQuestionsProvider = FutureProvider<Map<String, Question>>(
  (ref) => loadReadingQuestions(),
);
