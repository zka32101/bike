import 'package:project_040/models/crm_models.dart';

abstract class CRMRepository {
  // Account methods (12)
  Future<void> createAccount(Account account);
  Future<Account?> getAccount(String accountId);
  Future<List<Account>> getAllAccounts();
  Future<List<Account>> getAccountsByType(AccountType type);
  Future<List<Account>> getActiveAccounts();
  Future<List<Account>> getAccountsByIndustry(String industry);
  Future<void> updateAccount(Account account);
  Future<void> deleteAccount(String accountId);
  Future<int> getAccountCount();
  Future<List<Account>> getAccountsByOwner(String owner);
  Future<double> getTotalAnnualRevenue();
  Future<List<Account>> getAccountsWithoutActivity(int daysSinceActivity);

  // Contact methods (12)
  Future<void> createContact(Contact contact);
  Future<Contact?> getContact(String contactId);
  Future<List<Contact>> getAllContacts();
  Future<List<Contact>> getContactsByAccount(String accountId);
  Future<List<Contact>> getPrimaryContacts();
  Future<List<Contact>> getDecisionMakers();
  Future<List<Contact>> getContactsByRole(ContactRole role);
  Future<void> updateContact(Contact contact);
  Future<void> deleteContact(String contactId);
  Future<int> getContactCount();
  Future<int> getContactCountByAccount(String accountId);
  Future<List<Contact>> searchContactsByEmail(String email);

  // Lead methods (12)
  Future<void> createLead(Lead lead);
  Future<Lead?> getLead(String leadId);
  Future<List<Lead>> getAllLeads();
  Future<List<Lead>> getLeadsByStatus(LeadStatus status);
  Future<List<Lead>> getQualifiedLeads();
  Future<List<Lead>> getLeadsBySource(String source);
  Future<List<Lead>> getLeadsByIndustry(String industry);
  Future<void> updateLead(Lead lead);
  Future<void> deleteLead(String leadId);
  Future<int> getLeadCount();
  Future<double> getAverageLeadBudget();
  Future<int> getConvertedLeadCount();

  // Opportunity methods (12)
  Future<void> createOpportunity(Opportunity opportunity);
  Future<Opportunity?> getOpportunity(String opportunityId);
  Future<List<Opportunity>> getAllOpportunities();
  Future<List<Opportunity>> getOpportunitiesByStage(OpportunityStage stage);
  Future<List<Opportunity>> getOpenOpportunities();
  Future<List<Opportunity>> getOpportunitiesByOwner(String owner);
  Future<List<Opportunity>> getOverdueOpportunities();
  Future<void> updateOpportunity(Opportunity opportunity);
  Future<void> deleteOpportunity(String opportunityId);
  Future<int> getOpportunityCount();
  Future<double> getTotalPipelineValue();
  Future<double> getAverageOpportunityAmount();

  // Activity methods (10)
  Future<void> createActivity(Activity activity);
  Future<Activity?> getActivity(String activityId);
  Future<List<Activity>> getAllActivities();
  Future<List<Activity>> getActivitiesByAccount(String accountId);
  Future<List<Activity>> getActivitiesByType(ActivityType type);
  Future<List<Activity>> getIncompleteActivities();
  Future<void> updateActivity(Activity activity);
  Future<void> deleteActivity(String activityId);
  Future<int> getActivityCount();
  Future<List<Activity>> getRecentActivities(int days);

  // Campaign methods (12)
  Future<void> createCampaign(Campaign campaign);
  Future<Campaign?> getCampaign(String campaignId);
  Future<List<Campaign>> getAllCampaigns();
  Future<List<Campaign>> getActiveCampaigns();
  Future<List<Campaign>> getCampaignsByOwner(String owner);
  Future<List<Campaign>> getCampaignsByStatus(CampaignStatus status);
  Future<void> updateCampaign(Campaign campaign);
  Future<void> deleteCampaign(String campaignId);
  Future<int> getCampaignCount();
  Future<double> getTotalCampaignBudget();
  Future<double> getTotalCampaignSpent();
  Future<Map<String, int>> getCampaignResponsesByType();

  // Deal methods (10)
  Future<void> createDeal(Deal deal);
  Future<Deal?> getDeal(String dealId);
  Future<List<Deal>> getAllDeals();
  Future<List<Deal>> getDealsByStatus(DealStatus status);
  Future<List<Deal>> getWonDeals();
  Future<List<Deal>> getOverdueDeals();
  Future<void> updateDeal(Deal deal);
  Future<void> deleteDeal(String dealId);
  Future<int> getDealCount();
  Future<double> getTotalDealValue();

  // Forecast methods (12)
  Future<void> createForecast(Forecast forecast);
  Future<Forecast?> getForecast(String forecastId);
  Future<List<Forecast>> getAllForecasts();
  Future<List<Forecast>> getForecastsByOwner(String owner);
  Future<Forecast?> getLatestForecast(String owner);
  Future<List<Forecast>> getForecastsByMonth(int month, int year);
  Future<void> updateForecast(Forecast forecast);
  Future<void> deleteForecast(String forecastId);
  Future<int> getForecastCount();
  Future<double> getAverageForecastValue();
  Future<Map<String, double>> getForecastsByOwnerAggregated();
  Future<double> getPortfolioForecast();

  // Sales Metrics methods (8)
  Future<void> recordMetrics(SalesMetrics metrics);
  Future<SalesMetrics?> getLatestMetrics();
  Future<List<SalesMetrics>> getAllMetrics();
  Future<SalesMetrics?> getMetricsByDate(DateTime date);
  Future<double> getWinRate();
  Future<double> getAverageSalesCycleLength();
  Future<List<SalesMetrics>> getMetricsTimeSeriesData(int monthsBack);
  Future<Map<String, double>> getMetricsTrends();
}

class InMemoryCRMRepository implements CRMRepository {
  final Map<String, Account> _accounts = {};
  final Map<String, Contact> _contacts = {};
  final Map<String, Lead> _leads = {};
  final Map<String, Opportunity> _opportunities = {};
  final Map<String, Activity> _activities = {};
  final Map<String, Campaign> _campaigns = {};
  final Map<String, Deal> _deals = {};
  final Map<String, Forecast> _forecasts = {};
  final Map<String, SalesMetrics> _metrics = {};

  // Account implementations
  @override
  Future<void> createAccount(Account account) async => _accounts[account.accountId] = account;

  @override
  Future<Account?> getAccount(String accountId) async => _accounts[accountId];

  @override
  Future<List<Account>> getAllAccounts() async => _accounts.values.toList();

  @override
  Future<List<Account>> getAccountsByType(AccountType type) async =>
      _accounts.values.where((a) => a.type == type).toList();

  @override
  Future<List<Account>> getActiveAccounts() async =>
      _accounts.values.where((a) => a.isActive).toList();

  @override
  Future<List<Account>> getAccountsByIndustry(String industry) async =>
      _accounts.values.where((a) => a.industry == industry).toList();

  @override
  Future<void> updateAccount(Account account) async => _accounts[account.accountId] = account;

  @override
  Future<void> deleteAccount(String accountId) async => _accounts.remove(accountId);

  @override
  Future<int> getAccountCount() async => _accounts.length;

  @override
  Future<List<Account>> getAccountsByOwner(String owner) async =>
      _accounts.values.where((a) => a.accountOwner == owner).toList();

  @override
  Future<double> getTotalAnnualRevenue() async =>
      _accounts.values.fold<double>(0, (sum, a) => sum + a.annualRevenue);

  @override
  Future<List<Account>> getAccountsWithoutActivity(int daysSinceActivity) async =>
      _accounts.values.where((a) => a.daysSinceLastActivity > daysSinceActivity).toList();

  // Contact implementations
  @override
  Future<void> createContact(Contact contact) async => _contacts[contact.contactId] = contact;

  @override
  Future<Contact?> getContact(String contactId) async => _contacts[contactId];

  @override
  Future<List<Contact>> getAllContacts() async => _contacts.values.toList();

  @override
  Future<List<Contact>> getContactsByAccount(String accountId) async =>
      _contacts.values.where((c) => c.accountId == accountId).toList();

  @override
  Future<List<Contact>> getPrimaryContacts() async =>
      _contacts.values.where((c) => c.isPrimaryContact).toList();

  @override
  Future<List<Contact>> getDecisionMakers() async =>
      _contacts.values.where((c) => c.isDecisionMaker).toList();

  @override
  Future<List<Contact>> getContactsByRole(ContactRole role) async =>
      _contacts.values.where((c) => c.role == role).toList();

  @override
  Future<void> updateContact(Contact contact) async => _contacts[contact.contactId] = contact;

  @override
  Future<void> deleteContact(String contactId) async => _contacts.remove(contactId);

  @override
  Future<int> getContactCount() async => _contacts.length;

  @override
  Future<int> getContactCountByAccount(String accountId) async =>
      _contacts.values.where((c) => c.accountId == accountId).length;

  @override
  Future<List<Contact>> searchContactsByEmail(String email) async =>
      _contacts.values.where((c) => c.email.contains(email)).toList();

  // Lead implementations
  @override
  Future<void> createLead(Lead lead) async => _leads[lead.leadId] = lead;

  @override
  Future<Lead?> getLead(String leadId) async => _leads[leadId];

  @override
  Future<List<Lead>> getAllLeads() async => _leads.values.toList();

  @override
  Future<List<Lead>> getLeadsByStatus(LeadStatus status) async =>
      _leads.values.where((l) => l.status == status).toList();

  @override
  Future<List<Lead>> getQualifiedLeads() async =>
      _leads.values.where((l) => l.isQualified).toList();

  @override
  Future<List<Lead>> getLeadsBySource(String source) async =>
      _leads.values.where((l) => l.source == source).toList();

  @override
  Future<List<Lead>> getLeadsByIndustry(String industry) async =>
      _leads.values.where((l) => l.industry == industry).toList();

  @override
  Future<void> updateLead(Lead lead) async => _leads[lead.leadId] = lead;

  @override
  Future<void> deleteLead(String leadId) async => _leads.remove(leadId);

  @override
  Future<int> getLeadCount() async => _leads.length;

  @override
  Future<double> getAverageLeadBudget() async {
    if (_leads.isEmpty) return 0;
    final budgets = _leads.values.where((l) => l.estimatedBudget != null).map((l) => l.estimatedBudget!).toList();
    return budgets.isEmpty ? 0 : budgets.fold<double>(0, (sum, b) => sum + b) / budgets.length;
  }

  @override
  Future<int> getConvertedLeadCount() async =>
      _leads.values.where((l) => l.isConverted).length;

  // Opportunity implementations
  @override
  Future<void> createOpportunity(Opportunity opportunity) async =>
      _opportunities[opportunity.opportunityId] = opportunity;

  @override
  Future<Opportunity?> getOpportunity(String opportunityId) async =>
      _opportunities[opportunityId];

  @override
  Future<List<Opportunity>> getAllOpportunities() async =>
      _opportunities.values.toList();

  @override
  Future<List<Opportunity>> getOpportunitiesByStage(OpportunityStage stage) async =>
      _opportunities.values.where((o) => o.stage == stage).toList();

  @override
  Future<List<Opportunity>> getOpenOpportunities() async =>
      _opportunities.values.where((o) => !o.isClosed).toList();

  @override
  Future<List<Opportunity>> getOpportunitiesByOwner(String owner) async =>
      _opportunities.values.where((o) => o.owner == owner).toList();

  @override
  Future<List<Opportunity>> getOverdueOpportunities() async =>
      _opportunities.values.where((o) => o.isOverdue).toList();

  @override
  Future<void> updateOpportunity(Opportunity opportunity) async =>
      _opportunities[opportunity.opportunityId] = opportunity;

  @override
  Future<void> deleteOpportunity(String opportunityId) async =>
      _opportunities.remove(opportunityId);

  @override
  Future<int> getOpportunityCount() async => _opportunities.length;

  @override
  Future<double> getTotalPipelineValue() async =>
      _opportunities.values.fold<double>(0, (sum, o) => sum + o.amount);

  @override
  Future<double> getAverageOpportunityAmount() async {
    if (_opportunities.isEmpty) return 0;
    return _opportunities.values.fold<double>(0, (sum, o) => sum + o.amount) / _opportunities.length;
  }

  // Activity implementations
  @override
  Future<void> createActivity(Activity activity) async =>
      _activities[activity.activityId] = activity;

  @override
  Future<Activity?> getActivity(String activityId) async => _activities[activityId];

  @override
  Future<List<Activity>> getAllActivities() async => _activities.values.toList();

  @override
  Future<List<Activity>> getActivitiesByAccount(String accountId) async =>
      _activities.values.where((a) => a.accountId == accountId).toList();

  @override
  Future<List<Activity>> getActivitiesByType(ActivityType type) async =>
      _activities.values.where((a) => a.type == type).toList();

  @override
  Future<List<Activity>> getIncompleteActivities() async =>
      _activities.values.where((a) => !a.isCompleted).toList();

  @override
  Future<void> updateActivity(Activity activity) async =>
      _activities[activity.activityId] = activity;

  @override
  Future<void> deleteActivity(String activityId) async => _activities.remove(activityId);

  @override
  Future<int> getActivityCount() async => _activities.length;

  @override
  Future<List<Activity>> getRecentActivities(int days) async =>
      _activities.values.where((a) => a.ageInDays <= days).toList();

  // Campaign implementations
  @override
  Future<void> createCampaign(Campaign campaign) async =>
      _campaigns[campaign.campaignId] = campaign;

  @override
  Future<Campaign?> getCampaign(String campaignId) async => _campaigns[campaignId];

  @override
  Future<List<Campaign>> getAllCampaigns() async => _campaigns.values.toList();

  @override
  Future<List<Campaign>> getActiveCampaigns() async =>
      _campaigns.values.where((c) => c.isActive).toList();

  @override
  Future<List<Campaign>> getCampaignsByOwner(String owner) async =>
      _campaigns.values.where((c) => c.owner == owner).toList();

  @override
  Future<List<Campaign>> getCampaignsByStatus(CampaignStatus status) async =>
      _campaigns.values.where((c) => c.status == status).toList();

  @override
  Future<void> updateCampaign(Campaign campaign) async =>
      _campaigns[campaign.campaignId] = campaign;

  @override
  Future<void> deleteCampaign(String campaignId) async => _campaigns.remove(campaignId);

  @override
  Future<int> getCampaignCount() async => _campaigns.length;

  @override
  Future<double> getTotalCampaignBudget() async =>
      _campaigns.values.fold<double>(0, (sum, c) => sum + c.budget);

  @override
  Future<double> getTotalCampaignSpent() async =>
      _campaigns.values.fold<double>(0, (sum, c) => sum + (c.spentAmount ?? 0));

  @override
  Future<Map<String, int>> getCampaignResponsesByType() async {
    final result = <String, int>{};
    for (final campaign in _campaigns.values) {
      result[campaign.type] = (result[campaign.type] ?? 0) + (campaign.actualResponses ?? 0);
    }
    return result;
  }

  // Deal implementations
  @override
  Future<void> createDeal(Deal deal) async => _deals[deal.dealId] = deal;

  @override
  Future<Deal?> getDeal(String dealId) async => _deals[dealId];

  @override
  Future<List<Deal>> getAllDeals() async => _deals.values.toList();

  @override
  Future<List<Deal>> getDealsByStatus(DealStatus status) async =>
      _deals.values.where((d) => d.status == status).toList();

  @override
  Future<List<Deal>> getWonDeals() async =>
      _deals.values.where((d) => d.isWon).toList();

  @override
  Future<List<Deal>> getOverdueDeals() async =>
      _deals.values.where((d) => d.isOverdue).toList();

  @override
  Future<void> updateDeal(Deal deal) async => _deals[deal.dealId] = deal;

  @override
  Future<void> deleteDeal(String dealId) async => _deals.remove(dealId);

  @override
  Future<int> getDealCount() async => _deals.length;

  @override
  Future<double> getTotalDealValue() async =>
      _deals.values.fold<double>(0, (sum, d) => sum + d.dealValue);

  // Forecast implementations
  @override
  Future<void> createForecast(Forecast forecast) async =>
      _forecasts[forecast.forecastId] = forecast;

  @override
  Future<Forecast?> getForecast(String forecastId) async => _forecasts[forecastId];

  @override
  Future<List<Forecast>> getAllForecasts() async => _forecasts.values.toList();

  @override
  Future<List<Forecast>> getForecastsByOwner(String owner) async =>
      _forecasts.values.where((f) => f.owner == owner).toList();

  @override
  Future<Forecast?> getLatestForecast(String owner) async {
    final forecasts = await getForecastsByOwner(owner);
    return forecasts.isEmpty
        ? null
        : forecasts.reduce((a, b) => a.forecastDate.isAfter(b.forecastDate) ? a : b);
  }

  @override
  Future<List<Forecast>> getForecastsByMonth(int month, int year) async =>
      _forecasts.values.where((f) => f.month == month && f.year == year).toList();

  @override
  Future<void> updateForecast(Forecast forecast) async =>
      _forecasts[forecast.forecastId] = forecast;

  @override
  Future<void> deleteForecast(String forecastId) async => _forecasts.remove(forecastId);

  @override
  Future<int> getForecastCount() async => _forecasts.length;

  @override
  Future<double> getAverageForecastValue() async {
    if (_forecasts.isEmpty) return 0;
    return _forecasts.values.fold<double>(0, (sum, f) => sum + f.averageValue) /
        _forecasts.length;
  }

  @override
  Future<Map<String, double>> getForecastsByOwnerAggregated() async {
    final result = <String, double>{};
    for (final forecast in _forecasts.values) {
      result[forecast.owner] =
          (result[forecast.owner] ?? 0) + forecast.mostLikelyValue;
    }
    return result;
  }

  @override
  Future<double> getPortfolioForecast() async =>
      _forecasts.values.fold<double>(0, (sum, f) => sum + f.mostLikelyValue);

  // Sales Metrics implementations
  @override
  Future<void> recordMetrics(SalesMetrics metrics) async =>
      _metrics[metrics.metricsId] = metrics;

  @override
  Future<SalesMetrics?> getLatestMetrics() async {
    if (_metrics.isEmpty) return null;
    return _metrics.values.reduce((a, b) => a.reportDate.isAfter(b.reportDate) ? a : b);
  }

  @override
  Future<List<SalesMetrics>> getAllMetrics() async => _metrics.values.toList();

  @override
  Future<SalesMetrics?> getMetricsByDate(DateTime date) async {
    final matching = _metrics.values
        .where((m) => m.reportDate.year == date.year &&
            m.reportDate.month == date.month &&
            m.reportDate.day == date.day)
        .toList();
    return matching.isEmpty ? null : matching.first;
  }

  @override
  Future<double> getWinRate() async {
    final latest = await getLatestMetrics();
    return latest?.winRate ?? 0;
  }

  @override
  Future<double> getAverageSalesCycleLength() async {
    if (_metrics.isEmpty) return 0;
    return _metrics.values.fold<double>(0, (sum, m) => sum + m.salesCycleLength) /
        _metrics.length;
  }

  @override
  Future<List<SalesMetrics>> getMetricsTimeSeriesData(int monthsBack) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: monthsBack * 30));
    return _metrics.values.where((m) => m.reportDate.isAfter(cutoffDate)).toList();
  }

  @override
  Future<Map<String, double>> getMetricsTrends() async {
    final latest = await getLatestMetrics();
    return latest?.performanceByOwner ?? {};
  }
}

class SalesEngine {
  double calculateExpectedValue(Opportunity opportunity) {
    return opportunity.amount * opportunity.probability;
  }

  double calculateWinProbability(List<Opportunity> opportunities) {
    if (opportunities.isEmpty) return 0;
    final totalExpectedValue =
        opportunities.fold<double>(0, (sum, o) => sum + o.expectedValue);
    final totalAmount =
        opportunities.fold<double>(0, (sum, o) => sum + o.amount);
    return totalAmount == 0 ? 0 : (totalExpectedValue / totalAmount) * 100;
  }

  int calculateAverageSalesCycle(List<Deal> deals) {
    if (deals.isEmpty) return 0;
    return deals.fold<int>(0, (sum, d) => sum + d.cycleLength) ~/ deals.length;
  }
}

class CustomerSegmentationEngine {
  Map<String, List<Account>> segmentByRevenue(List<Account> accounts) {
    return {
      'Enterprise': accounts.where((a) => a.annualRevenue > 10000000).toList(),
      'MidMarket': accounts.where((a) => a.annualRevenue > 1000000 && a.annualRevenue <= 10000000).toList(),
      'SmallBusiness': accounts.where((a) => a.annualRevenue <= 1000000).toList(),
    };
  }

  Map<String, List<Account>> segmentByIndustry(List<Account> accounts) {
    final segments = <String, List<Account>>{};
    for (final account in accounts) {
      segments.putIfAbsent(account.industry, () => []).add(account);
    }
    return segments;
  }
}

class ForecastingEngine {
  double generateForecast(List<Opportunity> opportunities) {
    return opportunities.fold<double>(0, (sum, o) => sum + o.expectedValue);
  }

  Map<String, double> generateForecastByOwner(List<Opportunity> opportunities) {
    final result = <String, double>{};
    for (final opp in opportunities) {
      result[opp.owner] = (result[opp.owner] ?? 0) + opp.expectedValue;
    }
    return result;
  }
}

class CRMManager {
  final CRMRepository repository;
  late final SalesEngine salesEngine;
  late final CustomerSegmentationEngine segmentationEngine;
  late final ForecastingEngine forecastingEngine;

  CRMManager(this.repository) {
    salesEngine = SalesEngine();
    segmentationEngine = CustomerSegmentationEngine();
    forecastingEngine = ForecastingEngine();
  }

  Future<Map<String, dynamic>> getCRMDashboard() async {
    final accounts = await repository.getAllAccounts();
    final opportunities = await repository.getAllOpportunities();
    final deals = await repository.getAllDeals();
    final leads = await repository.getAllLeads();
    final activities = await repository.getAllActivities();

    return {
      'totalAccounts': accounts.length,
      'activeAccounts': accounts.where((a) => a.isActive).length,
      'totalPipelineValue': opportunities.fold<double>(0, (sum, o) => sum + o.amount),
      'openOpportunities': opportunities.where((o) => !o.isClosed).length,
      'expectedValue': opportunities.fold<double>(0, (sum, o) => sum + o.expectedValue),
      'totalDeals': deals.length,
      'wonDeals': deals.where((d) => d.isWon).length,
      'winRate': deals.isEmpty ? 0 : (deals.where((d) => d.isWon).length / deals.length) * 100,
      'totalLeads': leads.length,
      'qualifiedLeads': leads.where((l) => l.isQualified).length,
      'totalActivities': activities.length,
      'incompleteActivities': activities.where((a) => !a.isCompleted).length,
    };
  }
}

class CRMFacade {
  final CRMRepository repository;
  late final CRMManager manager;

  CRMFacade(this.repository) {
    manager = CRMManager(repository);
  }

  Future<void> createAccount(Account account) async => repository.createAccount(account);
  Future<Account?> getAccount(String accountId) async => repository.getAccount(accountId);
  Future<List<Account>> getAllAccounts() async => repository.getAllAccounts();
  Future<List<Account>> getActiveAccounts() async => repository.getActiveAccounts();
  Future<List<Account>> getAccountsByType(AccountType type) async =>
      repository.getAccountsByType(type);

  Future<void> createContact(Contact contact) async => repository.createContact(contact);
  Future<Contact?> getContact(String contactId) async => repository.getContact(contactId);
  Future<List<Contact>> getAllContacts() async => repository.getAllContacts();
  Future<List<Contact>> getContactsByAccount(String accountId) async =>
      repository.getContactsByAccount(accountId);
  Future<List<Contact>> getDecisionMakers() async => repository.getDecisionMakers();

  Future<void> createLead(Lead lead) async => repository.createLead(lead);
  Future<Lead?> getLead(String leadId) async => repository.getLead(leadId);
  Future<List<Lead>> getAllLeads() async => repository.getAllLeads();
  Future<List<Lead>> getQualifiedLeads() async => repository.getQualifiedLeads();
  Future<List<Lead>> getLeadsByStatus(LeadStatus status) async =>
      repository.getLeadsByStatus(status);

  Future<void> createOpportunity(Opportunity opportunity) async =>
      repository.createOpportunity(opportunity);
  Future<Opportunity?> getOpportunity(String opportunityId) async =>
      repository.getOpportunity(opportunityId);
  Future<List<Opportunity>> getAllOpportunities() async =>
      repository.getAllOpportunities();
  Future<List<Opportunity>> getOpenOpportunities() async =>
      repository.getOpenOpportunities();
  Future<List<Opportunity>> getOverdueOpportunities() async =>
      repository.getOverdueOpportunities();

  Future<void> createActivity(Activity activity) async =>
      repository.createActivity(activity);
  Future<Activity?> getActivity(String activityId) async =>
      repository.getActivity(activityId);
  Future<List<Activity>> getActivitiesByAccount(String accountId) async =>
      repository.getActivitiesByAccount(accountId);
  Future<List<Activity>> getIncompleteActivities() async =>
      repository.getIncompleteActivities();

  Future<void> createCampaign(Campaign campaign) async =>
      repository.createCampaign(campaign);
  Future<Campaign?> getCampaign(String campaignId) async =>
      repository.getCampaign(campaignId);
  Future<List<Campaign>> getActiveCampaigns() async =>
      repository.getActiveCampaigns();
  Future<double> getTotalCampaignBudget() async =>
      repository.getTotalCampaignBudget();

  Future<void> createDeal(Deal deal) async => repository.createDeal(deal);
  Future<Deal?> getDeal(String dealId) async => repository.getDeal(dealId);
  Future<List<Deal>> getAllDeals() async => repository.getAllDeals();
  Future<List<Deal>> getWonDeals() async => repository.getWonDeals();
  Future<double> getTotalDealValue() async => repository.getTotalDealValue();

  Future<void> createForecast(Forecast forecast) async =>
      repository.createForecast(forecast);
  Future<Forecast?> getForecast(String forecastId) async =>
      repository.getForecast(forecastId);
  Future<double> getPortfolioForecast() async => repository.getPortfolioForecast();

  Future<Map<String, dynamic>> getCRMDashboard() async =>
      manager.getCRMDashboard();
}
