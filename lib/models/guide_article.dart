/// 「役立つ情報」の解説記事。わかりにくい決まりを、図つきで説明する。
///
/// 内容は道路交通法・標識令・教則の本文で確認したものだけを書く。
/// 各記事の [sourceRef] に根拠、[checkedAt] に確認日を持つ。
library;

/// 記事の中で使う図の種類（lib/widgets/guide_diagrams.dart で描画）。
enum GuideDiagram {
  /// 道路の中央の白い線（中央線）
  centerWhite,

  /// 道路の中央の黄色い線（追越しのための右側部分はみ出し通行禁止）
  centerYellow,

  /// 道路の端の黄色の実線（駐停車禁止）
  kerbYellowSolid,

  /// 道路の端の黄色の破線（駐車禁止）
  kerbYellowBroken,

  /// 白の実線1本（路側帯）
  stripSingle,

  /// 白の実線と破線（駐停車禁止路側帯）
  stripSolidBroken,

  /// 白の2本線（歩行者用路側帯）
  stripDouble,

  /// 二段階右折の進路
  twoStageRightTurn,
}

class GuideFigure {
  const GuideFigure(this.diagram, this.caption);

  final GuideDiagram diagram;
  final String caption;
}

class GuideSection {
  const GuideSection({required this.heading, required this.body, this.figures = const []});

  final String heading;
  final String body;
  final List<GuideFigure> figures;
}

class GuideArticle {
  const GuideArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.sections,
    required this.sourceRef,
    this.officialFigures = const [],
    this.checkedAt = '2026-10-02',
  });

  final String id;
  final String title;
  final String summary;
  final List<GuideSection> sections;

  /// 根拠（条文・告示の名前と箇所）。
  final String sourceRef;

  /// 公式の図（assets/guides/ の標識令の図）。(ファイル名, 説明)
  final List<(String, String)> officialFigures;

  final String checkedAt;
}

const List<GuideArticle> kGuideArticles = [
  GuideArticle(
    id: 'line_colors',
    title: '黄色い線と白い線の意味',
    summary: '道路の真ん中や端にある線の色で、禁止されることが変わります。',
    sourceRef: '標識令 別表第六（102・103・104・205）、教則 付表3（2）',
    sections: [
      GuideSection(
        heading: '道路の真ん中の線',
        body: '白い線は「中央線」で、道路の中央を示します。'
            '黄色い線は「追越しのための右側部分はみ出し通行禁止」を表します。'
            '黄色い線のある道路では、追越しのために道路の右側部分にはみ出して通行してはいけません。',
        figures: [
          GuideFigure(GuideDiagram.centerWhite, '白＝中央線'),
          GuideFigure(GuideDiagram.centerYellow, '黄＝追越しのためのはみ出し禁止'),
        ],
      ),
      GuideSection(
        heading: '道路の端の黄色い線',
        body: '道路の端（縁石の側）に引かれた黄色い線は、駐停車の規制を表します。'
            '実線は「駐停車禁止」（停車も駐車もできない）、破線は「駐車禁止」（停車はできるが駐車はできない）です。',
        figures: [
          GuideFigure(GuideDiagram.kerbYellowSolid, '黄の実線＝駐停車禁止'),
          GuideFigure(GuideDiagram.kerbYellowBroken, '黄の破線＝駐車禁止'),
        ],
      ),
      GuideSection(
        heading: '覚え方',
        body: '黄色は「してはいけないこと」の線、白は「道路の区分を示す」線と考えると整理しやすくなります。'
            'ただし、禁止の内容は線の場所と形（実線か破線か）で決まるので、「黄色い線だから通行できない」のではありません。',
      ),
    ],
    officialFigures: [
      ('std_102_a.jpg', '追越しのための右側部分はみ出し通行禁止（102）の標示'),
      ('std_103.jpg', '駐停車禁止（103）の標示'),
      ('std_104.jpg', '駐車禁止（104）の標示'),
    ],
  ),
  GuideArticle(
    id: 'roadside_strips',
    title: '路側帯の線の種類',
    summary: '道路の端の白い線は、本数と形で「駐停車できるか」「入れるか」が変わります。',
    sourceRef: '標識令 別表第六（108・108の2・108の3）、教則 第9章（駐車、停車の方法）・付表3（2）',
    sections: [
      GuideSection(
        heading: '3種類の路側帯',
        body: '路側帯とは、歩道のない道路で、歩行者の通行などのために白い線で区分された道路の端の部分です。'
            '線の形で意味が変わります。',
        figures: [
          GuideFigure(GuideDiagram.stripSingle, '白の実線1本＝路側帯'),
          GuideFigure(GuideDiagram.stripSolidBroken, '白の実線と破線＝駐停車禁止路側帯'),
          GuideFigure(GuideDiagram.stripDouble, '白の2本線＝歩行者用路側帯'),
        ],
      ),
      GuideSection(
        heading: '路側帯の中に車を止められるか',
        body: '白の実線1本の路側帯は、幅が広い場合は中に入って駐停車できます。その場合は、0.75メートル以上の余地を空けておきます。'
            '白の実線と破線、または白の2本線の路側帯は、幅が広くても中に入って駐停車することはできません。',
      ),
      GuideSection(
        heading: '押さえるポイント',
        body: '駐停車禁止路側帯は、車の駐車と停車が禁止されている路側帯です。'
            '歩行者用路側帯は、車の駐停車に加えて、特例特定小型原動機付自転車と軽車両の通行も禁止されています。',
      ),
    ],
    officialFigures: [
      ('std_108.jpg', '路側帯（108）の標示'),
      ('std_108_2.jpg', '駐停車禁止路側帯（108の2）の標示'),
      ('std_108_3.jpg', '歩行者用路側帯（108の3）の標示'),
    ],
  ),
  GuideArticle(
    id: 'two_stage_right_turn',
    title: '二段階右折の条件と方法',
    summary: '原付が右折するとき、小回りで曲がるか二段階で曲がるかは、交差点の条件で決まります。',
    sourceRef: '道路交通法第34条第2項・第5項、教則 第8章（一般原動機付自転車の右折）',
    sections: [
      GuideSection(
        heading: '対象になるのは原動機付自転車だけ',
        body: '二段階右折をするのは「一般原動機付自転車」（原付）です。50cc以下の原付と、最高出力4.0kW以下に制御した125cc以下の新基準原付が含まれます。'
            '普通二輪・大型二輪などの自動二輪車は、二段階右折の対象ではなく、小回りで右折します。',
      ),
      GuideSection(
        heading: '二段階右折をする交差点',
        body: '信号機などで交通整理が行われている交差点で、次のどちらかに当てはまるとき、二段階右折をします。\n'
            '・「一般原動機付自転車の右折方法（二段階）」の標識がある\n'
            '・車両通行帯が3以上ある道路\n'
            'ただし「一般原動機付自転車の右折方法（小回り）」の標識がある道路は、小回りで右折します。\n'
            '交通整理が行われていない交差点では、二段階右折はしません。',
      ),
      GuideSection(
        heading: '二段階右折のしかた',
        body: '①あらかじめできるだけ道路の左端に寄り、交差点の手前の側端から30メートルの地点で右折の合図を出します。\n'
            '②青信号で、徐行しながら交差点の向こう側までまっすぐ進みます。\n'
            '③その地点で止まって右に向きを変え、合図をやめます。\n'
            '④前方の信号が青になってから進みます。\n'
            'この方法のときは、青の矢印の信号で右折することはできません。',
        figures: [
          GuideFigure(GuideDiagram.twoStageRightTurn, '①左端を直進 → ②向こう側で止まり右に向きを変える → ③前方が青で直進'),
        ],
      ),
      GuideSection(
        heading: '小回りの右折',
        body: '小回りで右折するときは、あらかじめできるだけ道路の中央に寄り、交差点の中心のすぐ内側を徐行して進みます。'
            'このときは、青の矢印の信号に従って右折できます。',
      ),
    ],
  ),
  GuideArticle(
    id: 'no_parking_vs_no_stopping',
    title: '駐車禁止と駐停車禁止の違い',
    summary: '「止められない場所」は2種類あり、停車できるかどうかが違います。',
    sourceRef: '道路交通法第2条第1項第18号・第19号、第44条、第45条',
    sections: [
      GuideSection(
        heading: '停車と駐車',
        body: '駐車とは、客待ち・荷待ち・故障などで継続して止めること、または運転者が車を離れてすぐには運転できない状態で止めることです。'
            '貨物の積卸しで5分を超えない停止や、人の乗降のための停止は、駐車ではなく停車です。',
      ),
      GuideSection(
        heading: '駐停車禁止の場所（第44条）',
        body: '停車も駐車もできない場所です。\n'
            '・交差点、横断歩道、自転車横断帯、踏切、軌道敷内、坂の頂上付近、勾配の急な坂、トンネル\n'
            '・交差点の側端や道路の曲がり角から5メートル以内\n'
            '・横断歩道・自転車横断帯の前後の側端からそれぞれ5メートル以内\n'
            '・安全地帯の左側と、その前後の側端からそれぞれ10メートル以内\n'
            '・バス停などの標示柱から10メートル以内（運行時間中）\n'
            '・踏切の前後の側端からそれぞれ10メートル以内',
      ),
      GuideSection(
        heading: '駐車禁止の場所（第45条）',
        body: '停車はできますが、駐車はできない場所です。\n'
            '・自動車用の出入口から3メートル以内\n'
            '・道路工事区域の側端から5メートル以内\n'
            '・消防用機械器具の置場、消防用防火水槽の側端や出入口から5メートル以内\n'
            '・消火栓、指定消防水利の標識の位置、防火水槽の吸水口などから5メートル以内\n'
            '・火災報知機から1メートル以内',
      ),
    ],
  ),
  GuideArticle(
    id: 'new_standard_moped',
    title: '新基準原付とは（2025年4月から）',
    summary: '125ccでも、最高出力を4.0kW以下に制御した二輪車は原付として扱われます。',
    sourceRef: '道路交通法施行規則第1条の2、同法施行令第11条',
    sections: [
      GuideSection(
        heading: '原付の範囲',
        body: '二輪の原動機付自転車は、総排気量50cc以下のもの、または、最高出力を4.0kW以下に制御した総排気量125cc以下のものです。'
            '後者を「新基準原付」と呼びます。',
      ),
      GuideSection(
        heading: '原付と同じ扱いになること',
        body: '新基準原付は原動機付自転車なので、一般道路での最高速度は30km/h、二人乗りはできず、二段階右折の対象になります。'
            '原付免許で運転できます。',
      ),
      GuideSection(
        heading: '区別のしかた',
        body: '同じ125ccでも、最高出力が4.0kWを超える二輪車は小型二輪（自動二輪車）で、小型限定普通二輪免許以上が必要です。'
            '最高速度は60km/hで、二人乗りは条件を満たせばできます。',
      ),
    ],
  ),
];
