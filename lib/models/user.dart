enum PurchaseStatus { free, singleCategoryPass, allCategorySetPass }

class AppUser {
  AppUser({
    required this.uid,
    this.licenseCategories = const [],
    this.trainingStage,
    this.examDatesByCategory = const {},
    this.streakCount = 0,
    this.purchaseStatus = PurchaseStatus.free,
    this.unlockedCategoryIds = const [],
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
  final PurchaseStatus purchaseStatus;

  /// [purchaseStatus] が [PurchaseStatus.singleCategoryPass] のときのみ意味を持つ。
  /// 単一区分パスを複数回購入した場合に備え、解放済みの区分を複数保持できる
  /// ようにする（1つ目購入後に2つ目を購入しても1つ目の解放状態を失わない）。
  final List<String> unlockedCategoryIds;

  /// データ作成日時（コンフリクト解決用）
  final DateTime createdAt;

  /// データ最終更新日時（コンフリクト解決用・Last-Write-Wins）
  final DateTime updatedAt;

  /// 指定した免許区分の全問題にフルアクセスできるか（無料プレビュー枠は含まない）。
  bool hasAccessToCategory(String categoryId) {
    if (purchaseStatus == PurchaseStatus.allCategorySetPass) return true;
    if (purchaseStatus == PurchaseStatus.singleCategoryPass) {
      return unlockedCategoryIds.contains(categoryId);
    }
    return false;
  }

  AppUser copyWith({
    List<String>? licenseCategories,
    String? trainingStage,
    Map<String, DateTime>? examDatesByCategory,
    int? streakCount,
    PurchaseStatus? purchaseStatus,
    List<String>? unlockedCategoryIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      uid: uid,
      licenseCategories: licenseCategories ?? this.licenseCategories,
      trainingStage: trainingStage ?? this.trainingStage,
      examDatesByCategory: examDatesByCategory ?? this.examDatesByCategory,
      streakCount: streakCount ?? this.streakCount,
      purchaseStatus: purchaseStatus ?? this.purchaseStatus,
      unlockedCategoryIds: unlockedCategoryIds ?? this.unlockedCategoryIds,
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
    purchaseStatus: PurchaseStatus.values.firstWhere(
      (e) => e.name == (json['purchaseStatus'] as String? ?? 'free'),
      orElse: () => PurchaseStatus.free,
    ),
    unlockedCategoryIds: json['unlockedCategoryIds'] != null
        ? List<String>.from(json['unlockedCategoryIds'] as List)
        // 旧形式（単一の unlockedCategoryId フィールド）からの読み込み互換。
        : json['unlockedCategoryId'] != null
            ? [json['unlockedCategoryId'] as String]
            : const [],
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
    'purchaseStatus': purchaseStatus.name,
    'unlockedCategoryIds': unlockedCategoryIds,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
