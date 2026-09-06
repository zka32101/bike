// ignore_for_file: constant_identifier_names

enum ProjectStatus {
  initiated,
  planning,
  active,
  onHold,
  completed,
  cancelled,
  archived;

  String get displayName {
    switch (this) {
      case ProjectStatus.initiated:
        return 'Initiated (開始)';
      case ProjectStatus.planning:
        return 'Planning (計画)';
      case ProjectStatus.active:
        return 'Active (実行中)';
      case ProjectStatus.onHold:
        return 'On Hold (保留中)';
      case ProjectStatus.completed:
        return 'Completed (完了)';
      case ProjectStatus.cancelled:
        return 'Cancelled (キャンセル)';
      case ProjectStatus.archived:
        return 'Archived (アーカイブ)';
    }
  }
}

enum ProjectType {
  strategic,
  operational,
  compliance,
  maintenance,
  innovation,
  infrastructure;

  String get displayName {
    switch (this) {
      case ProjectType.strategic:
        return 'Strategic (戦略的)';
      case ProjectType.operational:
        return 'Operational (運用)';
      case ProjectType.compliance:
        return 'Compliance (コンプライアンス)';
      case ProjectType.maintenance:
        return 'Maintenance (保守)';
      case ProjectType.innovation:
        return 'Innovation (革新)';
      case ProjectType.infrastructure:
        return 'Infrastructure (インフラ)';
    }
  }
}

enum ProjectPriority {
  critical,
  high,
  medium,
  low;

  String get displayName {
    switch (this) {
      case ProjectPriority.critical:
        return 'Critical (重大)';
      case ProjectPriority.high:
        return 'High (高)';
      case ProjectPriority.medium:
        return 'Medium (中)';
      case ProjectPriority.low:
        return 'Low (低)';
    }
  }
}

enum PortfolioStatus {
  active,
  inactive,
  archived;

  String get displayName {
    switch (this) {
      case PortfolioStatus.active:
        return 'Active (アクティブ)';
      case PortfolioStatus.inactive:
        return 'Inactive (非アクティブ)';
      case PortfolioStatus.archived:
        return 'Archived (アーカイブ)';
    }
  }
}

enum ResourceRole {
  projectManager,
  technicalLead,
  developer,
  qa,
  designer,
  analyst,
  stakeholder;

  String get displayName {
    switch (this) {
      case ResourceRole.projectManager:
        return 'Project Manager (プロジェクトマネージャー)';
      case ResourceRole.technicalLead:
        return 'Technical Lead (技術リード)';
      case ResourceRole.developer:
        return 'Developer (開発者)';
      case ResourceRole.qa:
        return 'QA (品質保証)';
      case ResourceRole.designer:
        return 'Designer (デザイナー)';
      case ResourceRole.analyst:
        return 'Analyst (分析者)';
      case ResourceRole.stakeholder:
        return 'Stakeholder (ステークホルダー)';
    }
  }
}

enum PhaseStatus {
  notStarted,
  inProgress,
  onHold,
  completed,
  failed;

  String get displayName {
    switch (this) {
      case PhaseStatus.notStarted:
        return 'Not Started (未開始)';
      case PhaseStatus.inProgress:
        return 'In Progress (進行中)';
      case PhaseStatus.onHold:
        return 'On Hold (保留中)';
      case PhaseStatus.completed:
        return 'Completed (完了)';
      case PhaseStatus.failed:
        return 'Failed (失敗)';
    }
  }
}

enum RiskCategory {
  technical,
  schedule,
  budget,
  resource,
  vendor,
  regulatory;

  String get displayName {
    switch (this) {
      case RiskCategory.technical:
        return 'Technical (技術的)';
      case RiskCategory.schedule:
        return 'Schedule (スケジュール)';
      case RiskCategory.budget:
        return 'Budget (予算)';
      case RiskCategory.resource:
        return 'Resource (リソース)';
      case RiskCategory.vendor:
        return 'Vendor (ベンダー)';
      case RiskCategory.regulatory:
        return 'Regulatory (規制)';
    }
  }
}

class Project {
  final String projectId;
  final String projectName;
  final ProjectStatus status;
  final ProjectType type;
  final ProjectPriority priority;
  final String description;
  final String sponsor;
  final String projectManager;
  final double budget;
  final double? actualCost;
  final DateTime startDate;
  final DateTime plannedEndDate;
  final DateTime? actualEndDate;
  final int completionPercentage;

  Project({
    required this.projectId,
    required this.projectName,
    required this.status,
    required this.type,
    required this.priority,
    required this.description,
    required this.sponsor,
    required this.projectManager,
    required this.budget,
    this.actualCost,
    required this.startDate,
    required this.plannedEndDate,
    this.actualEndDate,
    required this.completionPercentage,
  });

  bool get isActive => status == ProjectStatus.active;
  bool get isCompleted => status == ProjectStatus.completed;
  bool get isOverdue => DateTime.now().isAfter(plannedEndDate) && !isCompleted;
  int get daysUntilDeadline => plannedEndDate.difference(DateTime.now()).inDays;
  int get ageInDays => DateTime.now().difference(startDate).inDays;
  double? get budgetVariance => actualCost == null ? null : actualCost! - budget;
  double? get budgetPercentage => actualCost == null ? null : (actualCost! / budget) * 100;
  bool get isBudgetOverrun => budgetPercentage != null && budgetPercentage! > 100;

  Project copyWith({
    String? projectId,
    String? projectName,
    ProjectStatus? status,
    ProjectType? type,
    ProjectPriority? priority,
    String? description,
    String? sponsor,
    String? projectManager,
    double? budget,
    double? actualCost,
    DateTime? startDate,
    DateTime? plannedEndDate,
    DateTime? actualEndDate,
    int? completionPercentage,
  }) {
    return Project(
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      status: status ?? this.status,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      sponsor: sponsor ?? this.sponsor,
      projectManager: projectManager ?? this.projectManager,
      budget: budget ?? this.budget,
      actualCost: actualCost ?? this.actualCost,
      startDate: startDate ?? this.startDate,
      plannedEndDate: plannedEndDate ?? this.plannedEndDate,
      actualEndDate: actualEndDate ?? this.actualEndDate,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }
}

class Portfolio {
  final String portfolioId;
  final String portfolioName;
  final PortfolioStatus status;
  final String owner;
  final List<String> projectIds;
  final double totalBudget;
  final DateTime createdDate;
  final String? description;

  Portfolio({
    required this.portfolioId,
    required this.portfolioName,
    required this.status,
    required this.owner,
    required this.projectIds,
    required this.totalBudget,
    required this.createdDate,
    this.description,
  });

  int get projectCount => projectIds.length;
  bool get isActive => status == PortfolioStatus.active;
  int get ageInDays => DateTime.now().difference(createdDate).inDays;

  Portfolio copyWith({
    String? portfolioId,
    String? portfolioName,
    PortfolioStatus? status,
    String? owner,
    List<String>? projectIds,
    double? totalBudget,
    DateTime? createdDate,
    String? description,
  }) {
    return Portfolio(
      portfolioId: portfolioId ?? this.portfolioId,
      portfolioName: portfolioName ?? this.portfolioName,
      status: status ?? this.status,
      owner: owner ?? this.owner,
      projectIds: projectIds ?? this.projectIds,
      totalBudget: totalBudget ?? this.totalBudget,
      createdDate: createdDate ?? this.createdDate,
      description: description ?? this.description,
    );
  }
}

class ProjectPhase {
  final String phaseId;
  final String projectId;
  final String phaseName;
  final PhaseStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final int sequenceNumber;
  final List<String> deliverableIds;
  final int completionPercentage;

  ProjectPhase({
    required this.phaseId,
    required this.projectId,
    required this.phaseName,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.sequenceNumber,
    required this.deliverableIds,
    required this.completionPercentage,
  });

  bool get isCompleted => status == PhaseStatus.completed;
  bool get isOverdue => DateTime.now().isAfter(endDate) && !isCompleted;
  int get daysUntilDeadline => endDate.difference(DateTime.now()).inDays;
  int get ageInDays => DateTime.now().difference(startDate).inDays;

  ProjectPhase copyWith({
    String? phaseId,
    String? projectId,
    String? phaseName,
    PhaseStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int? sequenceNumber,
    List<String>? deliverableIds,
    int? completionPercentage,
  }) {
    return ProjectPhase(
      phaseId: phaseId ?? this.phaseId,
      projectId: projectId ?? this.projectId,
      phaseName: phaseName ?? this.phaseName,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      deliverableIds: deliverableIds ?? this.deliverableIds,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }
}

class Deliverable {
  final String deliverableId;
  final String projectId;
  final String phaseId;
  final String deliverableName;
  final String description;
  final DateTime dueDate;
  final DateTime? completionDate;
  final bool isCompleted;
  final String owner;
  final List<String> dependencies;

  Deliverable({
    required this.deliverableId,
    required this.projectId,
    required this.phaseId,
    required this.deliverableName,
    required this.description,
    required this.dueDate,
    this.completionDate,
    required this.isCompleted,
    required this.owner,
    required this.dependencies,
  });

  bool get isOverdue => DateTime.now().isAfter(dueDate) && !isCompleted;
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
  int get ageInDays => completionDate == null ? DateTime.now().difference(DateTime.now()).inDays : completionDate!.difference(DateTime.now()).inDays;

  Deliverable copyWith({
    String? deliverableId,
    String? projectId,
    String? phaseId,
    String? deliverableName,
    String? description,
    DateTime? dueDate,
    DateTime? completionDate,
    bool? isCompleted,
    String? owner,
    List<String>? dependencies,
  }) {
    return Deliverable(
      deliverableId: deliverableId ?? this.deliverableId,
      projectId: projectId ?? this.projectId,
      phaseId: phaseId ?? this.phaseId,
      deliverableName: deliverableName ?? this.deliverableName,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      completionDate: completionDate ?? this.completionDate,
      isCompleted: isCompleted ?? this.isCompleted,
      owner: owner ?? this.owner,
      dependencies: dependencies ?? this.dependencies,
    );
  }
}

class Resource {
  final String resourceId;
  final String resourceName;
  final ResourceRole role;
  final String department;
  final String projectId;
  final double allocationPercentage;
  final DateTime startDate;
  final DateTime? endDate;
  final String skills;

  Resource({
    required this.resourceId,
    required this.resourceName,
    required this.role,
    required this.department,
    required this.projectId,
    required this.allocationPercentage,
    required this.startDate,
    this.endDate,
    required this.skills,
  });

  bool get isAllocated => allocationPercentage > 0;
  bool get isFullyAllocated => allocationPercentage >= 100;
  int get tenureInDays => (endDate ?? DateTime.now()).difference(startDate).inDays;

  Resource copyWith({
    String? resourceId,
    String? resourceName,
    ResourceRole? role,
    String? department,
    String? projectId,
    double? allocationPercentage,
    DateTime? startDate,
    DateTime? endDate,
    String? skills,
  }) {
    return Resource(
      resourceId: resourceId ?? this.resourceId,
      resourceName: resourceName ?? this.resourceName,
      role: role ?? this.role,
      department: department ?? this.department,
      projectId: projectId ?? this.projectId,
      allocationPercentage: allocationPercentage ?? this.allocationPercentage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      skills: skills ?? this.skills,
    );
  }
}

class ProjectRisk {
  final String riskId;
  final String projectId;
  final String riskName;
  final RiskCategory category;
  final double probability;
  final double impact;
  final String mitigation;
  final String owner;
  final DateTime identifiedDate;
  final bool isResolved;

  ProjectRisk({
    required this.riskId,
    required this.projectId,
    required this.riskName,
    required this.category,
    required this.probability,
    required this.impact,
    required this.mitigation,
    required this.owner,
    required this.identifiedDate,
    required this.isResolved,
  });

  double get riskScore => probability * impact;
  int get ageInDays => DateTime.now().difference(identifiedDate).inDays;

  ProjectRisk copyWith({
    String? riskId,
    String? projectId,
    String? riskName,
    RiskCategory? category,
    double? probability,
    double? impact,
    String? mitigation,
    String? owner,
    DateTime? identifiedDate,
    bool? isResolved,
  }) {
    return ProjectRisk(
      riskId: riskId ?? this.riskId,
      projectId: projectId ?? this.projectId,
      riskName: riskName ?? this.riskName,
      category: category ?? this.category,
      probability: probability ?? this.probability,
      impact: impact ?? this.impact,
      mitigation: mitigation ?? this.mitigation,
      owner: owner ?? this.owner,
      identifiedDate: identifiedDate ?? this.identifiedDate,
      isResolved: isResolved ?? this.isResolved,
    );
  }
}

class ResourceAllocation {
  final String allocationId;
  final String resourceId;
  final String projectId;
  final double allocationPercentage;
  final DateTime startDate;
  final DateTime? endDate;
  final double hourlyRate;

  ResourceAllocation({
    required this.allocationId,
    required this.resourceId,
    required this.projectId,
    required this.allocationPercentage,
    required this.startDate,
    this.endDate,
    required this.hourlyRate,
  });

  double get estimatedCost => allocationPercentage * hourlyRate * 40 * 4.33; // Monthly cost
  int get durationInDays => (endDate ?? DateTime.now()).difference(startDate).inDays;
  bool get isActive => DateTime.now().isBefore(endDate ?? DateTime.now().add(Duration(days: 1)));

  ResourceAllocation copyWith({
    String? allocationId,
    String? resourceId,
    String? projectId,
    double? allocationPercentage,
    DateTime? startDate,
    DateTime? endDate,
    double? hourlyRate,
  }) {
    return ResourceAllocation(
      allocationId: allocationId ?? this.allocationId,
      resourceId: resourceId ?? this.resourceId,
      projectId: projectId ?? this.projectId,
      allocationPercentage: allocationPercentage ?? this.allocationPercentage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      hourlyRate: hourlyRate ?? this.hourlyRate,
    );
  }
}

class ProjectMetrics {
  final String metricsId;
  final String projectId;
  final DateTime reportDate;
  final double schedulePerformanceIndex;
  final double costPerformanceIndex;
  final double estimateAtCompletion;
  final int completionPercentage;
  final double actualSpend;
  final double plannedSpend;

  ProjectMetrics({
    required this.metricsId,
    required this.projectId,
    required this.reportDate,
    required this.schedulePerformanceIndex,
    required this.costPerformanceIndex,
    required this.estimateAtCompletion,
    required this.completionPercentage,
    required this.actualSpend,
    required this.plannedSpend,
  });

  bool get isOnSchedule => schedulePerformanceIndex >= 0.95;
  bool get isOnBudget => costPerformanceIndex >= 0.95;
  double get budgetVariance => actualSpend - plannedSpend;
  int get ageInDays => DateTime.now().difference(reportDate).inDays;

  ProjectMetrics copyWith({
    String? metricsId,
    String? projectId,
    DateTime? reportDate,
    double? schedulePerformanceIndex,
    double? costPerformanceIndex,
    double? estimateAtCompletion,
    int? completionPercentage,
    double? actualSpend,
    double? plannedSpend,
  }) {
    return ProjectMetrics(
      metricsId: metricsId ?? this.metricsId,
      projectId: projectId ?? this.projectId,
      reportDate: reportDate ?? this.reportDate,
      schedulePerformanceIndex: schedulePerformanceIndex ?? this.schedulePerformanceIndex,
      costPerformanceIndex: costPerformanceIndex ?? this.costPerformanceIndex,
      estimateAtCompletion: estimateAtCompletion ?? this.estimateAtCompletion,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      actualSpend: actualSpend ?? this.actualSpend,
      plannedSpend: plannedSpend ?? this.plannedSpend,
    );
  }
}

class IntegrationModels {
  final String integrationId;
  final String sourcePhase;
  final String targetPhase;
  final Map<String, dynamic> mappingConfig;

  IntegrationModels({
    required this.integrationId,
    required this.sourcePhase,
    required this.targetPhase,
    required this.mappingConfig,
  });

  IntegrationModels copyWith({
    String? integrationId,
    String? sourcePhase,
    String? targetPhase,
    Map<String, dynamic>? mappingConfig,
  }) {
    return IntegrationModels(
      integrationId: integrationId ?? this.integrationId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      targetPhase: targetPhase ?? this.targetPhase,
      mappingConfig: mappingConfig ?? this.mappingConfig,
    );
  }
}
