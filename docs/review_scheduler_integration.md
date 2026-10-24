# 復習スケジューラ接続 設計メモ（提案のみ・未実装）

## 確認結果

`lib/views/review_questions_view.dart` と `lib/services/review_reminder_service.dart` は、
ukalab_core の `Srs` / `ReviewSchedulerEngine` / `TodayReviewCard` を**使っていない**
（`lib/` 内に `Srs`・`ReviewScheduler*`・`TodayReviewCard`・`MistakeNote*` の参照なし。ukalab_core は v0.83.0 を依存済み）。

| 現状 | 内容 |
|---|---|
| `ReviewReminderService` | 誤答時に `providers.dart` から呼ばれ、回答日の +1/+3/+7 日にローカル通知を予約（固定、`reviewIntervalsDays = [1,3,7]`）。復習の成否は反映されない |
| `ReviewQuestionsView` | 受け取った `questionIds` を一覧表示するだけ。期限・段の概念なし |
| 呼び出し元 | `review_recommendation_card.dart`（学習分析）、`app.dart`（通知タップ） |

## core 側の部品

- `ReviewSchedulerEngine`: 間違いノート(`MistakeNoteEntry`)から `ReviewItem`（qid・段・dueAt）を生成。正解で段が上がり、不正解で1段戻る。間隔 [1,3,7,14,30] 日、暦日基準。
- `Srs`: 箱0〜5の Leitner 方式。全問題の履歴向けで、間違いノート向けの Engine とは用途が別。
- `TodayReviewCard(dueCount, onStart)` と `ReviewSchedulerStore`（SharedPreferences、キー `ukalab_<appId>_review_schedule`）。

## 最小接続案（段階導入、各段は単独で戻せる）

1. **記録のみ**: 回答処理（`providers.dart` の誤答分岐、通知予約の隣）で
   `store.read → engine.sync / applyResult → store.write` を追加。UI・通知は変えない。
   bike は `MistakeNoteStore` 未採用のため、`sync` に渡す `MistakeNoteEntry` を誤答ログから
   組み立てるか、`ReviewItem` を直接作る薄いアダプタが必要（要判断）。
2. **表示**: ホームまたは学習分析に `TodayReviewCard` を追加し、`engine.due(items, now)` の qid を
   既存 `ReviewQuestionsView(questionIds: ...)` に渡す。`ReviewQuestionsView` は無改修で流用できる。
3. **通知の置換（任意）**: 固定 [1,3,7] の予約を、`ReviewItem.dueAt` に基づく1件予約へ。
   既存の通知 ID 規則（`Object.hash(questionId, dayOffset)`）と移行時の二重通知を要確認。

## 影響範囲・リスク

- ホームのカード追加は広告禁止ゾーン(CD-007)外。ただし復習出題画面は問題領域なので広告を出さない。
- 復習データはバックアップ/削除対象に含める必要あり（`reviewSchedulerDataPart`、`user_deletion_service` と整合）。
- 既存ユーザーの過去の誤答は段0から再開になる（移行方針の決定が必要）。
- 無料/プレミアム境界は現状維持（本提案は課金を変えない）。

## 未決事項

間違いノートを bike に導入するか／誤答ログからのアダプタで済ませるか、通知を置換するか併存させるか。
