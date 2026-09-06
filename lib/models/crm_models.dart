// ignore_for_file: constant_identifier_names

enum AccountType {
  enterprise,
  midMarket,
  smallBusiness,
  startup,
  nonprofit,
  government;

  String get displayName {
    switch (this) {
      case AccountType.enterprise:
        return 'Enterprise (エンタープライズ)';
      case AccountType.midMarket:
        return 'Mid-Market (中堅企業)';
      case AccountType.smallBusiness:
        return 'Small Business (中小企業)';
      case AccountType.startup:
        return 'Startup (スタートアップ)';
      case AccountType.nonprofit:
        return 'Nonprofit (非営利団体)';
      case AccountType.government:
        return 'Government (政府機関)';
    }
  }
}

enum ContactRole {
  decisionMaker,
  influencer,
  endUser,
  technicalBuyer,
  economicBuyer,
  sponsor;

  String get displayName {
    switch (this) {
      case ContactRole.decisionMaker:
        return 'Decision Maker (決定者)';
      case ContactRole.influencer:
        return 'Influencer (影響力のある人)';
      case ContactRole.endUser:
        return 'End User (エンドユーザー)';
      case ContactRole.technicalBuyer:
        return 'Technical Buyer (技術購買者)';
      case ContactRole.economicBuyer:
        return 'Economic Buyer (経済購買者)';
      case ContactRole.sponsor:
        return 'Sponsor (スポンサー)';
    }
  }
}

enum OpportunityStage {
  prospecting,
  qualification,
  needsAnalysis,
  proposalAndPricing,
  negotiation,
  closed,
  closedWon,
  closedLost;

  String get displayName {
    switch (this) {
      case OpportunityStage.prospecting:
        return 'Prospecting (見込み客探索)';
      case OpportunityStage.qualification:
        return 'Qualification (適格性審査)';
      case OpportunityStage.needsAnalysis:
        return 'Needs Analysis (ニーズ分析)';
      case OpportunityStage.proposalAndPricing:
        return 'Proposal & Pricing (提案・価格設定)';
      case OpportunityStage.negotiation:
        return 'Negotiation (交渉)';
      case OpportunityStage.closed:
        return 'Closed (クローズ)';
      case OpportunityStage.closedWon:
        return 'Closed Won (受注)';
      case OpportunityStage.closedLost:
        return 'Closed Lost (失注)';
    }
  }
}

enum ActivityType {
  call,
  email,
  meeting,
  task,
  note,
  campaign,
  webinar,
  proposal;

  String get displayName {
    switch (this) {
      case ActivityType.call:
        return 'Call (通話)';
      case ActivityType.email:
        return 'Email (メール)';
      case ActivityType.meeting:
        return 'Meeting (会議)';
      case ActivityType.task:
        return 'Task (タスク)';
      case ActivityType.note:
        return 'Note (メモ)';
      case ActivityType.campaign:
        return 'Campaign (キャンペーン)';
      case ActivityType.webinar:
        return 'Webinar (ウェビナー)';
      case ActivityType.proposal:
        return 'Proposal (提案)';
    }
  }
}

enum LeadStatus {
  new_,
  contacted,
  qualified,
  unqualified,
  nurturing,
  converted,
  dead;

  String get displayName {
    switch (this) {
      case LeadStatus.new_:
        return 'New (新規)';
      case LeadStatus.contacted:
        return 'Contacted (接触済)';
      case LeadStatus.qualified:
        return 'Qualified (適格)';
      case LeadStatus.unqualified:
        return 'Unqualified (不適格)';
      case LeadStatus.nurturing:
        return 'Nurturing (育成中)';
      case LeadStatus.converted:
        return 'Converted (変換済)';
      case LeadStatus.dead:
        return 'Dead (終了)';
    }
  }
}

enum CampaignStatus {
  planned,
  active,
  paused,
  completed,
  archived;

  String get displayName {
    switch (this) {
      case CampaignStatus.planned:
        return 'Planned (計画)';
      case CampaignStatus.active:
        return 'Active (実行中)';
      case CampaignStatus.paused:
        return 'Paused (一時停止)';
      case CampaignStatus.completed:
        return 'Completed (完了)';
      case CampaignStatus.archived:
        return 'Archived (アーカイブ)';
    }
  }
}

enum DealStatus {
  open,
  inProgress,
  stalled,
  won,
  lost;

  String get displayName {
    switch (this) {
      case DealStatus.open:
        return 'Open (オープン)';
      case DealStatus.inProgress:
        return 'In Progress (進行中)';
      case DealStatus.stalled:
        return 'Stalled (停滞)';
      case DealStatus.won:
        return 'Won (受注)';
      case DealStatus.lost:
        return 'Lost (失注)';
    }
  }
}

class Account {
  final String accountId;
  final String accountName;
  final AccountType type;
  final String industry;
  final double annualRevenue;
  final int employeeCount;
  final String website;
  final String phone;
  final String address;
  final String city;
  final String country;
  final String? parentAccountId;
  final String accountOwner;
  final bool isActive;
  final DateTime createdDate;
  final DateTime? lastActivityDate;

  Account({
    required this.accountId,
    required this.accountName,
    required this.type,
    required this.industry,
    required this.annualRevenue,
    required this.employeeCount,
    required this.website,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
    this.parentAccountId,
    required this.accountOwner,
    required this.isActive,
    required this.createdDate,
    this.lastActivityDate,
  });

  int get ageInDays => DateTime.now().difference(createdDate).inDays;
  bool get hasActivity => lastActivityDate != null;
  int get daysSinceLastActivity =>
      lastActivityDate == null ? 0 : DateTime.now().difference(lastActivityDate!).inDays;

  Account copyWith({
    String? accountId,
    String? accountName,
    AccountType? type,
    String? industry,
    double? annualRevenue,
    int? employeeCount,
    String? website,
    String? phone,
    String? address,
    String? city,
    String? country,
    String? parentAccountId,
    String? accountOwner,
    bool? isActive,
    DateTime? createdDate,
    DateTime? lastActivityDate,
  }) {
    return Account(
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      type: type ?? this.type,
      industry: industry ?? this.industry,
      annualRevenue: annualRevenue ?? this.annualRevenue,
      employeeCount: employeeCount ?? this.employeeCount,
      website: website ?? this.website,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      parentAccountId: parentAccountId ?? this.parentAccountId,
      accountOwner: accountOwner ?? this.accountOwner,
      isActive: isActive ?? this.isActive,
      createdDate: createdDate ?? this.createdDate,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }
}

class Contact {
  final String contactId;
  final String accountId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String title;
  final ContactRole role;
  final String department;
  final bool isPrimaryContact;
  final bool isDecisionMaker;
  final DateTime createdDate;
  final DateTime? lastModified;

  Contact({
    required this.contactId,
    required this.accountId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.title,
    required this.role,
    required this.department,
    required this.isPrimaryContact,
    required this.isDecisionMaker,
    required this.createdDate,
    this.lastModified,
  });

  String get fullName => '$firstName $lastName';
  int get ageInDays => DateTime.now().difference(createdDate).inDays;

  Contact copyWith({
    String? contactId,
    String? accountId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? title,
    ContactRole? role,
    String? department,
    bool? isPrimaryContact,
    bool? isDecisionMaker,
    DateTime? createdDate,
    DateTime? lastModified,
  }) {
    return Contact(
      contactId: contactId ?? this.contactId,
      accountId: accountId ?? this.accountId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      title: title ?? this.title,
      role: role ?? this.role,
      department: department ?? this.department,
      isPrimaryContact: isPrimaryContact ?? this.isPrimaryContact,
      isDecisionMaker: isDecisionMaker ?? this.isDecisionMaker,
      createdDate: createdDate ?? this.createdDate,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}

class Lead {
  final String leadId;
  final String companyName;
  final String contactName;
  final String email;
  final String phone;
  final LeadStatus status;
  final String source;
  final String industry;
  final double? estimatedBudget;
  final String? leadOwner;
  final DateTime createdDate;
  final DateTime? convertedDate;

  Lead({
    required this.leadId,
    required this.companyName,
    required this.contactName,
    required this.email,
    required this.phone,
    required this.status,
    required this.source,
    required this.industry,
    this.estimatedBudget,
    this.leadOwner,
    required this.createdDate,
    this.convertedDate,
  });

  bool get isConverted => status == LeadStatus.converted;
  bool get isQualified => status == LeadStatus.qualified;
  int get ageInDays => DateTime.now().difference(createdDate).inDays;
  int get daysToConversion =>
      convertedDate == null ? 0 : convertedDate!.difference(createdDate).inDays;

  Lead copyWith({
    String? leadId,
    String? companyName,
    String? contactName,
    String? email,
    String? phone,
    LeadStatus? status,
    String? source,
    String? industry,
    double? estimatedBudget,
    String? leadOwner,
    DateTime? createdDate,
    DateTime? convertedDate,
  }) {
    return Lead(
      leadId: leadId ?? this.leadId,
      companyName: companyName ?? this.companyName,
      contactName: contactName ?? this.contactName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      source: source ?? this.source,
      industry: industry ?? this.industry,
      estimatedBudget: estimatedBudget ?? this.estimatedBudget,
      leadOwner: leadOwner ?? this.leadOwner,
      createdDate: createdDate ?? this.createdDate,
      convertedDate: convertedDate ?? this.convertedDate,
    );
  }
}

class Opportunity {
  final String opportunityId;
  final String accountId;
  final String contactId;
  final String opportunityName;
  final double amount;
  final OpportunityStage stage;
  final DateTime closeDate;
  final double probability;
  final String description;
  final String? competitorName;
  final String owner;
  final DateTime createdDate;

  Opportunity({
    required this.opportunityId,
    required this.accountId,
    required this.contactId,
    required this.opportunityName,
    required this.amount,
    required this.stage,
    required this.closeDate,
    required this.probability,
    required this.description,
    this.competitorName,
    required this.owner,
    required this.createdDate,
  });

  double get expectedValue => amount * probability;
  bool get isClosed => stage == OpportunityStage.closed || stage == OpportunityStage.closedWon || stage == OpportunityStage.closedLost;
  bool get isWon => stage == OpportunityStage.closedWon;
  bool get isOverdue => DateTime.now().isAfter(closeDate) && !isClosed;
  int get ageInDays => DateTime.now().difference(createdDate).inDays;
  int get daysUntilClose => closeDate.difference(DateTime.now()).inDays;

  Opportunity copyWith({
    String? opportunityId,
    String? accountId,
    String? contactId,
    String? opportunityName,
    double? amount,
    OpportunityStage? stage,
    DateTime? closeDate,
    double? probability,
    String? description,
    String? competitorName,
    String? owner,
    DateTime? createdDate,
  }) {
    return Opportunity(
      opportunityId: opportunityId ?? this.opportunityId,
      accountId: accountId ?? this.accountId,
      contactId: contactId ?? this.contactId,
      opportunityName: opportunityName ?? this.opportunityName,
      amount: amount ?? this.amount,
      stage: stage ?? this.stage,
      closeDate: closeDate ?? this.closeDate,
      probability: probability ?? this.probability,
      description: description ?? this.description,
      competitorName: competitorName ?? this.competitorName,
      owner: owner ?? this.owner,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}

class Activity {
  final String activityId;
  final String accountId;
  final String? contactId;
  final String? opportunityId;
  final ActivityType type;
  final String subject;
  final String description;
  final DateTime activityDate;
  final String? participant;
  final Duration? duration;
  final bool isCompleted;

  Activity({
    required this.activityId,
    required this.accountId,
    this.contactId,
    this.opportunityId,
    required this.type,
    required this.subject,
    required this.description,
    required this.activityDate,
    this.participant,
    this.duration,
    required this.isCompleted,
  });

  bool get isRecent => DateTime.now().difference(activityDate).inDays <= 7;
  bool get isOverdue => !isCompleted && DateTime.now().isAfter(activityDate);
  int get ageInDays => DateTime.now().difference(activityDate).inDays;

  Activity copyWith({
    String? activityId,
    String? accountId,
    String? contactId,
    String? opportunityId,
    ActivityType? type,
    String? subject,
    String? description,
    DateTime? activityDate,
    String? participant,
    Duration? duration,
    bool? isCompleted,
  }) {
    return Activity(
      activityId: activityId ?? this.activityId,
      accountId: accountId ?? this.accountId,
      contactId: contactId ?? this.contactId,
      opportunityId: opportunityId ?? this.opportunityId,
      type: type ?? this.type,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      activityDate: activityDate ?? this.activityDate,
      participant: participant ?? this.participant,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class Campaign {
  final String campaignId;
  final String campaignName;
  final CampaignStatus status;
  final String type;
  final DateTime startDate;
  final DateTime? endDate;
  final double budget;
  final double? spentAmount;
  final int? targetAudience;
  final int? actualResponses;
  final String owner;

  Campaign({
    required this.campaignId,
    required this.campaignName,
    required this.status,
    required this.type,
    required this.startDate,
    this.endDate,
    required this.budget,
    this.spentAmount,
    this.targetAudience,
    this.actualResponses,
    required this.owner,
  });

  bool get isActive => status == CampaignStatus.active;
  bool get isCompleted => status == CampaignStatus.completed;
  double get spendPercent => spentAmount == null ? 0 : (spentAmount! / budget) * 100;
  double? get responseRate =>
      targetAudience == null || actualResponses == null ? null : (actualResponses! / targetAudience!) * 100;
  double get remainingBudget => budget - (spentAmount ?? 0);
  int get ageInDays => DateTime.now().difference(startDate).inDays;

  Campaign copyWith({
    String? campaignId,
    String? campaignName,
    CampaignStatus? status,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    double? spentAmount,
    int? targetAudience,
    int? actualResponses,
    String? owner,
  }) {
    return Campaign(
      campaignId: campaignId ?? this.campaignId,
      campaignName: campaignName ?? this.campaignName,
      status: status ?? this.status,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      spentAmount: spentAmount ?? this.spentAmount,
      targetAudience: targetAudience ?? this.targetAudience,
      actualResponses: actualResponses ?? this.actualResponses,
      owner: owner ?? this.owner,
    );
  }
}

class Deal {
  final String dealId;
  final String opportunityId;
  final String accountId;
  final String dealName;
  final double dealValue;
  final DealStatus status;
  final DateTime expectedCloseDate;
  final DateTime? actualCloseDate;
  final String owner;
  final String? closingReason;
  final DateTime createdDate;

  Deal({
    required this.dealId,
    required this.opportunityId,
    required this.accountId,
    required this.dealName,
    required this.dealValue,
    required this.status,
    required this.expectedCloseDate,
    this.actualCloseDate,
    required this.owner,
    this.closingReason,
    required this.createdDate,
  });

  bool get isWon => status == DealStatus.won;
  bool get isLost => status == DealStatus.lost;
  bool get isClosed => status == DealStatus.won || status == DealStatus.lost;
  bool get isOverdue => DateTime.now().isAfter(expectedCloseDate) && !isClosed;
  int get ageInDays => DateTime.now().difference(createdDate).inDays;
  int get cycleLength =>
      actualCloseDate == null ? 0 : actualCloseDate!.difference(createdDate).inDays;

  Deal copyWith({
    String? dealId,
    String? opportunityId,
    String? accountId,
    String? dealName,
    double? dealValue,
    DealStatus? status,
    DateTime? expectedCloseDate,
    DateTime? actualCloseDate,
    String? owner,
    String? closingReason,
    DateTime? createdDate,
  }) {
    return Deal(
      dealId: dealId ?? this.dealId,
      opportunityId: opportunityId ?? this.opportunityId,
      accountId: accountId ?? this.accountId,
      dealName: dealName ?? this.dealName,
      dealValue: dealValue ?? this.dealValue,
      status: status ?? this.status,
      expectedCloseDate: expectedCloseDate ?? this.expectedCloseDate,
      actualCloseDate: actualCloseDate ?? this.actualCloseDate,
      owner: owner ?? this.owner,
      closingReason: closingReason ?? this.closingReason,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}

class Forecast {
  final String forecastId;
  final String owner;
  final DateTime forecastDate;
  final int month;
  final int year;
  final double pipelineValue;
  final double bestCaseValue;
  final double mostLikelyValue;
  final double worstCaseValue;
  final int opportunityCount;
  final int closedWonCount;

  Forecast({
    required this.forecastId,
    required this.owner,
    required this.forecastDate,
    required this.month,
    required this.year,
    required this.pipelineValue,
    required this.bestCaseValue,
    required this.mostLikelyValue,
    required this.worstCaseValue,
    required this.opportunityCount,
    required this.closedWonCount,
  });

  double get averageValue => (bestCaseValue + mostLikelyValue + worstCaseValue) / 3;
  double get confidenceScore => mostLikelyValue > 0 ? (closedWonCount / opportunityCount) * 100 : 0;
  int get ageInDays => DateTime.now().difference(forecastDate).inDays;

  Forecast copyWith({
    String? forecastId,
    String? owner,
    DateTime? forecastDate,
    int? month,
    int? year,
    double? pipelineValue,
    double? bestCaseValue,
    double? mostLikelyValue,
    double? worstCaseValue,
    int? opportunityCount,
    int? closedWonCount,
  }) {
    return Forecast(
      forecastId: forecastId ?? this.forecastId,
      owner: owner ?? this.owner,
      forecastDate: forecastDate ?? this.forecastDate,
      month: month ?? this.month,
      year: year ?? this.year,
      pipelineValue: pipelineValue ?? this.pipelineValue,
      bestCaseValue: bestCaseValue ?? this.bestCaseValue,
      mostLikelyValue: mostLikelyValue ?? this.mostLikelyValue,
      worstCaseValue: worstCaseValue ?? this.worstCaseValue,
      opportunityCount: opportunityCount ?? this.opportunityCount,
      closedWonCount: closedWonCount ?? this.closedWonCount,
    );
  }
}

class SalesMetrics {
  final String metricsId;
  final DateTime reportDate;
  final double totalPipelineValue;
  final double totalRevenueWon;
  final double averageDealSize;
  final double winRate;
  final int totalOpportunitiesCount;
  final int closedWonCount;
  final double salesCycleLength;
  final Map<String, double> performanceByOwner;

  SalesMetrics({
    required this.metricsId,
    required this.reportDate,
    required this.totalPipelineValue,
    required this.totalRevenueWon,
    required this.averageDealSize,
    required this.winRate,
    required this.totalOpportunitiesCount,
    required this.closedWonCount,
    required this.salesCycleLength,
    required this.performanceByOwner,
  });

  int get ageInDays => DateTime.now().difference(reportDate).inDays;

  SalesMetrics copyWith({
    String? metricsId,
    DateTime? reportDate,
    double? totalPipelineValue,
    double? totalRevenueWon,
    double? averageDealSize,
    double? winRate,
    int? totalOpportunitiesCount,
    int? closedWonCount,
    double? salesCycleLength,
    Map<String, double>? performanceByOwner,
  }) {
    return SalesMetrics(
      metricsId: metricsId ?? this.metricsId,
      reportDate: reportDate ?? this.reportDate,
      totalPipelineValue: totalPipelineValue ?? this.totalPipelineValue,
      totalRevenueWon: totalRevenueWon ?? this.totalRevenueWon,
      averageDealSize: averageDealSize ?? this.averageDealSize,
      winRate: winRate ?? this.winRate,
      totalOpportunitiesCount: totalOpportunitiesCount ?? this.totalOpportunitiesCount,
      closedWonCount: closedWonCount ?? this.closedWonCount,
      salesCycleLength: salesCycleLength ?? this.salesCycleLength,
      performanceByOwner: performanceByOwner ?? this.performanceByOwner,
    );
  }
}

class IntegrationModels {
  // Placeholder for integration with other phases
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
