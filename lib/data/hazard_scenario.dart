import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// 「危険予測シナリオ」（二輪特有の場面で判断を選ぶ体験型教材）のデータ。
/// 1シナリオ＝複数の場面（状況提示→3択の判断→解説）。最初の2本は無料、残りはプレミアム限定。

/// 画面に出す、体験用コンテンツであることの表示(事実に即した注記。専門家確認の有無は表示しない)。
const String kHazardExperienceNotice = '体験用の架空シナリオです';

/// データに付けるAI下書きの印（`contentStatus`）。
const String kHazardContentStatusAiDraft = 'ai-draft';

/// 無料で遊べるシナリオ（最初の2本）。残りはプレミアム限定。
const Set<String> freeHazardScenarioIds = {
  'bike_hazard-0001',
  'bike_hazard-0002',
};

const String kHazardScenarioAsset = 'assets/experience/hazard_scenarios_bike.jsonl';

/// 学習コンテンツに使わない表現。
const List<String> kHazardForbiddenWords = ['公式', '本試験相当', '過去問', '合格保証'];

class HazardChoice {
  const HazardChoice({
    required this.choiceId,
    required this.text,
    required this.isRecommended,
    required this.feedback,
  });

  final String choiceId;
  final String text;
  final bool isRecommended;
  final String feedback;
}

class HazardChapter {
  const HazardChapter({
    required this.chapterId,
    required this.situation,
    required this.choices,
  });

  final String chapterId;
  final String situation;
  final List<HazardChoice> choices;

  HazardChoice get recommended => choices.firstWhere((c) => c.isRecommended);
}

class HazardScenario {
  const HazardScenario({
    required this.scenarioId,
    required this.title,
    required this.description,
    required this.chapters,
    required this.source,
    required this.sourceRef,
    required this.contentStatus,
  });

  final String scenarioId;
  final String title;
  final String description;
  final List<HazardChapter> chapters;
  final String source;
  final String sourceRef;

  /// 'ai-draft' など。
  final String contentStatus;

  bool get isFree => freeHazardScenarioIds.contains(scenarioId);
  bool get isAiDraft => contentStatus == kHazardContentStatusAiDraft;
}

/// データの不備。[scenarioId] は不明な場合 null。
class HazardIssue {
  const HazardIssue(this.scenarioId, this.code, this.message);

  final String? scenarioId;
  final String code;
  final String message;

  @override
  String toString() => '$scenarioId [$code] $message';
}

class ParsedHazardScenarios {
  const ParsedHazardScenarios(this.scenarios, this.issues);

  final List<HazardScenario> scenarios;
  final List<HazardIssue> issues;
}

/// JSONL（`//` で始まる行と空行は無視）を読み込む。
ParsedHazardScenarios parseHazardScenarios(String text) {
  final scenarios = <HazardScenario>[];
  final issues = <HazardIssue>[];
  for (final raw in const LineSplitter().convert(text)) {
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('//')) continue;
    try {
      final j = jsonDecode(line);
      if (j is! Map<String, dynamic>) {
        issues.add(const HazardIssue(null, 'bad-line', 'JSONオブジェクトではありません'));
        continue;
      }
      scenarios.add(_scenarioFromJson(j));
    } on FormatException catch (e) {
      issues.add(HazardIssue(null, 'bad-json', e.message));
    } on TypeError {
      issues.add(const HazardIssue(null, 'bad-shape', '項目の型が正しくありません'));
    }
  }
  return ParsedHazardScenarios(scenarios, issues);
}

HazardScenario _scenarioFromJson(Map<String, dynamic> j) {
  return HazardScenario(
    scenarioId: j['scenarioId'] as String,
    title: j['title'] as String,
    description: j['description'] as String? ?? '',
    chapters: [
      for (final c in j['chapters'] as List<dynamic>)
        HazardChapter(
          chapterId: (c as Map<String, dynamic>)['chapterId'] as String,
          situation: c['situation'] as String,
          choices: [
            for (final ch in c['choices'] as List<dynamic>)
              HazardChoice(
                choiceId: (ch as Map<String, dynamic>)['choiceId'] as String,
                text: ch['text'] as String,
                isRecommended: ch['isRecommended'] as bool,
                feedback: ch['feedback'] as String,
              ),
          ],
        ),
    ],
    source: j['source'] as String? ?? '',
    sourceRef: j['sourceRef'] as String? ?? '',
    contentStatus: j['contentStatus'] as String? ?? '',
  );
}

/// 配信前の品質ゲート。構造・contentStatus(空=専門家確認済み/ai-draft=確認前)・自作の出典・禁止表現を確かめる。
List<HazardIssue> validateHazardScenarios(List<HazardScenario> items) {
  final issues = <HazardIssue>[];
  final seen = <String>{};
  for (final s in items) {
    void add(String code, String message) =>
        issues.add(HazardIssue(s.scenarioId, code, message));
    if (!seen.add(s.scenarioId)) add('duplicate-id', 'scenarioId が重複しています');
    if (s.chapters.isEmpty) add('no-chapters', '場面がありません');
    for (final c in s.chapters) {
      if (c.choices.length != 3) add('choice-count', '${c.chapterId}: 選択肢は3つ必要です');
      final recommended = c.choices.where((x) => x.isRecommended).length;
      if (recommended != 1) add('recommended-count', '${c.chapterId}: 推奨の選択肢は1つ必要です');
      for (final ch in c.choices) {
        if (ch.feedback.trim().isEmpty) add('no-feedback', '${c.chapterId}: 解説がありません');
      }
    }
    if (s.contentStatus.isNotEmpty && !s.isAiDraft) {
      add('invalid-content-status', 'contentStatus は空(専門家確認済み)か ai-draft のみ使えます');
    }
    if (s.source != 'original') add('not-original', 'source は original(自作)である必要があります');
    if (!s.sourceRef.contains('自作')) add('no-self-made', 'sourceRef に自作である旨がありません');
    final all = jsonEncode([
      s.title,
      s.description,
      s.sourceRef,
      for (final c in s.chapters) ...[
        c.situation,
        for (final ch in c.choices) ...[ch.text, ch.feedback],
      ],
    ]);
    for (final w in kHazardForbiddenWords) {
      if (all.contains(w)) add('forbidden-word', '使わない表現が含まれています: $w');
    }
  }
  return issues;
}

Future<List<HazardScenario>> loadHazardScenarios() async {
  final text = await rootBundle.loadString(kHazardScenarioAsset);
  final parsed = parseHazardScenarios(text);
  final issues = [...parsed.issues, ...validateHazardScenarios(parsed.scenarios)];
  if (issues.isNotEmpty) {
    throw StateError('危険予測シナリオのデータに不備があります: ${issues.first}');
  }
  return parsed.scenarios;
}
