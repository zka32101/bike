/// 技能試験（教習所の検定・試験場の技能試験）のコツ読み物と練習チェックリスト。
///
/// 定性的な内容だけを書く。速度・距離・時間・減点・合格点・コース寸法などの数値は
/// 教習所・試験場ごとに異なるため扱わない（指導員の指示・教習所の基準に従う）。
library;

import '../core/constants/license_category.dart';

/// コツの1項目。[manualOnly] が true のものは、クラッチ操作のない区分（原付・AT限定）では出さない。
class SkillTipSection {
  const SkillTipSection({required this.heading, required this.body, this.manualOnly = false});

  final String heading;
  final String body;
  final bool manualOnly;
}

/// チェックリストの1項目。
class SkillCheckItem {
  const SkillCheckItem(this.text, {this.manualOnly = false});

  final String text;
  final bool manualOnly;
}

/// 技能試験の1種目。
class SkillExamTip {
  const SkillExamTip({
    required this.id,
    required this.title,
    required this.summary,
    required this.categories,
    required this.sections,
    required this.checklist,
    this.contentStatus = 'ai-draft',
    this.source = 'original',
    this.sourceRef = '自作（AI下書き・専門確認前。法令・教習所細則の転載なし）',
  });

  final String id;
  final String title;
  final String summary;

  /// この種目を出す免許区分。
  final Set<LicenseCategory> categories;
  final List<SkillTipSection> sections;
  final List<SkillCheckItem> checklist;

  final String contentStatus;
  final String source;
  final String sourceRef;

  /// [category] で表示するコツ（クラッチ操作のない区分では manualOnly を除く）。
  List<SkillTipSection> sectionsFor(LicenseCategory category) => [
        for (final s in sections)
          if (!s.manualOnly || skillCategoryUsesClutch(category)) s,
      ];

  List<SkillCheckItem> checklistFor(LicenseCategory category) => [
        for (final c in checklist)
          if (!c.manualOnly || skillCategoryUsesClutch(category)) c,
      ];
}

/// クラッチ操作がある区分か（原付・AT限定は操作がない）。
bool skillCategoryUsesClutch(LicenseCategory category) =>
    category != LicenseCategory.gentsuki && category != LicenseCategory.atGentei;

/// 画面に出す注意書き。
const String kSkillExamDraftNotice = '学習用の解説（AI下書き・専門確認前）';
const String kSkillExamFollowNotice =
    '速さ・距離・時間・減点などの基準は教習所・試験場によって異なります。指導員の指示・教習所の基準に従ってください。';

/// 区分に合わせた種目の一覧。
List<SkillExamTip> skillExamTipsFor(LicenseCategory category) =>
    [for (final t in kSkillExamTips) if (t.categories.contains(category)) t];

const Set<LicenseCategory> _all = {
  LicenseCategory.gentsuki,
  LicenseCategory.kogataGentsukiNirin,
  LicenseCategory.futsuuNirin,
  LicenseCategory.ogataNirin,
  LicenseCategory.atGentei,
};

const Set<LicenseCategory> _nirin = {
  LicenseCategory.kogataGentsukiNirin,
  LicenseCategory.futsuuNirin,
  LicenseCategory.ogataNirin,
  LicenseCategory.atGentei,
};

const List<SkillExamTip> kSkillExamTips = [
  SkillExamTip(
    id: 'basic_riding',
    title: '乗車姿勢・発進と停止・安全確認',
    summary: 'どの種目にも共通する土台。姿勢と確認の習慣が、あとの種目の安定につながります。',
    categories: _all,
    sections: [
      SkillTipSection(
        heading: '目線と姿勢',
        body: '目線は進む先、できるだけ遠くへ向けます。足元や前輪を見つめると、車体がふらつきやすくなります。'
            '肩とひじの力を抜き、ハンドルは握りしめず、ひざで車体を軽くはさんで体を安定させます。',
      ),
      SkillTipSection(
        heading: '発進と停止',
        body: '発進の前に、目と頭で周囲を確認し、合図を出してから動き出します。'
            '停止は、ブレーキを前後ともに使い、止まる直前に力をゆるめると、車体の揺れが少なくなります。',
      ),
      SkillTipSection(
        heading: 'クラッチの考え方',
        body: 'クラッチは、つなぐ位置を手で覚えておくと、発進や低い速度での操作が落ち着きます。急に離さず、ゆっくり丁寧に扱います。',
        manualOnly: true,
      ),
      SkillTipSection(
        heading: 'スロットルの考え方',
        body: 'スロットルは、急に開けたり急に戻したりせず、なめらかに動かします。ブレーキとの切り替えも、一定のリズムで行います。',
      ),
    ],
    checklist: [
      SkillCheckItem('乗る前に、周囲と車体の状態を確認する習慣がある'),
      SkillCheckItem('目線が進む先に向いている'),
      SkillCheckItem('肩・ひじ・手首の力が抜けている'),
      SkillCheckItem('発進前に確認と合図を行っている'),
      SkillCheckItem('止まる直前にブレーキをやわらげている'),
      SkillCheckItem('クラッチを急に離さず、つなぐ位置を手で覚えている', manualOnly: true),
    ],
  ),
  SkillExamTip(
    id: 'ippon_bashi',
    title: '一本橋',
    summary: '細い橋の上を、ふらつかず落ち着いて通る種目。バランスと目線がカギです。',
    categories: _nirin,
    sections: [
      SkillTipSection(
        heading: '目線',
        body: '橋の入口ではなく、渡った先の遠くを見ます。足元を見ると体が固まり、車体が左右に振られやすくなります。',
      ),
      SkillTipSection(
        heading: 'バランスの取り方',
        body: '上半身の力を抜き、ひざで車体をはさんで下半身で支えます。ハンドルで直そうとせず、体の重心で車体を落ち着かせる意識を持ちます。',
      ),
      SkillTipSection(
        heading: 'スロットル・ブレーキ・クラッチ',
        body: '進入前に速さを整えておき、橋の上では急な操作を避けます。後ろブレーキを軽く残すと、車体が安定しやすくなります。'
            'クラッチは半分つながった状態を保ち、速度を細かく調整します。',
        manualOnly: true,
      ),
      SkillTipSection(
        heading: 'ブレーキとスロットル（クラッチ操作のない区分）',
        body: '橋の上では、スロットルを少し開け気味にして、後ろブレーキを軽く当てると、速度を整えながら安定して進めます。',
      ),
      SkillTipSection(
        heading: '失敗しやすい点',
        body: '落ちるのが怖くて目線が下がる、進入の姿勢が整っていない、途中で急に操作を変える、などが典型です。'
            '時間や速度の基準は教習所によって異なるので、指導員の指示に従って練習してください。',
      ),
    ],
    checklist: [
      SkillCheckItem('橋に入る前に、まっすぐ進入できる位置と向きを整えている'),
      SkillCheckItem('目線が渡った先の遠くにある'),
      SkillCheckItem('上半身の力が抜け、ひざで車体をはさんでいる'),
      SkillCheckItem('橋の上で急なスロットル操作をしていない'),
      SkillCheckItem('半クラッチを保ち、速度を細かく調整できる', manualOnly: true),
      SkillCheckItem('降りたあとも落ち着いて次の動作に移れる'),
    ],
  ),
  SkillExamTip(
    id: 'slalom',
    title: 'スラローム',
    summary: '並んだ目印の間を、左右に切り返しながら抜ける種目。リズムと目線がポイントです。',
    categories: _nirin,
    sections: [
      SkillTipSection(
        heading: '目線',
        body: '目の前の目印ではなく、次の、さらにその先の目印へ視線を送ります。目線が先に行くと、体と車体があとからついてきます。',
      ),
      SkillTipSection(
        heading: '体の使い方とリズム',
        body: '車体を倒す動きは、ハンドルをこじるのではなく、体重移動で作ります。'
            '切り返しは一定のリズムで、体を左右に入れ替える感覚で行うと、流れがなめらかになります。',
      ),
      SkillTipSection(
        heading: 'スロットル・ブレーキ・クラッチ',
        body: '進入前に速さを整え、コース中は一定の開け方を保ちます。速度が上がりすぎたときは、後ろブレーキで軽く整えます。'
            'クラッチは、必要なときに細かく使って車体の倒れ込みを支えます。',
        manualOnly: true,
      ),
      SkillTipSection(
        heading: 'スロットルとブレーキ（クラッチ操作のない区分）',
        body: 'スロットルを一定に保ち、速度が上がりすぎるときは後ろブレーキを軽く使って整えます。',
      ),
      SkillTipSection(
        heading: '失敗しやすい点',
        body: '目印を直前で見る、ハンドルだけで曲がろうとする、途中で操作が途切れてリズムが崩れる、などが典型です。'
            '間隔やタイムの基準は教習所によって異なるので、指導員の指示に従ってください。',
      ),
    ],
    checklist: [
      SkillCheckItem('進入前に速さと向きを整えている'),
      SkillCheckItem('次の目印の、さらに先へ視線を送れている'),
      SkillCheckItem('体重移動で車体を倒している（ハンドルをこじっていない）'),
      SkillCheckItem('切り返しのリズムが一定になっている'),
      SkillCheckItem('スロットルを途中で急に戻していない'),
      SkillCheckItem('クラッチを細かく使い、車体の倒れ込みを支えられる', manualOnly: true),
    ],
  ),
  SkillExamTip(
    id: 'kyuu_seidou',
    title: '急制動',
    summary: '決められた場所でしっかり止まる種目。前後ブレーキの配分と、止まるまでの姿勢が大切です。',
    categories: _all,
    sections: [
      SkillTipSection(
        heading: '目線と姿勢',
        body: '目線は進む先に置き、止まるまで下げません。上半身は力を抜き、ひざでタンクをはさんで体が前に流れないようにします。',
      ),
      SkillTipSection(
        heading: 'ブレーキの考え方',
        body: '前ブレーキと後ろブレーキを同時に使い、最初はやさしく、徐々に強くしていきます。'
            '最初からつかみすぎると、タイヤがすべる原因になります。止まる直前に力をゆるめると、車体が安定します。',
      ),
      SkillTipSection(
        heading: 'クラッチとスロットル',
        body: 'ブレーキを使う前にスロットルを戻し、止まる直前にクラッチを切ってエンストを防ぎます。'
            '切るタイミングが早すぎると、エンジンブレーキが使えなくなる点に注意します。',
        manualOnly: true,
      ),
      SkillTipSection(
        heading: '失敗しやすい点',
        body: '怖くて前ブレーキを使えない、後ろだけを強くかけてロックさせる、目線が下がって姿勢が崩れる、などが典型です。'
            '速度や止まる位置の基準は教習所によって異なるので、指導員の指示に従ってください。',
      ),
    ],
    checklist: [
      SkillCheckItem('ブレーキの前に、スロットルを戻している'),
      SkillCheckItem('前後のブレーキを同時に使っている'),
      SkillCheckItem('最初はやさしく、徐々に強くかけている'),
      SkillCheckItem('止まるまで目線が下がらない'),
      SkillCheckItem('止まる直前に力をゆるめ、車体を安定させている'),
      SkillCheckItem('止まる直前にクラッチを切り、エンストを防げている', manualOnly: true),
    ],
  ),
  SkillExamTip(
    id: 's_crank',
    title: 'S字・クランク',
    summary: '連続する曲がり角を、低い速度で正確に通る種目。目線の先送りと車体の向きの作り方がカギです。',
    categories: _all,
    sections: [
      SkillTipSection(
        heading: '目線',
        body: '曲がり角の先、出口の方向へ早めに視線を送ります。顔を向けると、体と車体の向きが自然についてきます。',
      ),
      SkillTipSection(
        heading: '車体の操作',
        body: 'ハンドルは強くこじらず、車体を軽く倒しながら、体重移動で向きを変えます。'
            '曲がっている間は、スロットルを一定に保ち、速度を安定させます。',
      ),
      SkillTipSection(
        heading: 'クラッチ・ブレーキの考え方',
        body: '低い速度では、半クラッチと後ろブレーキを組み合わせると、車体の安定が保てます。'
            '前ブレーキは、ハンドルを切った状態では使いすぎないよう注意します。',
        manualOnly: true,
      ),
      SkillTipSection(
        heading: 'ブレーキの考え方（クラッチ操作のない区分）',
        body: '低い速度では、スロットルを小さく開けて、後ろブレーキで速さを整えると、車体が安定します。'
            '前ブレーキは、ハンドルを切った状態では使いすぎないよう注意します。',
      ),
      SkillTipSection(
        heading: '失敗しやすい点',
        body: '曲がり角の内側ばかり見る、速度が落ちすぎて車体がふらつく、操作が途切れて車体が膨らむ、などが典型です。'
            '通行のしかたや基準は教習所によって異なるので、指導員の指示に従ってください。',
      ),
    ],
    checklist: [
      SkillCheckItem('曲がる前に、出口の方向へ視線を送れている'),
      SkillCheckItem('ハンドルをこじらず、体重移動で向きを変えている'),
      SkillCheckItem('曲がっている間、速度が安定している'),
      SkillCheckItem('前ブレーキを使いすぎていない'),
      SkillCheckItem('半クラッチと後ろブレーキで、低い速度を保てる', manualOnly: true),
      SkillCheckItem('次の曲がり角に向けて、早めに準備ができている'),
    ],
  ),
  SkillExamTip(
    id: 'houkou_tenkan',
    title: '方向変換',
    summary: '限られた場所で、車体を押して向きを変える種目。無理をせず、車体を支えることが基本です。',
    categories: {
      LicenseCategory.kogataGentsukiNirin,
      LicenseCategory.futsuuNirin,
      LicenseCategory.ogataNirin,
      LicenseCategory.atGentei,
    },
    sections: [
      SkillTipSection(
        heading: '目線と姿勢',
        body: '進みたい方向へ顔と視線を向けます。腰を落として体を安定させ、車体は体の近くで支えます。',
      ),
      SkillTipSection(
        heading: '車体の扱い',
        body: 'ハンドルを大きく切るときは、車体が倒れやすくなります。倒れそうになったら、無理に起こそうとせず、いったん止まって支え直します。'
            '重い車体ほど、慌てず落ち着いた動きが大切です。',
      ),
      SkillTipSection(
        heading: '安全確認',
        body: '動き出す前と向きを変える前に、周囲の安全を確認します。コース内で別の車両や人がいないかを意識します。',
      ),
      SkillTipSection(
        heading: '失敗しやすい点',
        body: '焦って勢いをつけすぎる、足の置き場が不安定、目線が足元に落ちる、などが典型です。'
            '進め方や方法は教習所によって異なるので、指導員の指示に従ってください。',
      ),
    ],
    checklist: [
      SkillCheckItem('動き出す前に、周囲の安全を確認している'),
      SkillCheckItem('進みたい方向へ視線を向けている'),
      SkillCheckItem('腰を落とし、車体を体の近くで支えている'),
      SkillCheckItem('倒れそうなときは、無理をせず止まって支え直している'),
      SkillCheckItem('焦らず、落ち着いた動きで進められている'),
    ],
  ),
];
