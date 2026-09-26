import 'package:flutter/material.dart';

/// アプリ全体の使い方・仕組みを説明するヘルプ画面。
/// 設定画面から開けるほか、初回オンボーディングの最後にも表示される
/// （[onContinue] が渡されている場合は続行ボタンを表示する）。
class HelpView extends StatelessWidget {
  const HelpView({super.key, this.onContinue});

  /// 指定されている場合、末尾に「次へ」ボタンを表示し、初回導線として使う。
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('アプリの使い方')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: const [
            _HelpSection(
              title: '無料でできること',
              body: '原付区分の最初の30問は、期間の制限なくいつでも無料で解けます。'
                  '一度覚えた問題を何度でも復習できます。',
            ),
            _HelpSection(
              title: '他の区分・原付の残り問題',
              body: '普通二輪・大型二輪・AT限定各種・小型限定普通二輪の問題、'
                  'および原付の31問目以降は、パスを購入すると解放されます。'
                  '「単一区分パス」は選んだ1区分のみ、「全区分セットパス」は'
                  '全区分がまとめて解放され、以降は合格まで無制限に学習できます。',
            ),
            _HelpSection(
              title: '問題を解く（ランダム出題）',
              body: 'ホーム画面の「問題を解く」から、その区分の問題に挑戦できます。'
                  'パス購入済みの区分では、まだ覚えていない問題の中からランダムに'
                  '出題され、上限はありません。',
            ),
            _HelpSection(
              title: '学習モード（読んで覚える）',
              body: 'クイズ形式で解く代わりに、問題文・正解・解説をまとめて'
                  '読みながら学習できるモードです。出題対象の範囲は「問題を解く」'
                  'と同じ無料/購入のルールが適用されます。',
            ),
            _HelpSection(
              title: '学習分析・合格予測',
              body: '回答結果は自動的に記録され、学習分析画面で弱点や伸びを'
                  '確認できます。合格予測メーターは、十分な回答数が集まると'
                  '表示されます。',
            ),
            _HelpSection(
              title: '試験日・教習段階',
              body: '設定画面から、免許区分ごとに試験日を登録できます。'
                  '複数区分を選んでいる場合は、区分ごとに別々の日付を'
                  '管理できます。',
            ),
                  _HelpSection(
                    title: '広告について',
                    body: '無料版では、練習を1回終えるとまれに広告が表示されることが'
                        'あります。パスを購入すると広告は表示されなくなります。',
                  ),
                ],
              ),
            ),
            if (onContinue != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onContinue,
                    child: const Text('次へ'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  const _HelpSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
