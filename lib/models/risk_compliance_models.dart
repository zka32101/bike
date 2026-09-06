/// Advanced Risk Management & Compliance Models
/// Comprehensive risk assessment, compliance tracking, and audit management

// ============================================================================
// Enums (7 total)
// ============================================================================

enum RiskLevel {
  critical,
  high,
  medium,
  low,
  minimal;

  String get displayName {
    switch (this) {
      case RiskLevel.critical:
        return 'Critical (致命的)';
      case RiskLevel.high:
        return 'High (高)';
      case RiskLevel.medium:
        return 'Medium (中)';
      case RiskLevel.low:
        return 'Low (低)';
      case RiskLevel.minimal:
        return 'Minimal (最小)';
    }
  }
}

enum RiskCategory {
  operational,
  financial,
  regulatory,
  reputational,
  strategic,
  technology;

  String get displayName {
    switch (this) {
      case RiskCategory.operational:
        return 'Operational (運用)';
      case RiskCategory.financial:
        return 'Financial (財務)';
      case RiskCategory.regulatory:
        return 'Regulatory (規制)';
      case RiskCategory.reputational:
        return 'Reputational (評判)';
      case RiskCategory.strategic:
        return 'Strategic (戦略)';
      case RiskCategory.technology:
        return 'Technology (技術)';
    }
  }
}

enum RiskStatus {
  identified,
  assessed,
  mitigating,
  monitored,
  resolved,
  accepted;

  String get displayName {
    switch (this) {
      case RiskStatus.identified:
        return 'Identified (特定)';
      case RiskStatus.assessed:
        return 'Assessed (評価済)';
      case RiskStatus.mitigating:
        return 'Mitigating (軽減中)';
      case RiskStatus.monitored:
        return 'Monitored (監視中)';
      case RiskStatus.resolved:
        return 'Resolved (解決)';
      case RiskStatus.accepted:
        return 'Accepted (許容)';
    }
  }
}

enum ComplianceFramework {
  iso27001,
  gdpr,
  hipaa,
  pci,
  sox,
  custom;

  String get displayName {
    switch (this) {
      case ComplianceFramework.iso27001:
        return 'ISO 27001';
      case ComplianceFramework.gdpr:
        return 'GDPR';
      case ComplianceFramework.hipaa:
        return 'HIPAA';
      case ComplianceFramework.pci:
        return 'PCI-DSS';
      case ComplianceFramework.sox:
        return 'SOX';
      case ComplianceFramework.custom:
        return 'Custom (カスタム)';
    }
  }
}

enum ComplianceStatus {
  compliant,
  nonCompliant,
  partiallyCompliant,
  underReview,
  notApplicable;

  String get displayName {
    switch (this) {
      case ComplianceStatus.compliant:
        return 'Compliant (準拠)';
      case ComplianceStatus.nonCompliant:
        return 'Non-Compliant (非準拠)';
      case ComplianceStatus.partiallyCompliant:
        return 'Partially Compliant (部分的)';
      case ComplianceStatus.underReview:
        return 'Under Review (審査中)';
      case ComplianceStatus.notApplicable:
        return 'Not Applicable (該当なし)';
    }
  }
}

enum AuditType {
  internal,
  external,
  regulatory,
  operational,
  financial,
  security;

  String get displayName {
    switch (this) {
      case AuditType.internal:
        return 'Internal (内部)';
      case AuditType.external:
        return 'External (外部)';
      case AuditType.regulatory:
        return 'Regulatory (規制)';
      case AuditType.operational:
        return 'Operational (運用)';
      case AuditType.financial:
        return 'Financial (財務)';
      case AuditType.security:
        return 'Security (セキュリティ)';
    }
  }
}

enum AuditStatus {
  planned,
  inProgress,
  completed,
  onHold,
  cancelled;

  String get displayName {
    switch (this) {
      case AuditStatus.planned:
        return 'Planned (計画中)';
      case AuditStatus.inProgress:
        return 'In Progress (進行中)';
      case AuditStatus.completed:
        return 'Completed (完了)';
      case AuditStatus.onHold:
        return 'On Hold (保留中)';
      case AuditStatus.cancelled:
        return 'Cancelled (キャンセル)';
    }
  }
}

// ============================================================================
// Model Classes (10 total)
// ============================================================================

class RiskAssessment {
  final String riskId;
  final String riskName;
  final String description;
  final RiskLevel level;
  final RiskCategory category;
  final RiskStatus status;
  final double probability;
  final double impact;
  final DateTime createdDate;

  RiskAssessment({
    required this.riskId,
    required this.riskName,
    required this.description,
    required this.level,
    required this.category,
    required this.status,
    required this.probability,
    required this.impact,
    required this.createdDate,
  });

  double get riskScore => probability * impact;
  bool get isActive => status != RiskStatus.resolved && status != RiskStatus.accepted;
  int get ageInDays => DateTime.now().difference(createdDate).inDays;

  RiskAssessment copyWith({
    String? riskId,
    String? riskName,
    String? description,
    RiskLevel? level,
    RiskCategory? category,
    RiskStatus? status,
    double? probability,
    double? impact,
    DateTime? createdDate,
  }) {
    return RiskAssessment(
      riskId: riskId ?? this.riskId,
      riskName: riskName ?? this.riskName,
      description: description ?? this.description,
      level: level ?? this.level,
      category: category ?? this.category,
      status: status ?? this.status,
      probability: probability ?? this.probability,
      impact: impact ?? this.impact,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}

class MitigationPlan {
  final String planId;
  final String riskId;
  final String mitigation;
  final String owner;
  final DateTime startDate;
  final DateTime targetDate;
  final double effectiveness;
  final int costEstimate;

  MitigationPlan({
    required this.planId,
    required this.riskId,
    required this.mitigation,
    required this.owner,
    required this.startDate,
    required this.targetDate,
    required this.effectiveness,
    required this.costEstimate,
  });

  bool get isOnTrack => DateTime.now().isBefore(targetDate);
  int get durationDays => targetDate.difference(startDate).inDays;
  int get ageInDays => DateTime.now().difference(startDate).inDays;

  MitigationPlan copyWith({
    String? planId,
    String? riskId,
    String? mitigation,
    String? owner,
    DateTime? startDate,
    DateTime? targetDate,
    double? effectiveness,
    int? costEstimate,
  }) {
    return MitigationPlan(
      planId: planId ?? this.planId,
      riskId: riskId ?? this.riskId,
      mitigation: mitigation ?? this.mitigation,
      owner: owner ?? this.owner,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      effectiveness: effectiveness ?? this.effectiveness,
      costEstimate: costEstimate ?? this.costEstimate,
    );
  }
}

class ComplianceRequirement {
  final String requirementId;
  final String requirementName;
  final ComplianceFramework framework;
  final String description;
  final ComplianceStatus status;
  final DateTime dueDate;
  final String owner;

  ComplianceRequirement({
    required this.requirementId,
    required this.requirementName,
    required this.framework,
    required this.description,
    required this.status,
    required this.dueDate,
    required this.owner,
  });

  bool get isCompliant => status == ComplianceStatus.compliant;
  bool get isOverdue => DateTime.now().isAfter(dueDate);
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;

  ComplianceRequirement copyWith({
    String? requirementId,
    String? requirementName,
    ComplianceFramework? framework,
    String? description,
    ComplianceStatus? status,
    DateTime? dueDate,
    String? owner,
  }) {
    return ComplianceRequirement(
      requirementId: requirementId ?? this.requirementId,
      requirementName: requirementName ?? this.requirementName,
      framework: framework ?? this.framework,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      owner: owner ?? this.owner,
    );
  }
}

class Audit {
  final String auditId;
  final String auditName;
  final AuditType type;
  final AuditStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final String auditor;
  final int findingsCount;

  Audit({
    required this.auditId,
    required this.auditName,
    required this.type,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.auditor,
    required this.findingsCount,
  });

  bool get isCompleted => status == AuditStatus.completed;
  int get durationDays => (endDate ?? DateTime.now()).difference(startDate).inDays;
  int get ageInDays => DateTime.now().difference(startDate).inDays;

  Audit copyWith({
    String? auditId,
    String? auditName,
    AuditType? type,
    AuditStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? auditor,
    int? findingsCount,
  }) {
    return Audit(
      auditId: auditId ?? this.auditId,
      auditName: auditName ?? this.auditName,
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      auditor: auditor ?? this.auditor,
      findingsCount: findingsCount ?? this.findingsCount,
    );
  }
}

class AuditFinding {
  final String findingId;
  final String auditId;
  final String title;
  final RiskLevel severity;
  final String description;
  final String correctionAction;
  final DateTime dueDate;
  final bool isClosed;

  AuditFinding({
    required this.findingId,
    required this.auditId,
    required this.title,
    required this.severity,
    required this.description,
    required this.correctionAction,
    required this.dueDate,
    required this.isClosed,
  });

  bool get isOverdue => !isClosed && DateTime.now().isAfter(dueDate);
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;

  AuditFinding copyWith({
    String? findingId,
    String? auditId,
    String? title,
    RiskLevel? severity,
    String? description,
    String? correctionAction,
    DateTime? dueDate,
    bool? isClosed,
  }) {
    return AuditFinding(
      findingId: findingId ?? this.findingId,
      auditId: auditId ?? this.auditId,
      title: title ?? this.title,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      correctionAction: correctionAction ?? this.correctionAction,
      dueDate: dueDate ?? this.dueDate,
      isClosed: isClosed ?? this.isClosed,
    );
  }
}

class Policy {
  final String policyId;
  final String policyName;
  final String content;
  final DateTime effectiveDate;
  final DateTime? reviewDate;
  final String owner;
  final bool isActive;

  Policy({
    required this.policyId,
    required this.policyName,
    required this.content,
    required this.effectiveDate,
    required this.reviewDate,
    required this.owner,
    required this.isActive,
  });

  bool get needsReview => reviewDate != null && DateTime.now().isAfter(reviewDate!);
  int get ageInDays => DateTime.now().difference(effectiveDate).inDays;

  Policy copyWith({
    String? policyId,
    String? policyName,
    String? content,
    DateTime? effectiveDate,
    DateTime? reviewDate,
    String? owner,
    bool? isActive,
  }) {
    return Policy(
      policyId: policyId ?? this.policyId,
      policyName: policyName ?? this.policyName,
      content: content ?? this.content,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      reviewDate: reviewDate ?? this.reviewDate,
      owner: owner ?? this.owner,
      isActive: isActive ?? this.isActive,
    );
  }
}

class ControlObjective {
  final String controlId;
  final String controlName;
  final String description;
  final RiskCategory category;
  final ComplianceStatus status;
  final DateTime lastTested;
  final bool isEffective;

  ControlObjective({
    required this.controlId,
    required this.controlName,
    required this.description,
    required this.category,
    required this.status,
    required this.lastTested,
    required this.isEffective,
  });

  bool get needsTesting => DateTime.now().difference(lastTested).inDays > 365;
  int get daysSinceTest => DateTime.now().difference(lastTested).inDays;

  ControlObjective copyWith({
    String? controlId,
    String? controlName,
    String? description,
    RiskCategory? category,
    ComplianceStatus? status,
    DateTime? lastTested,
    bool? isEffective,
  }) {
    return ControlObjective(
      controlId: controlId ?? this.controlId,
      controlName: controlName ?? this.controlName,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      lastTested: lastTested ?? this.lastTested,
      isEffective: isEffective ?? this.isEffective,
    );
  }
}

class IncidentReport {
  final String incidentId;
  final String title;
  final String description;
  final RiskLevel severity;
  final DateTime reportedDate;
  final DateTime? resolvedDate;
  final String reporter;
  final String rootCause;

  IncidentReport({
    required this.incidentId,
    required this.title,
    required this.description,
    required this.severity,
    required this.reportedDate,
    required this.resolvedDate,
    required this.reporter,
    required this.rootCause,
  });

  bool get isResolved => resolvedDate != null;
  int get durationDays => (resolvedDate ?? DateTime.now()).difference(reportedDate).inDays;
  int get ageInDays => DateTime.now().difference(reportedDate).inDays;

  IncidentReport copyWith({
    String? incidentId,
    String? title,
    String? description,
    RiskLevel? severity,
    DateTime? reportedDate,
    DateTime? resolvedDate,
    String? reporter,
    String? rootCause,
  }) {
    return IncidentReport(
      incidentId: incidentId ?? this.incidentId,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      reportedDate: reportedDate ?? this.reportedDate,
      resolvedDate: resolvedDate ?? this.resolvedDate,
      reporter: reporter ?? this.reporter,
      rootCause: rootCause ?? this.rootCause,
    );
  }
}

class ComplianceMetrics {
  final String metricsId;
  final DateTime reportDate;
  final double overallComplianceScore;
  final int totalRequirements;
  final int compliantRequirements;
  final double riskMitigationRate;
  final int openFindings;

  ComplianceMetrics({
    required this.metricsId,
    required this.reportDate,
    required this.overallComplianceScore,
    required this.totalRequirements,
    required this.compliantRequirements,
    required this.riskMitigationRate,
    required this.openFindings,
  });

  double get compliancePercentage => totalRequirements > 0 ? (compliantRequirements / totalRequirements) * 100 : 0;
  bool get isHealthy => overallComplianceScore >= 80;
  int get ageInDays => DateTime.now().difference(reportDate).inDays;

  ComplianceMetrics copyWith({
    String? metricsId,
    DateTime? reportDate,
    double? overallComplianceScore,
    int? totalRequirements,
    int? compliantRequirements,
    double? riskMitigationRate,
    int? openFindings,
  }) {
    return ComplianceMetrics(
      metricsId: metricsId ?? this.metricsId,
      reportDate: reportDate ?? this.reportDate,
      overallComplianceScore: overallComplianceScore ?? this.overallComplianceScore,
      totalRequirements: totalRequirements ?? this.totalRequirements,
      compliantRequirements: compliantRequirements ?? this.compliantRequirements,
      riskMitigationRate: riskMitigationRate ?? this.riskMitigationRate,
      openFindings: openFindings ?? this.openFindings,
    );
  }
}
