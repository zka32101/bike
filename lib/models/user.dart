class AppUser {
  AppUser({
    required this.uid,
    this.licenseCategories = const [],
    this.trainingStage,
    this.examDatesByCategory = const {},
    this.streakCount = 0,
    this.lastStudyDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String uid;

  /// 複数選択可（Step2 画面フロー：免許区分選択(複数選択可)）。
  final List<String> licenseCategories;

  /// 教習所の進行段階。任意入力・スキップ可。
  final String? trainingStage;

  /// 免許区分ごとの試験日（キー=LicenseCategory.name）。任意入力・区分ごとに管理。
  final Map<String, DateTime> examDatesByCategory;

  final int streakCount;

  /// 直近で学習した日（日付のみ意味を持つ。ストリーク計算に使用）。
  final DateTime? lastStudyDate;

  /// データ作成日時（コンフリクト解決用）
  final DateTime createdAt;

  /// データ最終更新日時（コンフリクト解決用・Last-Write-Wins）
  final DateTime updatedAt;

  AppUser copyWith({
    List<String>? licenseCategories,
    String? trainingStage,
    Map<String, DateTime>? examDatesByCategory,
    int? streakCount,
    DateTime? lastStudyDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      uid: uid,
      licenseCategories: licenseCategories ?? this.licenseCategories,
      trainingStage: trainingStage ?? this.trainingStage,
      examDatesByCategory: examDatesByCategory ?? this.examDatesByCategory,
      streakCount: streakCount ?? this.streakCount,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(), // Always update timestamp on modification
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    uid: json['uid'] as String,
    licenseCategories: List<String>.from(
      json['licenseCategories'] as List? ?? [],
    ),
    trainingStage: json['trainingStage'] as String?,
    examDatesByCategory: json['examDatesByCategory'] != null
        ? (json['examDatesByCategory'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, DateTime.parse(value as String)),
          )
        // 旧形式（単一の examDate フィールド）からの読み込み互換。
        // 区分が特定できないため、選択済み区分の先頭に割り当てる。
        : json['examDate'] != null && (json['licenseCategories'] as List?)?.isNotEmpty == true
            ? {
                (json['licenseCategories'] as List).first as String:
                    DateTime.parse(json['examDate'] as String),
              }
            : const {},
    streakCount: json['streakCount'] as int? ?? 0,
    lastStudyDate: json['lastStudyDate'] != null
        ? DateTime.parse(json['lastStudyDate'] as String)
        : null,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : null,
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'licenseCategories': licenseCategories,
    'trainingStage': trainingStage,
    'examDatesByCategory': examDatesByCategory.map(
      (key, value) => MapEntry(key, value.toIso8601String()),
    ),
    'streakCount': streakCount,
    'lastStudyDate': lastStudyDate?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
