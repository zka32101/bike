# 危険予測シナリオの画面注記整理 (2026-10-28)

## 経緯

- 危険予測シナリオ(`assets/experience/hazard_scenarios_bike.jsonl`、`bike_hazard-0001`〜`0014`)は体験コンテンツ。ユーザーが「体験なので専門家確認は不要」と判断。
- データ側の `contentStatus: ai-draft` 除去は #192 でマージ済み。
- 本変更で画面注記を整理: `kHazardDraftNotice`(AI下書き・専門確認前)を廃止し、`kHazardExperienceNotice` =「体験用の架空シナリオです」に置換。一覧画面・プレイ画面とも常時表示。「専門家確認済み」とは表示しない。シナリオ本文は変更なし。

## 未決事項(今回は触っていない)

Dart 内の `ai-draft` 定数が残る。体験コンテンツか、専門確認を要する学習コンテンツかの判断待ち。

| 対象 | 定数 | 表示箇所 |
|---|---|---|
| 憧れバイク図鑑 `lib/models/bike_zukan_entry.dart` | `contentStatus='ai-draft'`、`kZukanNotice`「架空のタイプ紹介（AI下書き・専門確認前）」 | `lib/views/bike_zukan_view.dart` の見出しに常時表示 |
| 技能試験のコツ `lib/models/skill_exam_tip.dart` | `contentStatus='ai-draft'`、`sourceRef`「自作（AI下書き・専門確認前…）」、`kSkillExamDraftNotice`「学習用の解説（AI下書き・専門確認前）」 | `lib/views/skill_exam_view.dart` に注記として表示 |

関連テスト: `test/bike_zukan_test.dart`、`test/skill_exam_test.dart` は `contentStatus == 'ai-draft'` を検証。

## sourceRef 訂正 (2026-10-28)

#192 で sourceRef を「専門家確認済み」としたが、体験コンテンツのため専門家確認は実施しておらず、事実と食い違っていた。ユーザーの明示指示により、14本の sourceRef を「自作の架空シナリオ(AI下書き由来。体験コンテンツのため専門家確認は不要と判断)。…」へ訂正(contentVer "3")。`validateHazardScenarios` のコメント・メッセージも「空=通常扱い」に修正。検証ロジック、`kHazardContentStatusAiDraft` / `isAiDraft`、シナリオ本文は不変。
