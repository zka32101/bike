import '../core/constants/license_category.dart';

/// 憧れバイク図鑑の1件（架空のタイプ紹介）。
///
/// 実在のメーカー名・車種名・ロゴ・実車の画像や仕様数値は一切含めない。
/// 排気量区分と免許区分の対応は [LicenseCategory] を使い、あくまで目安として示す。
class BikeZukanEntry {
  const BikeZukanEntry({
    required this.id,
    required this.stageIndex,
    required this.name,
    required this.type,
    required this.category,
    required this.feel,
    required this.suitedFor,
    required this.beforeRiding,
    required this.requiredCoverage,
    this.contentStatus = 'ai-draft',
    this.source = 'original',
    this.sourceRef = '自作（架空のタイプ紹介・実在車に依拠しない）',
  });

  final String id;

  /// 段階の順序（0=原付, 1=125, 2=250, 3=400, 4=大型）。
  final int stageIndex;

  /// 架空のタイプ名（一般名称。メーカー固有の商品名は使わない）。
  final String name;
  final String type;

  /// 免許区分（目安）。
  final LicenseCategory category;
  final String feel;
  final String suitedFor;
  final String beforeRiding;

  /// 解放に必要な、その免許区分の問題の「正解済み割合」（0〜1）。
  final double requiredCoverage;

  final String contentStatus;
  final String source;
  final String sourceRef;

  /// 解放条件の案内文。
  String get unlockHint =>
      '${category.label}の問題を${(requiredCoverage * 100).round()}%正解すると解放';
}

/// 正解済みの問題の種類÷区分の全問題数。全問題数0なら0。
double zukanCoverage({required int correctDistinct, required int total}) =>
    total <= 0 ? 0 : (correctDistinct / total).clamp(0.0, 1.0);

bool isZukanUnlocked(BikeZukanEntry e, double coverage) =>
    coverage >= e.requiredCoverage;

const String kZukanNotice = '架空のタイプ紹介（AI下書き・専門確認前）';
const String kZukanDisclaimer =
    '実在の車種とは関係ありません。排気量区分と免許区分の対応は目安です。'
    '実際の区分や条件は教習所・販売店で確認してください。';

const List<BikeZukanEntry> kBikeZukanEntries = [
  BikeZukanEntry(
    id: 'zukan_scooter_gentsuki',
    stageIndex: 0,
    name: 'シティスクーター',
    type: 'スクータータイプ',
    category: LicenseCategory.gentsuki,
    feel: 'ギアを操作せずアクセルで進む手軽さ。足元が広く、小回りがきく乗り味。',
    suitedFor: 'はじめて二輪に乗る人、街中の短い移動が中心の人。',
    beforeRiding: '小さな車体でも二人乗りはできない決まりがある。法定速度や二段階右折の扱いを先に確認しておこう。',
    requiredCoverage: 0.2,
  ),
  BikeZukanEntry(
    id: 'zukan_naked_125',
    stageIndex: 1,
    name: 'ネイキッド125',
    type: 'ネイキッドタイプ',
    category: LicenseCategory.kogataGentsukiNirin,
    feel: 'むき出しのフレームで操作が素直。車体が軽く、ギア操作の基本を学びやすい。',
    suitedFor: '小型の二輪でマニュアル操作に慣れたい人。',
    beforeRiding: '免許区分によって乗れる範囲が変わる。AT限定との違いも含め、教習所で確認しよう。',
    requiredCoverage: 0.3,
  ),
  BikeZukanEntry(
    id: 'zukan_naked_250',
    stageIndex: 2,
    name: 'ネイキッド250',
    type: 'ネイキッドタイプ',
    category: LicenseCategory.futsuuNirin,
    feel: '力強さと扱いやすさのバランスがよい中間的な乗り味。街乗りからツーリングまで幅広い。',
    suitedFor: '普段使いも遠出も一台でこなしたい人。',
    beforeRiding: '速度が出る分、制動距離が伸びる。雨の日や路面の状態によるブレーキの違いを意識しよう。',
    requiredCoverage: 0.4,
  ),
  BikeZukanEntry(
    id: 'zukan_adventure_400',
    stageIndex: 3,
    name: 'アドベンチャー400',
    type: 'アドベンチャータイプ',
    category: LicenseCategory.futsuuNirin,
    feel: '着座位置が高く視界が広い。長距離や荷物を積んだ移動で安定感を出しやすい。',
    suitedFor: '長めの旅や荷物の多い移動をしたい人。',
    beforeRiding: '車体が大きくなるほど、停止時の足つきや取り回しに慣れが必要。積載の制限も事前に確認しよう。',
    requiredCoverage: 0.6,
  ),
  BikeZukanEntry(
    id: 'zukan_tourer_large',
    stageIndex: 4,
    name: 'ツアラー大型',
    type: 'ツアラータイプ',
    category: LicenseCategory.ogataNirin,
    feel: 'どっしりとした重みで直進の安定性が高い。高速走行でゆとりを感じやすい。',
    suitedFor: '長距離をゆったり走りたい、経験を重ねた人。',
    beforeRiding: '重い車体は引き起こしや低速のバランスが難しい。大型二輪の免許条件は教習所で必ず確認しよう。',
    requiredCoverage: 0.8,
  ),
];
