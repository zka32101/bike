import 'package:project_040/models/ppm_models.dart';

abstract class PPMRepository {
  // Project methods (12)
  Future<void> createProject(Project project);
  Future<Project?> getProject(String projectId);
  Future<List<Project>> getAllProjects();
  Future<List<Project>> getProjectsByStatus(ProjectStatus status);
  Future<List<Project>> getActiveProjects();
  Future<List<Project>> getProjectsByPriority(ProjectPriority priority);
  Future<List<Project>> getOverdueProjects();
  Future<void> updateProject(Project project);
  Future<void> deleteProject(String projectId);
  Future<int> getProjectCount();
  Future<double> getTotalProjectBudget();
  Future<List<Project>> getProjectsByProjectManager(String manager);

  // Portfolio methods (12)
  Future<void> createPortfolio(Portfolio portfolio);
  Future<Portfolio?> getPortfolio(String portfolioId);
  Future<List<Portfolio>> getAllPortfolios();
  Future<List<Portfolio>> getActivePortfolios();
  Future<List<Portfolio>> getPortfoliosByOwner(String owner);
  Future<List<Portfolio>> getPortfoliosByStatus(PortfolioStatus status);
  Future<void> updatePortfolio(Portfolio portfolio);
  Future<void> deletePortfolio(String portfolioId);
  Future<int> getPortfolioCount();
  Future<double> getTotalPortfolioBudget();
  Future<List<String>> getProjectsInPortfolio(String portfolioId);
  Future<void> addProjectToPortfolio(String portfolioId, String projectId);

  // Phase methods (10)
  Future<void> createPhase(ProjectPhase phase);
  Future<ProjectPhase?> getPhase(String phaseId);
  Future<List<ProjectPhase>> getAllPhases();
  Future<List<ProjectPhase>> getPhasesByProject(String projectId);
  Future<List<ProjectPhase>> getPhasesByStatus(PhaseStatus status);
  Future<void> updatePhase(ProjectPhase phase);
  Future<void> deletePhase(String phaseId);
  Future<int> getPhaseCount();
  Future<List<ProjectPhase>> getProjectPhases(String projectId);
  Future<double> getProjectPhaseCompletion(String projectId);

  // Deliverable methods (12)
  Future<void> createDeliverable(Deliverable deliverable);
  Future<Deliverable?> getDeliverable(String deliverableId);
  Future<List<Deliverable>> getAllDeliverables();
  Future<List<Deliverable>> getDeliverablesByProject(String projectId);
  Future<List<Deliverable>> getDeliverablesByPhase(String phaseId);
  Future<List<Deliverable>> getOverdueDeliverables();
  Future<List<Deliverable>> getIncompleteDeliverables();
  Future<void> updateDeliverable(Deliverable deliverable);
  Future<void> deleteDeliverable(String deliverableId);
  Future<int> getDeliverableCount();
  Future<int> getCompletedDeliverableCount();
  Future<double> getDeliverableCompletionPercentage(String projectId);

  // Resource methods (12)
  Future<void> createResource(Resource resource);
  Future<Resource?> getResource(String resourceId);
  Future<List<Resource>> getAllResources();
  Future<List<Resource>> getResourcesByProject(String projectId);
  Future<List<Resource>> getResourcesByRole(ResourceRole role);
  Future<List<Resource>> getFullyAllocatedResources();
  Future<List<Resource>> getPartiallyAllocatedResources();
  Future<void> updateResource(Resource resource);
  Future<void> deleteResource(String resourceId);
  Future<int> getResourceCount();
  Future<double> getAverageAllocationPercentage();
  Future<List<Resource>> getResourcesByDepartment(String department);

  // Risk methods (10)
  Future<void> createRisk(ProjectRisk risk);
  Future<ProjectRisk?> getRisk(String riskId);
  Future<List<ProjectRisk>> getAllRisks();
  Future<List<ProjectRisk>> getRisksByProject(String projectId);
  Future<List<ProjectRisk>> getActiveRisks();
  Future<List<ProjectRisk>> getRisksByCategory(RiskCategory category);
  Future<void> updateRisk(ProjectRisk risk);
  Future<void> deleteRisk(String riskId);
  Future<int> getRiskCount();
  Future<double> getAverageRiskScore();

  // Allocation methods (10)
  Future<void> createAllocation(ResourceAllocation allocation);
  Future<ResourceAllocation?> getAllocation(String allocationId);
  Future<List<ResourceAllocation>> getAllAllocations();
  Future<List<ResourceAllocation>> getAllocationsByResource(String resourceId);
  Future<List<ResourceAllocation>> getAllocationsByProject(String projectId);
  Future<List<ResourceAllocation>> getActiveAllocations();
  Future<void> updateAllocation(ResourceAllocation allocation);
  Future<void> deleteAllocation(String allocationId);
  Future<double> getTotalAllocationCost();
  Future<double> getTotalProjectAllocationCost(String projectId);

  // Metrics methods (8)
  Future<void> recordMetrics(ProjectMetrics metrics);
  Future<ProjectMetrics?> getLatestMetrics(String projectId);
  Future<List<ProjectMetrics>> getAllMetrics();
  Future<List<ProjectMetrics>> getMetricsByProject(String projectId);
  Future<double> getAverageSPI();
  Future<double> getAverageCPI();
  Future<List<ProjectMetrics>> getMetricsTimeSeries(String projectId, int monthsBack);
  Future<Map<String, double>> getPortfolioMetrics();
}

class InMemoryPPMRepository implements PPMRepository {
  final Map<String, Project> _projects = {};
  final Map<String, Portfolio> _portfolios = {};
  final Map<String, ProjectPhase> _phases = {};
  final Map<String, Deliverable> _deliverables = {};
  final Map<String, Resource> _resources = {};
  final Map<String, ProjectRisk> _risks = {};
  final Map<String, ResourceAllocation> _allocations = {};
  final Map<String, ProjectMetrics> _metrics = {};

  // Project implementations
  @override
  Future<void> createProject(Project project) async => _projects[project.projectId] = project;

  @override
  Future<Project?> getProject(String projectId) async => _projects[projectId];

  @override
  Future<List<Project>> getAllProjects() async => _projects.values.toList();

  @override
  Future<List<Project>> getProjectsByStatus(ProjectStatus status) async =>
      _projects.values.where((p) => p.status == status).toList();

  @override
  Future<List<Project>> getActiveProjects() async =>
      _projects.values.where((p) => p.isActive).toList();

  @override
  Future<List<Project>> getProjectsByPriority(ProjectPriority priority) async =>
      _projects.values.where((p) => p.priority == priority).toList();

  @override
  Future<List<Project>> getOverdueProjects() async =>
      _projects.values.where((p) => p.isOverdue).toList();

  @override
  Future<void> updateProject(Project project) async => _projects[project.projectId] = project;

  @override
  Future<void> deleteProject(String projectId) async => _projects.remove(projectId);

  @override
  Future<int> getProjectCount() async => _projects.length;

  @override
  Future<double> getTotalProjectBudget() async =>
      _projects.values.fold<double>(0, (sum, p) => sum + p.budget);

  @override
  Future<List<Project>> getProjectsByProjectManager(String manager) async =>
      _projects.values.where((p) => p.projectManager == manager).toList();

  // Portfolio implementations
  @override
  Future<void> createPortfolio(Portfolio portfolio) async =>
      _portfolios[portfolio.portfolioId] = portfolio;

  @override
  Future<Portfolio?> getPortfolio(String portfolioId) async => _portfolios[portfolioId];

  @override
  Future<List<Portfolio>> getAllPortfolios() async => _portfolios.values.toList();

  @override
  Future<List<Portfolio>> getActivePortfolios() async =>
      _portfolios.values.where((p) => p.isActive).toList();

  @override
  Future<List<Portfolio>> getPortfoliosByOwner(String owner) async =>
      _portfolios.values.where((p) => p.owner == owner).toList();

  @override
  Future<List<Portfolio>> getPortfoliosByStatus(PortfolioStatus status) async =>
      _portfolios.values.where((p) => p.status == status).toList();

  @override
  Future<void> updatePortfolio(Portfolio portfolio) async =>
      _portfolios[portfolio.portfolioId] = portfolio;

  @override
  Future<void> deletePortfolio(String portfolioId) async => _portfolios.remove(portfolioId);

  @override
  Future<int> getPortfolioCount() async => _portfolios.length;

  @override
  Future<double> getTotalPortfolioBudget() async =>
      _portfolios.values.fold<double>(0, (sum, p) => sum + p.totalBudget);

  @override
  Future<List<String>> getProjectsInPortfolio(String portfolioId) async {
    final portfolio = _portfolios[portfolioId];
    return portfolio?.projectIds ?? [];
  }

  @override
  Future<void> addProjectToPortfolio(String portfolioId, String projectId) async {
    final portfolio = _portfolios[portfolioId];
    if (portfolio != null && !portfolio.projectIds.contains(projectId)) {
      final updated = portfolio.copyWith(projectIds: [...portfolio.projectIds, projectId]);
      _portfolios[portfolioId] = updated;
    }
  }

  // Phase implementations
  @override
  Future<void> createPhase(ProjectPhase phase) async => _phases[phase.phaseId] = phase;

  @override
  Future<ProjectPhase?> getPhase(String phaseId) async => _phases[phaseId];

  @override
  Future<List<ProjectPhase>> getAllPhases() async => _phases.values.toList();

  @override
  Future<List<ProjectPhase>> getPhasesByProject(String projectId) async =>
      _phases.values.where((p) => p.projectId == projectId).toList();

  @override
  Future<List<ProjectPhase>> getPhasesByStatus(PhaseStatus status) async =>
      _phases.values.where((p) => p.status == status).toList();

  @override
  Future<void> updatePhase(ProjectPhase phase) async => _phases[phase.phaseId] = phase;

  @override
  Future<void> deletePhase(String phaseId) async => _phases.remove(phaseId);

  @override
  Future<int> getPhaseCount() async => _phases.length;

  @override
  Future<List<ProjectPhase>> getProjectPhases(String projectId) async =>
      _phases.values.where((p) => p.projectId == projectId).toList();

  @override
  Future<double> getProjectPhaseCompletion(String projectId) async {
    final phases = await getProjectPhases(projectId);
    if (phases.isEmpty) return 0;
    return phases.fold<double>(0, (sum, p) => sum + p.completionPercentage) / phases.length;
  }

  // Deliverable implementations
  @override
  Future<void> createDeliverable(Deliverable deliverable) async =>
      _deliverables[deliverable.deliverableId] = deliverable;

  @override
  Future<Deliverable?> getDeliverable(String deliverableId) async =>
      _deliverables[deliverableId];

  @override
  Future<List<Deliverable>> getAllDeliverables() async => _deliverables.values.toList();

  @override
  Future<List<Deliverable>> getDeliverablesByProject(String projectId) async =>
      _deliverables.values.where((d) => d.projectId == projectId).toList();

  @override
  Future<List<Deliverable>> getDeliverablesByPhase(String phaseId) async =>
      _deliverables.values.where((d) => d.phaseId == phaseId).toList();

  @override
  Future<List<Deliverable>> getOverdueDeliverables() async =>
      _deliverables.values.where((d) => d.isOverdue).toList();

  @override
  Future<List<Deliverable>> getIncompleteDeliverables() async =>
      _deliverables.values.where((d) => !d.isCompleted).toList();

  @override
  Future<void> updateDeliverable(Deliverable deliverable) async =>
      _deliverables[deliverable.deliverableId] = deliverable;

  @override
  Future<void> deleteDeliverable(String deliverableId) async =>
      _deliverables.remove(deliverableId);

  @override
  Future<int> getDeliverableCount() async => _deliverables.length;

  @override
  Future<int> getCompletedDeliverableCount() async =>
      _deliverables.values.where((d) => d.isCompleted).length;

  @override
  Future<double> getDeliverableCompletionPercentage(String projectId) async {
    final deliverables = await getDeliverablesByProject(projectId);
    if (deliverables.isEmpty) return 0;
    final completed = deliverables.where((d) => d.isCompleted).length;
    return (completed / deliverables.length) * 100;
  }

  // Resource implementations
  @override
  Future<void> createResource(Resource resource) async =>
      _resources[resource.resourceId] = resource;

  @override
  Future<Resource?> getResource(String resourceId) async => _resources[resourceId];

  @override
  Future<List<Resource>> getAllResources() async => _resources.values.toList();

  @override
  Future<List<Resource>> getResourcesByProject(String projectId) async =>
      _resources.values.where((r) => r.projectId == projectId).toList();

  @override
  Future<List<Resource>> getResourcesByRole(ResourceRole role) async =>
      _resources.values.where((r) => r.role == role).toList();

  @override
  Future<List<Resource>> getFullyAllocatedResources() async =>
      _resources.values.where((r) => r.isFullyAllocated).toList();

  @override
  Future<List<Resource>> getPartiallyAllocatedResources() async =>
      _resources.values.where((r) => r.isAllocated && !r.isFullyAllocated).toList();

  @override
  Future<void> updateResource(Resource resource) async =>
      _resources[resource.resourceId] = resource;

  @override
  Future<void> deleteResource(String resourceId) async => _resources.remove(resourceId);

  @override
  Future<int> getResourceCount() async => _resources.length;

  @override
  Future<double> getAverageAllocationPercentage() async {
    if (_resources.isEmpty) return 0;
    return _resources.values.fold<double>(0, (sum, r) => sum + r.allocationPercentage) /
        _resources.length;
  }

  @override
  Future<List<Resource>> getResourcesByDepartment(String department) async =>
      _resources.values.where((r) => r.department == department).toList();

  // Risk implementations
  @override
  Future<void> createRisk(ProjectRisk risk) async => _risks[risk.riskId] = risk;

  @override
  Future<ProjectRisk?> getRisk(String riskId) async => _risks[riskId];

  @override
  Future<List<ProjectRisk>> getAllRisks() async => _risks.values.toList();

  @override
  Future<List<ProjectRisk>> getRisksByProject(String projectId) async =>
      _risks.values.where((r) => r.projectId == projectId).toList();

  @override
  Future<List<ProjectRisk>> getActiveRisks() async =>
      _risks.values.where((r) => !r.isResolved).toList();

  @override
  Future<List<ProjectRisk>> getRisksByCategory(RiskCategory category) async =>
      _risks.values.where((r) => r.category == category).toList();

  @override
  Future<void> updateRisk(ProjectRisk risk) async => _risks[risk.riskId] = risk;

  @override
  Future<void> deleteRisk(String riskId) async => _risks.remove(riskId);

  @override
  Future<int> getRiskCount() async => _risks.length;

  @override
  Future<double> getAverageRiskScore() async {
    if (_risks.isEmpty) return 0;
    return _risks.values.fold<double>(0, (sum, r) => sum + r.riskScore) / _risks.length;
  }

  // Allocation implementations
  @override
  Future<void> createAllocation(ResourceAllocation allocation) async =>
      _allocations[allocation.allocationId] = allocation;

  @override
  Future<ResourceAllocation?> getAllocation(String allocationId) async =>
      _allocations[allocationId];

  @override
  Future<List<ResourceAllocation>> getAllAllocations() async =>
      _allocations.values.toList();

  @override
  Future<List<ResourceAllocation>> getAllocationsByResource(String resourceId) async =>
      _allocations.values.where((a) => a.resourceId == resourceId).toList();

  @override
  Future<List<ResourceAllocation>> getAllocationsByProject(String projectId) async =>
      _allocations.values.where((a) => a.projectId == projectId).toList();

  @override
  Future<List<ResourceAllocation>> getActiveAllocations() async =>
      _allocations.values.where((a) => a.isActive).toList();

  @override
  Future<void> updateAllocation(ResourceAllocation allocation) async =>
      _allocations[allocation.allocationId] = allocation;

  @override
  Future<void> deleteAllocation(String allocationId) async =>
      _allocations.remove(allocationId);

  @override
  Future<double> getTotalAllocationCost() async =>
      _allocations.values.fold<double>(0, (sum, a) => sum + a.estimatedCost);

  @override
  Future<double> getTotalProjectAllocationCost(String projectId) async {
    final allocations = await getAllocationsByProject(projectId);
    return allocations.fold<double>(0, (sum, a) => sum + a.estimatedCost);
  }

  // Metrics implementations
  @override
  Future<void> recordMetrics(ProjectMetrics metrics) async =>
      _metrics[metrics.metricsId] = metrics;

  @override
  Future<ProjectMetrics?> getLatestMetrics(String projectId) async {
    final projectMetrics = _metrics.values.where((m) => m.projectId == projectId).toList();
    if (projectMetrics.isEmpty) return null;
    return projectMetrics.reduce((a, b) => a.reportDate.isAfter(b.reportDate) ? a : b);
  }

  @override
  Future<List<ProjectMetrics>> getAllMetrics() async => _metrics.values.toList();

  @override
  Future<List<ProjectMetrics>> getMetricsByProject(String projectId) async =>
      _metrics.values.where((m) => m.projectId == projectId).toList();

  @override
  Future<double> getAverageSPI() async {
    if (_metrics.isEmpty) return 0;
    return _metrics.values.fold<double>(0, (sum, m) => sum + m.schedulePerformanceIndex) /
        _metrics.length;
  }

  @override
  Future<double> getAverageCPI() async {
    if (_metrics.isEmpty) return 0;
    return _metrics.values.fold<double>(0, (sum, m) => sum + m.costPerformanceIndex) /
        _metrics.length;
  }

  @override
  Future<List<ProjectMetrics>> getMetricsTimeSeries(String projectId, int monthsBack) async {
    final cutoff = DateTime.now().subtract(Duration(days: monthsBack * 30));
    return _metrics.values
        .where((m) => m.projectId == projectId && m.reportDate.isAfter(cutoff))
        .toList();
  }

  @override
  Future<Map<String, double>> getPortfolioMetrics() async {
    final avgSPI = await getAverageSPI();
    final avgCPI = await getAverageCPI();
    return {'avgSPI': avgSPI, 'avgCPI': avgCPI, 'portfolioHealth': (avgSPI + avgCPI) / 2};
  }
}

class ProjectAnalysisEngine {
  double calculateEarnedValue(Project project, ProjectMetrics metrics) {
    return project.budget * (metrics.completionPercentage / 100);
  }

  double calculateScheduleVariance(ProjectMetrics metrics) {
    return metrics.schedulePerformanceIndex - 1.0;
  }

  double calculateCostVariance(ProjectMetrics metrics) {
    return metrics.costPerformanceIndex - 1.0;
  }
}

class ResourceManagementEngine {
  double calculateTotalProjectResourceCost(List<ResourceAllocation> allocations) {
    return allocations.fold<double>(0, (sum, a) => sum + a.estimatedCost);
  }

  double calculateResourceUtilization(List<Resource> resources) {
    if (resources.isEmpty) return 0;
    return resources.fold<double>(0, (sum, r) => sum + r.allocationPercentage) /
        resources.length;
  }

  Map<ResourceRole, int> groupResourcesByRole(List<Resource> resources) {
    final result = <ResourceRole, int>{};
    for (final resource in resources) {
      result[resource.role] = (result[resource.role] ?? 0) + 1;
    }
    return result;
  }
}

class PortfolioOptimizationEngine {
  List<Project> prioritizeProjects(List<Project> projects) {
    projects.sort((a, b) {
      final priorityComparison = b.priority.index.compareTo(a.priority.index);
      if (priorityComparison != 0) return priorityComparison;
      return a.ageInDays.compareTo(b.ageInDays);
    });
    return projects;
  }

  double calculatePortfolioValue(List<Project> projects) {
    return projects.fold<double>(0, (sum, p) => sum + (p.budget * (p.completionPercentage / 100)));
  }

  Map<ProjectType, double> calculateTypeDistribution(List<Project> projects) {
    final result = <ProjectType, double>{};
    for (final project in projects) {
      result[project.type] = (result[project.type] ?? 0) + project.budget;
    }
    return result;
  }
}

class PPMManager {
  final PPMRepository repository;
  late final ProjectAnalysisEngine projectEngine;
  late final ResourceManagementEngine resourceEngine;
  late final PortfolioOptimizationEngine portfolioEngine;

  PPMManager(this.repository) {
    projectEngine = ProjectAnalysisEngine();
    resourceEngine = ResourceManagementEngine();
    portfolioEngine = PortfolioOptimizationEngine();
  }

  Future<Map<String, dynamic>> getPPMDashboard() async {
    final projects = await repository.getAllProjects();
    final portfolios = await repository.getAllPortfolios();
    final resources = await repository.getAllResources();
    final risks = await repository.getAllRisks();

    return {
      'totalProjects': projects.length,
      'activeProjects': projects.where((p) => p.isActive).length,
      'overdueProjects': projects.where((p) => p.isOverdue).length,
      'completedProjects': projects.where((p) => p.isCompleted).length,
      'totalBudget': await repository.getTotalProjectBudget(),
      'portfolios': portfolios.length,
      'activePortfolios': portfolios.where((p) => p.isActive).length,
      'totalResources': resources.length,
      'activeRisks': risks.where((r) => !r.isResolved).length,
      'averageResourceAllocation': await repository.getAverageAllocationPercentage(),
      'portfolioMetrics': await repository.getPortfolioMetrics(),
    };
  }
}

class PPMFacade {
  final PPMRepository repository;
  late final PPMManager manager;

  PPMFacade(this.repository) {
    manager = PPMManager(repository);
  }

  Future<void> createProject(Project project) async => repository.createProject(project);
  Future<Project?> getProject(String projectId) async => repository.getProject(projectId);
  Future<List<Project>> getAllProjects() async => repository.getAllProjects();
  Future<List<Project>> getActiveProjects() async => repository.getActiveProjects();
  Future<List<Project>> getOverdueProjects() async => repository.getOverdueProjects();
  Future<double> getTotalProjectBudget() async => repository.getTotalProjectBudget();

  Future<void> createPortfolio(Portfolio portfolio) async =>
      repository.createPortfolio(portfolio);
  Future<Portfolio?> getPortfolio(String portfolioId) async =>
      repository.getPortfolio(portfolioId);
  Future<List<Portfolio>> getAllPortfolios() async => repository.getAllPortfolios();
  Future<List<Portfolio>> getActivePortfolios() async => repository.getActivePortfolios();

  Future<void> createPhase(ProjectPhase phase) async => repository.createPhase(phase);
  Future<List<ProjectPhase>> getProjectPhases(String projectId) async =>
      repository.getProjectPhases(projectId);

  Future<void> createDeliverable(Deliverable deliverable) async =>
      repository.createDeliverable(deliverable);
  Future<List<Deliverable>> getDeliverablesByProject(String projectId) async =>
      repository.getDeliverablesByProject(projectId);
  Future<List<Deliverable>> getOverdueDeliverables() async =>
      repository.getOverdueDeliverables();

  Future<void> createResource(Resource resource) async => repository.createResource(resource);
  Future<List<Resource>> getAllResources() async => repository.getAllResources();
  Future<List<Resource>> getFullyAllocatedResources() async =>
      repository.getFullyAllocatedResources();

  Future<void> createRisk(ProjectRisk risk) async => repository.createRisk(risk);
  Future<List<ProjectRisk>> getRisksByProject(String projectId) async =>
      repository.getRisksByProject(projectId);
  Future<List<ProjectRisk>> getActiveRisks() async => repository.getActiveRisks();

  Future<void> recordMetrics(ProjectMetrics metrics) async =>
      repository.recordMetrics(metrics);
  Future<Map<String, dynamic>> getPPMDashboard() async => manager.getPPMDashboard();
}
