import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/crm_models.dart';
import 'package:project_040/services/crm_service.dart';

void main() {
  group('Phase 101: Customer Relationship Management - Enum Tests', () {
    test('AccountType enum has all required values', () {
      expect(AccountType.values.length, equals(6));
      expect(AccountType.values, contains(AccountType.enterprise));
      expect(AccountType.values, contains(AccountType.midMarket));
      expect(AccountType.values, contains(AccountType.smallBusiness));
      expect(AccountType.values, contains(AccountType.startup));
      expect(AccountType.values, contains(AccountType.nonprofit));
      expect(AccountType.values, contains(AccountType.government));
    });

    test('AccountType displayName returns Japanese translations', () {
      expect(AccountType.enterprise.displayName, contains('Enterprise'));
      expect(AccountType.midMarket.displayName, contains('Mid-Market'));
      expect(AccountType.smallBusiness.displayName, contains('Small Business'));
      expect(AccountType.startup.displayName, contains('Startup'));
      expect(AccountType.nonprofit.displayName, contains('Nonprofit'));
      expect(AccountType.government.displayName, contains('Government'));
    });

    test('ContactRole enum has all required values', () {
      expect(ContactRole.values.length, equals(6));
      expect(ContactRole.values, contains(ContactRole.decisionMaker));
      expect(ContactRole.values, contains(ContactRole.influencer));
      expect(ContactRole.values, contains(ContactRole.endUser));
      expect(ContactRole.values, contains(ContactRole.technicalBuyer));
      expect(ContactRole.values, contains(ContactRole.economicBuyer));
      expect(ContactRole.values, contains(ContactRole.sponsor));
    });

    test('OpportunityStage enum has all required values', () {
      expect(OpportunityStage.values.length, equals(8));
      expect(OpportunityStage.values, contains(OpportunityStage.prospecting));
      expect(OpportunityStage.values, contains(OpportunityStage.qualification));
      expect(OpportunityStage.values, contains(OpportunityStage.closedWon));
      expect(OpportunityStage.values, contains(OpportunityStage.closedLost));
    });

    test('ActivityType enum has all required values', () {
      expect(ActivityType.values.length, equals(8));
      expect(ActivityType.values, contains(ActivityType.call));
      expect(ActivityType.values, contains(ActivityType.email));
      expect(ActivityType.values, contains(ActivityType.meeting));
      expect(ActivityType.values, contains(ActivityType.task));
    });

    test('LeadStatus enum has all required values', () {
      expect(LeadStatus.values.length, equals(7));
      expect(LeadStatus.values, contains(LeadStatus.new_));
      expect(LeadStatus.values, contains(LeadStatus.qualified));
      expect(LeadStatus.values, contains(LeadStatus.converted));
    });

    test('CampaignStatus enum has all required values', () {
      expect(CampaignStatus.values.length, equals(5));
      expect(CampaignStatus.values, contains(CampaignStatus.planned));
      expect(CampaignStatus.values, contains(CampaignStatus.active));
      expect(CampaignStatus.values, contains(CampaignStatus.completed));
    });

    test('DealStatus enum has all required values', () {
      expect(DealStatus.values.length, equals(5));
      expect(DealStatus.values, contains(DealStatus.open));
      expect(DealStatus.values, contains(DealStatus.won));
      expect(DealStatus.values, contains(DealStatus.lost));
    });
  });

  group('Phase 101: Customer Relationship Management - Model Tests', () {
    test('Account model creates with all properties', () {
      final now = DateTime.now();
      final account = Account(
        accountId: 'acc_001',
        accountName: 'Acme Corporation',
        type: AccountType.enterprise,
        industry: 'Technology',
        annualRevenue: 50000000,
        employeeCount: 5000,
        website: 'https://acme.com',
        phone: '+1-555-0100',
        address: '123 Main St',
        city: 'New York',
        country: 'USA',
        accountOwner: 'John Doe',
        isActive: true,
        createdDate: now,
      );

      expect(account.accountId, equals('acc_001'));
      expect(account.accountName, equals('Acme Corporation'));
      expect(account.type, equals(AccountType.enterprise));
      expect(account.isActive, isTrue);
    });

    test('Account ageInDays computed property works correctly', () {
      final now = DateTime.now();
      final account = Account(
        accountId: 'acc_001',
        accountName: 'Test Account',
        type: AccountType.midMarket,
        industry: 'Finance',
        annualRevenue: 5000000,
        employeeCount: 500,
        website: 'https://example.com',
        phone: '+1-555-0101',
        address: '456 Oak St',
        city: 'Boston',
        country: 'USA',
        accountOwner: 'Jane Smith',
        isActive: true,
        createdDate: now.subtract(Duration(days: 30)),
      );

      expect(account.ageInDays, equals(30));
    });

    test('Contact model creates with all properties', () {
      final now = DateTime.now();
      final contact = Contact(
        contactId: 'con_001',
        accountId: 'acc_001',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        phone: '+1-555-0102',
        title: 'VP of Sales',
        role: ContactRole.decisionMaker,
        department: 'Sales',
        isPrimaryContact: true,
        isDecisionMaker: true,
        createdDate: now,
      );

      expect(contact.fullName, equals('John Doe'));
      expect(contact.role, equals(ContactRole.decisionMaker));
      expect(contact.isDecisionMaker, isTrue);
    });

    test('Lead model creates with all properties', () {
      final now = DateTime.now();
      final lead = Lead(
        leadId: 'lead_001',
        companyName: 'StartUp Inc',
        contactName: 'Alice Johnson',
        email: 'alice@startup.com',
        phone: '+1-555-0103',
        status: LeadStatus.qualified,
        source: 'LinkedIn',
        industry: 'SaaS',
        estimatedBudget: 250000,
        leadOwner: 'Bob Wilson',
        createdDate: now,
      );

      expect(lead.leadId, equals('lead_001'));
      expect(lead.isQualified, isTrue);
      expect(lead.estimatedBudget, equals(250000));
    });

    test('Lead isConverted property works correctly', () {
      final now = DateTime.now();
      final convertedLead = Lead(
        leadId: 'lead_002',
        companyName: 'Converted Inc',
        contactName: 'Charlie Brown',
        email: 'charlie@converted.com',
        phone: '+1-555-0104',
        status: LeadStatus.converted,
        source: 'Referral',
        industry: 'Retail',
        leadOwner: 'David Lee',
        createdDate: now,
        convertedDate: now,
      );

      expect(convertedLead.isConverted, isTrue);
    });

    test('Opportunity model creates with all properties', () {
      final now = DateTime.now();
      final opp = Opportunity(
        opportunityId: 'opp_001',
        accountId: 'acc_001',
        contactId: 'con_001',
        opportunityName: 'Enterprise Deal',
        amount: 500000,
        stage: OpportunityStage.proposalAndPricing,
        closeDate: now.add(Duration(days: 30)),
        probability: 0.75,
        description: 'Large enterprise software deal',
        owner: 'Sales Rep',
        createdDate: now,
      );

      expect(opp.opportunityId, equals('opp_001'));
      expect(opp.stage, equals(OpportunityStage.proposalAndPricing));
      expect(opp.probability, equals(0.75));
    });

    test('Opportunity expectedValue computed property works correctly', () {
      final now = DateTime.now();
      final opp = Opportunity(
        opportunityId: 'opp_002',
        accountId: 'acc_001',
        contactId: 'con_001',
        opportunityName: 'Test Opportunity',
        amount: 100000,
        stage: OpportunityStage.qualification,
        closeDate: now.add(Duration(days: 15)),
        probability: 0.5,
        description: 'Test',
        owner: 'Sales Rep',
        createdDate: now,
      );

      expect(opp.expectedValue, equals(50000));
    });

    test('Activity model creates with all properties', () {
      final now = DateTime.now();
      final activity = Activity(
        activityId: 'act_001',
        accountId: 'acc_001',
        contactId: 'con_001',
        type: ActivityType.meeting,
        subject: 'Quarterly Review',
        description: 'Discuss Q4 goals',
        activityDate: now,
        participant: 'Sales Manager',
        isCompleted: true,
      );

      expect(activity.activityId, equals('act_001'));
      expect(activity.type, equals(ActivityType.meeting));
      expect(activity.isCompleted, isTrue);
    });

    test('Campaign model creates with all properties', () {
      final now = DateTime.now();
      final campaign = Campaign(
        campaignId: 'camp_001',
        campaignName: 'Summer Promotion',
        status: CampaignStatus.active,
        type: 'Email Marketing',
        startDate: now,
        endDate: now.add(Duration(days: 30)),
        budget: 50000,
        spentAmount: 25000,
        targetAudience: 10000,
        actualResponses: 500,
        owner: 'Marketing Manager',
      );

      expect(campaign.campaignId, equals('camp_001'));
      expect(campaign.isActive, isTrue);
      expect(campaign.spendPercent, equals(50.0));
    });

    test('Campaign responseRate computed property works correctly', () {
      final now = DateTime.now();
      final campaign = Campaign(
        campaignId: 'camp_002',
        campaignName: 'Test Campaign',
        status: CampaignStatus.planned,
        type: 'Social Media',
        startDate: now,
        budget: 20000,
        targetAudience: 1000,
        actualResponses: 100,
        owner: 'Manager',
      );

      expect(campaign.responseRate, equals(10.0));
    });

    test('Deal model creates with all properties', () {
      final now = DateTime.now();
      final deal = Deal(
        dealId: 'deal_001',
        opportunityId: 'opp_001',
        accountId: 'acc_001',
        dealName: 'Finalized Deal',
        dealValue: 450000,
        status: DealStatus.won,
        expectedCloseDate: now,
        actualCloseDate: now,
        owner: 'Sales Rep',
        closingReason: 'Successfully negotiated',
        createdDate: now.subtract(Duration(days: 45)),
      );

      expect(deal.dealId, equals('deal_001'));
      expect(deal.isWon, isTrue);
      expect(deal.isClosed, isTrue);
    });

    test('Deal cycleLength computed property works correctly', () {
      final now = DateTime.now();
      final deal = Deal(
        dealId: 'deal_002',
        opportunityId: 'opp_002',
        accountId: 'acc_002',
        dealName: 'Test Deal',
        dealValue: 100000,
        status: DealStatus.won,
        expectedCloseDate: now,
        actualCloseDate: now,
        owner: 'Rep',
        createdDate: now.subtract(Duration(days: 60)),
      );

      expect(deal.cycleLength, equals(60));
    });

    test('Forecast model creates with all properties', () {
      final now = DateTime.now();
      final forecast = Forecast(
        forecastId: 'fc_001',
        owner: 'Sales Manager',
        forecastDate: now,
        month: 9,
        year: 2026,
        pipelineValue: 2000000,
        bestCaseValue: 2500000,
        mostLikelyValue: 2000000,
        worstCaseValue: 1500000,
        opportunityCount: 15,
        closedWonCount: 12,
      );

      expect(forecast.forecastId, equals('fc_001'));
      expect(forecast.month, equals(9));
      expect(forecast.year, equals(2026));
    });

    test('Forecast averageValue computed property works correctly', () {
      final now = DateTime.now();
      final forecast = Forecast(
        forecastId: 'fc_002',
        owner: 'Manager',
        forecastDate: now,
        month: 8,
        year: 2026,
        pipelineValue: 1000000,
        bestCaseValue: 1200000,
        mostLikelyValue: 1000000,
        worstCaseValue: 800000,
        opportunityCount: 10,
        closedWonCount: 8,
      );

      expect(forecast.averageValue, equals(1000000));
    });

    test('SalesMetrics model creates with all properties', () {
      final now = DateTime.now();
      final metrics = SalesMetrics(
        metricsId: 'met_001',
        reportDate: now,
        totalPipelineValue: 5000000,
        totalRevenueWon: 4000000,
        averageDealSize: 250000,
        winRate: 75.0,
        totalOpportunitiesCount: 20,
        closedWonCount: 15,
        salesCycleLength: 45,
        performanceByOwner: {'Rep1': 500000, 'Rep2': 450000},
      );

      expect(metrics.metricsId, equals('met_001'));
      expect(metrics.winRate, equals(75.0));
    });

    test('Model copyWith immutability pattern works', () {
      final now = DateTime.now();
      final original = Account(
        accountId: 'acc_001',
        accountName: 'Original',
        type: AccountType.midMarket,
        industry: 'Tech',
        annualRevenue: 1000000,
        employeeCount: 100,
        website: 'https://original.com',
        phone: '+1-555-0105',
        address: '789 Elm St',
        city: 'Chicago',
        country: 'USA',
        accountOwner: 'Owner',
        isActive: true,
        createdDate: now,
      );

      final updated = original.copyWith(
        accountName: 'Updated',
        type: AccountType.enterprise,
      );

      expect(original.accountName, equals('Original'));
      expect(updated.accountName, equals('Updated'));
      expect(updated.type, equals(AccountType.enterprise));
    });
  });

  group('Phase 101: Customer Relationship Management - Repository Tests', () {
    late InMemoryCRMRepository repository;

    setUp(() {
      repository = InMemoryCRMRepository();
    });

    test('Repository creates and retrieves Account', () async {
      final now = DateTime.now();
      final account = Account(
        accountId: 'acc_001',
        accountName: 'Test Account',
        type: AccountType.enterprise,
        industry: 'Tech',
        annualRevenue: 10000000,
        employeeCount: 1000,
        website: 'https://test.com',
        phone: '+1-555-0106',
        address: '100 Test Ave',
        city: 'Seattle',
        country: 'USA',
        accountOwner: 'Owner',
        isActive: true,
        createdDate: now,
      );

      await repository.createAccount(account);
      final retrieved = await repository.getAccount('acc_001');

      expect(retrieved, isNotNull);
      expect(retrieved?.accountName, equals('Test Account'));
    });

    test('Repository gets all accounts', () async {
      final now = DateTime.now();
      for (int i = 0; i < 3; i++) {
        await repository.createAccount(Account(
          accountId: 'acc_$i',
          accountName: 'Account $i',
          type: AccountType.midMarket,
          industry: 'Finance',
          annualRevenue: 5000000,
          employeeCount: 500,
          website: 'https://account$i.com',
          phone: '+1-555-010$i',
          address: '200 Test Ave',
          city: 'Boston',
          country: 'USA',
          accountOwner: 'Owner',
          isActive: true,
          createdDate: now,
        ));
      }

      final all = await repository.getAllAccounts();
      expect(all.length, equals(3));
    });

    test('Repository filters accounts by type', () async {
      final now = DateTime.now();
      final enterprise = Account(
        accountId: 'acc_ent',
        accountName: 'Enterprise Co',
        type: AccountType.enterprise,
        industry: 'Tech',
        annualRevenue: 50000000,
        employeeCount: 5000,
        website: 'https://enterprise.com',
        phone: '+1-555-0200',
        address: '300 Enterprise Blvd',
        city: 'San Francisco',
        country: 'USA',
        accountOwner: 'Enterprise Owner',
        isActive: true,
        createdDate: now,
      );

      final small = Account(
        accountId: 'acc_small',
        accountName: 'Small Co',
        type: AccountType.smallBusiness,
        industry: 'Retail',
        annualRevenue: 500000,
        employeeCount: 50,
        website: 'https://small.com',
        phone: '+1-555-0201',
        address: '400 Small St',
        city: 'Portland',
        country: 'USA',
        accountOwner: 'Small Owner',
        isActive: true,
        createdDate: now,
      );

      await repository.createAccount(enterprise);
      await repository.createAccount(small);

      final enterprises = await repository.getAccountsByType(AccountType.enterprise);
      expect(enterprises.length, equals(1));
      expect(enterprises.first.accountName, equals('Enterprise Co'));
    });

    test('Repository creates and retrieves Contact', () async {
      final now = DateTime.now();
      final contact = Contact(
        contactId: 'con_001',
        accountId: 'acc_001',
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane@example.com',
        phone: '+1-555-0300',
        title: 'CEO',
        role: ContactRole.decisionMaker,
        department: 'Executive',
        isPrimaryContact: true,
        isDecisionMaker: true,
        createdDate: now,
      );

      await repository.createContact(contact);
      final retrieved = await repository.getContact('con_001');

      expect(retrieved, isNotNull);
      expect(retrieved?.fullName, equals('Jane Smith'));
    });

    test('Repository creates and retrieves Lead', () async {
      final now = DateTime.now();
      final lead = Lead(
        leadId: 'lead_001',
        companyName: 'New Company',
        contactName: 'Bob Jackson',
        email: 'bob@newcompany.com',
        phone: '+1-555-0400',
        status: LeadStatus.qualified,
        source: 'Web',
        industry: 'Manufacturing',
        estimatedBudget: 500000,
        leadOwner: 'Sales Rep',
        createdDate: now,
      );

      await repository.createLead(lead);
      final retrieved = await repository.getLead('lead_001');

      expect(retrieved, isNotNull);
      expect(retrieved?.isQualified, isTrue);
    });

    test('Repository creates and retrieves Opportunity', () async {
      final now = DateTime.now();
      final opp = Opportunity(
        opportunityId: 'opp_001',
        accountId: 'acc_001',
        contactId: 'con_001',
        opportunityName: 'Large Deal',
        amount: 1000000,
        stage: OpportunityStage.negotiation,
        closeDate: now.add(Duration(days: 20)),
        probability: 0.8,
        description: 'Strategic deal',
        owner: 'Top Rep',
        createdDate: now,
      );

      await repository.createOpportunity(opp);
      final retrieved = await repository.getOpportunity('opp_001');

      expect(retrieved, isNotNull);
      expect(retrieved?.amount, equals(1000000));
    });

    test('Repository gets pipeline value', () async {
      final now = DateTime.now();
      for (int i = 0; i < 2; i++) {
        await repository.createOpportunity(Opportunity(
          opportunityId: 'opp_$i',
          accountId: 'acc_001',
          contactId: 'con_001',
          opportunityName: 'Opp $i',
          amount: 500000,
          stage: OpportunityStage.prospecting,
          closeDate: now.add(Duration(days: 30)),
          probability: 0.5,
          description: 'Test',
          owner: 'Rep',
          createdDate: now,
        ));
      }

      final total = await repository.getTotalPipelineValue();
      expect(total, equals(1000000));
    });

    test('Repository creates and retrieves Activity', () async {
      final now = DateTime.now();
      final activity = Activity(
        activityId: 'act_001',
        accountId: 'acc_001',
        type: ActivityType.call,
        subject: 'Sales Call',
        description: 'Discuss pricing',
        activityDate: now,
        isCompleted: false,
      );

      await repository.createActivity(activity);
      final retrieved = await repository.getActivity('act_001');

      expect(retrieved, isNotNull);
      expect(retrieved?.type, equals(ActivityType.call));
    });

    test('Repository creates and retrieves Campaign', () async {
      final now = DateTime.now();
      final campaign = Campaign(
        campaignId: 'camp_001',
        campaignName: 'Holiday Sale',
        status: CampaignStatus.active,
        type: 'Email',
        startDate: now,
        budget: 100000,
        spentAmount: 50000,
        targetAudience: 50000,
        actualResponses: 5000,
        owner: 'Marketing',
      );

      await repository.createCampaign(campaign);
      final retrieved = await repository.getCampaign('camp_001');

      expect(retrieved, isNotNull);
      expect(retrieved?.status, equals(CampaignStatus.active));
    });

    test('Repository creates and retrieves Deal', () async {
      final now = DateTime.now();
      final deal = Deal(
        dealId: 'deal_001',
        opportunityId: 'opp_001',
        accountId: 'acc_001',
        dealName: 'Major Contract',
        dealValue: 2000000,
        status: DealStatus.inProgress,
        expectedCloseDate: now.add(Duration(days: 10)),
        owner: 'Sales VP',
        createdDate: now,
      );

      await repository.createDeal(deal);
      final retrieved = await repository.getDeal('deal_001');

      expect(retrieved, isNotNull);
      expect(retrieved?.dealValue, equals(2000000));
    });

    test('Repository creates and retrieves Forecast', () async {
      final now = DateTime.now();
      final forecast = Forecast(
        forecastId: 'fc_001',
        owner: 'Sales Manager',
        forecastDate: now,
        month: 9,
        year: 2026,
        pipelineValue: 5000000,
        bestCaseValue: 6000000,
        mostLikelyValue: 5000000,
        worstCaseValue: 4000000,
        opportunityCount: 20,
        closedWonCount: 16,
      );

      await repository.createForecast(forecast);
      final retrieved = await repository.getForecast('fc_001');

      expect(retrieved, isNotNull);
      expect(retrieved?.mostLikelyValue, equals(5000000));
    });

    test('Repository records and retrieves SalesMetrics', () async {
      final now = DateTime.now();
      final metrics = SalesMetrics(
        metricsId: 'met_001',
        reportDate: now,
        totalPipelineValue: 10000000,
        totalRevenueWon: 8000000,
        averageDealSize: 500000,
        winRate: 80.0,
        totalOpportunitiesCount: 16,
        closedWonCount: 13,
        salesCycleLength: 45,
        performanceByOwner: {'Rep1': 3000000, 'Rep2': 2500000},
      );

      await repository.recordMetrics(metrics);
      final retrieved = await repository.getLatestMetrics();

      expect(retrieved, isNotNull);
      expect(retrieved?.winRate, equals(80.0));
    });

    test('Repository counts total deals', () async {
      final now = DateTime.now();
      for (int i = 0; i < 5; i++) {
        await repository.createDeal(Deal(
          dealId: 'deal_$i',
          opportunityId: 'opp_$i',
          accountId: 'acc_001',
          dealName: 'Deal $i',
          dealValue: 100000,
          status: DealStatus.open,
          expectedCloseDate: now.add(Duration(days: 15)),
          owner: 'Rep',
          createdDate: now,
        ));
      }

      final count = await repository.getDealCount();
      expect(count, equals(5));
    });
  });

  group('Phase 101: Customer Relationship Management - Engine Tests', () {
    test('SalesEngine calculates expectedValue correctly', () {
      final engine = SalesEngine();
      final opp = Opportunity(
        opportunityId: 'opp_001',
        accountId: 'acc_001',
        contactId: 'con_001',
        opportunityName: 'Test',
        amount: 1000000,
        stage: OpportunityStage.prospecting,
        closeDate: DateTime.now(),
        probability: 0.6,
        description: 'Test',
        owner: 'Rep',
        createdDate: DateTime.now(),
      );

      final expected = engine.calculateExpectedValue(opp);
      expect(expected, equals(600000));
    });

    test('SalesEngine calculates win probability correctly', () {
      final engine = SalesEngine();
      final opportunities = [
        Opportunity(
          opportunityId: 'opp_001',
          accountId: 'acc_001',
          contactId: 'con_001',
          opportunityName: 'Opp 1',
          amount: 100000,
          stage: OpportunityStage.prospecting,
          closeDate: DateTime.now(),
          probability: 0.5,
          description: 'Test',
          owner: 'Rep',
          createdDate: DateTime.now(),
        ),
        Opportunity(
          opportunityId: 'opp_002',
          accountId: 'acc_001',
          contactId: 'con_001',
          opportunityName: 'Opp 2',
          amount: 100000,
          stage: OpportunityStage.prospecting,
          closeDate: DateTime.now(),
          probability: 0.8,
          description: 'Test',
          owner: 'Rep',
          createdDate: DateTime.now(),
        ),
      ];

      final probability = engine.calculateWinProbability(opportunities);
      expect(probability, equals(65.0)); // (0.5 + 0.8) / 2 * 100
    });

    test('CustomerSegmentationEngine segments by revenue', () {
      final engine = CustomerSegmentationEngine();
      final accounts = [
        Account(
          accountId: 'acc_1',
          accountName: 'Large',
          type: AccountType.enterprise,
          industry: 'Tech',
          annualRevenue: 50000000,
          employeeCount: 5000,
          website: 'https://large.com',
          phone: '+1-555-1000',
          address: 'Large St',
          city: 'City1',
          country: 'USA',
          accountOwner: 'Owner1',
          isActive: true,
          createdDate: DateTime.now(),
        ),
        Account(
          accountId: 'acc_2',
          accountName: 'Small',
          type: AccountType.smallBusiness,
          industry: 'Retail',
          annualRevenue: 500000,
          employeeCount: 50,
          website: 'https://small.com',
          phone: '+1-555-1001',
          address: 'Small St',
          city: 'City2',
          country: 'USA',
          accountOwner: 'Owner2',
          isActive: true,
          createdDate: DateTime.now(),
        ),
      ];

      final segments = engine.segmentByRevenue(accounts);
      expect(segments['Enterprise']?.length, equals(1));
      expect(segments['SmallBusiness']?.length, equals(1));
    });

    test('ForecastingEngine generates accurate forecast', () {
      final engine = ForecastingEngine();
      final opportunities = [
        Opportunity(
          opportunityId: 'opp_1',
          accountId: 'acc_001',
          contactId: 'con_001',
          opportunityName: 'Opp 1',
          amount: 100000,
          stage: OpportunityStage.prospecting,
          closeDate: DateTime.now(),
          probability: 0.5,
          description: 'Test',
          owner: 'Rep1',
          createdDate: DateTime.now(),
        ),
        Opportunity(
          opportunityId: 'opp_2',
          accountId: 'acc_001',
          contactId: 'con_001',
          opportunityName: 'Opp 2',
          amount: 200000,
          stage: OpportunityStage.prospecting,
          closeDate: DateTime.now(),
          probability: 0.8,
          description: 'Test',
          owner: 'Rep2',
          createdDate: DateTime.now(),
        ),
      ];

      final forecast = engine.generateForecast(opportunities);
      expect(forecast, equals(210000)); // (100000 * 0.5) + (200000 * 0.8)
    });
  });

  group('Phase 101: Customer Relationship Management - Manager Tests', () {
    test('CRMManager gets dashboard', () async {
      final repository = InMemoryCRMRepository();
      final manager = CRMManager(repository);

      final now = DateTime.now();
      await repository.createAccount(Account(
        accountId: 'acc_001',
        accountName: 'Test',
        type: AccountType.enterprise,
        industry: 'Tech',
        annualRevenue: 10000000,
        employeeCount: 1000,
        website: 'https://test.com',
        phone: '+1-555-2000',
        address: 'Test Ave',
        city: 'City',
        country: 'USA',
        accountOwner: 'Owner',
        isActive: true,
        createdDate: now,
      ));

      final dashboard = await manager.getCRMDashboard();

      expect(dashboard, isNotNull);
      expect(dashboard['totalAccounts'], equals(1));
      expect(dashboard.containsKey('totalPipelineValue'), isTrue);
    });

    test('CRMManager orchestrates all engines', () {
      final repository = InMemoryCRMRepository();
      final manager = CRMManager(repository);

      expect(manager.salesEngine, isNotNull);
      expect(manager.segmentationEngine, isNotNull);
      expect(manager.forecastingEngine, isNotNull);
    });
  });

  group('Phase 101: Customer Relationship Management - Facade Tests', () {
    late CRMFacade facade;

    setUp(() {
      facade = CRMFacade(InMemoryCRMRepository());
    });

    test('Facade creates account', () async {
      final now = DateTime.now();
      final account = Account(
        accountId: 'acc_001',
        accountName: 'Facade Test',
        type: AccountType.midMarket,
        industry: 'Tech',
        annualRevenue: 5000000,
        employeeCount: 500,
        website: 'https://facade.com',
        phone: '+1-555-3000',
        address: 'Facade Ave',
        city: 'City',
        country: 'USA',
        accountOwner: 'Owner',
        isActive: true,
        createdDate: now,
      );

      await facade.createAccount(account);
      final retrieved = await facade.getAccount('acc_001');

      expect(retrieved?.accountName, equals('Facade Test'));
    });

    test('Facade gets active accounts', () async {
      final now = DateTime.now();
      await facade.createAccount(Account(
        accountId: 'acc_active',
        accountName: 'Active',
        type: AccountType.enterprise,
        industry: 'Tech',
        annualRevenue: 50000000,
        employeeCount: 5000,
        website: 'https://active.com',
        phone: '+1-555-3001',
        address: 'Active Ave',
        city: 'City',
        country: 'USA',
        accountOwner: 'Owner',
        isActive: true,
        createdDate: now,
      ));

      final active = await facade.getActiveAccounts();
      expect(active.length, equals(1));
    });

    test('Facade creates and manages opportunities', () async {
      final now = DateTime.now();
      final opp = Opportunity(
        opportunityId: 'opp_001',
        accountId: 'acc_001',
        contactId: 'con_001',
        opportunityName: 'Facade Opportunity',
        amount: 500000,
        stage: OpportunityStage.qualification,
        closeDate: now.add(Duration(days: 30)),
        probability: 0.6,
        description: 'Test opportunity',
        owner: 'Rep',
        createdDate: now,
      );

      await facade.createOpportunity(opp);
      final retrieved = await facade.getOpportunity('opp_001');

      expect(retrieved?.opportunityName, equals('Facade Opportunity'));
    });

    test('Facade gets open opportunities', () async {
      final now = DateTime.now();
      final openOpp = Opportunity(
        opportunityId: 'opp_open',
        accountId: 'acc_001',
        contactId: 'con_001',
        opportunityName: 'Open Deal',
        amount: 300000,
        stage: OpportunityStage.needsAnalysis,
        closeDate: now.add(Duration(days: 20)),
        probability: 0.5,
        description: 'Open',
        owner: 'Rep',
        createdDate: now,
      );

      await facade.createOpportunity(openOpp);

      final open = await facade.getOpenOpportunities();
      expect(open.length, equals(1));
    });

    test('Facade gets CRM dashboard', () async {
      final now = DateTime.now();
      await facade.createAccount(Account(
        accountId: 'acc_dash',
        accountName: 'Dashboard Test',
        type: AccountType.enterprise,
        industry: 'Tech',
        annualRevenue: 25000000,
        employeeCount: 2500,
        website: 'https://dash.com',
        phone: '+1-555-3002',
        address: 'Dash Ave',
        city: 'City',
        country: 'USA',
        accountOwner: 'Owner',
        isActive: true,
        createdDate: now,
      ));

      final dashboard = await facade.getCRMDashboard();

      expect(dashboard, isNotNull);
      expect(dashboard['totalAccounts'], equals(1));
      expect(dashboard.containsKey('totalPipelineValue'), isTrue);
    });
  });

  group('Phase 101: Customer Relationship Management - Integration Tests', () {
    test('Complete sales workflow: Lead to Deal', () async {
      final repository = InMemoryCRMRepository();
      final facade = CRMFacade(repository);
      final now = DateTime.now();

      // Create Lead
      final lead = Lead(
        leadId: 'lead_001',
        companyName: 'Integration Test Co',
        contactName: 'Integration Lead',
        email: 'lead@integration.com',
        phone: '+1-555-4000',
        status: LeadStatus.new_,
        source: 'Website',
        industry: 'Technology',
        estimatedBudget: 500000,
        leadOwner: 'Sales Rep',
        createdDate: now,
      );
      await facade.createLead(lead);

      // Create Account
      final account = Account(
        accountId: 'acc_integration',
        accountName: 'Integration Test Co',
        type: AccountType.midMarket,
        industry: 'Technology',
        annualRevenue: 5000000,
        employeeCount: 500,
        website: 'https://integration.com',
        phone: '+1-555-4000',
        address: 'Integration St',
        city: 'Integration City',
        country: 'USA',
        accountOwner: 'Account Owner',
        isActive: true,
        createdDate: now,
      );
      await facade.createAccount(account);

      // Create Contact
      final contact = Contact(
        contactId: 'con_integration',
        accountId: 'acc_integration',
        firstName: 'Integration',
        lastName: 'Contact',
        email: 'contact@integration.com',
        phone: '+1-555-4000',
        title: 'VP Sales',
        role: ContactRole.decisionMaker,
        department: 'Sales',
        isPrimaryContact: true,
        isDecisionMaker: true,
        createdDate: now,
      );
      await facade.createContact(contact);

      // Create Opportunity
      final opp = Opportunity(
        opportunityId: 'opp_integration',
        accountId: 'acc_integration',
        contactId: 'con_integration',
        opportunityName: 'Integration Deal',
        amount: 500000,
        stage: OpportunityStage.proposalAndPricing,
        closeDate: now.add(Duration(days: 30)),
        probability: 0.75,
        description: 'Integration workflow deal',
        owner: 'Sales Rep',
        createdDate: now,
      );
      await facade.createOpportunity(opp);

      // Create Deal
      final deal = Deal(
        dealId: 'deal_integration',
        opportunityId: 'opp_integration',
        accountId: 'acc_integration',
        dealName: 'Integration Deal Closed',
        dealValue: 500000,
        status: DealStatus.won,
        expectedCloseDate: now,
        actualCloseDate: now,
        owner: 'Sales Rep',
        closingReason: 'Successfully completed',
        createdDate: now,
      );
      await facade.createDeal(deal);

      // Verify workflow
      final retrievedLead = await facade.getLead('lead_001');
      final retrievedAccount = await facade.getAccount('acc_integration');
      final retrievedOpp = await facade.getOpportunity('opp_integration');
      final retrievedDeal = await facade.getDeal('deal_integration');

      expect(retrievedLead, isNotNull);
      expect(retrievedAccount, isNotNull);
      expect(retrievedOpp?.expectedValue, equals(375000));
      expect(retrievedDeal?.isWon, isTrue);
    });

    test('Campaign tracking workflow', () async {
      final repository = InMemoryCRMRepository();
      final facade = CRMFacade(repository);
      final now = DateTime.now();

      // Create Campaign
      final campaign = Campaign(
        campaignId: 'camp_workflow',
        campaignName: 'Integration Campaign',
        status: CampaignStatus.active,
        type: 'Email Marketing',
        startDate: now,
        endDate: now.add(Duration(days: 30)),
        budget: 50000,
        spentAmount: 25000,
        targetAudience: 10000,
        actualResponses: 1000,
        owner: 'Marketing Manager',
      );
      await facade.createCampaign(campaign);

      // Create Activities related to campaign
      final activity = Activity(
        activityId: 'act_campaign',
        accountId: 'acc_001',
        type: ActivityType.campaign,
        subject: 'Campaign Execution',
        description: 'Execute integration campaign',
        activityDate: now,
        isCompleted: true,
      );
      await facade.createActivity(activity);

      // Verify campaign workflow
      final campaign_retrieved = await facade.getCampaign('camp_workflow');
      final activity_retrieved = await facade.getActivity('act_campaign');

      expect(campaign_retrieved?.responseRate, equals(10.0));
      expect(activity_retrieved?.type, equals(ActivityType.campaign));
    });

    test('Forecast and metrics tracking workflow', () async {
      final repository = InMemoryCRMRepository();
      final facade = CRMFacade(repository);
      final now = DateTime.now();

      // Create multiple opportunities
      for (int i = 0; i < 3; i++) {
        await facade.createOpportunity(Opportunity(
          opportunityId: 'opp_forecast_$i',
          accountId: 'acc_001',
          contactId: 'con_001',
          opportunityName: 'Forecast Opp $i',
          amount: 100000,
          stage: OpportunityStage.qualification,
          closeDate: now.add(Duration(days: 30)),
          probability: 0.5 + (i * 0.1),
          description: 'Forecast test',
          owner: 'Rep',
          createdDate: now,
        ));
      }

      // Create Forecast
      final forecast = Forecast(
        forecastId: 'fc_workflow',
        owner: 'Sales Manager',
        forecastDate: now,
        month: 9,
        year: 2026,
        pipelineValue: 300000,
        bestCaseValue: 400000,
        mostLikelyValue: 300000,
        worstCaseValue: 200000,
        opportunityCount: 3,
        closedWonCount: 2,
      );
      await facade.createForecast(forecast);

      // Create Metrics
      final metrics = SalesMetrics(
        metricsId: 'met_workflow',
        reportDate: now,
        totalPipelineValue: 300000,
        totalRevenueWon: 200000,
        averageDealSize: 100000,
        winRate: 66.67,
        totalOpportunitiesCount: 3,
        closedWonCount: 2,
        salesCycleLength: 45,
        performanceByOwner: {'Rep': 300000},
      );

      // Verify forecast workflow
      final fc_retrieved = await facade.getForecast('fc_workflow');
      expect(fc_retrieved?.opportunityCount, equals(3));
      expect(fc_retrieved?.averageValue, equals(300000));
    });
  });
}
