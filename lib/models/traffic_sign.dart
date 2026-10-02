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

  /// 五角形（横断歩道・自転車横断帯。頂点が上の家型）
  pentagon,

  /// 横長の長方形（一方通行）
  wideRect,
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

  /// 歩く人（歩行者通行止め）
  pedestrian,

  /// 横から見た自転車（自転車通行止め）
  bicycle,

  /// 上がって右へ曲がる矢印（車両横断禁止）
  turnRightArrow,

  /// 上がって左へ曲がる太い矢印（指定方向外進行禁止・左折）
  arrowLeft,

  /// 直進と右折の2方向の太い矢印（指定方向外進行禁止・直進・右折）
  arrowStraightRight,

  /// 数字の下の白い横線（最低速度）
  speedUnderline,

  /// 文字の上下に置く向かい合った三角（高さ制限）
  heightMarkers,

  /// ラッパ形の警笛（警笛鳴らせ）
  horn,

  /// 白い三角の中に歩行者と横断歩道の縞（横断歩道）
  crosswalk,

  /// 文字の下の白い太線（停止線）
  stopLineBar,

  /// 十字路（十形道路交差点あり）
  crossroad,

  /// T字路（T形道路交差点あり）
  tJunction,

  /// 下から上がって左へ曲がる矢印（左方屈曲あり）
  leftCurve,

  /// 上向きと下向きの2本の矢印（二方向交通）
  twoWayTraffic,

  /// スコップで掘る作業員と土の山（道路工事中）
  roadWorks,

  /// 跳ねるシカ（動物が飛び出すおそれあり）
  deer,

  /// 感嘆符（その他の危険）
  exclamation,

  /// 正面から見た乗用車（自動車専用）
  carFront,

  /// 自転車＋足もとの横断帯の縞（自転車横断帯）
  bicycleCrossing,

  /// 縦に並んだ2つの三角マーカー（安全地帯）
  safetyZoneMarkers,

  /// 並んだ2本の上向き矢印（車両通行区分）
  laneArrows,

  /// ラッパ形の警笛＋区間の両端を示す縦線（警笛区間）
  hornZone,

  /// 並んだ2台の車＋右側へはみ出す矢印（追越しのための右側部分はみ出し通行禁止）
  overtakingProtrusion,
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
    this.centerTextOffsetY = 0.0,
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

  /// 中央文字の縦位置のずらし量（標識サイズに対する比率。負で上へ）
  final double centerTextOffsetY;

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

/// 標識クイズの全データ。
///
/// 1〜20 は初期収録分、21 以降は追加収録分。
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
    symbolColor: SignColors.blue,
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
    hasDiagonalSlash: true,
    questionText: 'この標識の意味として正しいのはどれか。',
    choices: [
      '車両（自動車・原付・軽車両）は通行できない',
      '歩行者だけが通行できない',
      '自動車のみ通行できず、原付は通行できる',
      'この先は行き止まりである',
    ],
    answer: 0,
    explanation:
        '白地・赤枠の円に赤い斜めの帯が入り、中に図柄がない標識は「車両通行止め」。自動車だけでなく原動機付自転車や自転車などの軽車両も通行できない。'
        '中に車種の図柄が描かれている場合は、その車種だけが通行止めになる。',
  ),

  // 8. 徐行
  TrafficSign(
    id: 'sign_slow',
    name: '徐行',
    category: _kRegulatory,
    // 白地・赤縁・青字の逆三角形（国土交通省 2017-04-13 報道発表「『徐行』の標識に
    // 英字『SLOW』を併記します」の図による）。一時停止（赤地・白縁）と取り違えない。
    shape: SignShape.invertedTriangle,
    backgroundColor: SignColors.white,
    borderColor: SignColors.red,
    borderWidthRatio: 0.085,
    centerText: '徐行',
    centerTextColor: SignColors.blue,
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
    shape: SignShape.wideRect,
    backgroundColor: SignColors.blue,
    rimColor: SignColors.white,
    rimWidthRatio: 0.03,
    symbol: SignSymbol.oneWayArrow,
    symbolColor: SignColors.white,
    questionText: 'この標識の意味として正しいのはどれか。',
    choices: [
      '矢印の方向にしか曲がることができない',
      '車両は矢印の示す方向の反対方向には通行できない',
      '矢印の方向に優先道路がある',
      '矢印の方向に駐車場がある',
    ],
    answer: 1,
    explanation:
        '青い横長の長方形に白い矢印が描かれた標識は「一方通行」。車両は矢印の向きにしか進めず、逆向きに進入・通行してはいけない。',
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
    symbolColor: SignColors.blue,
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
    symbolColor: SignColors.blue,
    hasDiagonalSlash: true,
    questionText: 'この標識の意味として正しいのはどれか。',
    choices: [
      '二輪車の駐車場がある',
      '二輪車は徐行しなければならない',
      '二輪車の二人乗りが禁止されている',
      '自動二輪車と一般原動機付自転車は通行できない',
    ],
    answer: 3,
    explanation:
        '白地・赤枠の円に二輪車の図柄と赤い斜めの帯が入った標識は「二輪の自動車・一般原動機付自転車通行止め」。'
        '二輪車を押して歩く場合は歩行者として扱われる。',
  ),

  // ===== 追加収録分 =====

  // 21. 通行止め
  TrafficSign(
    id: 'sign_road_closed_all',
    name: '通行止め',
    category: _kRegulatory,
    shape: SignShape.circle,
    backgroundColor: SignColors.white,
    borderColor: SignColors.red,
    borderWidthRatio: 0.09,
    centerText: '通行止',
    centerTextColor: SignColors.blue,
    centerTextScale: 0.17,
    hasCrossSlash: true,
    centerTextOffsetY: 0.27,
    questionText: 'この標識がある道路を通行できるものはどれか。',
    choices: [
      '歩行者だけは通行できる',
      '一般原動機付自転車だけは通行できる',
      '歩行者も車両も路面電車も通行できない',
      '自転車を押して歩く人だけは通行できる',
    ],
    answer: 2,
    explanation:
        '赤い×印と「通行止」の文字が入った標識は、歩行者・車両・路面電車のすべてが通れないことを示す。'
        '赤い斜めの帯だけの「車両通行止め」は車両だけが対象なので、×印と文字の有無で区別する。',
  ),

  // 22. 歩行者通行止め
  TrafficSign(
    id: 'sign_no_pedestrians',
    name: '歩行者通行止め',
    category: _kRegulatory,
    shape: SignShape.square,
    backgroundColor: SignColors.white,
    borderColor: SignColors.red,
    borderWidthRatio: 0.09,
    symbol: SignSymbol.pedestrian,
    hasDiagonalSlash: true,
    symbolColor: SignColors.blue,
    centerText: '通行止',
    centerTextColor: SignColors.blue,
    centerTextScale: 0.14,
    centerTextOffsetY: 0.30,
    questionText: 'この標識が禁止しているものはどれか。',
    choices: [
      '歩行者の通行',
      '歩行者の横断だけ（通行は可）',
      '車両の通行',
      '車両の駐車',
    ],
    answer: 0,
    explanation:
        '歩く人の図柄に赤い斜線が入った標識は「歩行者通行止め」。この先は歩行者が通れない。'
        '二輪車を押して歩くと歩行者として扱われるため、押し歩きでも通行できない点に注意。',
  ),

  // 23. 自転車通行止め
  TrafficSign(
    id: 'sign_no_bicycles',
    name: '自転車通行止め',
    category: _kRegulatory,
    shape: SignShape.circle,
    backgroundColor: SignColors.white,
    borderColor: SignColors.red,
    borderWidthRatio: 0.09,
    symbol: SignSymbol.bicycle,
    symbolColor: SignColors.blue,
    hasDiagonalSlash: true,
    questionText: 'この標識の意味として正しいのはどれか。',
    choices: [
      '自転車専用の道路である',
      '自転車は通行できない',
      'この先に自転車横断帯がある',
      '自転車は歩道を通行しなければならない',
    ],
    answer: 1,
    explanation:
        '白地・赤枠の円に自転車の図柄と赤い斜めの帯が入った標識は「自転車通行止め」。'
        '青い円に白い自転車の「自転車専用」とは色で見分ける。',
  ),

  // 24. 車両横断禁止
  TrafficSign(
    id: 'sign_no_crossing_vehicles',
    name: '車両横断禁止',
    category: _kRegulatory,
    shape: SignShape.circle,
    backgroundColor: SignColors.white,
    borderColor: SignColors.red,
    borderWidthRatio: 0.09,
    symbol: SignSymbol.turnRightArrow,
    hasDiagonalSlash: true,
    symbolColor: SignColors.blue,
    questionText: 'この標識が示す規制として正しいのはどれか。',
    choices: [
      '交差点での右折が禁止されている',
      '歩行者の横断が禁止されている',
      '車両がUターンすることが禁止されている',
      '車両が道路を右に横切って横断することが禁止されている',
    ],
    answer: 3,
    explanation:
        '右へ曲がる矢印に斜線の標識は「車両横断禁止」。道路外の施設に入るためなどで、車両が道路を右へ横切ることを禁じている。'
        '左に横切る（左折して道路外へ出る）ことは禁止されていない。',
  ),

  // 25. 指定方向外進行禁止（左折）
  TrafficSign(
    id: 'sign_left_turn_only',
    name: '指定方向外進行禁止（左折）',
    category: _kRegulatory,
    shape: SignShape.circle,
    backgroundColor: SignColors.blue,
    rimColor: SignColors.white,
    rimWidthRatio: 0.025,
    symbol: SignSymbol.arrowLeft,
    symbolColor: SignColors.white,
    questionText: 'この標識がある交差点で、車両が進めるのはどの方向か。',
    choices: [
      '左折だけ',
      '直進と左折',
      '左折以外のすべての方向',
      '右折だけ',
    ],
    answer: 0,
    explanation:
        '青い円に白い矢印の標識は、矢印の方向以外へ進むことを禁じる「指定方向外進行禁止」。'
        'この矢印は左を向いているので、左折しかできない。',
  ),

  // 26. 指定方向外進行禁止（直進・右折）
  TrafficSign(
    id: 'sign_straight_or_right_only',
    name: '指定方向外進行禁止（直進・右折）',
    category: _kRegulatory,
    shape: SignShape.circle,
    backgroundColor: SignColors.blue,
    rimColor: SignColors.white,
    rimWidthRatio: 0.025,
    symbol: SignSymbol.arrowStraightRight,
    symbolColor: SignColors.white,
    questionText: 'この標識がある交差点での通行方法として正しいのはどれか。',
    choices: [
      '直進も右折もしてはいけない',
      '直進と右折はできるが、左折はできない',
      '右折する場合は必ず二段階で右折する',
      '直進する車が右折する車より優先する',
    ],
    answer: 1,
    explanation:
        '「指定方向外進行禁止」の矢印が上と右を向いているので、進めるのは直進と右折だけで、左折は禁止される。'
        '矢印が示すのは「進んでよい方向」であることを覚えておこう。',
  ),

  // 27. 最低速度
  TrafficSign(
    id: 'sign_min_speed_30',
    name: '最低速度（30km/h）',
    category: _kRegulatory,
    shape: SignShape.circle,
    backgroundColor: SignColors.white,
    symbol: SignSymbol.speedUnderline,
    symbolColor: SignColors.blue,
    centerText: '30',
    centerTextColor: SignColors.blue,
    centerTextScale: 0.42,
    centerTextOffsetY: -0.04,
    borderColor: SignColors.red,
    borderWidthRatio: 0.09,
    questionText: 'この標識の意味として正しいのはどれか。',
    choices: [
      '時速30キロメートルを超えて走ってはいけない',
      'この先30メートルは徐行しなければならない',
      '自動車は時速30キロメートルに満たない速度で走ってはいけない',
      'この先30キロメートルは追越しが禁止されている',
    ],
    answer: 2,
    explanation:
        '白地・赤枠の円に青い数字と、その下の青い線が入った標識は「最低速度」。自動車は表示の速度より遅く走ってはいけない（渋滞などやむを得ない場合を除く）。'
        '同じ白地・赤枠の「最高速度」には数字の下に線がないので、下線の有無で見分ける。',
  ),

  // 28. 重量制限
  TrafficSign(
    id: 'sign_weight_limit',
    name: '重量制限（5.5t）',
    category: _kRegulatory,
    shape: SignShape.circle,
    backgroundColor: SignColors.white,
    borderColor: SignColors.red,
    borderWidthRatio: 0.09,
    centerText: '5.5t',
    centerTextColor: SignColors.blue,
    centerTextScale: 0.3,
    questionText: 'この標識が示す内容として正しいのはどれか。',
    choices: [
      '総重量が5.5トンを超える車両は通行できない',
      '積み荷が5.5トン以下の車両は通行できない',
      'この先5.5キロメートルは工事区間である',
      '車両の高さが5.5メートルまでに制限されている',
    ],
    answer: 0,
    explanation:
        '数字に「t」がついた規制標識は「重量制限」。車の総重量（車体・人・荷物の合計）が表示の重さを超える車両は通れない。'
        '橋などが重さに耐えられない場所に設置される。',
  ),

  // 29. 高さ制限
  TrafficSign(
    id: 'sign_height_limit',
    name: '高さ制限（3.3m）',
    category: _kRegulatory,
    shape: SignShape.circle,
    backgroundColor: SignColors.white,
    borderColor: SignColors.red,
    borderWidthRatio: 0.09,
    symbol: SignSymbol.heightMarkers,
    symbolColor: SignColors.blue,
    centerText: '3.3m',
    centerTextColor: SignColors.blue,
    centerTextScale: 0.24,
    questionText: 'この標識の意味として正しいのはどれか。',
    choices: [
      '道路の幅が3.3メートルに狭くなる',
      '地上から3.3メートルを超える高さの車両は通行できない',
      '車両どうしは3.3メートル以上の車間距離をとる',
      '積み荷の長さは3.3メートルまでに制限される',
    ],
    answer: 1,
    explanation:
        '上下から向かい合う三角の間に数値がある標識は「高さ制限」。積み荷を含めた地面からの高さが表示を超える車両は通れない。'
        '左右から向かい合う三角の「最大幅」と混同しないこと。',
  ),

  // 30. 警笛鳴らせ
  TrafficSign(
    id: 'sign_sound_horn',
    name: '警笛鳴らせ',
    category: _kRegulatory,
    shape: SignShape.circle,
    backgroundColor: SignColors.blue,
    rimColor: SignColors.white,
    rimWidthRatio: 0.025,
    symbol: SignSymbol.horn,
    symbolColor: SignColors.white,
    questionText: 'この標識のある場所で、車両がしなければならないことはどれか。',
    choices: [
      '警音器を鳴らしてはいけない',
      '夜間だけ前照灯を点滅させる',
      '一時停止して左右を確かめる',
      '警音器を鳴らす',
    ],
    answer: 3,
    explanation:
        '青い円に白いラッパの図柄は「警笛鳴らせ」。この標識のある場所では、車両は必ず警音器を鳴らす。'
        '下に「区間内」の補助標識がある場合は「警笛区間」を示し、区間内の見通しのきかない交差点・曲がり角・上り坂の頂上で警音器を鳴らす。',
  ),

  // 31. 横断歩道
  TrafficSign(
    id: 'sign_pedestrian_crossing',
    name: '横断歩道',
    category: _kInstruction,
    shape: SignShape.pentagon,
    backgroundColor: SignColors.blue,
    rimColor: SignColors.white,
    rimWidthRatio: 0.03,
    symbol: SignSymbol.crosswalk,
    symbolColor: SignColors.white,
    questionText: 'この標識が示している内容はどれか。',
    choices: [
      '歩行者専用道路である',
      'この付近に学校や幼稚園がある',
      'この場所が横断歩道であることを示している',
      '歩行者の横断が禁止されている',
    ],
    answer: 2,
    explanation:
        '青い五角形（家型）に白い三角、その中に歩く人と縞模様がある標識は「横断歩道」を示す指示標識。'
        '横断しようとする歩行者がいるときは、横断歩道の手前で一時停止して道を譲らなければならない。',
  ),

  // 32. 駐車可
  TrafficSign(
    id: 'sign_parking_allowed',
    name: '駐車可',
    category: _kInstruction,
    shape: SignShape.square,
    backgroundColor: SignColors.blue,
    rimColor: SignColors.white,
    rimWidthRatio: 0.03,
    centerText: 'P',
    centerTextColor: SignColors.white,
    centerTextScale: 0.62,
    questionText: 'この標識の意味として正しいのはどれか。',
    choices: [
      '駐車が禁止されている',
      '駐車してよい場所である',
      'パーキングエリアまで1キロメートルある',
      '停車だけが認められている',
    ],
    answer: 1,
    explanation:
        '青い四角に白い「P」は「駐車可」を示す指示標識で、駐車してよい場所であることを表す。'
        '青い円に赤い斜線の「駐車禁止」（規制標識）とは形も意味も異なる。',
  ),

  // 33. 停車可
  TrafficSign(
    id: 'sign_stopping_allowed',
    name: '停車可',
    category: _kInstruction,
    shape: SignShape.square,
    backgroundColor: SignColors.blue,
    rimColor: SignColors.white,
    rimWidthRatio: 0.03,
    centerText: '停',
    centerTextColor: SignColors.white,
    centerTextScale: 0.52,
    questionText: 'この標識がある場所についての説明で正しいのはどれか。',
    choices: [
      '車両は必ず一時停止しなければならない',
      'バスの停留所である',
      '駐車も停車もしてはいけない',
      '停車してよい場所である',
    ],
    answer: 3,
    explanation:
        '青い四角に白い「停」の文字は「停車可」を示す指示標識で、停車してよい場所であることを表す。'
        '一時停止を命じる赤い逆三角の「止まれ」とは別物なので注意する。',
  ),

  // 34. 停止線
  TrafficSign(
    id: 'sign_stop_line',
    name: '停止線',
    category: _kInstruction,
    shape: SignShape.square,
    backgroundColor: SignColors.blue,
    rimColor: SignColors.white,
    rimWidthRatio: 0.03,
    symbol: SignSymbol.stopLineBar,
    symbolColor: SignColors.white,
    centerText: '停止線',
    centerTextColor: SignColors.white,
    centerTextScale: 0.24,
    centerTextOffsetY: 0.2,
    questionText: 'この標識が示している内容はどれか。',
    choices: [
      '車両が停止するときの位置を示している',
      'この先は通行止めである',
      'ここから先は駐車禁止である',
      'ここで必ず一時停止しなければならない',
    ],
    answer: 0,
    explanation:
        '「停止線」の文字と白線の指示標識は、信号や一時停止の標識などで車両が止まる場合の停止位置を示す。'
        'この標識自体が一時停止を命じているわけではない。',
  ),

  // 35. 十形道路交差点あり
  TrafficSign(
    id: 'sign_crossroad_ahead',
    name: '十形道路交差点あり',
    category: _kWarning,
    shape: SignShape.diamond,
    backgroundColor: SignColors.yellow,
    borderColor: SignColors.black,
    borderWidthRatio: 0.02,
    rimColor: SignColors.yellow,
    rimWidthRatio: 0.03,
    symbol: SignSymbol.crossroad,
    questionText: 'この標識が知らせている内容はどれか。',
    choices: [
      'この先に病院がある',
      'この先に十字形の交差点がある',
      'この先の交差点では右左折できない',
      'この先に踏切がある',
    ],
    answer: 1,
    explanation:
        '黄色いひし形に「十」の図柄は「十形道路交差点あり」。見通しの悪い場所で、この先に十字路があることを前もって知らせる。'
        '交差する道路から出てくる車に注意して減速する。',
  ),

  // 36. T形道路交差点あり
  TrafficSign(
    id: 'sign_t_junction_ahead',
    name: 'T形道路交差点あり',
    category: _kWarning,
    shape: SignShape.diamond,
    backgroundColor: SignColors.yellow,
    borderColor: SignColors.black,
    borderWidthRatio: 0.02,
    rimColor: SignColors.yellow,
    rimWidthRatio: 0.03,
    symbol: SignSymbol.tJunction,
    questionText: 'この標識が知らせている内容はどれか。',
    choices: [
      'この先に、道路が突き当たって左右に分かれるT字形の交差点がある',
      'この先は優先道路である',
      'この先は一方通行である',
      'この先に料金所がある',
    ],
    answer: 0,
    explanation:
        '「T」の図柄の警戒標識は「T形道路交差点あり」。この先で道路が突き当たり、左右どちらかに曲がる必要がある。'
        '手前から十分に速度を落として進路を準備する。',
  ),

  // 37. 左方屈曲あり（左カーブ）
  TrafficSign(
    id: 'sign_left_curve',
    name: '左方屈曲あり',
    category: _kWarning,
    shape: SignShape.diamond,
    backgroundColor: SignColors.yellow,
    borderColor: SignColors.black,
    borderWidthRatio: 0.02,
    rimColor: SignColors.yellow,
    rimWidthRatio: 0.03,
    symbol: SignSymbol.leftCurve,
    questionText: 'この標識の意味として正しいのはどれか。',
    choices: [
      'この先は左折しかできない',
      'この先に左から合流する道路がある',
      'この先の道路は左へ曲がっている',
      '左側に寄って通行しなければならない',
    ],
    answer: 2,
    explanation:
        '黄色いひし形に左へ曲がる矢印は「左方屈曲あり」で、この先が左カーブであることを知らせる警戒標識。'
        '青い円に白い矢印の「指定方向外進行禁止」とは違い、進路を命じるものではない。',
  ),

  // 38. 二方向交通
  TrafficSign(
    id: 'sign_two_way_traffic',
    name: '二方向交通',
    category: _kWarning,
    shape: SignShape.diamond,
    backgroundColor: SignColors.yellow,
    borderColor: SignColors.black,
    borderWidthRatio: 0.02,
    rimColor: SignColors.yellow,
    rimWidthRatio: 0.03,
    symbol: SignSymbol.twoWayTraffic,
    questionText: 'この標識が知らせている内容はどれか。',
    choices: [
      'この先は対面通行（二方向の交通）の道路である',
      'この先は追越し禁止である',
      'この先はUターンしなければならない',
      'この先は車線が2本に増える',
    ],
    answer: 0,
    explanation:
        '上向きと下向きの矢印が並んだ警戒標識は「二方向交通」。一方通行の道路から対面通行の道路に変わるところなどに設置される。'
        '対向車が来ることを意識し、道路の左側を通行する。',
  ),

  // 39. 道路工事中
  TrafficSign(
    id: 'sign_road_works',
    name: '道路工事中',
    category: _kWarning,
    shape: SignShape.diamond,
    backgroundColor: SignColors.yellow,
    borderColor: SignColors.black,
    borderWidthRatio: 0.02,
    rimColor: SignColors.yellow,
    rimWidthRatio: 0.03,
    symbol: SignSymbol.roadWorks,
    questionText: 'この標識が知らせている内容はどれか。',
    choices: [
      'この先は土砂崩れで通行止めである',
      'この先で道路工事が行われている',
      'この先は未舗装の道路である',
      'この先に作業員の休憩所がある',
    ],
    answer: 1,
    explanation:
        'スコップで作業する人の図柄は「道路工事中」。この先で工事をしているので、作業員や工事車両、路面の段差などに注意して減速する。',
  ),

  // 40. 動物が飛び出すおそれあり
  TrafficSign(
    id: 'sign_animal_crossing',
    name: '動物が飛び出すおそれあり',
    category: _kWarning,
    shape: SignShape.diamond,
    backgroundColor: SignColors.yellow,
    borderColor: SignColors.black,
    borderWidthRatio: 0.02,
    rimColor: SignColors.yellow,
    rimWidthRatio: 0.03,
    symbol: SignSymbol.deer,
    questionText: 'この標識の意味として正しいのはどれか。',
    choices: [
      'この付近に動物園がある',
      'この先は家畜を連れた人の専用道路である',
      '動物を乗せた車は通行できない',
      '動物が道路に飛び出してくるおそれがある',
    ],
    answer: 3,
    explanation:
        '動物の図柄の警戒標識は「動物が飛び出すおそれあり」。シカのほか、地域によってサルやタヌキなどの図柄もある。'
        '二輪車は動物との衝突で転倒しやすいので、速度を落として前方をよく見る。',
  ),

  // 41. その他の危険
  TrafficSign(
    id: 'sign_other_danger',
    name: 'その他の危険',
    category: _kWarning,
    shape: SignShape.diamond,
    backgroundColor: SignColors.yellow,
    borderColor: SignColors.black,
    borderWidthRatio: 0.02,
    rimColor: SignColors.yellow,
    rimWidthRatio: 0.03,
    symbol: SignSymbol.exclamation,
    questionText: 'この標識の意味として正しいのはどれか。',
    choices: [
      'この先は通行止めである',
      'この先で必ず一時停止しなければならない',
      '他の警戒標識で表せない危険がこの先にある',
      'この先に救急病院がある',
    ],
    answer: 2,
    explanation:
        '黄色いひし形に「！」の図柄は「その他の危険」。ほかの警戒標識では表せない危険があることを知らせるので、周囲をよく見て慎重に進む。',
  ),

  // 42. 自動車専用
  TrafficSign(
    id: 'sign_motorway',
    name: '自動車専用',
    category: _kRegulatory,
    shape: SignShape.circle,
    backgroundColor: SignColors.blue,
    rimColor: SignColors.white,
    rimWidthRatio: 0.025,
    symbol: SignSymbol.carFront,
    symbolColor: SignColors.white,
    questionText: 'この標識がある道路を通行できないものはどれか。',
    choices: [
      '普通自動車',
      '大型自動二輪車',
      '普通自動二輪車（排気量125cc超）',
      '一般原動機付自転車',
    ],
    answer: 3,
    explanation:
        '青い円に白い自動車の図柄は「自動車専用」で、高速道路や自動車専用道路の入口に設置される。'
        '一般原動機付自転車や排気量125cc以下の普通自動二輪車、歩行者、自転車は通行できない。',
  ),

  // 43. 自転車横断帯
  TrafficSign(
    id: 'sign_bicycle_crossing',
    name: '自転車横断帯',
    category: _kInstruction,
    shape: SignShape.pentagon,
    backgroundColor: SignColors.blue,
    rimColor: SignColors.white,
    rimWidthRatio: 0.03,
    symbol: SignSymbol.bicycleCrossing,
    symbolColor: SignColors.white,
    questionText: 'この標識がある場所について正しいのはどれか。',
    choices: [
      '自転車が道路を横断するための場所であることを示す',
      '自転車の通行が禁止されている場所であることを示す',
      '自転車専用の駐輪スペースであることを示す',
      '自転車の速度を制限する場所であることを示す',
    ],
    answer: 0,
    explanation:
        '青い五角形（家型）の中に自転車と縞模様の図柄は「自転車横断帯」。自転車が道路を横断するための場所であることを示し、'
        'この標識のある場所付近では自動車・二輪車は自転車の横断を妨げないよう注意する。',
  ),

  // 44. 安全地帯
  TrafficSign(
    id: 'sign_safety_zone',
    name: '安全地帯',
    category: _kInstruction,
    shape: SignShape.square,
    backgroundColor: SignColors.blue,
    rimColor: SignColors.white,
    rimWidthRatio: 0.03,
    symbol: SignSymbol.safetyZoneMarkers,
    symbolColor: SignColors.white,
    questionText: 'この標識がある場所での運転者の義務として正しいのはどれか。',
    choices: [
      '歩行者がいなければ徐行せずに通過してよい',
      '安全地帯に歩行者がいるときは、その側方を徐行しなければならない',
      '安全地帯には駐停車できるが、徐行の必要はない',
      'この標識がある区間は追越しが禁止される'
    ],
    answer: 1,
    explanation:
        '青い四角に白いV字のマークは「安全地帯」で、路面電車の停留所などで歩行者が安全に待機する場所を示す。'
        '安全地帯に歩行者がいるときは、その側方を通過する際に徐行しなければならない。',
  ),

  // 46. 警笛区間
  TrafficSign(
    id: 'sign_horn_zone',
    name: '警笛区間',
    category: _kRegulatory,
    shape: SignShape.square,
    backgroundColor: SignColors.blue,
    symbol: SignSymbol.hornZone,
    symbolColor: SignColors.white,
    questionText: 'この標識がある区間の通行について正しいのはどれか。',
    choices: [
      '区間内は常に警音器を鳴らし続けなければならない',
      '見通しの悪い交差点やカーブなど、必要な場所で警音器を鳴らさなければならない',
      '警音器の使用が禁止されている区間であることを示す',
      '緊急車両のみ警音器を鳴らせる区間であることを示す'
    ],
    answer: 1,
    explanation:
        '青い四角にラッパと区間を示す縦線は「警笛区間」。区間内では、見通しの悪い交差点・曲がり角・上り坂の頂上などで'
        '必要に応じて警音器を鳴らさなければならない（区間内を常時鳴らし続ける必要はない）。',
  ),

];
