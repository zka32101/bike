# テスト失敗トリアージ (C) 9件の個別調査

作成: 2026-10-24 / 前提: `docs/test_triage.md` の (C) 分類 9 件

## 調査方法と確度

- この環境に flutter は無い。代わりに **Dart SDK 3.13.7 を取得**し、対象 lib（`models/*`, `services/*` は純 Dart）と
  対象テストを一時ディレクトリにコピーして `dart analyze` / `dart test` を実行した（`flutter_test` は `package:test` に置換、
  import は相対/パッケージ名を機械的に正しい形へ補正）。リポジトリ本体は未変更。
- 併せて main の CI ログ（run 40056033746 / 40057082874 の `Analyze & Test`）の `flutter analyze` 出力を
  ファイル別に集計し、静的エラー件数の裏付けにした。
- 確度: 「コンパイル不能の事実」「phase_62 の 5 件失敗」は **実行で確認済み（高）**。
  「削除すべきか」は設計判断を含むため **提案（中）**。
- ファイル名は `test/` 配下。パッケージ名の誤り（`your_app_name`/`project_040`）は全件で修正しても直らない
  （直した上でも下表の API 不一致が残る）ことを確認した。

## 判定サマリ

| テスト | 判定 | CIでの現状 | 要点 |
|---|---|---|---|
| `export_service_test.dart` | (2) 実装が未完成（スタブ） | コンパイル不能（analyze 11件） | import を直しても `exportData` がスタブで 6 件中ほぼ全て失敗 |
| `phase_46_notification_test.dart` | (3) 削除提案 | コンパイル不能（202件） | 現行 lib と別設計。lib 側に一致する実装なし |
| `phase_47_analytics_test.dart` | (3) 削除提案 | コンパイル不能（73件） | 同上。Phase 90 設計に置換済みの旧版 |
| `phase_49_export_test.dart` | (3) 削除提案 | コンパイル不能（215件） | 現行 lib は phase_62 設計。旧版 |
| `phase_56_export_test.dart` | (3) 削除提案 | コンパイル不能（99件） | 同上。旧版 |
| `phase_59_notification_test.dart` | (3) 削除提案 | コンパイル不能（281件） | phase_46 とも非互換の第3の設計 |
| `phase_61_analytics_test.dart` | (3) 削除提案 | コンパイル不能（65件） | 旧版 |
| `phase_62_export_test.dart` | (2) 実装バグ（lib 修正方針あり） | コンパイル可。**5件が実行時失敗** | 現行 lib と整合する唯一のテスト。残る失敗は lib 側の不具合 |
| `phase_90_analytics_test.dart` | (3) 削除提案（要判断） | コンパイル不能（247件） | 型名は同じだがフィールド構成が別物。import 修正後は 884 件に増える |

**本PRでテストは 1 件も修正していない。** 「テスト側の修正だけで確実に直る」と言えるものが 0 件だったため
（skip/無効化もしていない）。lib/ は変更していない。削除も行っていない（提案のみ）。

## 個別所見

### 1. export_service_test.dart — (2) 実装が未完成

- 誤り: import が `your_app_name`、`report_model.dart`/`export_service.dart`（`ExportConfig` は `export_models.dart`、
  `ExportService` は `export_service_impl.dart` にある）。
- import を `export_models.dart` + `export_service_impl.dart` に直し、`clearAllCache()`（lib に無い）の呼び出しを除いて実行すると、
  `exportData` 系テストの多くが失敗する。
  - `status` が `'ready'` を期待 → 実装は常に `'pending'`
  - `fileSizeBytes > 0` → 実装は常に `0`
  - `isEncrypted == true`（`encryptionType: 'aes256'`）→ `null`
  - `expiresAt` / `downloadCount` → 常に `null`
- 根拠: `lib/services/export_service_impl.dart` の `exportData` は `ExportResult` を固定値で返すだけのスタブ
  （コメントなし、`dataRecords` も `config` も `recordCount` 以外参照しない）。
- 注意点（製品面）: `maskPersonalData` / `includePersonalInfo` / `encryptionType` / `includedFields` が **受け取るだけで無視される**。
  `exportDataProvider`（`lib/viewmodels/providers.dart:1114` 付近）はこれらを渡すが、現時点で UI からの呼び出しは確認できなかった。
  将来配線する場合は、個人情報マスクが効かないままエクスポートされるリスクがある。
- 方針: `exportData` を実装する（マスク・項目絞り込み・暗号化・有効期限）か、機能を使わないなら `exportData` と
  このテストを一緒に整理する。いずれも lib 変更が必要。テスト側だけでは直らない。

### 2. phase_62_export_test.dart — (2) 実装バグ（5件が実行時失敗）

現行の `lib/models/export_models.dart` / `lib/services/export_service.dart`（`ExportEngine`/`ReportEngine`/`ExportManager`/`ExportFacade`）と
唯一整合しており、analyze エラー 0。70 件中 65 件が通り、5 件が失敗する。6 回連続実行で同一の 5 件が再現した。

| 失敗テスト | 原因 | lib 側の修正方針 |
|---|---|---|
| `Calculate success rate`（95/100 で `isHealthy == true` を期待） | `ExportStatistics.isHealthy` が `successRate > 95.0`。95.0 ちょうどで false | 境界仕様を決める。テストの意図（95%は健全、90%は不健全）に合わせるなら `>= 95.0` |
| `Get statistics in date range` | `MemoryExportRepository.getStatisticsInRange` が `isAfter(start) && isBefore(end)`（排他的）。`periodStart == start` の統計が除外される | 境界を含める（`!isBefore(start) && !isAfter(end)`） |
| `List exports` / `Multiple exports simultaneously` / `Export formats variety` | `ExportEngine.initializeExport` の ID が `'export_${DateTime.now().millisecondsSinceEpoch}'`。同一ミリ秒に複数回呼ぶと **ID が衝突**して後勝ちで上書き（4件作って 1件になる） | 連番/UUID 等、衝突しない ID にする（`ExportEngine.processExport` の `task_...` も同様） |

テスト側で `Future.delayed` を挟む、開始日時を1分ずらす、期待値を 96% に変える、といった修正で通すことは可能だが、
**いずれも lib の不具合を隠すだけ**なので行っていない。lib 修正後は無修正で全件通る見込み（ただし未確認）。
→ ID 衝突はテスト環境でのみ顕在化しやすいが、アプリが同一ミリ秒に複数ジョブを作る経路があれば本番でも起こり得る。

### 3. phase_46 / phase_59（通知）— (3) 削除提案

- 現行 lib（`notification_models.dart` / `notification_service.dart`）の `Notification` には `type` フィールドが無く、
  `NotificationType` は `{mention, reply, like, comment, system, alert}`、各 enum に `.value` は無い。
  `MemoryNotificationManager(this._repository)` は位置引数1つで、`NotificationManagerFacade` は存在しない（実体は `NotificationFacade`）。
- phase_46 は `.value` 付き enum・`Notification(type: ...)`・`MemoryNotificationManager(repository:, deliveryEngine:)`・
  `createNotification`、phase_59 は `NotificationType.info/success/warning/error`・`PriorityLevel`・`titleTemplate`・`supportedChannels` を使う。
  **両者は互いにも非互換**で、同じ lib に対して成立し得るのはどちらか一方（実際は両方とも成立しない）。
- 修正するには 46 または 59 のどちらかの設計に合わせて lib とテストの双方を作り直す必要があり、テスト修正では直らない。
- 提案: 削除（現行の通知実装 `notification_service_impl.dart` を検証するテストは別途新規に書く方が安い）。

### 4. phase_47 / phase_61 / phase_90（分析）— (3) 削除提案

- 現行 `analytics_models.dart` の先頭コメントは「Phase 90」。型名 `PredictionType/AnomalyType/FraudDetection/Recommendation` は
  phase_90 と一致するが、**フィールド構成が別**（lib の `PredictiveModel` 等は `modelName`/`createdAt`/`datasetId` を必須とし、
  テストは `name`/`trainingDataPoints` 等を渡す。enum 値も `PredictionType.batch`、`AnomalyType.statistical` などは lib に無い）。
  import を正しい形（`package:bike_license_kore/...`）に直して再解析すると、エラーは 247 → **884 件**に増える（それまでは未解決 import で隠れていた）。
- phase_47（`AnalyticsMetricType`, `AnalyticsMetric`, `TimeSeriesDataPoint`）と phase_61（`TimePeriod`, `AggregationType`,
  `AnalyticsFacade.recordMetric/generateReport`）は、lib に該当型・メソッド自体が無い。Phase 90 の設計に置き換えられた旧版とみられる
  （履歴が squash されており git 上では確認不能。ファイル内容からの推定）。
- 提案: phase_47 / phase_61 は削除。phase_90 は 2043 行のテストを現行 lib に合わせて書き直すか、削除して現行モデルの
  テストを新規作成。いずれもテスト修正だけで「確実に直る」とは言えない規模。

### 5. phase_49 / phase_56（エクスポート）— (3) 削除提案

- 現行 lib は phase_62 設計（`ExportFormat {csv,json,xml,pdf}`, `ReportStatus`, `ExportJob(jobId, dataSource, ...)`, `ExportManager`,
  `ExportFacade`）。phase_49 は `ReportType/ExportStatus/ExportManagerFacade/MemoryReportEngine`・`ScheduleFrequency.value`・
  `ExportRepository.addJob`、phase_56 は `ExportConfiguration/ReportType/FilterType/ExportJobStatus/MemoryExportEngine` を使う。いずれも lib に無い。
- phase_62 と同じ領域（エクスポート）を別設計でテストしている旧世代。phase_62 が残れば領域のカバレッジは保てる。
- 提案: 削除。

## 参考: CI の失敗34件との関係（推定）

テストファイルのコンパイル不能は 1 ファイル = 1 失敗として集計される（`scripts/ci_guard.py` は `testDone` の error を数える）。
(C) のうち 8 ファイルがコンパイル不能 → 8 件、phase_62 が 5 件、他にコンパイル不能の対象外ファイル
（`offline_sync_integration_test` ほか 5 ファイル）が 6 件で計 19 件。残り約 15 件は未特定。
(C) の 8 ファイルを削除すれば `ci/test_failure_baseline.txt` は 34 → 26 になる見込みだが、
実測前なので本PRでは変更していない。phase_62 の lib 修正が入れば更に 5 件減る。
