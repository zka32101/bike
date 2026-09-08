/// ひっかけ道場：誤答は自動でボス化し再挑戦キューに積まれる。
class TrapDojoSession {
  TrapDojoSession({
    required this.uid,
    this.questionId,
    this.bossQuestionId,
    this.licenseCategory,
    this.isBoss = false,
    this.defeatedCount = 0,
    this.createdAt,
    this.defeatedAt,
    this.lastDefeatedAt,
    this.retryCount = 0,
  });

  final String uid;
  final String? questionId; // For Firestore compatibility
  final String? bossQuestionId; // Legacy field
  final String? licenseCategory;
  final bool isBoss;
  final int defeatedCount;
  final DateTime? createdAt;
  final DateTime? defeatedAt;
  final DateTime? lastDefeatedAt;
  final int retryCount;

  bool get isDefeated => defeatedAt != null || lastDefeatedAt != null;

  TrapDojoSession copyWithRetry() => TrapDojoSession(
    uid: uid,
    questionId: questionId,
    bossQuestionId: bossQuestionId,
    licenseCategory: licenseCategory,
    isBoss: isBoss,
    defeatedCount: defeatedCount,
    createdAt: createdAt,
    defeatedAt: defeatedAt,
    lastDefeatedAt: lastDefeatedAt,
    retryCount: retryCount + 1,
  );

  TrapDojoSession copyAsDefeated(DateTime at) => TrapDojoSession(
    uid: uid,
    questionId: questionId,
    bossQuestionId: bossQuestionId,
    licenseCategory: licenseCategory,
    isBoss: isBoss,
    defeatedCount: defeatedCount + 1,
    createdAt: createdAt,
    defeatedAt: at,
    lastDefeatedAt: at,
    retryCount: retryCount,
  );

  factory TrapDojoSession.fromJson(Map<String, dynamic> json) =>
      TrapDojoSession(
        uid: json['uid'] as String,
        questionId: json['questionId'] as String?,
        bossQuestionId: json['bossQuestionId'] as String?,
        licenseCategory: json['licenseCategory'] as String?,
        isBoss: json['isBoss'] as bool? ?? false,
        defeatedCount: json['defeatedCount'] as int? ?? 0,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        defeatedAt: json['defeatedAt'] != null
            ? DateTime.parse(json['defeatedAt'] as String)
            : null,
        lastDefeatedAt: json['lastDefeatedAt'] != null
            ? DateTime.parse(json['lastDefeatedAt'] as String)
            : null,
        retryCount: json['retryCount'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'questionId': questionId,
    'bossQuestionId': bossQuestionId,
    'licenseCategory': licenseCategory,
    'isBoss': isBoss,
    'defeatedCount': defeatedCount,
    'createdAt': createdAt?.toIso8601String(),
    'defeatedAt': defeatedAt?.toIso8601String(),
    'lastDefeatedAt': lastDefeatedAt?.toIso8601String(),
    'retryCount': retryCount,
  };
}
