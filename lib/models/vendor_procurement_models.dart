import 'package:intl/intl.dart';

// ============================================================================
// ENUMS - 8 Total
// ============================================================================

enum VendorStatus {
  active,
  inactive,
  suspended,
  blocked,
  onboarding,
  offboarding;

  String get displayName {
    switch (this) {
      case VendorStatus.active:
        return 'Active (有効)';
      case VendorStatus.inactive:
        return 'Inactive (非アクティブ)';
      case VendorStatus.suspended:
        return 'Suspended (停止中)';
      case VendorStatus.blocked:
        return 'Blocked (ブロック済)';
      case VendorStatus.onboarding:
        return 'Onboarding (オンボーディング中)';
      case VendorStatus.offboarding:
        return 'Offboarding (オフボーディング中)';
    }
  }
}

enum VendorType {
  supplier,
  manufacturer,
  distributor,
  logistics,
  service,
  technology;

  String get displayName {
    switch (this) {
      case VendorType.supplier:
        return 'Supplier (サプライヤー)';
      case VendorType.manufacturer:
        return 'Manufacturer (製造業者)';
      case VendorType.distributor:
        return 'Distributor (流通業者)';
      case VendorType.logistics:
        return 'Logistics (物流)';
      case VendorType.service:
        return 'Service (サービス)';
      case VendorType.technology:
        return 'Technology (技術)';
    }
  }
}

enum ProcurementStatus {
  draft,
  submitted,
  approved,
  rejected,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case ProcurementStatus.draft:
        return 'Draft (下書き)';
      case ProcurementStatus.submitted:
        return 'Submitted (提出済)';
      case ProcurementStatus.approved:
        return 'Approved (承認済)';
      case ProcurementStatus.rejected:
        return 'Rejected (却下)';
      case ProcurementStatus.completed:
        return 'Completed (完了)';
      case ProcurementStatus.cancelled:
        return 'Cancelled (キャンセル)';
    }
  }
}

enum PurchaseOrderStatus {
  pending,
  confirmed,
  shipped,
  delivered,
  invoiced,
  paid,
  cancelled;

  String get displayName {
    switch (this) {
      case PurchaseOrderStatus.pending:
        return 'Pending (保留中)';
      case PurchaseOrderStatus.confirmed:
        return 'Confirmed (確認済)';
      case PurchaseOrderStatus.shipped:
        return 'Shipped (発送済)';
      case PurchaseOrderStatus.delivered:
        return 'Delivered (配送完了)';
      case PurchaseOrderStatus.invoiced:
        return 'Invoiced (請求済)';
      case PurchaseOrderStatus.paid:
        return 'Paid (支払済)';
      case PurchaseOrderStatus.cancelled:
        return 'Cancelled (キャンセル)';
    }
  }
}

enum ContractStatus {
  draft,
  active,
  expired,
  terminated,
  renewed;

  String get displayName {
    switch (this) {
      case ContractStatus.draft:
        return 'Draft (下書き)';
      case ContractStatus.active:
        return 'Active (有効)';
      case ContractStatus.expired:
        return 'Expired (期限切れ)';
      case ContractStatus.terminated:
        return 'Terminated (終了)';
      case ContractStatus.renewed:
        return 'Renewed (更新)';
    }
  }
}

enum ReceiptStatus {
  pending,
  partial,
  complete,
  cancelled;

  String get displayName {
    switch (this) {
      case ReceiptStatus.pending:
        return 'Pending (保留中)';
      case ReceiptStatus.partial:
        return 'Partial (部分受領)';
      case ReceiptStatus.complete:
        return 'Complete (受領完了)';
      case ReceiptStatus.cancelled:
        return 'Cancelled (キャンセル)';
    }
  }
}

enum InvoiceStatus {
  draft,
  submitted,
  approved,
  paid,
  overdue,
  cancelled;

  String get displayName {
    switch (this) {
      case InvoiceStatus.draft:
        return 'Draft (下書き)';
      case InvoiceStatus.submitted:
        return 'Submitted (提出済)';
      case InvoiceStatus.approved:
        return 'Approved (承認済)';
      case InvoiceStatus.paid:
        return 'Paid (支払済)';
      case InvoiceStatus.overdue:
        return 'Overdue (期限切れ)';
      case InvoiceStatus.cancelled:
        return 'Cancelled (キャンセル)';
    }
  }
}

enum PaymentTerms {
  net15,
  net30,
  net60,
  net90,
  cod,
  prepaid;

  String get displayName {
    switch (this) {
      case PaymentTerms.net15:
        return 'Net 15 (15日払)';
      case PaymentTerms.net30:
        return 'Net 30 (30日払)';
      case PaymentTerms.net60:
        return 'Net 60 (60日払)';
      case PaymentTerms.net90:
        return 'Net 90 (90日払)';
      case PaymentTerms.cod:
        return 'COD (着払)';
      case PaymentTerms.prepaid:
        return 'Prepaid (前払)';
    }
  }
}

// ============================================================================
// MODEL CLASSES - 10 Total
// ============================================================================

class Vendor {
  final String vendorId;
  final String vendorName;
  final VendorType type;
  final VendorStatus status;
  final String contactPerson;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String country;
  final String taxId;
  final double creditLimit;
  final double creditUsed;
  final bool isPreferred;
  final String accountManager;
  final DateTime createdDate;
  final DateTime? lastUpdatedDate;

  Vendor({
    required this.vendorId,
    required this.vendorName,
    required this.type,
    required this.status,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
    required this.taxId,
    required this.creditLimit,
    required this.creditUsed,
    this.isPreferred = false,
    required this.accountManager,
    required this.createdDate,
    this.lastUpdatedDate,
  });

  bool get isActive => status == VendorStatus.active;
  bool get isCreditAvailable => creditUsed < creditLimit;
  int get ageInDays => DateTime.now().difference(createdDate).inDays;
  double get availableCredit => creditLimit - creditUsed;

  Vendor copyWith({
    String? vendorId,
    String? vendorName,
    VendorType? type,
    VendorStatus? status,
    String? contactPerson,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? country,
    String? taxId,
    double? creditLimit,
    double? creditUsed,
    bool? isPreferred,
    String? accountManager,
    DateTime? createdDate,
    DateTime? lastUpdatedDate,
  }) {
    return Vendor(
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      type: type ?? this.type,
      status: status ?? this.status,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      taxId: taxId ?? this.taxId,
      creditLimit: creditLimit ?? this.creditLimit,
      creditUsed: creditUsed ?? this.creditUsed,
      isPreferred: isPreferred ?? this.isPreferred,
      accountManager: accountManager ?? this.accountManager,
      createdDate: createdDate ?? this.createdDate,
      lastUpdatedDate: lastUpdatedDate ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMarkdown() => {
        'vendorId': vendorId,
        'vendorName': vendorName,
        'type': type.displayName,
        'status': status.displayName,
        'isActive': isActive,
        'availableCredit': availableCredit,
        'ageInDays': ageInDays,
      };
}

class VendorContract {
  final String contractId;
  final String vendorId;
  final String contractName;
  final ContractStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final double contractValue;
  final String paymentTerms;
  final String deliveryTerms;
  final String owner;
  final String description;
  final DateTime createdDate;

  VendorContract({
    required this.contractId,
    required this.vendorId,
    required this.contractName,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.contractValue,
    required this.paymentTerms,
    required this.deliveryTerms,
    required this.owner,
    required this.description,
    required this.createdDate,
  });

  bool get isActive => status == ContractStatus.active;
  bool get isExpired => DateTime.now().isAfter(endDate);
  int get daysUntilExpiration => endDate.difference(DateTime.now()).inDays;
  int get ageInDays => DateTime.now().difference(createdDate).inDays;

  VendorContract copyWith({
    String? contractId,
    String? vendorId,
    String? contractName,
    ContractStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    double? contractValue,
    String? paymentTerms,
    String? deliveryTerms,
    String? owner,
    String? description,
    DateTime? createdDate,
  }) {
    return VendorContract(
      contractId: contractId ?? this.contractId,
      vendorId: vendorId ?? this.vendorId,
      contractName: contractName ?? this.contractName,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      contractValue: contractValue ?? this.contractValue,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      deliveryTerms: deliveryTerms ?? this.deliveryTerms,
      owner: owner ?? this.owner,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  Map<String, dynamic> toMarkdown() => {
        'contractId': contractId,
        'contractName': contractName,
        'status': status.displayName,
        'isActive': isActive,
        'isExpired': isExpired,
        'daysUntilExpiration': daysUntilExpiration,
        'contractValue': contractValue,
      };
}

class ProcurementRequest {
  final String procurementId;
  final String departmentName;
  final String requester;
  final ProcurementStatus status;
  final DateTime requestDate;
  final DateTime? targetDate;
  final double totalBudget;
  final int itemCount;
  final String approver;
  final String description;
  final DateTime createdDate;

  ProcurementRequest({
    required this.procurementId,
    required this.departmentName,
    required this.requester,
    required this.status,
    required this.requestDate,
    this.targetDate,
    required this.totalBudget,
    required this.itemCount,
    required this.approver,
    required this.description,
    required this.createdDate,
  });

  bool get isApproved => status == ProcurementStatus.approved;
  bool get isCompleted => status == ProcurementStatus.completed;
  bool get isOverdue => targetDate != null && DateTime.now().isAfter(targetDate!);
  int get daysUntilDue => targetDate?.difference(DateTime.now()).inDays ?? 0;
  int get ageInDays => DateTime.now().difference(createdDate).inDays;

  ProcurementRequest copyWith({
    String? procurementId,
    String? departmentName,
    String? requester,
    ProcurementStatus? status,
    DateTime? requestDate,
    DateTime? targetDate,
    double? totalBudget,
    int? itemCount,
    String? approver,
    String? description,
    DateTime? createdDate,
  }) {
    return ProcurementRequest(
      procurementId: procurementId ?? this.procurementId,
      departmentName: departmentName ?? this.departmentName,
      requester: requester ?? this.requester,
      status: status ?? this.status,
      requestDate: requestDate ?? this.requestDate,
      targetDate: targetDate ?? this.targetDate,
      totalBudget: totalBudget ?? this.totalBudget,
      itemCount: itemCount ?? this.itemCount,
      approver: approver ?? this.approver,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  Map<String, dynamic> toMarkdown() => {
        'procurementId': procurementId,
        'departmentName': departmentName,
        'status': status.displayName,
        'isApproved': isApproved,
        'isOverdue': isOverdue,
        'daysUntilDue': daysUntilDue,
        'totalBudget': totalBudget,
        'ageInDays': ageInDays,
      };
}

class PurchaseOrder {
  final String poId;
  final String vendorId;
  final String procurementId;
  final PurchaseOrderStatus status;
  final DateTime createdDate;
  final DateTime targetDeliveryDate;
  final double totalAmount;
  final int lineItemCount;
  final String buyer;
  final String description;
  final DateTime? shippedDate;
  final DateTime? deliveredDate;

  PurchaseOrder({
    required this.poId,
    required this.vendorId,
    required this.procurementId,
    required this.status,
    required this.createdDate,
    required this.targetDeliveryDate,
    required this.totalAmount,
    required this.lineItemCount,
    required this.buyer,
    required this.description,
    this.shippedDate,
    this.deliveredDate,
  });

  bool get isDelivered => status == PurchaseOrderStatus.delivered;
  bool get isPaid => status == PurchaseOrderStatus.paid;
  bool get isOverdue =>
      DateTime.now().isAfter(targetDeliveryDate) &&
      status != PurchaseOrderStatus.delivered &&
      status != PurchaseOrderStatus.cancelled;
  int get daysUntilDelivery => targetDeliveryDate.difference(DateTime.now()).inDays;
  int get ageInDays => DateTime.now().difference(createdDate).inDays;

  PurchaseOrder copyWith({
    String? poId,
    String? vendorId,
    String? procurementId,
    PurchaseOrderStatus? status,
    DateTime? createdDate,
    DateTime? targetDeliveryDate,
    double? totalAmount,
    int? lineItemCount,
    String? buyer,
    String? description,
    DateTime? shippedDate,
    DateTime? deliveredDate,
  }) {
    return PurchaseOrder(
      poId: poId ?? this.poId,
      vendorId: vendorId ?? this.vendorId,
      procurementId: procurementId ?? this.procurementId,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
      targetDeliveryDate: targetDeliveryDate ?? this.targetDeliveryDate,
      totalAmount: totalAmount ?? this.totalAmount,
      lineItemCount: lineItemCount ?? this.lineItemCount,
      buyer: buyer ?? this.buyer,
      description: description ?? this.description,
      shippedDate: shippedDate ?? this.shippedDate,
      deliveredDate: deliveredDate ?? this.deliveredDate,
    );
  }

  Map<String, dynamic> toMarkdown() => {
        'poId': poId,
        'vendorId': vendorId,
        'status': status.displayName,
        'isDelivered': isDelivered,
        'isPaid': isPaid,
        'isOverdue': isOverdue,
        'daysUntilDelivery': daysUntilDelivery,
        'totalAmount': totalAmount,
        'ageInDays': ageInDays,
      };
}

class GoodsReceipt {
  final String receiptId;
  final String poId;
  final String vendorId;
  final ReceiptStatus status;
  final DateTime receivedDate;
  final int quantityReceived;
  final int quantityExpected;
  final String receivedBy;
  final String warehouse;
  final String notes;
  final DateTime createdDate;

  GoodsReceipt({
    required this.receiptId,
    required this.poId,
    required this.vendorId,
    required this.status,
    required this.receivedDate,
    required this.quantityReceived,
    required this.quantityExpected,
    required this.receivedBy,
    required this.warehouse,
    required this.notes,
    required this.createdDate,
  });

  bool get isComplete => status == ReceiptStatus.complete;
  bool get isPartial => status == ReceiptStatus.partial;
  double get receiptPercentage => (quantityReceived / quantityExpected) * 100;
  int get ageInDays => DateTime.now().difference(createdDate).inDays;

  GoodsReceipt copyWith({
    String? receiptId,
    String? poId,
    String? vendorId,
    ReceiptStatus? status,
    DateTime? receivedDate,
    int? quantityReceived,
    int? quantityExpected,
    String? receivedBy,
    String? warehouse,
    String? notes,
    DateTime? createdDate,
  }) {
    return GoodsReceipt(
      receiptId: receiptId ?? this.receiptId,
      poId: poId ?? this.poId,
      vendorId: vendorId ?? this.vendorId,
      status: status ?? this.status,
      receivedDate: receivedDate ?? this.receivedDate,
      quantityReceived: quantityReceived ?? this.quantityReceived,
      quantityExpected: quantityExpected ?? this.quantityExpected,
      receivedBy: receivedBy ?? this.receivedBy,
      warehouse: warehouse ?? this.warehouse,
      notes: notes ?? this.notes,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  Map<String, dynamic> toMarkdown() => {
        'receiptId': receiptId,
        'poId': poId,
        'status': status.displayName,
        'isComplete': isComplete,
        'isPartial': isPartial,
        'receiptPercentage': receiptPercentage,
        'quantityReceived': quantityReceived,
        'quantityExpected': quantityExpected,
      };
}

class VendorInvoice {
  final String invoiceId;
  final String vendorId;
  final String poId;
  final InvoiceStatus status;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final double invoiceAmount;
  final double amountPaid;
  final PaymentTerms paymentTerms;
  final String invoiceNumber;
  final String description;
  final DateTime createdDate;

  VendorInvoice({
    required this.invoiceId,
    required this.vendorId,
    required this.poId,
    required this.status,
    required this.invoiceDate,
    required this.dueDate,
    required this.invoiceAmount,
    required this.amountPaid,
    required this.paymentTerms,
    required this.invoiceNumber,
    required this.description,
    required this.createdDate,
  });

  bool get isPaid => status == InvoiceStatus.paid;
  bool get isOverdue => DateTime.now().isAfter(dueDate) && status != InvoiceStatus.paid;
  double get amountRemaining => invoiceAmount - amountPaid;
  double get paymentPercentage => (amountPaid / invoiceAmount) * 100;
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
  int get ageInDays => DateTime.now().difference(createdDate).inDays;

  VendorInvoice copyWith({
    String? invoiceId,
    String? vendorId,
    String? poId,
    InvoiceStatus? status,
    DateTime? invoiceDate,
    DateTime? dueDate,
    double? invoiceAmount,
    double? amountPaid,
    PaymentTerms? paymentTerms,
    String? invoiceNumber,
    String? description,
    DateTime? createdDate,
  }) {
    return VendorInvoice(
      invoiceId: invoiceId ?? this.invoiceId,
      vendorId: vendorId ?? this.vendorId,
      poId: poId ?? this.poId,
      status: status ?? this.status,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      invoiceAmount: invoiceAmount ?? this.invoiceAmount,
      amountPaid: amountPaid ?? this.amountPaid,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  Map<String, dynamic> toMarkdown() => {
        'invoiceId': invoiceId,
        'vendorId': vendorId,
        'status': status.displayName,
        'isPaid': isPaid,
        'isOverdue': isOverdue,
        'amountRemaining': amountRemaining,
        'paymentPercentage': paymentPercentage,
        'daysUntilDue': daysUntilDue,
        'ageInDays': ageInDays,
      };
}

class ProcurementLineItem {
  final String lineItemId;
  final String procurementId;
  final String itemName;
  final String itemCode;
  final int quantity;
  final double unitPrice;
  final String uom;
  final String description;
  final String requestedBy;
  final DateTime createdDate;

  ProcurementLineItem({
    required this.lineItemId,
    required this.procurementId,
    required this.itemName,
    required this.itemCode,
    required this.quantity,
    required this.unitPrice,
    required this.uom,
    required this.description,
    required this.requestedBy,
    required this.createdDate,
  });

  double get lineTotal => quantity * unitPrice;
  int get ageInDays => DateTime.now().difference(createdDate).inDays;

  ProcurementLineItem copyWith({
    String? lineItemId,
    String? procurementId,
    String? itemName,
    String? itemCode,
    int? quantity,
    double? unitPrice,
    String? uom,
    String? description,
    String? requestedBy,
    DateTime? createdDate,
  }) {
    return ProcurementLineItem(
      lineItemId: lineItemId ?? this.lineItemId,
      procurementId: procurementId ?? this.procurementId,
      itemName: itemName ?? this.itemName,
      itemCode: itemCode ?? this.itemCode,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      uom: uom ?? this.uom,
      description: description ?? this.description,
      requestedBy: requestedBy ?? this.requestedBy,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  Map<String, dynamic> toMarkdown() => {
        'lineItemId': lineItemId,
        'itemName': itemName,
        'itemCode': itemCode,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'lineTotal': lineTotal,
        'uom': uom,
        'ageInDays': ageInDays,
      };
}

class VendorPerformanceMetrics {
  final String metricsId;
  final String vendorId;
  final double onTimeDeliveryRate;
  final double qualityScore;
  final double communicationScore;
  final double priceCompetitiveness;
  final int totalOrdersCompleted;
  final int defectRate;
  final double overallRating;
  final DateTime evaluatedDate;
  final String evaluatedBy;

  VendorPerformanceMetrics({
    required this.metricsId,
    required this.vendorId,
    required this.onTimeDeliveryRate,
    required this.qualityScore,
    required this.communicationScore,
    required this.priceCompetitiveness,
    required this.totalOrdersCompleted,
    required this.defectRate,
    required this.overallRating,
    required this.evaluatedDate,
    required this.evaluatedBy,
  });

  bool get isHighPerformer => overallRating >= 4.0;
  bool get isLowPerformer => overallRating < 2.5;
  int get ageInDays => DateTime.now().difference(evaluatedDate).inDays;

  VendorPerformanceMetrics copyWith({
    String? metricsId,
    String? vendorId,
    double? onTimeDeliveryRate,
    double? qualityScore,
    double? communicationScore,
    double? priceCompetitiveness,
    int? totalOrdersCompleted,
    int? defectRate,
    double? overallRating,
    DateTime? evaluatedDate,
    String? evaluatedBy,
  }) {
    return VendorPerformanceMetrics(
      metricsId: metricsId ?? this.metricsId,
      vendorId: vendorId ?? this.vendorId,
      onTimeDeliveryRate: onTimeDeliveryRate ?? this.onTimeDeliveryRate,
      qualityScore: qualityScore ?? this.qualityScore,
      communicationScore: communicationScore ?? this.communicationScore,
      priceCompetitiveness: priceCompetitiveness ?? this.priceCompetitiveness,
      totalOrdersCompleted: totalOrdersCompleted ?? this.totalOrdersCompleted,
      defectRate: defectRate ?? this.defectRate,
      overallRating: overallRating ?? this.overallRating,
      evaluatedDate: evaluatedDate ?? this.evaluatedDate,
      evaluatedBy: evaluatedBy ?? this.evaluatedBy,
    );
  }

  Map<String, dynamic> toMarkdown() => {
        'metricsId': metricsId,
        'vendorId': vendorId,
        'onTimeDeliveryRate': onTimeDeliveryRate,
        'qualityScore': qualityScore,
        'communicationScore': communicationScore,
        'isHighPerformer': isHighPerformer,
        'isLowPerformer': isLowPerformer,
        'overallRating': overallRating,
      };
}

class ProcurementAnalytics {
  final String analyticsId;
  final double totalProcurementValue;
  final double totalInvoiceAmount;
  final double totalAmountPaid;
  final int activeVendors;
  final int activeContracts;
  final int completedPurchaseOrders;
  final int pendingPurchaseOrders;
  final double averagePaymentDuration;
  final DateTime generatedDate;

  ProcurementAnalytics({
    required this.analyticsId,
    required this.totalProcurementValue,
    required this.totalInvoiceAmount,
    required this.totalAmountPaid,
    required this.activeVendors,
    required this.activeContracts,
    required this.completedPurchaseOrders,
    required this.pendingPurchaseOrders,
    required this.averagePaymentDuration,
    required this.generatedDate,
  });

  double get paymentPercentage => (totalAmountPaid / totalInvoiceAmount) * 100;
  int get ageInDays => DateTime.now().difference(generatedDate).inDays;

  ProcurementAnalytics copyWith({
    String? analyticsId,
    double? totalProcurementValue,
    double? totalInvoiceAmount,
    double? totalAmountPaid,
    int? activeVendors,
    int? activeContracts,
    int? completedPurchaseOrders,
    int? pendingPurchaseOrders,
    double? averagePaymentDuration,
    DateTime? generatedDate,
  }) {
    return ProcurementAnalytics(
      analyticsId: analyticsId ?? this.analyticsId,
      totalProcurementValue: totalProcurementValue ?? this.totalProcurementValue,
      totalInvoiceAmount: totalInvoiceAmount ?? this.totalInvoiceAmount,
      totalAmountPaid: totalAmountPaid ?? this.totalAmountPaid,
      activeVendors: activeVendors ?? this.activeVendors,
      activeContracts: activeContracts ?? this.activeContracts,
      completedPurchaseOrders: completedPurchaseOrders ?? this.completedPurchaseOrders,
      pendingPurchaseOrders: pendingPurchaseOrders ?? this.pendingPurchaseOrders,
      averagePaymentDuration: averagePaymentDuration ?? this.averagePaymentDuration,
      generatedDate: generatedDate ?? this.generatedDate,
    );
  }

  Map<String, dynamic> toMarkdown() => {
        'analyticsId': analyticsId,
        'totalProcurementValue': totalProcurementValue,
        'totalInvoiceAmount': totalInvoiceAmount,
        'totalAmountPaid': totalAmountPaid,
        'paymentPercentage': paymentPercentage,
        'activeVendors': activeVendors,
        'activeContracts': activeContracts,
        'completedPurchaseOrders': completedPurchaseOrders,
      };
  }
}

class IntegrationModels {
  // Integration support for cross-domain functionality
  final String integrationId;
  final String referenceId;
  final String referenceType; // vendor, contract, po, invoice, etc.
  final Map<String, dynamic> metadata;

  IntegrationModels({
    required this.integrationId,
    required this.referenceId,
    required this.referenceType,
    required this.metadata,
  });

  IntegrationModels copyWith({
    String? integrationId,
    String? referenceId,
    String? referenceType,
    Map<String, dynamic>? metadata,
  }) {
    return IntegrationModels(
      integrationId: integrationId ?? this.integrationId,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMarkdown() => {
        'integrationId': integrationId,
        'referenceId': referenceId,
        'referenceType': referenceType,
        'metadataKeys': metadata.keys.toList(),
      };
}
