class UserAnswerLog {
  UserAnswerLog({
    required this.uid,
    required this.questionId,
    required this.isCorrect,
    required this.answeredAt,
    this.licenseCategory,
    this.userAnswer,
    this.correctAnswer,
    this.stage,
  });

  final String uid;
  final String questionId;
  final bool isCorrect;
  final DateTime answeredAt;
  final String? licenseCategory;
  final String? userAnswer;
  final String? correctAnswer;
  final String? stage;

  factory UserAnswerLog.fromJson(Map<String, dynamic> json) => UserAnswerLog(
    uid: json['uid'] as String,
    questionId: json['questionId'] as String,
    isCorrect: json['isCorrect'] as bool,
    answeredAt: DateTime.parse(json['answeredAt'] as String),
    licenseCategory: json['licenseCategory'] as String?,
    userAnswer: json['userAnswer'] as String?,
    correctAnswer: json['correctAnswer'] as String?,
    stage: json['stage'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'questionId': questionId,
    'isCorrect': isCorrect,
    'answeredAt': answeredAt.toIso8601String(),
    'licenseCategory': licenseCategory,
    'userAnswer': userAnswer,
    'correctAnswer': correctAnswer,
    'stage': stage,
  };
}
