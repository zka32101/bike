import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/ppm_models.dart';
import 'package:project_040/services/ppm_service.dart';

void main() {
  group('Phase 102: Project Portfolio Management - Enum Tests', () {
    test('ProjectStatus enum has all required values', () {
      expect(ProjectStatus.values.length, equals(7));
      expect(ProjectStatus.values, contains(ProjectStatus.initiated));
      expect(ProjectStatus.values, contains(ProjectStatus.active));
      expect(ProjectStatus.values, contains(ProjectStatus.completed));
      expect(ProjectStatus.values, contains(ProjectStatus.cancelled));
    });

    test('ProjectStatus displayName returns Japanese translations', () {
      expect(ProjectStatus.initiated.displayName, contains('Initiated'));
      expect(ProjectStatus.planning.displayName, contains('Planning'));
      expect(ProjectStatus.active.displayName, contains('Active'));
      expect(ProjectStatus.completed.displayName, contains('Completed'));
    });

    test('ProjectType enum has all required values', () {
      expect(ProjectType.values.length, equals(6));
      expect(ProjectType.values, contains(ProjectType.strategic));
      expect(ProjectType.values, contains(ProjectType.operational));
      expect(ProjectType.values, contains(ProjectType.innovation));
    });

    test('ProjectPriority enum has all required values', () {
      expect(ProjectPriority.values.length, equals(4));
      expect(ProjectPriority.values, contains(ProjectPriority.critical));
      expect(ProjectPriority.values, contains(ProjectPriority.high));
      expect(ProjectPriority.values, contains(ProjectPriority.medium));
      expect(ProjectPriority.values, contains(ProjectPriority.low));
    });

    test('PortfolioStatus enum has all required values', () {
      expect(PortfolioStatus.values.length, equals(3));
      expect(PortfolioStatus.values, contains(PortfolioStatus.active));
      expect(PortfolioStatus.values, contains(PortfolioStatus.inactive));
    });

    test('ResourceRole enum has all required values', () {
      expect(ResourceRole.values.length, equals(7));
      expect(ResourceRole.values, contains(ResourceRole.projectManager));
      expect(ResourceRole.values, contains(ResourceRole.developer));
      expect(ResourceRole.values, contains(ResourceRole.qa));
    });

    test('PhaseStatus enum has all required values', () {
      expect(PhaseStatus.values.length, equals(5));
      expect(PhaseStatus.values, contains(PhaseStatus.notStarted));
      expect(PhaseStatus.values, contains(PhaseStatus.completed));
    });

    test('RiskCategory enum has all required values', () {
      expect(RiskCategory.values.length, equals(6));
      expect(RiskCategory.values, contains(RiskCategory.technical));
      expect(RiskCategory.values, contains(RiskCategory.schedule));
      expect(RiskCategory.values, contains(RiskCategory.budget));
    });
  });

  group('Phase 102: Project Portfolio Management - Model Tests', () {
    test('Project model creates with all properties', () {
      final now = DateTime.now();
      final project = Project(
        projectId: 'proj_001',
        projectName: 'Enterprise Platform',
        status: ProjectStatus.active,
        type: ProjectType.strategic,
        priority: ProjectPriority.high,
        description: 'Build new enterprise platform',
        sponsor: 'VP Technology',
        projectManager: 'John Manager',
        budget: 1000000,
        startDate: now,
        plannedEndDate: now.add(Duration(days: 180)),
        completionPercentage: 50,
      );

      expect(project.projectId, equals('proj_001'));
      expect(project.isActive, isTrue);
      expect(project.priority, equals(ProjectPriority.high));
    });

    test('Project isOverdue computed property works correctly', () {
      final now = DateTime.now();
      final project = Project(
        projectId: 'proj_001',
        projectName: 'Test Project',
        status: ProjectStatus.active,
        type: ProjectType.operational,
        priority: ProjectPriority.medium,
        description: 'Test',
        sponsor: 'Sponsor',
        projectManager: 'Manager',
        budget: 500000,
        startDate: now.subtract(Duration(days: 100)),
        plannedEndDate: now.subtract(Duration(days: 10)),
        completionPercentage: 75,
      );

      expect(project.isOverdue, isTrue);
    });

    test('Project budgetVariance computed property works correctly', () {
      final now = DateTime.now();
      final project = Project(
        projectId: 'proj_001',
        projectName: 'Budget Test',
        status: ProjectStatus.active,
        type: ProjectType.strategic,
        priority: ProjectPriority.high,
        description: 'Test',
        sponsor: 'Sponsor',
        projectManager: 'Manager',
        budget: 1000000,
        actualCost: 1100000,
        startDate: now,
        plannedEndDate: now.add(Duration(days: 90)),
        completionPercentage: 50,
      );

      expect(project.budgetVariance, equals(100000));
      expect(project.isBudgetOverrun, isTrue);
    });

    test('Portfolio model creates with all properties', () {
      final now = DateTime.now();
      final portfolio = Portfolio(
        portfolioId: 'port_001',
        portfolioName: 'Digital Transformation',
        status: PortfolioStatus.active,
        owner: 'CIO',
        projectIds: ['proj_001', 'proj_002'],
        totalBudget: 5000000,
        createdDate: now,
      );

      expect(portfolio.portfolioId, equals('port_001'));
      expect(portfolio.projectCount, equals(2));
      expect(portfolio.isActive, isTrue);
    });

    test('ProjectPhase model creates with all properties', () {
      final now = DateTime.now();
      final phase = ProjectPhase(
        phaseId: 'phase_001',
        projectId: 'proj_001',
        phaseName: 'Design Phase',
        status: PhaseStatus.inProgress,
        startDate: now,
        endDate: now.add(Duration(days: 30)),
        sequenceNumber: 1,
        deliverableIds: ['deliv_001'],
        completionPercentage: 60,
      );

      expect(phase.phaseId, equals('phase_001'));
      expect(phase.isCompleted, isFalse);
    });

    test('Deliverable model creates with all properties', () {
      final now = DateTime.now();
      final deliverable = Deliverable(
        deliverableId: 'deliv_001',
        projectId: 'proj_001',
        phaseId: 'phase_001',
        deliverableName: 'Design Document',
        description: 'Complete system design',
        dueDate: now.add(Duration(days: 15)),
        isCompleted: false,
        owner: 'Architect',
        dependencies: [],
      );

      expect(deliverable.deliverableId, equals('deliv_001'));
      expect(deliverable.isOverdue, isFalse);
    });

    test('Resource model creates with all properties', () {
      final now = DateTime.now();
      final resource = Resource(
        resourceId: 'res_001',
        resourceName: 'Alice Developer',
        role: ResourceRole.developer,
        department: 'Engineering',
        projectId: 'proj_001',
        allocationPercentage: 100,
        startDate: now,
        skills: 'Java, Python, SQL',
      );

      expect(resource.resourceId, equals('res_001'));
      expect(resource.isFullyAllocated, isTrue);
    });

    test('ProjectRisk model creates with all properties', () {
      final now = DateTime.now();
      final risk = ProjectRisk(
        riskId: 'risk_001',
        projectId: 'proj_001',
        riskName: 'Resource Shortage',
        category: RiskCategory.resource,
        probability: 0.4,
        impact: 0.7,
        mitigation: 'Hire contractors',
        owner: 'HR Manager',
        identifiedDate: now,
        isResolved: false,
      );

      expect(risk.riskId, equals('risk_001'));
      expect(risk.riskScore, equals(0.28));
    });

    test('ResourceAllocation model creates with all properties', () {
      final now = DateTime.now();
      final allocation = ResourceAllocation(
        allocationId: 'alloc_001',
        resourceId: 'res_001',
        projectId: 'proj_001',
        allocationPercentage: 80,
        startDate: now,
        endDate: now.add(Duration(days: 90)),
        hourlyRate: 150,
      );

      expect(allocation.allocationId, equals('alloc_001'));
      expect(allocation.isActive, isTrue);
    });

    test('ProjectMetrics model creates with all properties', () {
      final now = DateTime.now();
      final metrics = ProjectMetrics(
        metricsId: 'met_001',
        projectId: 'proj_001',
        reportDate: now,
        schedulePerformanceIndex: 0.95,
        costPerformanceIndex: 0.98,
        estimateAtCompletion: 980000,
        completionPercentage: 50,
        actualSpend: 450000,
        plannedSpend: 460000,
      );

      expect(metrics.metricsId, equals('met_001'));
      expect(metrics.isOnBudget, isTrue);
    });

    test('Model copyWith immutability pattern works', () {
      final now = DateTime.now();
      final original = Project(
        projectId: 'proj_001',
        projectName: 'Original',
        status: ProjectStatus.planning,
        type: ProjectType.strategic,
        priority: ProjectPriority.medium,
        description: 'Test',
        sponsor: 'Sponsor',
        projectManager: 'Manager',
        budget: 1000000,
        startDate: now,
        plannedEndDate: now.add(Duration(days: 90)),
        completionPercentage: 0,
      );

      final updated = original.copyWith(
        projectName: 'Updated',
        status: ProjectStatus.active,
      );

      expect(original.projectName, equals('Original'));
      expect(updated.projectName, equals('Updated'));
      expect(updated.status, equals(ProjectStatus.active));
    });
  });

  group('Phase 102: Project Portfolio Management - Repository Tests', () {
    late InMemoryPPMRepository repository;

    setUp(() {
      repository = InMemoryPPMRepository();
    });

    test('Repository creates and retrieves Project', () async {
      final now = DateTime.now();
      final project = Project(
        projectId: 'proj_001',
        projectName: 'Test Project',
        status: ProjectStatus.planning,
        type: ProjectType.operational,
        priority: ProjectPriority.high,
        description: 'Test project',
        sponsor: 'Sponsor',
        projectManager: 'Manager',
        budget: 500000,
        startDate: now,
        plannedEndDate: now.add(Duration(days: 90)),
        completionPercentage: 0,
      );

      await repository.createProject(project);
      final retrieved = await repository.getProject('proj_001');

      expect(retrieved, isNotNull);
      expect(retrieved?.projectName, equals('Test Project'));
    });

    test('Repository gets all projects', () async {
      final now = DateTime.now();
      for (int i = 0; i < 3; i++) {
        await repository.createProject(Project(
          projectId: 'proj_$i',
          projectName: 'Project $i',
          status: ProjectStatus.active,
          type: ProjectType.strategic,
          priority: ProjectPriority.medium,
          description: 'Project $i',
          sponsor: 'Sponsor',
          projectManager: 'Manager',
          budget: 500000,
          startDate: now,
          plannedEndDate: now.add(Duration(days: 90)),
          completionPercentage: 50,
        ));
      }

      final all = await repository.getAllProjects();
      expect(all.length, equals(3));
    });

    test('Repository filters projects by status', () async {
      final now = DateTime.now();
      final active = Project(
        projectId: 'proj_active',
        projectName: 'Active Project',
        status: ProjectStatus.active,
        type: ProjectType.strategic,
        priority: ProjectPriority.high,
        description: 'Active',
        sponsor: 'Sponsor',
        projectManager: 'Manager',
        budget: 1000000,
        startDate: now,
        plannedEndDate: now.add(Duration(days: 90)),
        completionPercentage: 50,
      );

      final completed = Project(
        projectId: 'proj_done',
        projectName: 'Completed Project',
        status: ProjectStatus.completed,
        type: ProjectType.operational,
        priority: ProjectPriority.medium,
        description: 'Completed',
        sponsor: 'Sponsor',
        projectManager: 'Manager',
        budget: 500000,
        startDate: now.subtract(Duration(days: 90)),
        plannedEndDate: now,
        completionPercentage: 100,
      );

      await repository.createProject(active);
      await repository.createProject(completed);

      final actives = await repository.getProjectsByStatus(ProjectStatus.active);
      expect(actives.length, equals(1));
      expect(actives.first.projectName, equals('Active Project'));
    });

    test('Repository creates and retrieves Portfolio', () async {
      final now = DateTime.now();
      final portfolio = Portfolio(
        portfolioId: 'port_001',
        portfolioName: 'Test Portfolio',
        status: PortfolioStatus.active,
        owner: 'Owner',
        projectIds: [],
        totalBudget: 5000000,
        createdDate: now,
      );

      await repository.createPortfolio(portfolio);
      final retrieved = await repository.getPortfolio('port_001');

      expect(retrieved, isNotNull);
      expect(retrieved?.portfolioName, equals('Test Portfolio'));
    });

    test('Repository creates and retrieves Phase', () async {
      final now = DateTime.now();
      final phase = ProjectPhase(
        phaseId: 'phase_001',
        projectId: 'proj_001',
        phaseName: 'Planning',
        status: PhaseStatus.inProgress,
        startDate: now,
        endDate: now.add(Duration(days: 30)),
        sequenceNumber: 1,
        deliverableIds: [],
        completionPercentage: 50,
      );

      await repository.createPhase(phase);
      final retrieved = await repository.getPhase('phase_001');

      expect(retrieved, isNotNull);
      expect(retrieved?.phaseName, equals('Planning'));
    });

    test('Repository creates and retrieves Deliverable', () async {
      final now = DateTime.now();
      final deliverable = Deliverable(
        deliverableId: 'deliv_001',
        projectId: 'proj_001',
        phaseId: 'phase_001',
        deliverableName: 'Design Doc',
        description: 'System design document',
        dueDate: now.add(Duration(days: 15)),
        isCompleted: false,
        owner: 'Architect',
        dependencies: [],
      );

      await repository.createDeliverable(deliverable);
      final retrieved = await repository.getDeliverable('deliv_001');

      expect(retrieved, isNotNull);
      expect(retrieved?.deliverableName, equals('Design Doc'));
    });

    test('Repository creates and retrieves Resource', () async {
      final now = DateTime.now();
      final resource = Resource(
        resourceId: 'res_001',
        resourceName: 'John Developer',
        role: ResourceRole.developer,
        department: 'Engineering',
        projectId: 'proj_001',
        allocationPercentage: 100,
        startDate: now,
        skills: 'Java, Python',
      );

      await repository.createResource(resource);
      final retrieved = await repository.getResource('res_001');

      expect(retrieved, isNotNull);
      expect(retrieved?.allocationPercentage, equals(100));
    });

    test('Repository creates and retrieves Risk', () async {
      final now = DateTime.now();
      final risk = ProjectRisk(
        riskId: 'risk_001',
        projectId: 'proj_001',
        riskName: 'Schedule Delay',
        category: RiskCategory.schedule,
        probability: 0.3,
        impact: 0.8,
        mitigation: 'Add buffer time',
        owner: 'PM',
        identifiedDate: now,
        isResolved: false,
      );

      await repository.createRisk(risk);
      final retrieved = await repository.getRisk('risk_001');

      expect(retrieved, isNotNull);
      expect(retrieved?.category, equals(RiskCategory.schedule));
    });

    test('Repository creates and retrieves Allocation', () async {
      final now = DateTime.now();
      final allocation = ResourceAllocation(
        allocationId: 'alloc_001',
        resourceId: 'res_001',
        projectId: 'proj_001',
        allocationPercentage: 100,
        startDate: now,
        endDate: now.add(Duration(days: 90)),
        hourlyRate: 150,
      );

      await repository.createAllocation(allocation);
      final retrieved = await repository.getAllocation('alloc_001');

      expect(retrieved, isNotNull);
      expect(retrieved?.hourlyRate, equals(150));
    });

    test('Repository records and retrieves Metrics', () async {
      final now = DateTime.now();
      final metrics = ProjectMetrics(
        metricsId: 'met_001',
        projectId: 'proj_001',
        reportDate: now,
        schedulePerformanceIndex: 1.0,
        costPerformanceIndex: 0.95,
        estimateAtCompletion: 950000,
        completionPercentage: 50,
        actualSpend: 475000,
        plannedSpend: 500000,
      );

      await repository.recordMetrics(metrics);
      final retrieved = await repository.getLatestMetrics('proj_001');

      expect(retrieved, isNotNull);
      expect(retrieved?.schedulePerformanceIndex, equals(1.0));
    });

    test('Repository counts total projects', () async {
      final now = DateTime.now();
      for (int i = 0; i < 5; i++) {
        await repository.createProject(Project(
          projectId: 'proj_$i',
          projectName: 'Project $i',
          status: ProjectStatus.active,
          type: ProjectType.strategic,
          priority: ProjectPriority.high,
          description: 'Project',
          sponsor: 'Sponsor',
          projectManager: 'Manager',
          budget: 500000,
          startDate: now,
          plannedEndDate: now.add(Duration(days: 90)),
          completionPercentage: 50,
        ));
      }

      final count = await repository.getProjectCount();
      expect(count, equals(5));
    });

    test('Repository calculates average resource allocation', () async {
      final now = DateTime.now();
      for (int i = 0; i < 3; i++) {
        await repository.createResource(Resource(
          resourceId: 'res_$i',
          resourceName: 'Resource $i',
          role: ResourceRole.developer,
          department: 'Eng',
          projectId: 'proj_001',
          allocationPercentage: 50 + (i * 20),
          startDate: now,
          skills: 'Java',
        ));
      }

      final avg = await repository.getAverageAllocationPercentage();
      expect(avg, equals(70)); // (50 + 70 + 90) / 3
    });
  });

  group('Phase 102: Project Portfolio Management - Engine Tests', () {
    test('ProjectAnalysisEngine calculates earned value', () {
      final engine = ProjectAnalysisEngine();
      final now = DateTime.now();
      final project = Project(
        projectId: 'proj_001',
        projectName: 'Test',
        status: ProjectStatus.active,
        type: ProjectType.strategic,
        priority: ProjectPriority.high,
        description: 'Test',
        sponsor: 'Sponsor',
        projectManager: 'Manager',
        budget: 1000000,
        startDate: now,
        plannedEndDate: now.add(Duration(days: 90)),
        completionPercentage: 50,
      );

      final metrics = ProjectMetrics(
        metricsId: 'met_001',
        projectId: 'proj_001',
        reportDate: now,
        schedulePerformanceIndex: 1.0,
        costPerformanceIndex: 1.0,
        estimateAtCompletion: 1000000,
        completionPercentage: 50,
        actualSpend: 500000,
        plannedSpend: 500000,
      );

      final ev = engine.calculateEarnedValue(project, metrics);
      expect(ev, equals(500000));
    });

    test('ResourceManagementEngine calculates resource utilization', () {
      final engine = ResourceManagementEngine();
      final now = DateTime.now();
      final resources = [
        Resource(
          resourceId: 'res_1',
          resourceName: 'Resource 1',
          role: ResourceRole.developer,
          department: 'Eng',
          projectId: 'proj_001',
          allocationPercentage: 80,
          startDate: now,
          skills: 'Java',
        ),
        Resource(
          resourceId: 'res_2',
          resourceName: 'Resource 2',
          role: ResourceRole.qa,
          department: 'QA',
          projectId: 'proj_001',
          allocationPercentage: 60,
          startDate: now,
          skills: 'Testing',
        ),
      ];

      final utilization = engine.calculateResourceUtilization(resources);
      expect(utilization, equals(70));
    });

    test('PortfolioOptimizationEngine prioritizes projects correctly', () {
      final engine = PortfolioOptimizationEngine();
      final now = DateTime.now();
      final projects = [
        Project(
          projectId: 'proj_1',
          projectName: 'Low Priority',
          status: ProjectStatus.active,
          type: ProjectType.strategic,
          priority: ProjectPriority.low,
          description: 'Test',
          sponsor: 'Sponsor',
          projectManager: 'Manager',
          budget: 500000,
          startDate: now,
          plannedEndDate: now.add(Duration(days: 90)),
          completionPercentage: 50,
        ),
        Project(
          projectId: 'proj_2',
          projectName: 'High Priority',
          status: ProjectStatus.active,
          type: ProjectType.strategic,
          priority: ProjectPriority.high,
          description: 'Test',
          sponsor: 'Sponsor',
          projectManager: 'Manager',
          budget: 500000,
          startDate: now,
          plannedEndDate: now.add(Duration(days: 90)),
          completionPercentage: 50,
        ),
      ];

      final prioritized = engine.prioritizeProjects(projects);
      expect(prioritized.first.priority, equals(ProjectPriority.high));
    });
  });

  group('Phase 102: Project Portfolio Management - Manager Tests', () {
    test('PPMManager gets dashboard', () async {
      final repository = InMemoryPPMRepository();
      final manager = PPMManager(repository);

      final now = DateTime.now();
      await repository.createProject(Project(
        projectId: 'proj_001',
        projectName: 'Test',
        status: ProjectStatus.active,
        type: ProjectType.strategic,
        priority: ProjectPriority.high,
        description: 'Test',
        sponsor: 'Sponsor',
        projectManager: 'Manager',
        budget: 1000000,
        startDate: now,
        plannedEndDate: now.add(Duration(days: 90)),
        completionPercentage: 50,
      ));

      final dashboard = await manager.getPPMDashboard();

      expect(dashboard, isNotNull);
      expect(dashboard['totalProjects'], equals(1));
      expect(dashboard['activeProjects'], equals(1));
    });
  });

  group('Phase 102: Project Portfolio Management - Facade Tests', () {
    late PPMFacade facade;

    setUp(() {
      facade = PPMFacade(InMemoryPPMRepository());
    });

    test('Facade creates project', () async {
      final now = DateTime.now();
      final project = Project(
        projectId: 'proj_001',
        projectName: 'Facade Test',
        status: ProjectStatus.planning,
        type: ProjectType.strategic,
        priority: ProjectPriority.high,
        description: 'Test',
        sponsor: 'Sponsor',
        projectManager: 'Manager',
        budget: 1000000,
        startDate: now,
        plannedEndDate: now.add(Duration(days: 90)),
        completionPercentage: 0,
      );

      await facade.createProject(project);
      final retrieved = await facade.getProject('proj_001');

      expect(retrieved?.projectName, equals('Facade Test'));
    });

    test('Facade gets active projects', () async {
      final now = DateTime.now();
      await facade.createProject(Project(
        projectId: 'proj_001',
        projectName: 'Active',
        status: ProjectStatus.active,
        type: ProjectType.strategic,
        priority: ProjectPriority.high,
        description: 'Test',
        sponsor: 'Sponsor',
        projectManager: 'Manager',
        budget: 500000,
        startDate: now,
        plannedEndDate: now.add(Duration(days: 90)),
        completionPercentage: 50,
      ));

      final active = await facade.getActiveProjects();
      expect(active.length, equals(1));
    });

    test('Facade gets PPM dashboard', () async {
      final now = DateTime.now();
      await facade.createProject(Project(
        projectId: 'proj_001',
        projectName: 'Dashboard Test',
        status: ProjectStatus.active,
        type: ProjectType.strategic,
        priority: ProjectPriority.high,
        description: 'Test',
        sponsor: 'Sponsor',
        projectManager: 'Manager',
        budget: 1000000,
        startDate: now,
        plannedEndDate: now.add(Duration(days: 90)),
        completionPercentage: 50,
      ));

      final dashboard = await facade.getPPMDashboard();

      expect(dashboard, isNotNull);
      expect(dashboard['totalProjects'], equals(1));
      expect(dashboard.containsKey('portfolioMetrics'), isTrue);
    });
  });

  group('Phase 102: Project Portfolio Management - Integration Tests', () {
    test('Complete project lifecycle workflow', () async {
      final repository = InMemoryPPMRepository();
      final facade = PPMFacade(repository);
      final now = DateTime.now();

      // Create Project
      final project = Project(
        projectId: 'proj_001',
        projectName: 'Integration Project',
        status: ProjectStatus.planning,
        type: ProjectType.strategic,
        priority: ProjectPriority.high,
        description: 'Complete project lifecycle',
        sponsor: 'VP',
        projectManager: 'PM',
        budget: 2000000,
        startDate: now,
        plannedEndDate: now.add(Duration(days: 180)),
        completionPercentage: 0,
      );
      await facade.createProject(project);

      // Create Phases
      final phase = ProjectPhase(
        phaseId: 'phase_001',
        projectId: 'proj_001',
        phaseName: 'Design Phase',
        status: PhaseStatus.inProgress,
        startDate: now,
        endDate: now.add(Duration(days: 30)),
        sequenceNumber: 1,
        deliverableIds: ['deliv_001'],
        completionPercentage: 50,
      );
      await repository.createPhase(phase);

      // Create Deliverable
      final deliverable = Deliverable(
        deliverableId: 'deliv_001',
        projectId: 'proj_001',
        phaseId: 'phase_001',
        deliverableName: 'Architecture Design',
        description: 'System architecture document',
        dueDate: now.add(Duration(days: 20)),
        isCompleted: false,
        owner: 'Architect',
        dependencies: [],
      );
      await repository.createDeliverable(deliverable);

      // Verify workflow
      final proj = await facade.getProject('proj_001');
      final phases = await facade.getProjectPhases('proj_001');
      final delivs = await facade.getDeliverablesByProject('proj_001');

      expect(proj?.isActive, isFalse);
      expect(phases.length, equals(1));
      expect(delivs.length, equals(1));
    });

    test('Resource allocation and tracking workflow', () async {
      final repository = InMemoryPPMRepository();
      final facade = PPMFacade(repository);
      final now = DateTime.now();

      // Create Resources
      final resource1 = Resource(
        resourceId: 'res_001',
        resourceName: 'Alice Developer',
        role: ResourceRole.developer,
        department: 'Engineering',
        projectId: 'proj_001',
        allocationPercentage: 100,
        startDate: now,
        skills: 'Java, Python',
      );

      final resource2 = Resource(
        resourceId: 'res_002',
        resourceName: 'Bob QA',
        role: ResourceRole.qa,
        department: 'QA',
        projectId: 'proj_001',
        allocationPercentage: 50,
        startDate: now,
        skills: 'Testing',
      );

      await facade.createResource(resource1);
      await facade.createResource(resource2);

      // Verify resources
      final resources = await facade.getAllResources();
      final fully = await facade.getFullyAllocatedResources();

      expect(resources.length, equals(2));
      expect(fully.length, equals(1));
    });

    test('Risk management and portfolio tracking workflow', () async {
      final repository = InMemoryPPMRepository();
      final facade = PPMFacade(repository);
      final now = DateTime.now();

      // Create risks
      final risk1 = ProjectRisk(
        riskId: 'risk_001',
        projectId: 'proj_001',
        riskName: 'Technical Complexity',
        category: RiskCategory.technical,
        probability: 0.4,
        impact: 0.8,
        mitigation: 'POC development',
        owner: 'Architect',
        identifiedDate: now,
        isResolved: false,
      );

      final risk2 = ProjectRisk(
        riskId: 'risk_002',
        projectId: 'proj_001',
        riskName: 'Resource Shortage',
        category: RiskCategory.resource,
        probability: 0.3,
        impact: 0.6,
        mitigation: 'Contract staff',
        owner: 'PM',
        identifiedDate: now,
        isResolved: false,
      );

      await facade.createRisk(risk1);
      await facade.createRisk(risk2);

      // Verify risks
      final risks = await facade.getRisksByProject('proj_001');
      final activeRisks = await facade.getActiveRisks();

      expect(risks.length, equals(2));
      expect(activeRisks.length, equals(2));
    });
  });
}
