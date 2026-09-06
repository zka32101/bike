import 'package:project_040/models/vendor_procurement_models.dart';

// ============================================================================
// REPOSITORY INTERFACE - 92 Methods across 9 Categories
// ============================================================================

abstract class VendorProcurementRepository {
  // ========== VENDORS (12 methods) ==========
  Future<Vendor?> createVendor(Vendor vendor);
  Future<Vendor?> getVendor(String vendorId);
  Future<List<Vendor>> getAllVendors();
  Future<List<Vendor>> getActiveVendors();
  Future<List<Vendor>> getVendorsByType(VendorType type);
  Future<List<Vendor>> getPreferredVendors();
  Future<List<Vendor>> getBlockedVendors();
  Future<List<Vendor>> getVendorsByStatus(VendorStatus status);
  Future<Vendor?> updateVendor(Vendor vendor);
  Future<bool> deleteVendor(String vendorId);
  Future<int> getVendorCount();
  Future<List<Vendor>> getVendorsByAccountManager(String accountManager);

  // ========== VENDOR CONTRACTS (12 methods) ==========
  Future<VendorContract?> createContract(VendorContract contract);
  Future<VendorContract?> getContract(String contractId);
  Future<List<VendorContract>> getAllContracts();
  Future<List<VendorContract>> getActiveContracts();
  Future<List<VendorContract>> getContractsByVendor(String vendorId);
  Future<List<VendorContract>> getContractsByStatus(ContractStatus status);
  Future<List<VendorContract>> getExpiringContracts(int daysUntilExpiry);
  Future<List<VendorContract>> getExpiredContracts();
  Future<VendorContract?> updateContract(VendorContract contract);
  Future<bool> deleteContract(String contractId);
  Future<int> getContractCount();
  Future<double> getTotalContractValue();

  // ========== PROCUREMENT REQUESTS (12 methods) ==========
  Future<ProcurementRequest?> createProcurementRequest(ProcurementRequest request);
  Future<ProcurementRequest?> getProcurementRequest(String procurementId);
  Future<List<ProcurementRequest>> getAllProcurementRequests();
  Future<List<ProcurementRequest>> getApprovedProcurementRequests();
  Future<List<ProcurementRequest>> getProcurementRequestsByStatus(ProcurementStatus status);
  Future<List<ProcurementRequest>> getOverdueProcurementRequests();
  Future<List<ProcurementRequest>> getProcurementRequestsByDepartment(String department);
  Future<List<ProcurementRequest>> getProcurementRequestsByRequester(String requester);
  Future<ProcurementRequest?> updateProcurementRequest(ProcurementRequest request);
  Future<bool> deleteProcurementRequest(String procurementId);
  Future<int> getProcurementRequestCount();
  Future<double> getTotalProcurementBudget();

  // ========== PURCHASE ORDERS (12 methods) ==========
  Future<PurchaseOrder?> createPurchaseOrder(PurchaseOrder po);
  Future<PurchaseOrder?> getPurchaseOrder(String poId);
  Future<List<PurchaseOrder>> getAllPurchaseOrders();
  Future<List<PurchaseOrder>> getDeliveredPurchaseOrders();
  Future<List<PurchaseOrder>> getPurchaseOrdersByStatus(PurchaseOrderStatus status);
  Future<List<PurchaseOrder>> getOverduePurchaseOrders();
  Future<List<PurchaseOrder>> getPurchaseOrdersByVendor(String vendorId);
  Future<List<PurchaseOrder>> getPendingPurchaseOrders();
  Future<PurchaseOrder?> updatePurchaseOrder(PurchaseOrder po);
  Future<bool> deletePurchaseOrder(String poId);
  Future<int> getPurchaseOrderCount();
  Future<double> getTotalPurchaseOrderAmount();

  // ========== GOODS RECEIPTS (10 methods) ==========
  Future<GoodsReceipt?> createGoodsReceipt(GoodsReceipt receipt);
  Future<GoodsReceipt?> getGoodsReceipt(String receiptId);
  Future<List<GoodsReceipt>> getAllGoodsReceipts();
  Future<List<GoodsReceipt>> getReceiptsByPO(String poId);
  Future<List<GoodsReceipt>> getReceiptsByVendor(String vendorId);
  Future<List<GoodsReceipt>> getCompleteReceipts();
  Future<List<GoodsReceipt>> getPartialReceipts();
  Future<GoodsReceipt?> updateGoodsReceipt(GoodsReceipt receipt);
  Future<bool> deleteGoodsReceipt(String receiptId);
  Future<int> getGoodsReceiptCount();

  // ========== VENDOR INVOICES (12 methods) ==========
  Future<VendorInvoice?> createInvoice(VendorInvoice invoice);
  Future<VendorInvoice?> getInvoice(String invoiceId);
  Future<List<VendorInvoice>> getAllInvoices();
  Future<List<VendorInvoice>> getPaidInvoices();
  Future<List<VendorInvoice>> getInvoicesByStatus(InvoiceStatus status);
  Future<List<VendorInvoice>> getOverdueInvoices();
  Future<List<VendorInvoice>> getInvoicesByVendor(String vendorId);
  Future<List<VendorInvoice>> getUnpaidInvoices();
  Future<VendorInvoice?> updateInvoice(VendorInvoice invoice);
  Future<bool> deleteInvoice(String invoiceId);
  Future<int> getInvoiceCount();
  Future<double> getTotalInvoiceAmount();

  // ========== PROCUREMENT LINE ITEMS (10 methods) ==========
  Future<ProcurementLineItem?> createLineItem(ProcurementLineItem item);
  Future<ProcurementLineItem?> getLineItem(String lineItemId);
  Future<List<ProcurementLineItem>> getAllLineItems();
  Future<List<ProcurementLineItem>> getLineItemsByProcurement(String procurementId);
  Future<List<ProcurementLineItem>> getLineItemsByItemCode(String itemCode);
  Future<ProcurementLineItem?> updateLineItem(ProcurementLineItem item);
  Future<bool> deleteLineItem(String lineItemId);
  Future<int> getLineItemCount();
  Future<double> getTotalLineItemValue();
  Future<List<ProcurementLineItem>> getLineItemsByRequester(String requester);

  // ========== VENDOR PERFORMANCE (10 methods) ==========
  Future<VendorPerformanceMetrics?> recordPerformanceMetrics(VendorPerformanceMetrics metrics);
  Future<VendorPerformanceMetrics?> getPerformanceMetrics(String metricsId);
  Future<List<VendorPerformanceMetrics>> getAllPerformanceMetrics();
  Future<List<VendorPerformanceMetrics>> getMetricsByVendor(String vendorId);
  Future<List<VendorPerformanceMetrics>> getHighPerformers();
  Future<List<VendorPerformanceMetrics>> getLowPerformers();
  Future<VendorPerformanceMetrics?> updatePerformanceMetrics(VendorPerformanceMetrics metrics);
  Future<bool> deletePerformanceMetrics(String metricsId);
  Future<int> getPerformanceMetricsCount();
  Future<double> getAverageVendorRating();

  // ========== PROCUREMENT ANALYTICS (12 methods) ==========
  Future<ProcurementAnalytics?> recordAnalytics(ProcurementAnalytics analytics);
  Future<ProcurementAnalytics?> getLatestAnalytics();
  Future<List<ProcurementAnalytics>> getAllAnalytics();
  Future<double> getTotalSpentAmount();
  Future<double> getTotalInvoicedAmount();
  Future<int> getActiveProcurements();
  Future<int> getCompletedProcurements();
  Future<double> getAverageProcurementValue();
  Future<List<Vendor>> getTopVendorsBySpend(int limit);
  Future<double> getProcurementCycleTime();
  Future<List<Map<String, dynamic>>> getProcurementTrendAnalysis();
  Future<Map<String, dynamic>> getProcurementDashboard();
}

// ============================================================================
// IN-MEMORY REPOSITORY IMPLEMENTATION
// ============================================================================

class InMemoryVendorProcurementRepository implements VendorProcurementRepository {
  final Map<String, Vendor> _vendors = {};
  final Map<String, VendorContract> _contracts = {};
  final Map<String, ProcurementRequest> _procurementRequests = {};
  final Map<String, PurchaseOrder> _purchaseOrders = {};
  final Map<String, GoodsReceipt> _goodsReceipts = {};
  final Map<String, VendorInvoice> _invoices = {};
  final Map<String, ProcurementLineItem> _lineItems = {};
  final Map<String, VendorPerformanceMetrics> _performanceMetrics = {};
  final Map<String, ProcurementAnalytics> _analytics = {};

  // ========== VENDORS ==========
  @override
  Future<Vendor?> createVendor(Vendor vendor) async {
    _vendors[vendor.vendorId] = vendor;
    return vendor;
  }

  @override
  Future<Vendor?> getVendor(String vendorId) async => _vendors[vendorId];

  @override
  Future<List<Vendor>> getAllVendors() async => _vendors.values.toList();

  @override
  Future<List<Vendor>> getActiveVendors() async =>
      _vendors.values.where((v) => v.isActive).toList();

  @override
  Future<List<Vendor>> getVendorsByType(VendorType type) async =>
      _vendors.values.where((v) => v.type == type).toList();

  @override
  Future<List<Vendor>> getPreferredVendors() async =>
      _vendors.values.where((v) => v.isPreferred).toList();

  @override
  Future<List<Vendor>> getBlockedVendors() async =>
      _vendors.values.where((v) => v.status == VendorStatus.blocked).toList();

  @override
  Future<List<Vendor>> getVendorsByStatus(VendorStatus status) async =>
      _vendors.values.where((v) => v.status == status).toList();

  @override
  Future<Vendor?> updateVendor(Vendor vendor) async {
    _vendors[vendor.vendorId] = vendor;
    return vendor;
  }

  @override
  Future<bool> deleteVendor(String vendorId) async {
    return _vendors.remove(vendorId) != null;
  }

  @override
  Future<int> getVendorCount() async => _vendors.length;

  @override
  Future<List<Vendor>> getVendorsByAccountManager(String accountManager) async =>
      _vendors.values.where((v) => v.accountManager == accountManager).toList();

  // ========== VENDOR CONTRACTS ==========
  @override
  Future<VendorContract?> createContract(VendorContract contract) async {
    _contracts[contract.contractId] = contract;
    return contract;
  }

  @override
  Future<VendorContract?> getContract(String contractId) async => _contracts[contractId];

  @override
  Future<List<VendorContract>> getAllContracts() async => _contracts.values.toList();

  @override
  Future<List<VendorContract>> getActiveContracts() async =>
      _contracts.values.where((c) => c.isActive).toList();

  @override
  Future<List<VendorContract>> getContractsByVendor(String vendorId) async =>
      _contracts.values.where((c) => c.vendorId == vendorId).toList();

  @override
  Future<List<VendorContract>> getContractsByStatus(ContractStatus status) async =>
      _contracts.values.where((c) => c.status == status).toList();

  @override
  Future<List<VendorContract>> getExpiringContracts(int daysUntilExpiry) async =>
      _contracts.values
          .where((c) => c.daysUntilExpiration <= daysUntilExpiry && c.daysUntilExpiration > 0)
          .toList();

  @override
  Future<List<VendorContract>> getExpiredContracts() async =>
      _contracts.values.where((c) => c.isExpired).toList();

  @override
  Future<VendorContract?> updateContract(VendorContract contract) async {
    _contracts[contract.contractId] = contract;
    return contract;
  }

  @override
  Future<bool> deleteContract(String contractId) async {
    return _contracts.remove(contractId) != null;
  }

  @override
  Future<int> getContractCount() async => _contracts.length;

  @override
  Future<double> getTotalContractValue() async =>
      _contracts.values.fold(0, (sum, c) => sum + c.contractValue);

  // ========== PROCUREMENT REQUESTS ==========
  @override
  Future<ProcurementRequest?> createProcurementRequest(ProcurementRequest request) async {
    _procurementRequests[request.procurementId] = request;
    return request;
  }

  @override
  Future<ProcurementRequest?> getProcurementRequest(String procurementId) async =>
      _procurementRequests[procurementId];

  @override
  Future<List<ProcurementRequest>> getAllProcurementRequests() async =>
      _procurementRequests.values.toList();

  @override
  Future<List<ProcurementRequest>> getApprovedProcurementRequests() async =>
      _procurementRequests.values
          .where((p) => p.status == ProcurementStatus.approved)
          .toList();

  @override
  Future<List<ProcurementRequest>> getProcurementRequestsByStatus(ProcurementStatus status) async =>
      _procurementRequests.values.where((p) => p.status == status).toList();

  @override
  Future<List<ProcurementRequest>> getOverdueProcurementRequests() async =>
      _procurementRequests.values.where((p) => p.isOverdue).toList();

  @override
  Future<List<ProcurementRequest>> getProcurementRequestsByDepartment(String department) async =>
      _procurementRequests.values.where((p) => p.departmentName == department).toList();

  @override
  Future<List<ProcurementRequest>> getProcurementRequestsByRequester(String requester) async =>
      _procurementRequests.values.where((p) => p.requester == requester).toList();

  @override
  Future<ProcurementRequest?> updateProcurementRequest(ProcurementRequest request) async {
    _procurementRequests[request.procurementId] = request;
    return request;
  }

  @override
  Future<bool> deleteProcurementRequest(String procurementId) async {
    return _procurementRequests.remove(procurementId) != null;
  }

  @override
  Future<int> getProcurementRequestCount() async => _procurementRequests.length;

  @override
  Future<double> getTotalProcurementBudget() async =>
      _procurementRequests.values.fold(0, (sum, p) => sum + p.totalBudget);

  // ========== PURCHASE ORDERS ==========
  @override
  Future<PurchaseOrder?> createPurchaseOrder(PurchaseOrder po) async {
    _purchaseOrders[po.poId] = po;
    return po;
  }

  @override
  Future<PurchaseOrder?> getPurchaseOrder(String poId) async => _purchaseOrders[poId];

  @override
  Future<List<PurchaseOrder>> getAllPurchaseOrders() async => _purchaseOrders.values.toList();

  @override
  Future<List<PurchaseOrder>> getDeliveredPurchaseOrders() async =>
      _purchaseOrders.values.where((p) => p.isDelivered).toList();

  @override
  Future<List<PurchaseOrder>> getPurchaseOrdersByStatus(PurchaseOrderStatus status) async =>
      _purchaseOrders.values.where((p) => p.status == status).toList();

  @override
  Future<List<PurchaseOrder>> getOverduePurchaseOrders() async =>
      _purchaseOrders.values.where((p) => p.isOverdue).toList();

  @override
  Future<List<PurchaseOrder>> getPurchaseOrdersByVendor(String vendorId) async =>
      _purchaseOrders.values.where((p) => p.vendorId == vendorId).toList();

  @override
  Future<List<PurchaseOrder>> getPendingPurchaseOrders() async =>
      _purchaseOrders.values.where((p) => p.status == PurchaseOrderStatus.pending).toList();

  @override
  Future<PurchaseOrder?> updatePurchaseOrder(PurchaseOrder po) async {
    _purchaseOrders[po.poId] = po;
    return po;
  }

  @override
  Future<bool> deletePurchaseOrder(String poId) async {
    return _purchaseOrders.remove(poId) != null;
  }

  @override
  Future<int> getPurchaseOrderCount() async => _purchaseOrders.length;

  @override
  Future<double> getTotalPurchaseOrderAmount() async =>
      _purchaseOrders.values.fold(0, (sum, p) => sum + p.totalAmount);

  // ========== GOODS RECEIPTS ==========
  @override
  Future<GoodsReceipt?> createGoodsReceipt(GoodsReceipt receipt) async {
    _goodsReceipts[receipt.receiptId] = receipt;
    return receipt;
  }

  @override
  Future<GoodsReceipt?> getGoodsReceipt(String receiptId) async => _goodsReceipts[receiptId];

  @override
  Future<List<GoodsReceipt>> getAllGoodsReceipts() async => _goodsReceipts.values.toList();

  @override
  Future<List<GoodsReceipt>> getReceiptsByPO(String poId) async =>
      _goodsReceipts.values.where((r) => r.poId == poId).toList();

  @override
  Future<List<GoodsReceipt>> getReceiptsByVendor(String vendorId) async =>
      _goodsReceipts.values.where((r) => r.vendorId == vendorId).toList();

  @override
  Future<List<GoodsReceipt>> getCompleteReceipts() async =>
      _goodsReceipts.values.where((r) => r.isComplete).toList();

  @override
  Future<List<GoodsReceipt>> getPartialReceipts() async =>
      _goodsReceipts.values.where((r) => r.isPartial).toList();

  @override
  Future<GoodsReceipt?> updateGoodsReceipt(GoodsReceipt receipt) async {
    _goodsReceipts[receipt.receiptId] = receipt;
    return receipt;
  }

  @override
  Future<bool> deleteGoodsReceipt(String receiptId) async {
    return _goodsReceipts.remove(receiptId) != null;
  }

  @override
  Future<int> getGoodsReceiptCount() async => _goodsReceipts.length;

  // ========== VENDOR INVOICES ==========
  @override
  Future<VendorInvoice?> createInvoice(VendorInvoice invoice) async {
    _invoices[invoice.invoiceId] = invoice;
    return invoice;
  }

  @override
  Future<VendorInvoice?> getInvoice(String invoiceId) async => _invoices[invoiceId];

  @override
  Future<List<VendorInvoice>> getAllInvoices() async => _invoices.values.toList();

  @override
  Future<List<VendorInvoice>> getPaidInvoices() async =>
      _invoices.values.where((i) => i.isPaid).toList();

  @override
  Future<List<VendorInvoice>> getInvoicesByStatus(InvoiceStatus status) async =>
      _invoices.values.where((i) => i.status == status).toList();

  @override
  Future<List<VendorInvoice>> getOverdueInvoices() async =>
      _invoices.values.where((i) => i.isOverdue).toList();

  @override
  Future<List<VendorInvoice>> getInvoicesByVendor(String vendorId) async =>
      _invoices.values.where((i) => i.vendorId == vendorId).toList();

  @override
  Future<List<VendorInvoice>> getUnpaidInvoices() async =>
      _invoices.values.where((i) => !i.isPaid).toList();

  @override
  Future<VendorInvoice?> updateInvoice(VendorInvoice invoice) async {
    _invoices[invoice.invoiceId] = invoice;
    return invoice;
  }

  @override
  Future<bool> deleteInvoice(String invoiceId) async {
    return _invoices.remove(invoiceId) != null;
  }

  @override
  Future<int> getInvoiceCount() async => _invoices.length;

  @override
  Future<double> getTotalInvoiceAmount() async =>
      _invoices.values.fold(0, (sum, i) => sum + i.invoiceAmount);

  // ========== PROCUREMENT LINE ITEMS ==========
  @override
  Future<ProcurementLineItem?> createLineItem(ProcurementLineItem item) async {
    _lineItems[item.lineItemId] = item;
    return item;
  }

  @override
  Future<ProcurementLineItem?> getLineItem(String lineItemId) async => _lineItems[lineItemId];

  @override
  Future<List<ProcurementLineItem>> getAllLineItems() async => _lineItems.values.toList();

  @override
  Future<List<ProcurementLineItem>> getLineItemsByProcurement(String procurementId) async =>
      _lineItems.values.where((l) => l.procurementId == procurementId).toList();

  @override
  Future<List<ProcurementLineItem>> getLineItemsByItemCode(String itemCode) async =>
      _lineItems.values.where((l) => l.itemCode == itemCode).toList();

  @override
  Future<ProcurementLineItem?> updateLineItem(ProcurementLineItem item) async {
    _lineItems[item.lineItemId] = item;
    return item;
  }

  @override
  Future<bool> deleteLineItem(String lineItemId) async {
    return _lineItems.remove(lineItemId) != null;
  }

  @override
  Future<int> getLineItemCount() async => _lineItems.length;

  @override
  Future<double> getTotalLineItemValue() async =>
      _lineItems.values.fold(0, (sum, l) => sum + l.lineTotal);

  @override
  Future<List<ProcurementLineItem>> getLineItemsByRequester(String requester) async =>
      _lineItems.values.where((l) => l.requestedBy == requester).toList();

  // ========== VENDOR PERFORMANCE ==========
  @override
  Future<VendorPerformanceMetrics?> recordPerformanceMetrics(
      VendorPerformanceMetrics metrics) async {
    _performanceMetrics[metrics.metricsId] = metrics;
    return metrics;
  }

  @override
  Future<VendorPerformanceMetrics?> getPerformanceMetrics(String metricsId) async =>
      _performanceMetrics[metricsId];

  @override
  Future<List<VendorPerformanceMetrics>> getAllPerformanceMetrics() async =>
      _performanceMetrics.values.toList();

  @override
  Future<List<VendorPerformanceMetrics>> getMetricsByVendor(String vendorId) async =>
      _performanceMetrics.values.where((m) => m.vendorId == vendorId).toList();

  @override
  Future<List<VendorPerformanceMetrics>> getHighPerformers() async =>
      _performanceMetrics.values.where((m) => m.isHighPerformer).toList();

  @override
  Future<List<VendorPerformanceMetrics>> getLowPerformers() async =>
      _performanceMetrics.values.where((m) => m.isLowPerformer).toList();

  @override
  Future<VendorPerformanceMetrics?> updatePerformanceMetrics(
      VendorPerformanceMetrics metrics) async {
    _performanceMetrics[metrics.metricsId] = metrics;
    return metrics;
  }

  @override
  Future<bool> deletePerformanceMetrics(String metricsId) async {
    return _performanceMetrics.remove(metricsId) != null;
  }

  @override
  Future<int> getPerformanceMetricsCount() async => _performanceMetrics.length;

  @override
  Future<double> getAverageVendorRating() async {
    if (_performanceMetrics.isEmpty) return 0;
    final sum =
        _performanceMetrics.values.fold(0.0, (sum, m) => sum + m.overallRating);
    return sum / _performanceMetrics.length;
  }

  // ========== PROCUREMENT ANALYTICS ==========
  @override
  Future<ProcurementAnalytics?> recordAnalytics(ProcurementAnalytics analytics) async {
    _analytics[analytics.analyticsId] = analytics;
    return analytics;
  }

  @override
  Future<ProcurementAnalytics?> getLatestAnalytics() async {
    if (_analytics.isEmpty) return null;
    return _analytics.values.reduce((a, b) => a.generatedDate.isAfter(b.generatedDate) ? a : b);
  }

  @override
  Future<List<ProcurementAnalytics>> getAllAnalytics() async => _analytics.values.toList();

  @override
  Future<double> getTotalSpentAmount() async =>
      _invoices.values.fold(0, (sum, i) => sum + i.amountPaid);

  @override
  Future<double> getTotalInvoicedAmount() async =>
      _invoices.values.fold(0, (sum, i) => sum + i.invoiceAmount);

  @override
  Future<int> getActiveProcurements() async =>
      _procurementRequests.values
          .where((p) => p.status == ProcurementStatus.submitted)
          .length;

  @override
  Future<int> getCompletedProcurements() async =>
      _procurementRequests.values.where((p) => p.isCompleted).length;

  @override
  Future<double> getAverageProcurementValue() async {
    if (_procurementRequests.isEmpty) return 0;
    final sum = _procurementRequests.values.fold(0.0, (sum, p) => sum + p.totalBudget);
    return sum / _procurementRequests.length;
  }

  @override
  Future<List<Vendor>> getTopVendorsBySpend(int limit) async {
    final vendorSpend = <String, double>{};
    for (final po in _purchaseOrders.values) {
      vendorSpend[po.vendorId] = (vendorSpend[po.vendorId] ?? 0) + po.totalAmount;
    }
    final sorted = vendorSpend.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted
        .take(limit)
        .map((e) => _vendors[e.key])
        .whereType<Vendor>()
        .toList();
  }

  @override
  Future<double> getProcurementCycleTime() async {
    if (_purchaseOrders.isEmpty) return 0;
    final totalDays = _purchaseOrders.values.fold(0, (sum, po) {
      final delivered = po.deliveredDate ?? DateTime.now();
      return sum + delivered.difference(po.createdDate).inDays;
    });
    return totalDays / _purchaseOrders.length;
  }

  @override
  Future<List<Map<String, dynamic>>> getProcurementTrendAnalysis() async => [];

  @override
  Future<Map<String, dynamic>> getProcurementDashboard() async => {
        'totalVendors': _vendors.length,
        'activeVendors': (await getActiveVendors()).length,
        'totalContracts': _contracts.length,
        'activeContracts': (await getActiveContracts()).length,
        'totalProcurementRequests': _procurementRequests.length,
        'approvedRequests': (await getApprovedProcurementRequests()).length,
        'totalPurchaseOrders': _purchaseOrders.length,
        'deliveredOrders': (await getDeliveredPurchaseOrders()).length,
        'totalInvoiced': await getTotalInvoiceAmount(),
        'totalPaid': await getTotalSpentAmount(),
        'overdueInvoices': (await getOverdueInvoices()).length,
        'averageVendorRating': await getAverageVendorRating(),
        'procurementCycleTime': await getProcurementCycleTime(),
      };
}

// ============================================================================
// SPECIALIZED ENGINES
// ============================================================================

class VendorAnalysisEngine {
  final VendorProcurementRepository repository;

  VendorAnalysisEngine(this.repository);

  Future<Map<String, dynamic>> analyzeVendorPerformance(String vendorId) async {
    final vendor = await repository.getVendor(vendorId);
    final metrics = await repository.getMetricsByVendor(vendorId);
    final contracts = await repository.getContractsByVendor(vendorId);

    if (vendor == null) return {};

    return {
      'vendorId': vendorId,
      'vendorName': vendor.vendorName,
      'averageRating': metrics.isEmpty ? 0 : metrics[0].overallRating,
      'activeContracts': contracts.where((c) => c.isActive).length,
      'creditHealth': vendor.isCreditAvailable,
      'preferredStatus': vendor.isPreferred,
    };
  }

  Future<List<Vendor>> rankVendorsByPerformance() async {
    final vendors = await repository.getAllVendors();
    final ranked = <Vendor>[];

    for (final vendor in vendors) {
      final metrics = await repository.getMetricsByVendor(vendor.vendorId);
      if (metrics.isNotEmpty) {
        ranked.add(vendor);
      }
    }

    return ranked;
  }
}

class ProcurementAnalysisEngine {
  final VendorProcurementRepository repository;

  ProcurementAnalysisEngine(this.repository);

  Future<double> calculateProcurementCost(String procurementId) async {
    final lineItems = await repository.getLineItemsByProcurement(procurementId);
    return lineItems.fold(0.0, (sum, item) => sum + item.lineTotal);
  }

  Future<Map<String, dynamic>> analyzeProcurementStatus(String procurementId) async {
    final request = await repository.getProcurementRequest(procurementId);
    final lineItems = await repository.getLineItemsByProcurement(procurementId);
    final cost = await calculateProcurementCost(procurementId);

    if (request == null) return {};

    return {
      'procurementId': procurementId,
      'status': request.status.displayName,
      'itemCount': lineItems.length,
      'totalCost': cost,
      'budgetRemaining': request.totalBudget - cost,
      'isBudgetExceeded': cost > request.totalBudget,
    };
  }
}

class PaymentAnalysisEngine {
  final VendorProcurementRepository repository;

  PaymentAnalysisEngine(this.repository);

  Future<double> calculateTotalDueAmount() async {
    final unpaidInvoices = await repository.getUnpaidInvoices();
    return unpaidInvoices.fold(0.0, (sum, inv) => sum + inv.amountRemaining);
  }

  Future<Map<String, dynamic>> analyzePaymentStatus() async {
    final allInvoices = await repository.getAllInvoices();
    final paidInvoices = await repository.getPaidInvoices();
    final overdueInvoices = await repository.getOverdueInvoices();
    final totalDue = await calculateTotalDueAmount();

    return {
      'totalInvoices': allInvoices.length,
      'paidInvoices': paidInvoices.length,
      'unpaidInvoices': allInvoices.length - paidInvoices.length,
      'overdueInvoices': overdueInvoices.length,
      'totalDueAmount': totalDue,
      'paymentPercentage': allInvoices.isEmpty ? 0 : (paidInvoices.length / allInvoices.length) * 100,
    };
  }
}

// ============================================================================
// MANAGER - Orchestrates Repository & Engines
// ============================================================================

class VendorProcurementManager {
  final VendorProcurementRepository repository;
  late final VendorAnalysisEngine vendorAnalysisEngine;
  late final ProcurementAnalysisEngine procurementAnalysisEngine;
  late final PaymentAnalysisEngine paymentAnalysisEngine;

  VendorProcurementManager(this.repository) {
    vendorAnalysisEngine = VendorAnalysisEngine(repository);
    procurementAnalysisEngine = ProcurementAnalysisEngine(repository);
    paymentAnalysisEngine = PaymentAnalysisEngine(repository);
  }

  Future<Map<String, dynamic>> getVendorProcurementDashboard() async {
    return await repository.getProcurementDashboard();
  }
}

// ============================================================================
// FACADE - Simplified Public API
// ============================================================================

class VendorProcurementFacade {
  final VendorProcurementRepository repository;
  late final VendorProcurementManager manager;

  VendorProcurementFacade(this.repository) {
    manager = VendorProcurementManager(repository);
  }

  // Vendor Management
  Future<Vendor?> createVendor(Vendor vendor) => repository.createVendor(vendor);
  Future<Vendor?> getVendor(String vendorId) => repository.getVendor(vendorId);
  Future<List<Vendor>> getActiveVendors() => repository.getActiveVendors();
  Future<List<Vendor>> getPreferredVendors() => repository.getPreferredVendors();
  Future<int> getVendorCount() => repository.getVendorCount();

  // Contract Management
  Future<VendorContract?> createContract(VendorContract contract) =>
      repository.createContract(contract);
  Future<List<VendorContract>> getActiveContracts() => repository.getActiveContracts();
  Future<List<VendorContract>> getExpiringContracts(int daysUntilExpiry) =>
      repository.getExpiringContracts(daysUntilExpiry);

  // Procurement Management
  Future<ProcurementRequest?> createProcurementRequest(ProcurementRequest request) =>
      repository.createProcurementRequest(request);
  Future<List<ProcurementRequest>> getApprovedProcurementRequests() =>
      repository.getApprovedProcurementRequests();
  Future<List<ProcurementRequest>> getOverdueProcurementRequests() =>
      repository.getOverdueProcurementRequests();

  // Purchase Order Management
  Future<PurchaseOrder?> createPurchaseOrder(PurchaseOrder po) =>
      repository.createPurchaseOrder(po);
  Future<List<PurchaseOrder>> getDeliveredPurchaseOrders() =>
      repository.getDeliveredPurchaseOrders();
  Future<List<PurchaseOrder>> getOverduePurchaseOrders() =>
      repository.getOverduePurchaseOrders();

  // Goods Receipt Management
  Future<GoodsReceipt?> createGoodsReceipt(GoodsReceipt receipt) =>
      repository.createGoodsReceipt(receipt);
  Future<List<GoodsReceipt>> getCompleteReceipts() => repository.getCompleteReceipts();

  // Invoice Management
  Future<VendorInvoice?> createInvoice(VendorInvoice invoice) =>
      repository.createInvoice(invoice);
  Future<List<VendorInvoice>> getPaidInvoices() => repository.getPaidInvoices();
  Future<List<VendorInvoice>> getOverdueInvoices() => repository.getOverdueInvoices();

  // Performance Tracking
  Future<VendorPerformanceMetrics?> recordPerformanceMetrics(
          VendorPerformanceMetrics metrics) =>
      repository.recordPerformanceMetrics(metrics);
  Future<List<VendorPerformanceMetrics>> getHighPerformers() =>
      repository.getHighPerformers();
  Future<List<VendorPerformanceMetrics>> getLowPerformers() =>
      repository.getLowPerformers();

  // Dashboard
  Future<Map<String, dynamic>> getVendorProcurementDashboard() =>
      manager.getVendorProcurementDashboard();
}
