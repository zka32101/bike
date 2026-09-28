import 'package:flutter/material.dart';

/// 本番の学科試験についての詳細情報・解説画面。
///
/// 免許区分によって出題数・制限時間が異なるため、原付と二輪（普通・大型・
/// AT限定・小型限定）の2パターンに分けて説明する。アプリ内の「本番模擬
/// テスト」機能の出題数・制限時間もこの内容に準拠している。
class ExamInfoView extends StatelessWidget {
  const ExamInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('本番試験について')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SectionHeader(title: '学科試験の基本ルール'),
          _InfoCard(
            children: [
              _InfoRow(label: '合格ライン', value: '正答率90%以上'),
              _InfoRow(label: '出題形式', value: '文章問題（○×・4択形式）＋イラスト問題（危険予測）'),
              _InfoRow(label: '再受験', value: '不合格の場合は日を改めて再受験可能（手数料が別途必要）'),
            ],
          ),
          SizedBox(height: 20),
          _SectionHeader(title: '原付免許（原動機付自転車）'),
          _ExamSpecCard(
            questionCount: '48問',
            breakdown: '文章問題 46問（1問1点）＋ イラスト問題 2問（1問2点）＝ 50点満点',
            timeLimit: '30分',
            passLine: '45点以上（90%以上）',
          ),
          SizedBox(height: 20),
          _SectionHeader(title: '二輪免許（普通自動二輪・大型自動二輪・AT限定・小型限定）'),
          _ExamSpecCard(
            questionCount: '95問',
            breakdown: '文章問題 90問 ＋ イラスト問題（危険予測）5問',
            timeLimit: '50分',
            passLine: '90%以上',
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '※ 指定自動車教習所を卒業した場合、技能試験は免除されますが、学科試験は'
              '別途、運転免許試験場・運転免許センターで受験する必要があります'
              '（教習所内の卒業検定とは別物です）。',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          SizedBox(height: 20),
          _SectionHeader(title: '出題される分野'),
          _InfoCard(
            children: [
              _InfoRow(label: '標識・標示', value: '道路標識・道路標示の意味'),
              _InfoRow(label: '法規・通行ルール', value: '交差点・追越し・駐停車などの交通法規'),
              _InfoRow(label: '駐停車・積載・二人乗り', value: '駐停車禁止場所、積載制限、二人乗りの条件'),
              _InfoRow(label: '運転操作・技能', value: '発進・停止・カーブなど基本操作の知識'),
              _InfoRow(label: '危険予測・安全確認', value: 'イラスト問題を中心とした危険予測'),
              _InfoRow(label: '整備・点検', value: '日常点検・車両の仕組み'),
              _InfoRow(label: '免許制度', value: '免許の種類・条件・有効期間など'),
              _InfoRow(label: '事故時の対応', value: '事故発生時の措置・応急救護'),
            ],
          ),
          SizedBox(height: 20),
          _SectionHeader(title: 'このアプリでの対策方法'),
          _InfoCard(
            children: [
              _InfoRow(label: '問題を解く／学習モード', value: '出題分野を幅広くカバーして基礎を固める'),
              _InfoRow(label: '標識クイズ', value: 'イラスト問題対策として標識の形・色・意味を練習'),
              _InfoRow(label: 'ヒッかけ問題クイズ', value: '引っかけ問題のパターンに慣れる'),
              _InfoRow(label: '数字・距離クイズ', value: '制限速度・制動距離など数値問題を集中練習'),
              _InfoRow(label: '本番模擬テスト', value: '実際と同じ出題数・制限時間・合格ラインで通し練習'),
            ],
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

/// 免許区分ごとの試験仕様（出題数・制限時間・合格ライン）を表示するカード。
class _ExamSpecCard extends StatelessWidget {
  const _ExamSpecCard({
    required this.questionCount,
    required this.breakdown,
    required this.timeLimit,
    required this.passLine,
  });

  final String questionCount;
  final String breakdown;
  final String timeLimit;
  final String passLine;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SpecChip(icon: Icons.format_list_numbered, label: '出題数：$questionCount'),
                const SizedBox(width: 8),
                _SpecChip(icon: Icons.timer_outlined, label: '制限時間：$timeLimit'),
              ],
            ),
            const SizedBox(height: 12),
            Text('内訳：$breakdown', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Text(
              '合格ライン：$passLine',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecChip extends StatelessWidget {
  const _SpecChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
