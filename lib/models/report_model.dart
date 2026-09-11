/// レポート生成・エクスポートシステムのデータモデル

// ============================================================================
// 1. レポート定義・設定
// ============================================================================

/// レポートテンプレート
class ReportTemplate {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> includedMetrics;
  final String defaultFormat;
  final Map<String, dynamic> templateConfig;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isCustom;

  ReportTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.includedMetrics,
    required this.defaultFormat,
    required this.templateConfig,
    this.createdAt,
    this.updatedAt,
    this.isCustom,
  });
}

/// レポート設定（フィルタ・期間・フォーマット）
class ReportConfig {
  final String id;
  final String templateId;
  final String reportType;
  final String format;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic>? filters;
  final List<String>? includedFields;
  final bool? includeCharts;
  final bool? includeSummary;
  final String? timezone;
  final DateTime? createdAt;

  ReportConfig({
    required this.id,
    required this.templateId,
    required this.reportType,
    required this.format,
    required this.startDate,
    required this.endDate,
    this.filters,
    this.includedFields,
    this.includeCharts,
    this.includeSummary,
    this.timezone,
    this.createdAt,
  });
}

// ============================================================================
// 2. 生成されたレポート
// ============================================================================

/// 生成済みレポート
class GeneratedReport {
  final String id;
  final String templateId;
  final String reportType;
  final String title;
  final String description;
  final String format;
  final DateTime generatedAt;
  final DateTime startDate;
  final DateTime endDate;
  final String contentUrl;
  final double fileSizeBytes;
  final String generatedBy;
  final int? pageCount;
  final int? recordCount;
  final String? status;
  final String? errorMessage;
  final DateTime? expiresAt;
  final int? downloadCount;
  final DateTime? lastDownloadedAt;

  GeneratedReport({
    required this.id,
    required this.templateId,
    required this.reportType,
    required this.title,
    required this.description,
    required this.format,
    required this.generatedAt,
    required this.startDate,
    required this.endDate,
    required this.contentUrl,
    required this.fileSizeBytes,
    required this.generatedBy,
    this.pageCount,
    this.recordCount,
    this.status,
    this.errorMessage,
    this.expiresAt,
    this.downloadCount,
    this.lastDownloadedAt,
  });
}

/// レポート配信設定（スケジュール）
class ReportDeliverySchedule {
  final String id;
  final String templateId;
  final String deliveryType;
  final String frequency;
  final String dayOfWeek;
  final int dayOfMonth;
  final String time;
  final List<String> recipientEmails;
  final String timezone;
  final bool? isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? nextDeliveryAt;
  final int? totalDeliveries;

  ReportDeliverySchedule({
    required this.id,
    required this.templateId,
    required this.deliveryType,
    required this.frequency,
    required this.dayOfWeek,
    required this.dayOfMonth,
    required this.time,
    required this.recipientEmails,
    required this.timezone,
    this.isActive,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.nextDeliveryAt,
    this.totalDeliveries,
  });
}

// ============================================================================
// 3. エクスポート機能
// ============================================================================

/// エクスポート設定
class ExportConfig {
  final String id;
  final String dataType;
  final String format;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic>? filters;
  final List<String>? includedFields;
  final bool? includePersonalInfo;
  final bool? maskPersonalData;
  final String? encryptionType;
  final DateTime? createdAt;

  ExportConfig({
    required this.id,
    required this.dataType,
    required this.format,
    required this.startDate,
    required this.endDate,
    this.filters,
    this.includedFields,
    this.includePersonalInfo,
    this.maskPersonalData,
    this.encryptionType,
    this.createdAt,
  });
}

/// エクスポート結果
class ExportResult {
  final String id;
  final String exportType;
  final String format;
  final String downloadUrl;
  final int recordCount;
  final double fileSizeBytes;
  final DateTime createdAt;
  final String status;
  final String? errorMessage;
  final DateTime? expiresAt;
  final int? downloadCount;
  final bool? isEncrypted;
  final String? encryptionKey;

  ExportResult({
    required this.id,
    required this.exportType,
    required this.format,
    required this.downloadUrl,
    required this.recordCount,
    required this.fileSizeBytes,
    required this.createdAt,
    required this.status,
    this.errorMessage,
    this.expiresAt,
    this.downloadCount,
    this.isEncrypted,
    this.encryptionKey,
  });
}

// ============================================================================
// 4. 教師・管理者向けダッシュボード
// ============================================================================

/// クラス管理ビュー
class ClassManagementView {
  final String classId;
  final String className;
  final int totalStudents;
  final int activeStudents;
  final double averageScore;
  final Map<String, int> scoreDistribution;
  final List<String> topPerformers;
  final List<String> needsSupport;
  final Map<String, double> categoryAverages;
  final DateTime lastUpdatedAt;

  ClassManagementView({
    required this.classId,
    required this.className,
    required this.totalStudents,
    required this.activeStudents,
    required this.averageScore,
    required this.scoreDistribution,
    required this.topPerformers,
    required this.needsSupport,
    required this.categoryAverages,
    required this.lastUpdatedAt,
  });
}

/// 学生パフォーマンス分析（教師用）
class StudentPerformanceAnalysis {
  final String studentId;
  final String studentName;
  final double currentScore;
  final double previousScore;
  final double scoreChange;
  final String trend;
  final int questionsAttempted;
  final int correctAnswers;
  final double accuracy;
  final Map<String, double> categoryScores;
  final List<String> weakCategories;
  final List<String> strongCategories;
  final DateTime lastActivityAt;
  final String engagementLevel;
  final List<String> recommendedActions;

  StudentPerformanceAnalysis({
    required this.studentId,
    required this.studentName,
    required this.currentScore,
    required this.previousScore,
    required this.scoreChange,
    required this.trend,
    required this.questionsAttempted,
    required this.correctAnswers,
    required this.accuracy,
    required this.categoryScores,
    required this.weakCategories,
    required this.strongCategories,
    required this.lastActivityAt,
    required this.engagementLevel,
    required this.recommendedActions,
  });
}

/// 掲示板（クラス内コミュニケーション）
class Announcement {
  final String id;
  final String classId;
  final String creatorId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String priority;
  final List<String> targetStudentIds;
  final DateTime? expiresAt;
  final int? viewCount;

  Announcement({
    required this.id,
    required this.classId,
    required this.creatorId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    required this.priority,
    required this.targetStudentIds,
    this.expiresAt,
    this.viewCount,
  });
}

/// 課題・アサインメント
class Assignment {
  final String id;
  final String classId;
  final String creatorId;
  final String title;
  final String description;
  final DateTime dueDate;
  final List<String> assignedStudentIds;
  final String category;
  final int estimatedMinutes;
  final DateTime? createdAt;
  final Map<String, dynamic>? rubric;
  final List<String>? resourceUrls;
  final bool? allowLateSubmission;
  final int? lateSubmissionPenaltyPercent;

  Assignment({
    required this.id,
    required this.classId,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.assignedStudentIds,
    required this.category,
    required this.estimatedMinutes,
    this.createdAt,
    this.rubric,
    this.resourceUrls,
    this.allowLateSubmission,
    this.lateSubmissionPenaltyPercent,
  });
}

/// 採点・フィードバック
class GradingFeedback {
  final String id;
  final String assignmentId;
  final String studentId;
  final double score;
  final String scoreOutOf;
  final String feedbackText;
  final DateTime submittedAt;
  final DateTime gradedAt;
  final String gradedBy;
  final List<String>? attachmentUrls;
  final bool? isPublished;
  final DateTime? publishedAt;

  GradingFeedback({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.score,
    required this.scoreOutOf,
    required this.feedbackText,
    required this.submittedAt,
    required this.gradedAt,
    required this.gradedBy,
    this.attachmentUrls,
    this.isPublished,
    this.publishedAt,
  });
}

// ============================================================================
// 5. 統計分析・予測
// ============================================================================

/// コホート分析（学年別、入学日別の比較）
class CohortAnalysis {
  final String id;
  final String cohortName;
  final String cohortType;
  final int totalStudents;
  final double averageScore;
  final double medianScore;
  final double stdDeviation;
  final Map<String, int> scoreDistribution;
  final Map<String, double> categoryAverages;
  final double completionRate;
  final double passRate;
  final DateTime generatedAt;
  final int percentileRank;

  CohortAnalysis({
    required this.id,
    required this.cohortName,
    required this.cohortType,
    required this.totalStudents,
    required this.averageScore,
    required this.medianScore,
    required this.stdDeviation,
    required this.scoreDistribution,
    required this.categoryAverages,
    required this.completionRate,
    required this.passRate,
    required this.generatedAt,
    required this.percentileRank,
  });
}

/// 修了予定日・脱落リスク予測
class CompletionPrediction {
  final String studentId;
  final DateTime estimatedCompletionDate;
  final int estimatedDaysRemaining;
  final double completionLikelihood;
  final String riskLevel;
  final List<String> riskFactors;
  final List<String> positiveFactors;
  final String recommendedAction;
  final DateTime predictedAt;

  CompletionPrediction({
    required this.studentId,
    required this.estimatedCompletionDate,
    required this.estimatedDaysRemaining,
    required this.completionLikelihood,
    required this.riskLevel,
    required this.riskFactors,
    required this.positiveFactors,
    required this.recommendedAction,
    required this.predictedAt,
  });
}

/// ベンチマーク分析（機関内外の比較）
class BenchmarkAnalysis {
  final String id;
  final String institutionId;
  final double institutionAverage;
  final double nationalAverage;
  final double regionAverage;
  final double performanceDifference;
  final String performanceRating;
  final Map<String, double> categoryComparison;
  final int percentilRank;
  final DateTime analyzeDate;

  BenchmarkAnalysis({
    required this.id,
    required this.institutionId,
    required this.institutionAverage,
    required this.nationalAverage,
    required this.regionAverage,
    required this.performanceDifference,
    required this.performanceRating,
    required this.categoryComparison,
    required this.percentilRank,
    required this.analyzeDate,
  });
}
