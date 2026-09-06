import 'package:test/test.dart';
import 'package:project_040/models/vendor_procurement_models.dart';
import 'package:project_040/services/vendor_procurement_service.dart';

void main() {
  group('Phase 103: Vendor & Procurement Management Tests', () {
    late VendorProcurementFacade facade;
    late InMemoryVendorProcurementRepository repository;

    setUp(() {
      repository = InMemoryVendorProcurementRepository();
      facade = VendorProcurementFacade(repository);
    });

    // ========== ENUM TESTS ==========
    group('Enum Tests', () {
      test('VendorStatus has all values with display names', () {
        expect(VendorStatus.values.length, equals(6));
        expect(VendorStatus.active.displayName, contains('Active'));
        expect(VendorStatus.inactive.displayName, contains('Inactive'));
      });

      test('VendorType has all values with display names', () {
        expect(VendorType.values.length, equals(6));
        expect(VendorType.supplier.displayName, contains('Supplier'));
        expect(VendorType.manufacturer.displayName, contains('Manufacturer'));
      });

      test('ProcurementStatus has all values with display names', () {
        expect(ProcurementStatus.values.length, equals(6));
        expect(ProcurementStatus.approved.displayName, contains('Approved'));
      });

      test('PurchaseOrderStatus has all values with display names', () {
        expect(PurchaseOrderStatus.values.length, equals(7));
        expect(PurchaseOrderStatus.delivered.displayName, contains('Delivered'));
      });

      test('ContractStatus has all values with display names', () {
        expect(ContractStatus.values.length, equals(5));
        expect(ContractStatus.active.displayName, contains('Active'));
      });

      test('ReceiptStatus has all values with display names', () {
        expect(ReceiptStatus.values.length, equals(4));
        expect(ReceiptStatus.complete.displayName, contains('Complete'));
      });

      test('InvoiceStatus has all values with display names', () {
        expect(InvoiceStatus.values.length, equals(6));
        expect(InvoiceStatus.paid.displayName, contains('Paid'));
      });

      test('PaymentTerms has all values with display names', () {
        expect(PaymentTerms.values.length, equals(6));
        expect(PaymentTerms.net30.displayName, contains('Net 30'));
      });
    });

    // ========== MODEL TESTS ==========
    group('Model Tests', () {
      test('Vendor model initializes correctly', () {
        final vendor = Vendor(
          vendorId: 'v1',
          vendorName: 'Acme Supply',
          type: VendorType.supplier,
          status: VendorStatus.active,
          contactPerson: 'John Doe',
          email: 'john@acme.com',
          phone: '+1-555-0100',
          address: '123 Main St',
          city: 'New York',
          country: 'USA',
          taxId: 'TAX123',
          creditLimit: 100000,
          creditUsed: 50000,
          accountManager: 'Jane Smith',
          createdDate: DateTime.now(),
        );

        expect(vendor.vendorId, equals('v1'));
        expect(vendor.isActive, isTrue);
        expect(vendor.isCreditAvailable, isTrue);
        expect(vendor.availableCredit, equals(50000));
      });

      test('Vendor copyWith immutability', () {
        final vendor1 = Vendor(
          vendorId: 'v1',
          vendorName: 'Acme',
          type: VendorType.supplier,
          status: VendorStatus.active,
          contactPerson: 'John',
          email: 'john@acme.com',
          phone: '+1-555-0100',
          address: '123 Main',
          city: 'NY',
          country: 'USA',
          taxId: 'TAX123',
          creditLimit: 100000,
          creditUsed: 50000,
          accountManager: 'Jane',
          createdDate: DateTime.now(),
        );

        final vendor2 = vendor1.copyWith(status: VendorStatus.inactive);
        expect(vendor1.status, equals(VendorStatus.active));
        expect(vendor2.status, equals(VendorStatus.inactive));
      });

      test('VendorContract computed properties', () {
        final contract = VendorContract(
          contractId: 'c1',
          vendorId: 'v1',
          contractName: 'Supply Agreement',
          status: ContractStatus.active,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 30)),
          contractValue: 500000,
          paymentTerms: 'Net 30',
          deliveryTerms: 'FOB',
          owner: 'Manager',
          description: 'Test',
          createdDate: DateTime.now(),
        );

        expect(contract.isActive, isTrue);
        expect(contract.daysUntilExpiration, greaterThan(0));
      });

      test('ProcurementRequest computed properties', () {
        final request = ProcurementRequest(
          procurementId: 'p1',
          departmentName: 'Ops',
          requester: 'John',
          status: ProcurementStatus.approved,
          requestDate: DateTime.now(),
          targetDate: DateTime.now().add(Duration(days: 5)),
          totalBudget: 100000,
          itemCount: 10,
          approver: 'Manager',
          description: 'Test',
          createdDate: DateTime.now(),
        );

        expect(request.isApproved, isTrue);
        expect(request.isOverdue, isFalse);
        expect(request.daysUntilDue, greaterThan(0));
      });

      test('PurchaseOrder computed properties', () {
        final po = PurchaseOrder(
          poId: 'po1',
          vendorId: 'v1',
          procurementId: 'p1',
          status: PurchaseOrderStatus.shipped,
          createdDate: DateTime.now(),
          targetDeliveryDate: DateTime.now().add(Duration(days: 5)),
          totalAmount: 50000,
          lineItemCount: 5,
          buyer: 'John',
          description: 'Test',
        );

        expect(po.isDelivered, isFalse);
        expect(po.isOverdue, isFalse);
        expect(po.daysUntilDelivery, greaterThan(0));
      });

      test('GoodsReceipt computed properties', () {
        final receipt = GoodsReceipt(
          receiptId: 'gr1',
          poId: 'po1',
          vendorId: 'v1',
          status: ReceiptStatus.complete,
          receivedDate: DateTime.now(),
          quantityReceived: 100,
          quantityExpected: 100,
          receivedBy: 'Warehouse',
          warehouse: 'Main',
          notes: 'Test',
          createdDate: DateTime.now(),
        );

        expect(receipt.isComplete, isTrue);
        expect(receipt.receiptPercentage, equals(100.0));
      });

      test('VendorInvoice computed properties', () {
        final invoice = VendorInvoice(
          invoiceId: 'inv1',
          vendorId: 'v1',
          poId: 'po1',
          status: InvoiceStatus.submitted,
          invoiceDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 30)),
          invoiceAmount: 50000,
          amountPaid: 25000,
          paymentTerms: PaymentTerms.net30,
          invoiceNumber: 'INV-001',
          description: 'Test',
          createdDate: DateTime.now(),
        );

        expect(invoice.isPaid, isFalse);
        expect(invoice.amountRemaining, equals(25000));
        expect(invoice.paymentPercentage, equals(50.0));
      });

      test('ProcurementLineItem computed properties', () {
        final item = ProcurementLineItem(
          lineItemId: 'li1',
          procurementId: 'p1',
          itemName: 'Item 1',
          itemCode: 'ITEM001',
          quantity: 10,
          unitPrice: 100,
          uom: 'EA',
          description: 'Test',
          requestedBy: 'John',
          createdDate: DateTime.now(),
        );

        expect(item.lineTotal, equals(1000));
      });

      test('VendorPerformanceMetrics computed properties', () {
        final metrics = VendorPerformanceMetrics(
          metricsId: 'm1',
          vendorId: 'v1',
          onTimeDeliveryRate: 95.0,
          qualityScore: 4.5,
          communicationScore: 4.0,
          priceCompetitiveness: 4.2,
          totalOrdersCompleted: 50,
          defectRate: 2,
          overallRating: 4.5,
          evaluatedDate: DateTime.now(),
          evaluatedBy: 'Manager',
        );

        expect(metrics.isHighPerformer, isTrue);
        expect(metrics.isLowPerformer, isFalse);
      });
    });

    // ========== REPOSITORY TESTS ==========
    group('Repository Tests', () {
      test('Create and retrieve vendor', () async {
        final vendor = Vendor(
          vendorId: 'v1',
          vendorName: 'Test Vendor',
          type: VendorType.supplier,
          status: VendorStatus.active,
          contactPerson: 'John',
          email: 'john@test.com',
          phone: '+1-555-0100',
          address: '123 Main',
          city: 'NY',
          country: 'USA',
          taxId: 'TAX123',
          creditLimit: 100000,
          creditUsed: 0,
          accountManager: 'Jane',
          createdDate: DateTime.now(),
        );

        await facade.createVendor(vendor);
        final retrieved = await repository.getVendor('v1');
        expect(retrieved, isNotNull);
        expect(retrieved!.vendorName, equals('Test Vendor'));
      });

      test('Get active vendors', () async {
        final vendor1 = Vendor(
          vendorId: 'v1',
          vendorName: 'Active Vendor',
          type: VendorType.supplier,
          status: VendorStatus.active,
          contactPerson: 'John',
          email: 'john@test.com',
          phone: '+1-555-0100',
          address: '123 Main',
          city: 'NY',
          country: 'USA',
          taxId: 'TAX123',
          creditLimit: 100000,
          creditUsed: 0,
          accountManager: 'Jane',
          createdDate: DateTime.now(),
        );

        await facade.createVendor(vendor1);
        final active = await facade.getActiveVendors();
        expect(active.length, equals(1));
      });

      test('Create and retrieve contract', () async {
        final contract = VendorContract(
          contractId: 'c1',
          vendorId: 'v1',
          contractName: 'Test Contract',
          status: ContractStatus.active,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 30)),
          contractValue: 500000,
          paymentTerms: 'Net 30',
          deliveryTerms: 'FOB',
          owner: 'Manager',
          description: 'Test',
          createdDate: DateTime.now(),
        );

        await facade.createContract(contract);
        final retrieved = await repository.getContract('c1');
        expect(retrieved, isNotNull);
      });

      test('Create and retrieve procurement request', () async {
        final request = ProcurementRequest(
          procurementId: 'p1',
          departmentName: 'Ops',
          requester: 'John',
          status: ProcurementStatus.approved,
          requestDate: DateTime.now(),
          targetDate: DateTime.now().add(Duration(days: 5)),
          totalBudget: 100000,
          itemCount: 10,
          approver: 'Manager',
          description: 'Test',
          createdDate: DateTime.now(),
        );

        await facade.createProcurementRequest(request);
        final retrieved = await repository.getProcurementRequest('p1');
        expect(retrieved, isNotNull);
      });

      test('Create and retrieve purchase order', () async {
        final po = PurchaseOrder(
          poId: 'po1',
          vendorId: 'v1',
          procurementId: 'p1',
          status: PurchaseOrderStatus.pending,
          createdDate: DateTime.now(),
          targetDeliveryDate: DateTime.now().add(Duration(days: 5)),
          totalAmount: 50000,
          lineItemCount: 5,
          buyer: 'John',
          description: 'Test',
        );

        await facade.createPurchaseOrder(po);
        final retrieved = await repository.getPurchaseOrder('po1');
        expect(retrieved, isNotNull);
      });

      test('Create and retrieve goods receipt', () async {
        final receipt = GoodsReceipt(
          receiptId: 'gr1',
          poId: 'po1',
          vendorId: 'v1',
          status: ReceiptStatus.complete,
          receivedDate: DateTime.now(),
          quantityReceived: 100,
          quantityExpected: 100,
          receivedBy: 'Warehouse',
          warehouse: 'Main',
          notes: 'Test',
          createdDate: DateTime.now(),
        );

        await facade.createGoodsReceipt(receipt);
        final retrieved = await repository.getGoodsReceipt('gr1');
        expect(retrieved, isNotNull);
      });

      test('Create and retrieve invoice', () async {
        final invoice = VendorInvoice(
          invoiceId: 'inv1',
          vendorId: 'v1',
          poId: 'po1',
          status: InvoiceStatus.submitted,
          invoiceDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 30)),
          invoiceAmount: 50000,
          amountPaid: 0,
          paymentTerms: PaymentTerms.net30,
          invoiceNumber: 'INV-001',
          description: 'Test',
          createdDate: DateTime.now(),
        );

        await facade.createInvoice(invoice);
        final retrieved = await repository.getInvoice('inv1');
        expect(retrieved, isNotNull);
      });

      test('Create and retrieve line item', () async {
        final item = ProcurementLineItem(
          lineItemId: 'li1',
          procurementId: 'p1',
          itemName: 'Item 1',
          itemCode: 'ITEM001',
          quantity: 10,
          unitPrice: 100,
          uom: 'EA',
          description: 'Test',
          requestedBy: 'John',
          createdDate: DateTime.now(),
        );

        await repository.createLineItem(item);
        final retrieved = await repository.getLineItem('li1');
        expect(retrieved, isNotNull);
      });

      test('Get vendor count', () async {
        final vendor = Vendor(
          vendorId: 'v1',
          vendorName: 'Test',
          type: VendorType.supplier,
          status: VendorStatus.active,
          contactPerson: 'John',
          email: 'john@test.com',
          phone: '+1-555-0100',
          address: '123 Main',
          city: 'NY',
          country: 'USA',
          taxId: 'TAX123',
          creditLimit: 100000,
          creditUsed: 0,
          accountManager: 'Jane',
          createdDate: DateTime.now(),
        );

        await facade.createVendor(vendor);
        final count = await facade.getVendorCount();
        expect(count, equals(1));
      });

      test('Get total procurement budget', () async {
        final request = ProcurementRequest(
          procurementId: 'p1',
          departmentName: 'Ops',
          requester: 'John',
          status: ProcurementStatus.approved,
          requestDate: DateTime.now(),
          targetDate: DateTime.now().add(Duration(days: 5)),
          totalBudget: 100000,
          itemCount: 10,
          approver: 'Manager',
          description: 'Test',
          createdDate: DateTime.now(),
        );

        await facade.createProcurementRequest(request);
        final total = await repository.getTotalProcurementBudget();
        expect(total, equals(100000));
      });

      test('Get paid invoices', () async {
        final invoice = VendorInvoice(
          invoiceId: 'inv1',
          vendorId: 'v1',
          poId: 'po1',
          status: InvoiceStatus.paid,
          invoiceDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 30)),
          invoiceAmount: 50000,
          amountPaid: 50000,
          paymentTerms: PaymentTerms.net30,
          invoiceNumber: 'INV-001',
          description: 'Test',
          createdDate: DateTime.now(),
        );

        await facade.createInvoice(invoice);
        final paid = await facade.getPaidInvoices();
        expect(paid.length, equals(1));
      });

      test('Get overdue invoices', () async {
        final invoice = VendorInvoice(
          invoiceId: 'inv1',
          vendorId: 'v1',
          poId: 'po1',
          status: InvoiceStatus.submitted,
          invoiceDate: DateTime.now(),
          dueDate: DateTime.now().subtract(Duration(days: 5)),
          invoiceAmount: 50000,
          amountPaid: 0,
          paymentTerms: PaymentTerms.net30,
          invoiceNumber: 'INV-001',
          description: 'Test',
          createdDate: DateTime.now(),
        );

        await facade.createInvoice(invoice);
        final overdue = await facade.getOverdueInvoices();
        expect(overdue.length, equals(1));
      });

      test('Update vendor', () async {
        final vendor = Vendor(
          vendorId: 'v1',
          vendorName: 'Original',
          type: VendorType.supplier,
          status: VendorStatus.active,
          contactPerson: 'John',
          email: 'john@test.com',
          phone: '+1-555-0100',
          address: '123 Main',
          city: 'NY',
          country: 'USA',
          taxId: 'TAX123',
          creditLimit: 100000,
          creditUsed: 0,
          accountManager: 'Jane',
          createdDate: DateTime.now(),
        );

        await facade.createVendor(vendor);
        final updated =
            vendor.copyWith(vendorName: 'Updated', status: VendorStatus.inactive);
        await repository.updateVendor(updated);
        final retrieved = await repository.getVendor('v1');
        expect(retrieved!.vendorName, equals('Updated'));
        expect(retrieved.status, equals(VendorStatus.inactive));
      });

      test('Delete vendor', () async {
        final vendor = Vendor(
          vendorId: 'v1',
          vendorName: 'Test',
          type: VendorType.supplier,
          status: VendorStatus.active,
          contactPerson: 'John',
          email: 'john@test.com',
          phone: '+1-555-0100',
          address: '123 Main',
          city: 'NY',
          country: 'USA',
          taxId: 'TAX123',
          creditLimit: 100000,
          creditUsed: 0,
          accountManager: 'Jane',
          createdDate: DateTime.now(),
        );

        await facade.createVendor(vendor);
        final deleted = await repository.deleteVendor('v1');
        expect(deleted, isTrue);
        final retrieved = await repository.getVendor('v1');
        expect(retrieved, isNull);
      });
    });

    // ========== ENGINE TESTS ==========
    group('Engine Tests', () {
      test('VendorAnalysisEngine analyzes vendor performance', () async {
        final vendor = Vendor(
          vendorId: 'v1',
          vendorName: 'Test Vendor',
          type: VendorType.supplier,
          status: VendorStatus.active,
          contactPerson: 'John',
          email: 'john@test.com',
          phone: '+1-555-0100',
          address: '123 Main',
          city: 'NY',
          country: 'USA',
          taxId: 'TAX123',
          creditLimit: 100000,
          creditUsed: 50000,
          accountManager: 'Jane',
          createdDate: DateTime.now(),
        );

        await repository.createVendor(vendor);
        final analysis =
            await repository.manager.vendorAnalysisEngine.analyzeVendorPerformance('v1');
        expect(analysis['vendorId'], equals('v1'));
      });

      test('ProcurementAnalysisEngine calculates procurement cost', () async {
        final item = ProcurementLineItem(
          lineItemId: 'li1',
          procurementId: 'p1',
          itemName: 'Item 1',
          itemCode: 'ITEM001',
          quantity: 10,
          unitPrice: 100,
          uom: 'EA',
          description: 'Test',
          requestedBy: 'John',
          createdDate: DateTime.now(),
        );

        await repository.createLineItem(item);
        final cost = await repository.manager.procurementAnalysisEngine
            .calculateProcurementCost('p1');
        expect(cost, equals(1000));
      });

      test('PaymentAnalysisEngine calculates total due amount', () async {
        final invoice = VendorInvoice(
          invoiceId: 'inv1',
          vendorId: 'v1',
          poId: 'po1',
          status: InvoiceStatus.submitted,
          invoiceDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 30)),
          invoiceAmount: 50000,
          amountPaid: 25000,
          paymentTerms: PaymentTerms.net30,
          invoiceNumber: 'INV-001',
          description: 'Test',
          createdDate: DateTime.now(),
        );

        await repository.createInvoice(invoice);
        final due = await repository.manager.paymentAnalysisEngine
            .calculateTotalDueAmount();
        expect(due, equals(25000));
      });
    });

    // ========== MANAGER TESTS ==========
    group('Manager Tests', () {
      test('Manager provides dashboard', () async {
        final dashboard =
            await facade.getVendorProcurementDashboard();
        expect(dashboard, isNotNull);
        expect(dashboard.containsKey('totalVendors'), isTrue);
        expect(dashboard.containsKey('totalContracts'), isTrue);
      });
    });

    // ========== FACADE TESTS ==========
    group('Facade Tests', () {
      test('Facade creates vendor', () async {
        final vendor = Vendor(
          vendorId: 'v1',
          vendorName: 'Test',
          type: VendorType.supplier,
          status: VendorStatus.active,
          contactPerson: 'John',
          email: 'john@test.com',
          phone: '+1-555-0100',
          address: '123 Main',
          city: 'NY',
          country: 'USA',
          taxId: 'TAX123',
          creditLimit: 100000,
          creditUsed: 0,
          accountManager: 'Jane',
          createdDate: DateTime.now(),
        );

        final result = await facade.createVendor(vendor);
        expect(result, isNotNull);
      });

      test('Facade gets active vendors', () async {
        final vendor = Vendor(
          vendorId: 'v1',
          vendorName: 'Active',
          type: VendorType.supplier,
          status: VendorStatus.active,
          contactPerson: 'John',
          email: 'john@test.com',
          phone: '+1-555-0100',
          address: '123 Main',
          city: 'NY',
          country: 'USA',
          taxId: 'TAX123',
          creditLimit: 100000,
          creditUsed: 0,
          accountManager: 'Jane',
          createdDate: DateTime.now(),
        );

        await facade.createVendor(vendor);
        final active = await facade.getActiveVendors();
        expect(active.isNotEmpty, isTrue);
      });

      test('Facade gets preferred vendors', () async {
        final vendor = Vendor(
          vendorId: 'v1',
          vendorName: 'Preferred',
          type: VendorType.supplier,
          status: VendorStatus.active,
          contactPerson: 'John',
          email: 'john@test.com',
          phone: '+1-555-0100',
          address: '123 Main',
          city: 'NY',
          country: 'USA',
          taxId: 'TAX123',
          creditLimit: 100000,
          creditUsed: 0,
          isPreferred: true,
          accountManager: 'Jane',
          createdDate: DateTime.now(),
        );

        await facade.createVendor(vendor);
        final preferred = await facade.getPreferredVendors();
        expect(preferred.isNotEmpty, isTrue);
      });
    });

    // ========== INTEGRATION TESTS ==========
    group('Integration Tests', () {
      test('Complete procurement workflow', () async {
        // Create vendor
        final vendor = Vendor(
          vendorId: 'v1',
          vendorName: 'Test Vendor',
          type: VendorType.supplier,
          status: VendorStatus.active,
          contactPerson: 'John',
          email: 'john@test.com',
          phone: '+1-555-0100',
          address: '123 Main',
          city: 'NY',
          country: 'USA',
          taxId: 'TAX123',
          creditLimit: 100000,
          creditUsed: 0,
          accountManager: 'Jane',
          createdDate: DateTime.now(),
        );
        await facade.createVendor(vendor);

        // Create procurement request
        final request = ProcurementRequest(
          procurementId: 'p1',
          departmentName: 'Ops',
          requester: 'John',
          status: ProcurementStatus.approved,
          requestDate: DateTime.now(),
          targetDate: DateTime.now().add(Duration(days: 5)),
          totalBudget: 100000,
          itemCount: 1,
          approver: 'Manager',
          description: 'Test',
          createdDate: DateTime.now(),
        );
        await facade.createProcurementRequest(request);

        // Create purchase order
        final po = PurchaseOrder(
          poId: 'po1',
          vendorId: 'v1',
          procurementId: 'p1',
          status: PurchaseOrderStatus.pending,
          createdDate: DateTime.now(),
          targetDeliveryDate: DateTime.now().add(Duration(days: 5)),
          totalAmount: 50000,
          lineItemCount: 1,
          buyer: 'John',
          description: 'Test',
        );
        await facade.createPurchaseOrder(po);

        // Verify workflow
        final retrievedVendor = await repository.getVendor('v1');
        final retrievedRequest = await repository.getProcurementRequest('p1');
        final retrievedPO = await repository.getPurchaseOrder('po1');

        expect(retrievedVendor, isNotNull);
        expect(retrievedRequest, isNotNull);
        expect(retrievedPO, isNotNull);
      });

      test('Complete invoice and payment workflow', () async {
        // Create invoice
        final invoice = VendorInvoice(
          invoiceId: 'inv1',
          vendorId: 'v1',
          poId: 'po1',
          status: InvoiceStatus.submitted,
          invoiceDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 30)),
          invoiceAmount: 50000,
          amountPaid: 0,
          paymentTerms: PaymentTerms.net30,
          invoiceNumber: 'INV-001',
          description: 'Test',
          createdDate: DateTime.now(),
        );
        await facade.createInvoice(invoice);

        // Verify invoice
        final retrieved = await repository.getInvoice('inv1');
        expect(retrieved, isNotNull);
        expect(retrieved!.isPaid, isFalse);
        expect(retrieved.amountRemaining, equals(50000));

        // Update payment
        final paid = invoice.copyWith(
          status: InvoiceStatus.paid,
          amountPaid: 50000,
        );
        await repository.updateInvoice(paid);

        // Verify payment
        final updated = await repository.getInvoice('inv1');
        expect(updated!.isPaid, isTrue);
        expect(updated.amountRemaining, equals(0));
      });

      test('Contract lifecycle', () async {
        // Create contract
        final contract = VendorContract(
          contractId: 'c1',
          vendorId: 'v1',
          contractName: 'Supply Agreement',
          status: ContractStatus.draft,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 365)),
          contractValue: 500000,
          paymentTerms: 'Net 30',
          deliveryTerms: 'FOB',
          owner: 'Manager',
          description: 'Test',
          createdDate: DateTime.now(),
        );
        await facade.createContract(contract);

        // Verify draft status
        var retrieved = await repository.getContract('c1');
        expect(retrieved!.status, equals(ContractStatus.draft));

        // Activate contract
        final active = contract.copyWith(status: ContractStatus.active);
        await repository.updateContract(active);

        // Verify active status
        retrieved = await repository.getContract('c1');
        expect(retrieved!.isActive, isTrue);
      });

      test('Vendor performance tracking', () async {
        // Record performance
        final metrics = VendorPerformanceMetrics(
          metricsId: 'm1',
          vendorId: 'v1',
          onTimeDeliveryRate: 95.0,
          qualityScore: 4.5,
          communicationScore: 4.0,
          priceCompetitiveness: 4.2,
          totalOrdersCompleted: 50,
          defectRate: 2,
          overallRating: 4.5,
          evaluatedDate: DateTime.now(),
          evaluatedBy: 'Manager',
        );
        await repository.recordPerformanceMetrics(metrics);

        // Verify high performer
        final highPerformers = await facade.getHighPerformers();
        expect(highPerformers.isNotEmpty, isTrue);
      });
    });
  });
}
