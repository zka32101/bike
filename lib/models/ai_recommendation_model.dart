/// AI推奨ロジックのデータモデル集合
/// 適応的学習パスと個別最適化学習を支える

// ============================================================================
// 1. 学習パス・推奨データモデル
// ============================================================================

/// 学習パス要素（単一の学習ステップ）
class LearningPathElement {
  final String id;
  final String questionId;
  final String categoryId;
  final String subcategoryId;
  final int difficulty;
  final String rationale;
  final DateTime recommendedAt;
  final DateTime? completedAt;
  final bool? passed;

  LearningPathElement({
    required this.id,
    required this.questionId,
    required this.categoryId,
    required this.subcategoryId,
    required this.difficulty,
    required this.rationale,
    required this.recommendedAt,
    this.completedAt,
    this.passed,
  });
}

/// 適応的学習パス（学生ごとの個別学習経路）
class AdaptiveLearningPath {
  final String studentId;
  final List<LearningPathElement> elements;
  final DateTime generatedAt;
  final String generationReason;
  final double estimatedCompletionTime;
  final int? currentElementIndex;
  final bool? isActive;

  AdaptiveLearningPath({
    required this.studentId,
    required this.elements,
    required this.generatedAt,
    required this.generationReason,
    required this.estimatedCompletionTime,
    this.currentElementIndex,
    this.isActive,
  });
}

/// 学習推奨（特定のトピックや学習方法の推奨）
class LearningRecommendation {
  final String id;
  final String studentId;
  final String type;
  final String contentId;
  final String contentTitle;
  final String description;
  final int priority;
  final double effectScore;
  final String reason;
  final DateTime? createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final double? userRating;

  LearningRecommendation({
    required this.id,
    required this.studentId,
    required this.type,
    required this.contentId,
    required this.contentTitle,
    required this.description,
    required this.priority,
    required this.effectScore,
    required this.reason,
    this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.userRating,
  });
}

// ============================================================================
// 2. 難度調整・スケーリングモデル
// ============================================================================

/// 難度調整エンジンの状態
class DifficultyAdjustment {
  final String studentId;
  final Map<String, DifficultyLevel> categoryLevels;
  final DateTime lastAdjustedAt;
  final String adjustmentStrategy;

  DifficultyAdjustment({
    required this.studentId,
    required this.categoryLevels,
    required this.lastAdjustedAt,
    required this.adjustmentStrategy,
  });
}

/// カテゴリごとの難度レベル
class DifficultyLevel {
  final String categoryId;
  final int currentLevel;
  final double accuracyRate;
  final int questionCount;
  final DateTime lastUpdatedAt;

  DifficultyLevel({
    required this.categoryId,
    required this.currentLevel,
    required this.accuracyRate,
    required this.questionCount,
    required this.lastUpdatedAt,
  });
}

// ============================================================================
// 3. 予測・分析モデル
// ============================================================================

/// 学習効果予測
class LearningEffectPrediction {
  final String studentId;
  final double passLikelihood;
  final double estimatedDaysToCompletion;
  final double estimatedHoursToCompletion;
  final String completionStatus;
  final List<String> riskFactors;
  final List<String> successFactors;
  final DateTime generatedAt;
  final double confidenceScore;

  LearningEffectPrediction({
    required this.studentId,
    required this.passLikelihood,
    required this.estimatedDaysToCompletion,
    required this.estimatedHoursToCompletion,
    required this.completionStatus,
    required this.riskFactors,
    required this.successFactors,
    required this.generatedAt,
    required this.confidenceScore,
  });
}

/// 脱落リスク検出
class DropoutRiskDetection {
  final String studentId;
  final double riskScore;
  final List<String> riskIndicators;
  final String riskLevel;
  final List<String> interventionSuggestions;
  final DateTime detectedAt;

  DropoutRiskDetection({
    required this.studentId,
    required this.riskScore,
    required this.riskIndicators,
    required this.riskLevel,
    required this.interventionSuggestions,
    required this.detectedAt,
  });
}

// ============================================================================
// 4. スタック・プラトー検出モデル
// ============================================================================

/// スタック検出（成長停滞）
class StuckDetection {
  final String studentId;
  final String categoryId;
  final int dayCount;
  final double accuracyRate;
  final int problemCount;
  final DateTime detectedAt;
  final List<String> suggestedInterventions;

  StuckDetection({
    required this.studentId,
    required this.categoryId,
    required this.dayCount,
    required this.accuracyRate,
    required this.problemCount,
    required this.detectedAt,
    required this.suggestedInterventions,
  });
}

/// 代替学習法提案
class AlternativeLearningMethod {
  final String id;
  final String studentId;
  final String categoryId;
  final String methodType;
  final String description;
  final double expectedEffectiveness;
  final String reason;
  final DateTime? suggestedAt;

  AlternativeLearningMethod({
    required this.id,
    required this.studentId,
    required this.categoryId,
    required this.methodType,
    required this.description,
    required this.expectedEffectiveness,
    required this.reason,
    this.suggestedAt,
  });
}

// ============================================================================
// 5. 復習スケジューリング・忘却曲線モデル
// ============================================================================

/// 復習予定
class ReviewSchedule {
  final String studentId;
  final String questionId;
  final DateTime nextReviewDate;
  final int reviewCount;
  final String interval;
  final double retentionRate;
  final DateTime? lastReviewedAt;

  ReviewSchedule({
    required this.studentId,
    required this.questionId,
    required this.nextReviewDate,
    required this.reviewCount,
    required this.interval,
    required this.retentionRate,
    this.lastReviewedAt,
  });
}

// ============================================================================
// 6. グループ学習マッチングモデル
// ============================================================================

/// スタディグループマッチング情報
class StudyGroupMatch {
  final String studentId;
  final List<String> suggestedPeerIds;
  final List<String> suggestedTopics;
  final double compatibilityScore;
  final String reason;
  final DateTime generatedAt;

  StudyGroupMatch({
    required this.studentId,
    required this.suggestedPeerIds,
    required this.suggestedTopics,
    required this.compatibilityScore,
    required this.reason,
    required this.generatedAt,
  });
}

/// グループ学習セッション
class GroupLearningSession {
  final String id;
  final List<String> studentIds;
  final String topicId;
  final String topicName;
  final DateTime scheduledAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int estimatedDurationMinutes;
  final List<String>? resourceUrls;
  final String? outcome;
  final Map<String, double>? studentScores;

  GroupLearningSession({
    required this.id,
    required this.studentIds,
    required this.topicId,
    required this.topicName,
    required this.scheduledAt,
    this.startedAt,
    this.completedAt,
    required this.estimatedDurationMinutes,
    this.resourceUrls,
    this.outcome,
    this.studentScores,
  });
}

// ============================================================================
// 7. ピア比較・モチベーションモデル
// ============================================================================

/// ピア比較情報
class PeerComparison {
  final String studentId;
  final double studentScore;
  final double cohortAverage;
  final double cohortMedian;
  final int percentileRank;
  final int cohortSize;
  final String performanceLevel;
  final List<String> strengths;
  final List<String> improvementAreas;
  final DateTime generatedAt;

  PeerComparison({
    required this.studentId,
    required this.studentScore,
    required this.cohortAverage,
    required this.cohortMedian,
    required this.percentileRank,
    required this.cohortSize,
    required this.performanceLevel,
    required this.strengths,
    required this.improvementAreas,
    required this.generatedAt,
  });
}

/// 励まし・モチベーションメッセージ
class MotivationalInsight {
  final String id;
  final String studentId;
  final String messageType;
  final String message;
  final String actionCTA;
  final DateTime generatedAt;
  final DateTime? viewedAt;

  MotivationalInsight({
    required this.id,
    required this.studentId,
    required this.messageType,
    required this.message,
    required this.actionCTA,
    required this.generatedAt,
    this.viewedAt,
  });
}
