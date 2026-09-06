import 'package:flutter/foundation.dart';
import '../models/risk_compliance_models.dart';

abstract class RiskComplianceRepository {
  // Risk Assessment (12)
  Future<void> createRiskAssessment(RiskAssessment risk);
  Future<RiskAssessment?> getRiskAssessment(String riskId);
  Future<List<RiskAssessment>> getAllRisks();
  Future<List<RiskAssessment>> getRisksByLevel(RiskLevel level);
  Future<List<RiskAssessment>> getActiveRisks();
  Future<List<RiskAssessment>> getRisksByCategory(RiskCategory category);
  Future<void> updateRiskAssessment(RiskAssessment risk);
  Future<void> deleteRiskAssessment(String riskId);
  Future<int> getRiskCount();
  Future<double> getAverageRiskScore();
  Future<List<RiskAssessment>> getCriticalRisks();
  Future<List<RiskAssessment>> getHighRisks();

  // Mitigation Plan (12)
  Future<void> createMitigationPlan(MitigationPlan plan);
  Future<MitigationPlan?> getMitigationPlan(String planId);
  Future<List<MitigationPlan>> getAllPlans();
  Future<List<MitigationPlan>> getPlansByRisk(String riskId);
  Future<List<MitigationPlan>> getOnTrackPlans();
  Future<List<MitigationPlan>> getOffTrackPlans();
  Future<void> updateMitigationPlan(MitigationPlan plan);
  Future<void> deleteMitigationPlan(String planId);
  Future<int> getPlanCount();
  Future<double> getAverageEffectiveness();
  Future<int> getTotalMitigationCost();
  Future<List<MitigationPlan>> getOverduePlans();

  // Compliance Requirement (12)
  Future<void> createComplianceRequirement(ComplianceRequirement req);
  Future<ComplianceRequirement?> getComplianceRequirement(String reqId);
  Future<List<ComplianceRequirement>> getAllRequirements();
  Future<List<ComplianceRequirement>> getRequirementsByFramework(ComplianceFramework framework);
  Future<List<ComplianceRequirement>> getCompliantRequirements();
  Future<List<ComplianceRequirement>> getNonCompliantRequirements();
  Future<void> updateComplianceRequirement(ComplianceRequirement req);
  Future<void> deleteComplianceRequirement(String reqId);
  Future<int> getRequirementCount();
  Future<double> getCompliancePercentage();
  Future<List<ComplianceRequirement>> getOverdueRequirements();
  Future<Map<ComplianceFramework, int>> getRequirementsByFrameworkCount();

  // Audit (10)
  Future<void> createAudit(Audit audit);
  Future<Audit?> getAudit(String auditId);
  Future<List<Audit>> getAllAudits();
  Future<List<Audit>> getAuditsByType(AuditType type);
  Future<List<Audit>> getCompletedAudits();
  Future<void> updateAudit(Audit audit);
  Future<void> deleteAudit(String auditId);
  Future<int> getAuditCount();
  Future<List<Audit>> getRecentAudits(Duration duration);
  Future<int> getTotalAuditFindings();

  // Audit Finding (10)
  Future<void> createAuditFinding(AuditFinding finding);
  Future<AuditFinding?> getAuditFinding(String findingId);
  Future<List<AuditFinding>> getAllFindings();
  Future<List<AuditFinding>> getFindingsByAudit(String auditId);
  Future<List<AuditFinding>> getOpenFindings();
  Future<List<AuditFinding>> getClosedFindings();
  Future<void> updateAuditFinding(AuditFinding finding);
  Future<void> deleteAuditFinding(String findingId);
  Future<int> getFindingCount();
  Future<List<AuditFinding>> getOverdueFindings();

  // Policy (10)
  Future<void> createPolicy(Policy policy);
  Future<Policy?> getPolicy(String policyId);
  Future<List<Policy>> getAllPolicies();
  Future<List<Policy>> getActivePolicies();
  Future<List<Policy>> getPoliciesNeedingReview();
  Future<void> updatePolicy(Policy policy);
  Future<void> deletePolicy(String policyId);
  Future<int> getPolicyCount();
  Future<List<Policy>> getRecentPolicies(Duration duration);
  Future<int> getTotalActivePolicy();

  // Control Objective (10)
  Future<void> createControlObjective(ControlObjective control);
  Future<ControlObjective?> getControlObjective(String controlId);
  Future<List<ControlObjective>> getAllControls();
  Future<List<ControlObjective>> getControlsByCategory(RiskCategory category);
  Future<List<ControlObjective>> getEffectiveControls();
  Future<List<ControlObjective>> getControlsNeedingTesting();
  Future<void> updateControlObjective(ControlObjective control);
  Future<void> deleteControlObjective(String controlId);
  Future<int> getControlCount();
  Future<double> getControlEffectivenessRate();

  // Incident Report (10)
  Future<void> reportIncident(IncidentReport incident);
  Future<IncidentReport?> getIncident(String incidentId);
  Future<List<IncidentReport>> getAllIncidents();
  Future<List<IncidentReport>> getIncidentsBySeverity(RiskLevel severity);
  Future<List<IncidentReport>> getUnresolvedIncidents();
  Future<List<IncidentReport>> getResolvedIncidents();
  Future<void> updateIncident(IncidentReport incident);
  Future<void> deleteIncident(String incidentId);
  Future<int> getIncidentCount();
  Future<List<IncidentReport>> getRecentIncidents(Duration duration);

  // Compliance Metrics (8)
  Future<void> recordComplianceMetrics(ComplianceMetrics metrics);
  Future<ComplianceMetrics?> getComplianceMetrics(String metricsId);
  Future<List<ComplianceMetrics>> getAllMetrics();
  Future<ComplianceMetrics?> getLatestMetrics();
  Future<void> updateComplianceMetrics(ComplianceMetrics metrics);
  Future<void> deleteComplianceMetrics(String metricsId);
  Future<int> getMetricsCount();
  Future<double> getAverageComplianceScore();
}

class InMemoryRiskComplianceRepository implements RiskComplianceRepository {
  final Map<String, RiskAssessment> _risks = {};
  final Map<String, MitigationPlan> _plans = {};
  final Map<String, ComplianceRequirement> _requirements = {};
  final Map<String, Audit> _audits = {};
  final Map<String, AuditFinding> _findings = {};
  final Map<String, Policy> _policies = {};
  final Map<String, ControlObjective> _controls = {};
  final Map<String, IncidentReport> _incidents = {};
  final Map<String, ComplianceMetrics> _metrics = {};

  @override
  Future<void> createRiskAssessment(RiskAssessment risk) async =>
    _risks[risk.riskId] = risk;

  @override
  Future<RiskAssessment?> getRiskAssessment(String riskId) async =>
    _risks[riskId];

  @override
  Future<List<RiskAssessment>> getAllRisks() async => _risks.values.toList();

  @override
  Future<List<RiskAssessment>> getRisksByLevel(RiskLevel level) async =>
    _risks.values.where((r) => r.level == level).toList();

  @override
  Future<List<RiskAssessment>> getActiveRisks() async =>
    _risks.values.where((r) => r.isActive).toList();

  @override
  Future<List<RiskAssessment>> getRisksByCategory(RiskCategory category) async =>
    _risks.values.where((r) => r.category == category).toList();

  @override
  Future<void> updateRiskAssessment(RiskAssessment risk) async =>
    _risks[risk.riskId] = risk;

  @override
  Future<void> deleteRiskAssessment(String riskId) async =>
    _risks.remove(riskId);

  @override
  Future<int> getRiskCount() async => _risks.length;

  @override
  Future<double> getAverageRiskScore() async {
    if (_risks.isEmpty) return 0;
    final total = _risks.values.fold<double>(0, (sum, r) => sum + r.riskScore);
    return total / _risks.length;
  }

  @override
  Future<List<RiskAssessment>> getCriticalRisks() async =>
    _risks.values.where((r) => r.level == RiskLevel.critical).toList();

  @override
  Future<List<RiskAssessment>> getHighRisks() async =>
    _risks.values.where((r) => r.level == RiskLevel.high).toList();

  @override
  Future<void> createMitigationPlan(MitigationPlan plan) async =>
    _plans[plan.planId] = plan;

  @override
  Future<MitigationPlan?> getMitigationPlan(String planId) async =>
    _plans[planId];

  @override
  Future<List<MitigationPlan>> getAllPlans() async => _plans.values.toList();

  @override
  Future<List<MitigationPlan>> getPlansByRisk(String riskId) async =>
    _plans.values.where((p) => p.riskId == riskId).toList();

  @override
  Future<List<MitigationPlan>> getOnTrackPlans() async =>
    _plans.values.where((p) => p.isOnTrack).toList();

  @override
  Future<List<MitigationPlan>> getOffTrackPlans() async =>
    _plans.values.where((p) => !p.isOnTrack).toList();

  @override
  Future<void> updateMitigationPlan(MitigationPlan plan) async =>
    _plans[plan.planId] = plan;

  @override
  Future<void> deleteMitigationPlan(String planId) async =>
    _plans.remove(planId);

  @override
  Future<int> getPlanCount() async => _plans.length;

  @override
  Future<double> getAverageEffectiveness() async {
    if (_plans.isEmpty) return 0;
    final total = _plans.values.fold<double>(0, (sum, p) => sum + p.effectiveness);
    return total / _plans.length;
  }

  @override
  Future<int> getTotalMitigationCost() async =>
    _plans.values.fold<int>(0, (sum, p) => sum + p.costEstimate);

  @override
  Future<List<MitigationPlan>> getOverduePlans() async =>
    _plans.values.where((p) => !p.isOnTrack && DateTime.now().isAfter(p.targetDate)).toList();

  @override
  Future<void> createComplianceRequirement(ComplianceRequirement req) async =>
    _requirements[req.requirementId] = req;

  @override
  Future<ComplianceRequirement?> getComplianceRequirement(String reqId) async =>
    _requirements[reqId];

  @override
  Future<List<ComplianceRequirement>> getAllRequirements() async =>
    _requirements.values.toList();

  @override
  Future<List<ComplianceRequirement>> getRequirementsByFramework(ComplianceFramework framework) async =>
    _requirements.values.where((r) => r.framework == framework).toList();

  @override
  Future<List<ComplianceRequirement>> getCompliantRequirements() async =>
    _requirements.values.where((r) => r.isCompliant).toList();

  @override
  Future<List<ComplianceRequirement>> getNonCompliantRequirements() async =>
    _requirements.values.where((r) => !r.isCompliant).toList();

  @override
  Future<void> updateComplianceRequirement(ComplianceRequirement req) async =>
    _requirements[req.requirementId] = req;

  @override
  Future<void> deleteComplianceRequirement(String reqId) async =>
    _requirements.remove(reqId);

  @override
  Future<int> getRequirementCount() async => _requirements.length;

  @override
  Future<double> getCompliancePercentage() async {
    if (_requirements.isEmpty) return 0;
    final compliant = _requirements.values.where((r) => r.isCompliant).length;
    return (compliant / _requirements.length) * 100;
  }

  @override
  Future<List<ComplianceRequirement>> getOverdueRequirements() async =>
    _requirements.values.where((r) => r.isOverdue).toList();

  @override
  Future<Map<ComplianceFramework, int>> getRequirementsByFrameworkCount() async {
    final map = <ComplianceFramework, int>{};
    for (final req in _requirements.values) {
      map[req.framework] = (map[req.framework] ?? 0) + 1;
    }
    return map;
  }

  @override
  Future<void> createAudit(Audit audit) async => _audits[audit.auditId] = audit;

  @override
  Future<Audit?> getAudit(String auditId) async => _audits[auditId];

  @override
  Future<List<Audit>> getAllAudits() async => _audits.values.toList();

  @override
  Future<List<Audit>> getAuditsByType(AuditType type) async =>
    _audits.values.where((a) => a.type == type).toList();

  @override
  Future<List<Audit>> getCompletedAudits() async =>
    _audits.values.where((a) => a.isCompleted).toList();

  @override
  Future<void> updateAudit(Audit audit) async => _audits[audit.auditId] = audit;

  @override
  Future<void> deleteAudit(String auditId) async => _audits.remove(auditId);

  @override
  Future<int> getAuditCount() async => _audits.length;

  @override
  Future<List<Audit>> getRecentAudits(Duration duration) async =>
    _audits.values.where((a) => DateTime.now().difference(a.startDate) <= duration).toList();

  @override
  Future<int> getTotalAuditFindings() async =>
    _audits.values.fold<int>(0, (sum, a) => sum + a.findingsCount);

  @override
  Future<void> createAuditFinding(AuditFinding finding) async =>
    _findings[finding.findingId] = finding;

  @override
  Future<AuditFinding?> getAuditFinding(String findingId) async =>
    _findings[findingId];

  @override
  Future<List<AuditFinding>> getAllFindings() async => _findings.values.toList();

  @override
  Future<List<AuditFinding>> getFindingsByAudit(String auditId) async =>
    _findings.values.where((f) => f.auditId == auditId).toList();

  @override
  Future<List<AuditFinding>> getOpenFindings() async =>
    _findings.values.where((f) => !f.isClosed).toList();

  @override
  Future<List<AuditFinding>> getClosedFindings() async =>
    _findings.values.where((f) => f.isClosed).toList();

  @override
  Future<void> updateAuditFinding(AuditFinding finding) async =>
    _findings[finding.findingId] = finding;

  @override
  Future<void> deleteAuditFinding(String findingId) async =>
    _findings.remove(findingId);

  @override
  Future<int> getFindingCount() async => _findings.length;

  @override
  Future<List<AuditFinding>> getOverdueFindings() async =>
    _findings.values.where((f) => f.isOverdue).toList();

  @override
  Future<void> createPolicy(Policy policy) async =>
    _policies[policy.policyId] = policy;

  @override
  Future<Policy?> getPolicy(String policyId) async => _policies[policyId];

  @override
  Future<List<Policy>> getAllPolicies() async => _policies.values.toList();

  @override
  Future<List<Policy>> getActivePolicies() async =>
    _policies.values.where((p) => p.isActive).toList();

  @override
  Future<List<Policy>> getPoliciesNeedingReview() async =>
    _policies.values.where((p) => p.needsReview).toList();

  @override
  Future<void> updatePolicy(Policy policy) async =>
    _policies[policy.policyId] = policy;

  @override
  Future<void> deletePolicy(String policyId) async =>
    _policies.remove(policyId);

  @override
  Future<int> getPolicyCount() async => _policies.length;

  @override
  Future<List<Policy>> getRecentPolicies(Duration duration) async =>
    _policies.values.where((p) => DateTime.now().difference(p.effectiveDate) <= duration).toList();

  @override
  Future<int> getTotalActivePolicy() async =>
    _policies.values.where((p) => p.isActive).length;

  @override
  Future<void> createControlObjective(ControlObjective control) async =>
    _controls[control.controlId] = control;

  @override
  Future<ControlObjective?> getControlObjective(String controlId) async =>
    _controls[controlId];

  @override
  Future<List<ControlObjective>> getAllControls() async =>
    _controls.values.toList();

  @override
  Future<List<ControlObjective>> getControlsByCategory(RiskCategory category) async =>
    _controls.values.where((c) => c.category == category).toList();

  @override
  Future<List<ControlObjective>> getEffectiveControls() async =>
    _controls.values.where((c) => c.isEffective).toList();

  @override
  Future<List<ControlObjective>> getControlsNeedingTesting() async =>
    _controls.values.where((c) => c.needsTesting).toList();

  @override
  Future<void> updateControlObjective(ControlObjective control) async =>
    _controls[control.controlId] = control;

  @override
  Future<void> deleteControlObjective(String controlId) async =>
    _controls.remove(controlId);

  @override
  Future<int> getControlCount() async => _controls.length;

  @override
  Future<double> getControlEffectivenessRate() async {
    if (_controls.isEmpty) return 0;
    final effective = _controls.values.where((c) => c.isEffective).length;
    return (effective / _controls.length) * 100;
  }

  @override
  Future<void> reportIncident(IncidentReport incident) async =>
    _incidents[incident.incidentId] = incident;

  @override
  Future<IncidentReport?> getIncident(String incidentId) async =>
    _incidents[incidentId];

  @override
  Future<List<IncidentReport>> getAllIncidents() async =>
    _incidents.values.toList();

  @override
  Future<List<IncidentReport>> getIncidentsBySeverity(RiskLevel severity) async =>
    _incidents.values.where((i) => i.severity == severity).toList();

  @override
  Future<List<IncidentReport>> getUnresolvedIncidents() async =>
    _incidents.values.where((i) => !i.isResolved).toList();

  @override
  Future<List<IncidentReport>> getResolvedIncidents() async =>
    _incidents.values.where((i) => i.isResolved).toList();

  @override
  Future<void> updateIncident(IncidentReport incident) async =>
    _incidents[incident.incidentId] = incident;

  @override
  Future<void> deleteIncident(String incidentId) async =>
    _incidents.remove(incidentId);

  @override
  Future<int> getIncidentCount() async => _incidents.length;

  @override
  Future<List<IncidentReport>> getRecentIncidents(Duration duration) async =>
    _incidents.values.where((i) => DateTime.now().difference(i.reportedDate) <= duration).toList();

  @override
  Future<void> recordComplianceMetrics(ComplianceMetrics metrics) async =>
    _metrics[metrics.metricsId] = metrics;

  @override
  Future<ComplianceMetrics?> getComplianceMetrics(String metricsId) async =>
    _metrics[metricsId];

  @override
  Future<List<ComplianceMetrics>> getAllMetrics() async =>
    _metrics.values.toList();

  @override
  Future<ComplianceMetrics?> getLatestMetrics() async {
    if (_metrics.isEmpty) return null;
    return _metrics.values.reduce((a, b) =>
      a.reportDate.isAfter(b.reportDate) ? a : b);
  }

  @override
  Future<void> updateComplianceMetrics(ComplianceMetrics metrics) async =>
    _metrics[metrics.metricsId] = metrics;

  @override
  Future<void> deleteComplianceMetrics(String metricsId) async =>
    _metrics.remove(metricsId);

  @override
  Future<int> getMetricsCount() async => _metrics.length;

  @override
  Future<double> getAverageComplianceScore() async {
    if (_metrics.isEmpty) return 0;
    final total = _metrics.values.fold<double>(0, (sum, m) => sum + m.overallComplianceScore);
    return total / _metrics.length;
  }
}

class RiskAssessmentEngine {
  final RiskComplianceRepository repository;
  RiskAssessmentEngine(this.repository);

  Future<double> getPortfolioRiskScore() async =>
    await repository.getAverageRiskScore();
}

class ComplianceEngine {
  final RiskComplianceRepository repository;
  ComplianceEngine(this.repository);

  Future<double> getOverallComplianceScore() async =>
    await repository.getCompliancePercentage();
}

class AuditEngine {
  final RiskComplianceRepository repository;
  AuditEngine(this.repository);

  Future<int> getOpenFindingCount() async =>
    (await repository.getOpenFindings()).length;
}

class RiskComplianceManager {
  final RiskComplianceRepository repository;
  late final RiskAssessmentEngine riskEngine;
  late final ComplianceEngine complianceEngine;
  late final AuditEngine auditEngine;

  RiskComplianceManager(this.repository) {
    riskEngine = RiskAssessmentEngine(repository);
    complianceEngine = ComplianceEngine(repository);
    auditEngine = AuditEngine(repository);
  }

  Future<Map<String, dynamic>> getRiskComplianceDashboard() async {
    return {
      'totalRisks': await repository.getRiskCount(),
      'criticalRisks': (await repository.getCriticalRisks()).length,
      'activeRisks': (await repository.getActiveRisks()).length,
      'averageRiskScore': await riskEngine.getPortfolioRiskScore(),
      'totalRequirements': await repository.getRequirementCount(),
      'compliantRequirements': (await repository.getCompliantRequirements()).length,
      'compliancePercentage': await complianceEngine.getOverallComplianceScore(),
      'totalAudits': await repository.getAuditCount(),
      'openFindings': await auditEngine.getOpenFindingCount(),
      'averageComplianceScore': await repository.getAverageComplianceScore(),
    };
  }
}

class RiskComplianceFacade {
  final RiskComplianceRepository _repository;
  late final RiskComplianceManager _manager;

  RiskComplianceFacade(this._repository) {
    _manager = RiskComplianceManager(_repository);
  }

  Future<void> createRiskAssessment(RiskAssessment risk) =>
    _repository.createRiskAssessment(risk);
  Future<List<RiskAssessment>> getActiveRisks() =>
    _repository.getActiveRisks();
  Future<List<RiskAssessment>> getCriticalRisks() =>
    _repository.getCriticalRisks();

  Future<void> createComplianceRequirement(ComplianceRequirement req) =>
    _repository.createComplianceRequirement(req);
  Future<List<ComplianceRequirement>> getCompliantRequirements() =>
    _repository.getCompliantRequirements();
  Future<List<ComplianceRequirement>> getNonCompliantRequirements() =>
    _repository.getNonCompliantRequirements();

  Future<void> createAudit(Audit audit) => _repository.createAudit(audit);
  Future<List<Audit>> getCompletedAudits() => _repository.getCompletedAudits();

  Future<void> reportIncident(IncidentReport incident) =>
    _repository.reportIncident(incident);
  Future<List<IncidentReport>> getUnresolvedIncidents() =>
    _repository.getUnresolvedIncidents();

  Future<Map<String, dynamic>> getRiskComplianceDashboard() =>
    _manager.getRiskComplianceDashboard();
}
