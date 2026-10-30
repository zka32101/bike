# 読み物(章ごとの読み物)

ukalab_core の `ChapterReading` 形式(v0.87.0〜)で、手順と表を使った読み物を提供する。

## データ

- ファイル: `assets/experience/chapter_readings_bike.jsonl`(1行1読み物。先頭の `//` 行はコメント)
- 読み込み: `lib/data/chapter_readings.dart`(`loadChapterReadings`)。core の検証に加え、次を満たさないと読み込みで例外にする。
  - `source` は `original`、`sourceRef` に「自作」「AI下書き由来」を含み、「専門家確認済み」を含まない
  - 本文・表・手順に、禁止語(`kReadingForbiddenWords`)と、数字・条文番号・距離の表現を入れない
  - `relatedQuestionIds` の問題と、`relatedLinks` の hazard の参照先(`HazardScenario.scenarioId`)が実在する
- `sourceRef`: 「自作（AI下書き由来。体験コンテンツのため専門家確認は不要と判断）」。危険予測シナリオと同じ扱い。
- `contentVer`: 新規は "1"。本文を変えたら上げる。
- 試作フラグ(`READING_PROTOTYPE` / `showReadingPrototype`)は廃止。常に有効。

## 画面

| 画面 | ファイル | 内容 |
|---|---|---|
| 入口 | `lib/views/guide_view.dart` の `ReadingEntryCard` | 「役立つ情報」の先頭 |
| 一覧・詳細 | `lib/views/chapter_reading_view.dart` | 節は core の `ReadingSectionContent`。末尾に確認問題リンクと危険予測の導線 |
| 誤答導線 | `lib/widgets/reading_feedback.dart` | 毎日の練習の誤答時、`AnswerResultOverlay.wrongAnswerExtra` に `RelatedReadingsCard` |

- 確認問題リンク: 先頭 `kReadingFirstQuestionLinks`(5)件だけ出し、「すべて見る」で全件。先頭5件は区分を問わず共通の問題を選ぶ(`relatedQuestionIds` の並び順がそのまま表示順)。ラベルは問題文そのまま(core が3行まで折り返す)。
- 危険予測: `relatedLinks` の `kind: hazard` の id を `hazardLinkIds` で取り出す。画面は既存の `HazardScenarioListView` へ遷移し、無料枠・プレミアム限定の判定は一覧に任せる。
- 誤答導線は誤答原因の選択欄(`AnswerFeedbackPanel`)を使わず、単体の `RelatedReadingsCard` を使う。記録先のない選択欄を置かない。
- 広告: 読み物の画面・誤答導線には置かない。既存の広告配置ルール(問題中・危険予測ゾーンに広告なし、noads/premium は広告なし)は変更なし。`test/chapter_reading_test.dart` に静的ガードがある。

## 表の作り方

長文セルが縦に長くならないよう、表は3列以下にする(場面・先に確かめること・基本の動き)。補足の列は表の下の箇条書きの節に分ける。

## テスト

core v0.87.0 は4文字以上の数字語の `Text.data` に U+2060 を入れる。完全一致の `find.text` は、`replaceAll('⁠', '')` してから比べる。
