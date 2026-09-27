import 'package:flutter/material.dart';

/// 標識クイズ専用モードで使う道路標識の視覚データ＋設問データ。
///
/// 【著作権方針】標識の絵は画像ファイルを一切使わず、
/// `TrafficSignWidget`（lib/widgets/traffic_sign_painter.dart）が
/// このデータをもとに CustomPainter でゼロから描画する。
/// 形状・色・意匠は道路標識令で定められた公共のデザインを
/// 単純な幾何学形状の組み合わせとして再現したもの。

/// 標識の外形。
enum SignShape {
  /// 円形（規制標識の多く）
  circle,

  /// 逆三角形（一時停止・徐行）
  invertedTriangle,

  /// ひし形（警戒標識）
  diamond,

  /// 四角形（指示標識・一方通行など）
  square,
}

/// 標識の中に描くシンボル（図柄）。すべて CustomPainter で描画する。
enum SignSymbol {
  none,

  /// 二輪車＋二人の乗員（二人乗り通行禁止）
  twoRiders,

  /// 二輪車＋一人の乗員（二輪の自動車・一般原付通行止め）
  motorcycle,

  /// 並んだ2台の車（追越し禁止）
  twoCars,

  /// U字の矢印（転回禁止）
  uTurnArrow,

  /// 上向きの矢印（指定方向外進行禁止・直進）
  arrowUp,

  /// 右向きの太い矢印（一方通行）
  oneWayArrow,

  /// 太い縦線と細い横線の交差（優先道路）
  priorityRoad,

  /// 機関車（踏切あり）
  train,

  /// 子どものシルエット（学校、幼稚園、保育所等あり）
  children,

  /// 縦型の信号機（信号機あり）
  trafficLight,

  /// 両側から狭まる道路（幅員減少）
  roadNarrows,

  /// 右へ曲がる矢印（右方屈曲あり）
  rightCurve,

  /// 車とスリップ跡（すべりやすい）
  slippery,
}

/// 禁止を表す赤線の種類。
enum SignSlash {
  none,

  /// 左上→右下の斜線1本
  single,

  /// ×字（2本の斜線）
  cross,
}

/// 標識1枚分の視覚データ＋4択設問。
class TrafficSign {
  const TrafficSign({
    required this.id,
    required this.name,
    required this.category,
    required this.shape,
    required this.backgroundColor,
    this.borderColor,
    this.borderWidthRatio = 0.0,
    this.rimColor,
    this.rimWidthRatio = 0.0,
    this.symbol = SignSymbol.none,
    this.symbolColor = SignColors.black,
    this.centerText,
    this.centerTextColor = SignColors.black,
    this.centerTextScale = 0.4,
    this.subText,
    this.centerIcon,
    this.hasDiagonalSlash = false,
    this.hasCrossSlash = false,
    this.hasHorizontalBar = false,
    required this.questionText,
    required this.choices,
    required this.answer,
    required this.explanation,
  }) : assert(answer >= 0 && answer < 4, 'answer must be 0..3');

  /// 一意なID（例: "sign_stop"）
  final String id;

  /// 標識の正式名称（結果画面・復習表示用）
  final String name;

  /// 標識の種類（規制標識・警戒標識・指示標識）
  final String category;

  final SignShape shape;

  /// 標識の地色
  final Color backgroundColor;

  /// 枠線の色（赤いリング、黒い縁取り線など）。null なら枠なし。
  final Color? borderColor;

  /// 枠線の太さ（標識サイズに対する比率）
  final double borderWidthRatio;

  /// 最外周のフチ色（一時停止の白フチ、警戒標識の黄色いフチ等）。
  final Color? rimColor;

  /// 最外周フチの太さ（標識サイズに対する比率）
  final double rimWidthRatio;

  /// 中に描く図柄
  final SignSymbol symbol;

  /// 図柄の色
  final Color symbolColor;

  /// 中央に表示する文字（速度数値、"止まれ"等）
  final String? centerText;

  final Color centerTextColor;

  /// 文字サイズ（標識サイズに対する比率）
  final double centerTextScale;

  /// 中央文字の下に小さく添える文字（"SLOW"等）
  final String? subText;

  /// 文字・図柄の代わりにアイコンを使う場合
  final IconData? centerIcon;

  /// 赤い斜線（左上→右下）を重ねるか
  final bool hasDiagonalSlash;

  /// 赤い×字を重ねるか
  final bool hasCrossSlash;

  /// 中央に白い横棒を描くか（車両進入禁止）
  final bool hasHorizontalBar;

  final String questionText;
  final List<String> choices;
  final int answer;
  final String explanation;

  SignSlash get slash => hasCrossSlash
      ? SignSlash.cross
      : hasDiagonalSlash
          ? SignSlash.single
          : SignSlash.none;
}

/// 標識で使う色（道路標識の配色を近似）。
class SignColors {
  SignColors._();

  static const Color red = Color(0xFFD7282F);
  static const Color blue = Color(0xFF0B57A4);
  static const Color yellow = Color(0xFFFFCC00);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF1A1A1A);
  static const Color signalRed = Color(0xFFE53935);
  static const Color signalYellow = Color(0xFFFFB300);
  static const Color signalGreen = Color(0xFF16A085);
}

const String _kRegulatory = '規制標識';
const String _kWarning = '警戒標識';
const String _kInstruction = '指示標識';

/// 標識クイズの全データ（20種）。
const List<TrafficSign> kTrafficSigns = [
  // 1. 最高速度
  TrafficSign(
    id: 'sign_max_speed_40',
    name: '最高速度（40km/h）',
    category: _kRegulatory,
    shape: SignShape.circle,
    backgroundColor: SignColors.white,
    borderColor: SignColors.red,
    borderWidthRatio: 0.09,
    centerText: '40',
    centerTextColor: SignColors.blue,
    centerTextScale: 0.46,
    questionText: 'この標識が示す内容として正しいのはどれか。',
    choices: [
      'この先は時速40キロメートル以上で走らなければならない',
      '車両は時速40キロメートルを超えて走ってはならない',
      'この先40メートルで道路工事が行われている',
      '重量40トンを超える車両は通行できない',
    ],
    answer: 1,
    explanation:
        '「最高速度」の規制標識で、表示された速度（ここでは時速40km）を超えて走ってはいけない。'
        'ただし一般原動機付自転車は、標識の数値が30を超えていても法定速度の時速30kmが上限となる点に注意。',
  ),

  // 2. 一時停止
  TrafficSign(
    id: 'sign_stop',
    name: '一時停止',
    category: _kRegulatory,
    shape: SignShape.invertedTriangle,
    backgroundColor: SignColors.red,
    rimColor: SignColors.white,
    rimWidthRatio: 0.045,
    centerText: '止まれ',
    centerTextColor: SignColors.white,
    centerTextScale: 0.2,
    questionText: 'この標識のある場所で、二輪車の運転者がとるべき行動はどれか。',
    choices: [
      '他の車がいなければ徐行して通過してよい',
      '警音器を鳴らしてから進む',
      '停止線の直前（停止線がなければ交差点の直前）で一時停止する',
      '歩行者がいるときだけ停止すればよい',
    ],
    answer: 2,
    explanation:
        '「一時停止」の標識では、交通の有無にかかわらず停止線の直前で必ず一度止まる。'
        '停止線がない場合は交差点の直前で止まり、安全を確かめてから発進する。',
  ),

  // 3. 駐車禁止
  TrafficSign(
    id: 'sign_no_parking',
    name: '駐車禁止',
    category: _kRegulatory,
    shape: SignShape.circle,
    backgroundColor: SignColors.blue,
    borderColor: SignColors.red,
    borderWidthRatio: 0.09,
    hasDiagonalSlash: true,
    questionText: 'この標識の意味として正しいのはどれか。',
    choices: [
      '車の駐車をしてはいけないが、5分以内の荷物の積みおろしのための停車はできる',
      '駐車も停車もしてはいけない',
      '車両は通行してはいけない',
      '二輪車に限り駐車してよい',
    ],
    answer: 0,
    explanation:
        '青地に赤い斜線1本は「駐車禁止」。駐車はできないが、人の乗り降りや5分以内の荷物の積みおろしなどの停車は認められる。'
        '赤い線が×字になっている「駐停車禁止」と見分けること。',
  ),

  // 4. 駐停車禁止
  TrafficSign(
    id: 'sign_no_stopping',
    name: '駐停車禁止',
    category: _kRegulatory,
    shape: SignShape.circle,
    backgroundColor: SignColors.blue,
    borderColor: SignColors.red,
    borderWidthRatio: 0.09,
    hasCrossSlash: true,
    questionText: 'この標識が設置された場所についての説明で正しいのはどれか。',
    choices: [
      '駐車は禁止されているが、短時間の停車は自由にできる',
      '車両の通行が禁止されている',
      '夜間に限り駐車が禁止されている',
      '駐車だけでなく停車も禁止されている',
    ],
    answer: 3,
    explanation:
        '青地に赤い×字は「駐停車禁止」。駐車に加えて、人の乗り降りなどの短い停車も禁止されている。'
        '斜線1本の「駐車禁止」よりも規制が厳しい。',
  ),

  // 5. 二輪車二人乗り通行禁止
  TrafficSign(
    id: 'sign_no_tandem',
    name: '大型自動二輪車及び普通自動二輪車二人乗り通行禁止',
    category: _kRegulatory,
    shape: SignShape.circle,
    backgroundColor: SignColors.white,
    borderColor: SignColors.red,
    borderWidthRatio: 0.09,
    symbol: SignSymbol.twoRiders,
    hasDiagonalSlash: true,
    questionText: 'この標識の意味として正しいのはどれか。',
    choices: [
      '二輪車は通行できない',
      '大型・普通自動二輪車は二人乗りで通行してはいけない',
      '二輪車は必ず二人乗りで通行しなければならない',
      '二輪車の駐車が禁止されている',
    ],
    answer: 1,
    explanation:
        '二人が乗った二輪車に斜線が引かれた図柄は、大型自動二輪車と普通自動二輪車の「二人乗り通行禁止」を表す。'
        '一人乗りであれば通行できる。',
  ),

  // 6. 追越し禁止
  TrafficSign(
    id: 'sign_no_overtaking',
    name: '追越し禁止',
    category: _kRegulatory,
    shape: SignShape.circle,
    backgroundColor: SignColors.white,
    borderColor: SignColors.red,
    borderWidthRatio: 0.09,
    symbol: SignSymbol.twoCars,
    hasDiagonalSlash: true,
    questionText: 'この標識が示す規制はどれか。',
    choices: [
      '車両の並進（横に並んで走ること）の禁止',
      '二輪車以外の自動車の通行禁止',
      '追越しの禁止',
      '車線変更の禁止',
    ],
    answer: 2,
    explanation:
        '2台の車に斜線を重ねた図柄は「追越し禁止」。この区間では前の車を追い越してはいけない。'
        '二輪車であっても例外ではない。',
  ),

  // 7. 車両通行止め
  TrafficSign(
    id: 'sign_road_closed_vehicles',
    name: '車両通行止め',
    category: _kRegulatory,
    shape: SignShape.circle,
    backgroundColor: SignColors.white,
    borderColor: SignColors.red,
    borderWidthRatio: 0.09,
    questionText: 'この標識の意味として正しいのはどれか。',
    choices: [
      '車両（自動車・原付・軽車両）は通行できない',
      '歩行者だけが通行できない',
      '自動車のみ通行できず、原付は通行できる',
      'この先は行き止まりである',
    ],
    answer: 0,
    explanation:
        '白地に赤い円枠だけの標識は「車両通行止め」。自動車だけでなく原動機付自転車や自転車などの軽車両も通行できない。'
        '中に図柄が描かれている場合は、その車種だけが通行止めになる。',
  ),

  // 8. 徐行
  TrafficSign(
    id: 'sign_slow',
    name: '徐行',
    category: _kRegulatory,
    shape: SignShape.invertedTriangle,
    backgroundColor: SignColors.red,
    rimColor: SignColors.white,
    rimWidthRatio: 0.045,
    centerText: '徐行',
    centerTextColor: SignColors.white,
    centerTextScale: 0.2,
    subText: 'SLOW',
    questionText: 'この標識がある場所での正しい運転はどれか。',
    choices: [
      '一時停止してから進む',
      '時速20キロメートル以下で走ればよい',
      '後続車に道を譲る',
      '車がすぐに停止できるような速度で進む',
    ],
    answer: 3,
    explanation:
        '「徐行」の標識では、ただちに停止できる速度（おおむね時速10km以下が目安）で進まなければならない。'
        '一時停止までは求められていないが、速度を十分に落とす必要がある。',
  ),

  // 9. 一方通行
  TrafficSign(
    id: 'sign_one_way',
    name: '一方通行',
    category: _kRegulatory,
    shape: SignShape.square,
    backgroundColor: SignColors.blue,
    rimColor: SignColors.white,
    rimWidthRatio: 0.03,
    symbol: SignSymbol.oneWayArrow,
    symbolColor: SignColors.white,
    centerText: '一方通行',
    centerTextColor: SignColors.blue,
    centerTextScale: 0.11,
    questionText: 'この標識の意味として正しいのはどれか。',
    choices: [
      '矢印の方向にしか曲がることができない',
      '車両は矢印の示す方向の反対方向には通行できない',
      '矢印の方向に優先道路がある',
      '矢印の方向に駐車場がある',
    ],
    answer: 1,
    explanation:
        '青い四角に白い矢印が描かれた標識は「一方通行」。車両は矢印の向きにしか進めず、逆向きに進入・通行してはいけない。',
  ),

  // 10. 車両進入禁止
  TrafficSign(
    id: 'sign_no_entry',
    name: '車両進入禁止',
    category: _kRegulatory,
    shape: SignShape.circle,
    backgroundColor: SignColors.red,
    rimColor: SignColors.white,
    rimWidthRatio: 0.025,
    hasHorizontalBar: true,
    questionText: 'この標識の意味として正しいのはどれか。',
    choices: [
      '車両はこの標識のある方向から進入できない',
      '車両の通行が一時的に中止されている',
      '歩行者の横断が禁止されている',
      'この先は工事中で徐行しなければならない',
    ],
    answer: 0,
    explanation:
        '赤い円に白い横棒は「車両進入禁止」。標識の立っている側から車両が進入してはいけない。'
        '一方通行の出口側などに設置されることが多い。',
  ),

  // 11. 転回禁止
  TrafficSign(
    id: 'sign_no_u_turn',
    name: '転回禁止',
    category: _kRegulatory,
    shape: SignShape.circle,
    backgroundColor: SignColors.white,
    borderColor: SignColors.red,
    borderWidthRatio: 0.09,
    symbol: SignSymbol.uTurnArrow,
    hasDiagonalSlash: true,
    questionText: 'この標識が示す規制はどれか。',
    choices: [
      '右折の禁止',
      '後退（バック）の禁止',
      'Uターン（転回）の禁止',
      '進路変更の禁止',
    ],
    answer: 2,
    explanation:
        'U字形の矢印に斜線が引かれた標識は「転回禁止」。この場所では車両がUターンしてはいけない。',
  ),

  // 12. 優先道路
  TrafficSign(
    id: 'sign_priority_road',
    name: '優先道路',
    category: _kInstruction,
    shape: SignShape.square,
    backgroundColor: SignColors.blue,
    rimColor: SignColors.white,
    rimWidthRatio: 0.03,
    symbol: SignSymbol.priorityRoad,
    symbolColor: SignColors.white,
    questionText: 'この標識の意味として正しいのはどれか。',
    choices: [
      'この先に交差点があることを予告している',
      '自動車専用の道路であることを示している',
      '歩行者が優先される道路であることを示している',
      '通行している道路が優先道路であることを示している',
    ],
    answer: 3,
    explanation:
        '太い縦線に細い横線が交わる図柄は、走行中の道路が「優先道路」であることを示す指示標識。'
        '交差する道路の車両は、優先道路を通行する車両の進行を妨げてはいけない。',
  ),

  // 13. 踏切あり
  TrafficSign(
    id: 'sign_railroad_crossing',
    name: '踏切あり',
    category: _kWarning,
    shape: SignShape.diamond,
    backgroundColor: SignColors.yellow,
    borderColor: SignColors.black,
    borderWidthRatio: 0.02,
    rimColor: SignColors.yellow,
    rimWidthRatio: 0.03,
    symbol: SignSymbol.train,
    questionText: 'この標識が知らせている内容はどれか。',
    choices: [
      'この先に踏切がある',
      'この先に駅がある',
      'この先で鉄道と立体交差している',
      '路面電車の停留所がある',
    ],
    answer: 0,
    explanation:
        '黄色いひし形は注意をうながす警戒標識。汽車の図柄は「踏切あり」を表す。'
        '踏切の手前では停止線（なければ踏切の直前）で一時停止し、左右の安全を確かめる。',
  ),

  // 14. 学校、幼稚園、保育所等あり
  TrafficSign(
    id: 'sign_school_zone',
    name: '学校、幼稚園、保育所等あり',
    category: _kWarning,
    shape: SignShape.diamond,
    backgroundColor: SignColors.yellow,
    borderColor: SignColors.black,
    borderWidthRatio: 0.02,
    rimColor: SignColors.yellow,
    rimWidthRatio: 0.03,
    symbol: SignSymbol.children,
    questionText: 'この標識の意味として正しいのはどれか。',
    choices: [
      '歩行者専用道路である',
      'この付近に学校、幼稚園、保育所などがある',
      'この先に横断歩道がある',
      '通学時間帯は車両通行止めである',
    ],
    answer: 1,
    explanation:
        '子どもの図柄の警戒標識は「学校、幼稚園、保育所等あり」。子どもの急な飛び出しなどに備え、速度を落として注意して走る。',
  ),

  // 15. 信号機あり
  TrafficSign(
    id: 'sign_traffic_signal_ahead',
    name: '信号機あり',
    category: _kWarning,
    shape: SignShape.diamond,
    backgroundColor: SignColors.yellow,
    borderColor: SignColors.black,
    borderWidthRatio: 0.02,
    rimColor: SignColors.yellow,
    rimWidthRatio: 0.03,
    symbol: SignSymbol.trafficLight,
    questionText: 'この標識が知らせている内容はどれか。',
    choices: [
      'この先の信号機は故障している',
      'この先は信号機のない交差点である',
      'この先に信号機がある',
      '信号機に従わずに進んでよい',
    ],
    answer: 2,
    explanation:
        '信号機の図柄の警戒標識は「信号機あり」。見通しの悪いカーブの先などに信号機があることを前もって知らせている。',
  ),

  // 16. 幅員減少
  TrafficSign(
    id: 'sign_road_narrows',
    name: '幅員減少',
    category: _kWarning,
    shape: SignShape.diamond,
    backgroundColor: SignColors.yellow,
    borderColor: SignColors.black,
    borderWidthRatio: 0.02,
    rimColor: SignColors.yellow,
    rimWidthRatio: 0.03,
    symbol: SignSymbol.roadNarrows,
    questionText: 'この標識の意味として正しいのはどれか。',
    choices: [
      'この先で車線が増える',
      'この先で道路の幅が狭くなる',
      'この先は二輪車専用の道路になる',
      'この先で道路が合流する',
    ],
    answer: 1,
    explanation:
        '左右の線が内側に寄っていく図柄は「幅員減少」。この先で道幅が狭くなるので、対向車や並走車との間隔に注意する。',
  ),

  // 17. 右方屈曲あり（右カーブ）
  TrafficSign(
    id: 'sign_right_curve',
    name: '右方屈曲あり',
    category: _kWarning,
    shape: SignShape.diamond,
    backgroundColor: SignColors.yellow,
    borderColor: SignColors.black,
    borderWidthRatio: 0.02,
    rimColor: SignColors.yellow,
    rimWidthRatio: 0.03,
    symbol: SignSymbol.rightCurve,
    questionText: 'この標識が知らせている内容はどれか。',
    choices: [
      'この先で右折しなければならない',
      'この先は右折禁止である',
      'この先の道路は右に曲がっている',
      'この先に右側から合流する道路がある',
    ],
    answer: 2,
    explanation:
        '右へ曲がる矢印の警戒標識は、この先の道路が右方向に曲がっていることを知らせる（右カーブ）。'
        '指示や禁止ではなく注意喚起なので、カーブの手前で十分に減速する。',
  ),

  // 18. すべりやすい
  TrafficSign(
    id: 'sign_slippery',
    name: 'すべりやすい',
    category: _kWarning,
    shape: SignShape.diamond,
    backgroundColor: SignColors.yellow,
    borderColor: SignColors.black,
    borderWidthRatio: 0.02,
    rimColor: SignColors.yellow,
    rimWidthRatio: 0.03,
    symbol: SignSymbol.slippery,
    questionText: 'この標識の意味として正しいのはどれか。',
    choices: [
      'この先は急な下り坂である',
      'この先は路面が凍結している',
      'この先の道路は曲がりくねっている',
      'この先の路面はすべりやすい',
    ],
    answer: 3,
    explanation:
        '車とくねったタイヤ跡の図柄は「すべりやすい」。二輪車は特に転倒しやすいので、急ブレーキ・急ハンドルを避けて速度を落とす。',
  ),

  // 19. 指定方向外進行禁止（直進のみ）
  TrafficSign(
    id: 'sign_straight_only',
    name: '指定方向外進行禁止（直進）',
    category: _kRegulatory,
    shape: SignShape.circle,
    backgroundColor: SignColors.blue,
    rimColor: SignColors.white,
    rimWidthRatio: 0.025,
    symbol: SignSymbol.arrowUp,
    symbolColor: SignColors.white,
    questionText: 'この標識がある交差点での正しい通行はどれか。',
    choices: [
      '車両は直進しかできず、右折や左折はできない',
      '直進する車両が優先される',
      'この先は一方通行である',
      '直進は禁止されている',
    ],
    answer: 0,
    explanation:
        '青い円に白い矢印は「指定方向外進行禁止」。矢印の示す方向（ここでは直進）以外に進んではいけない。'
        '一方通行（青い四角）と混同しないこと。',
  ),

  // 20. 二輪の自動車・一般原動機付自転車通行止め
  TrafficSign(
    id: 'sign_no_motorcycles',
    name: '二輪の自動車・一般原動機付自転車通行止め',
    category: _kRegulatory,
    shape: SignShape.circle,
    backgroundColor: SignColors.white,
    borderColor: SignColors.red,
    borderWidthRatio: 0.09,
    symbol: SignSymbol.motorcycle,
    questionText: 'この標識の意味として正しいのはどれか。',
    choices: [
      '二輪車の駐車場がある',
      '二輪車は徐行しなければならない',
      '二輪車の二人乗りが禁止されている',
      '自動二輪車と一般原動機付自転車は通行できない',
    ],
    answer: 3,
    explanation:
        '白地・赤枠の円に二輪車の図柄（斜線なし）は「二輪の自動車・一般原動機付自転車通行止め」。'
        '二輪車を押して歩く場合は歩行者として扱われる。',
  ),
];
