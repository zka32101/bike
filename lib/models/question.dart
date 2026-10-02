/// 二輪特有のひっかけで間違えやすい数字の種類。
/// 道場モードの出題選定・ボス化ロジックで参照する。
enum TrapNumberType {
  none,
  twoPersonRiding, // 二人乗り条件
  loadLimit, // 積載制限
  twoStageRightTurn, // 二段階右折
  speedLimit,
  followingDistance,
  brakingDistance, // 制動距離
  licensePeriod, // 免許の有効期間
  turningRules, // 右左折・進路変更のルール
  nightDriving, // 夜間運転
  signalAndMarkings, // 信号・標示
  hazardRecognition, // 危険予測
  weatherConditions, // 天候
  weatherSafety, // 悪天候時の安全運転
  brakeTechnique, // ブレーキ操作
  other,
}

class Question {
  Question({
    required this.id,
    required this.licenseCategory,
    required this.stageTag,
    required this.difficulty,
    required this.questionText,
    required this.choices,
    required this.answer,
    required this.explanation,
    this.isTrapQuestion = false,
    this.trapNumberType = TrapNumberType.none,
    this.topicTag,
    this.sourceRef,
    this.lawVersion,
  }) : assert(choices.length >= 2, 'choices must have at least 2 options'),
       assert(
         answer >= 0 && answer < choices.length,
         'answer index out of range',
       );

  final String id;

  /// 対象免許区分（複数区分で共通出題されうるため配列）。
  final List<String> licenseCategory;

  /// 教習所段階タグ（例: '第一段階', '第二段階', 'AT教習'）。段階別モードのフィルタに使う。
  final String stageTag;

  /// 1(易)〜5(難)。
  final int difficulty;

  final String questionText;
  final List<String> choices;

  /// choices のうち正解のインデックス。
  final int answer;
  final String explanation;

  /// ひっかけ（二輪特有の間違えやすい数字等）を含む問題か。
  /// 学習分析の弱点分析（トラップ種別）で使用（ひっかけ道場画面自体はUIから非表示）。
  final bool isTrapQuestion;

  /// ひっかけの種類（isTrapQuestion=true のときのみ意味を持つ）。
  final TrapNumberType trapNumberType;

  /// トピックタグ（学習パスの個別最適化に使用）。
  final String? topicTag;

  /// 出典（条文・教則の該当箇所）。確認できたものだけに付く。
  final String? sourceRef;

  /// 出典を確認した日（YYYY-MM-DD）。法令・教則はこの日時点の版。
  final String? lawVersion;

  /// 解説に出典を添えた表示用の文。出典がなければ解説だけ。
  String get displayExplanation {
    final src = sourceRef;
    if (src == null || src.isEmpty) return explanation;
    final ver = (lawVersion == null || lawVersion!.isEmpty) ? '' : '（$lawVersion 確認）';
    final line = '出典: $src$ver';
    return explanation.isEmpty ? line : '$explanation\n\n$line';
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      licenseCategory: List<String>.from(json['licenseCategory'] as List),
      stageTag: json['stageTag'] as String? ?? '',
      difficulty: json['difficulty'] as int? ?? 1,
      questionText: json['questionText'] as String,
      choices: List<String>.from(json['choices'] as List),
      answer: json['answer'] as int,
      explanation: json['explanation'] as String? ?? '',
      isTrapQuestion: json['isTrapQuestion'] as bool? ?? false,
      trapNumberType: TrapNumberType.values.firstWhere(
        (e) => e.name == (json['trapNumberType'] as String? ?? 'none'),
        orElse: () => TrapNumberType.none,
      ),
      topicTag: json['topicTag'] as String?,
      sourceRef: json['sourceRef'] as String?,
      lawVersion: json['lawVersion'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'licenseCategory': licenseCategory,
    'stageTag': stageTag,
    'difficulty': difficulty,
    'questionText': questionText,
    'choices': choices,
    'answer': answer,
    'explanation': explanation,
    'isTrapQuestion': isTrapQuestion,
    'trapNumberType': trapNumberType.name,
    'topicTag': topicTag,
    if (sourceRef != null) 'sourceRef': sourceRef,
    if (lawVersion != null) 'lawVersion': lawVersion,
  };
}
