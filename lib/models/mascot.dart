/// うかラボ共通の「推し」キャラクター（初回ラインナップの画像4体）。
///
/// 成長Lv(1〜5)は習熟度から決まり、下がらない。画像は assets/mascot/<id>/。
enum Mascot {
  kai('kai', 'カイ', '頼れる先輩', _kaiLines),
  mio('mio', 'ミオ', '明るい後輩', _mioLines),
  moka('moka', 'モカ', 'ゆるい相棒（犬）', _mokaLines),
  mike('mike', 'ミケ', 'ていねいな解説役（猫）', _mikeLines);

  const Mascot(this.id, this.displayName, this.role, this.lines);

  final String id;
  final String displayName;
  final String role;

  /// Lv別の励ましの一言（責めない・短く）。index 0 = Lv1。
  final List<List<String>> lines;

  static Mascot? fromId(String? id) {
    for (final m in Mascot.values) {
      if (m.id == id) return m;
    }
    return null;
  }

  String get iconAsset => 'assets/mascot/$id/${id}_icon_256.webp';

  /// 通常画像（Lv別）。[costume] が true ならバイク免許のヘルメット衣装。
  String imageAsset(int level, {bool costume = false, bool passed = false}) {
    final lv = level.clamp(1, 5);
    if (costume) {
      if (passed) return 'assets/mascot/$id/${id}_bike_pass.webp';
      return 'assets/mascot/$id/${id}_bike_${lv >= 5 ? 'lv5' : 'lv1'}.webp';
    }
    return 'assets/mascot/$id/${id}_lv${lv}_normal.webp';
  }

  String joyAsset(int level) =>
      'assets/mascot/$id/${id}_lv${level.clamp(1, 5)}_joy.webp';
}

/// 習熟度スコア(0〜100)と回答数から成長Lvを求める。
int mascotLevelFromScore(double? score, int answeredCount) {
  if (score == null || answeredCount < 10) return 1;
  if (score >= 80) return 5;
  if (score >= 60) return 4;
  if (score >= 40) return 3;
  if (score >= 20) return 2;
  return 1;
}

/// 日付から決まる一言（同じ日は同じ言葉、日が変わると入れ替わる）。
String mascotLine(Mascot m, int level, {int salt = 0, DateTime? now}) {
  final list = m.lines[(level.clamp(1, 5)) - 1];
  final d = now ?? DateTime.now();
  final day = d.year * 400 + d.month * 31 + d.day;
  return list[(day + salt).abs() % list.length];
}

const _kaiLines = <List<String>>[
  ['まずは1問から。ゆっくりいこう。', '焦らなくていい。今日の一歩が大事だ。'],
  ['いい調子だ。続けていこう。', '少しずつ形になってきたな。'],
  ['基礎はしっかりしてきたぞ。', '苦手な所も、一緒に潰していこう。'],
  ['合格が見えてきたな。', 'ここまで来たのは、積み重ねの成果だ。'],
  ['仕上げの段階だ。自信を持っていい。', '本番も、いつも通りでいこう。'],
];
const _mioLines = <List<String>>[
  ['はじめの一歩、えらい！', '1問からでOK！いっしょにやろう！'],
  ['いいね、その調子！', 'どんどん覚えてるよ！'],
  ['すごい、半分近くまで来たよ！', '苦手もちょっとずつ減ってるね！'],
  ['もうすぐだよ、がんばろう！', 'ここまで来たの、本当にすごい！'],
  ['もう完璧に近いよ！', '本番もぜったい大丈夫！'],
];
const _mokaLines = <List<String>>[
  ['のんびりいこうね〜。', '1問だけでも、わふっ、えらい。'],
  ['いい感じ〜。ごほうびのおやつ、ほしいね。', 'ちょっとずつ、ちょっとずつ。'],
  ['けっこう覚えたね〜。', 'あったかいお茶でひと休みしよ。'],
  ['もうすぐゴールだね、わふっ。', 'すごいなぁ、いっしょにうれしい。'],
  ['ばっちりだね〜！', '本番もゆったり、だよ。'],
];
const _mikeLines = <List<String>>[
  ['まずは基本から。順に説明するわ。', '1問ずつで十分よ。'],
  ['理解が進んでいるわね。', '用語の意味も、少しずつ押さえましょう。'],
  ['要点をつかめてきたわね。', '間違えた所は、理由を確認すれば力になるわ。'],
  ['仕上がりは上々よ。', 'あと少し。落ち着いて確認しましょう。'],
  ['十分な実力ね。自信を持って。', '本番では見直しを忘れずに。'],
];
