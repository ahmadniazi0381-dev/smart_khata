import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/errors/app_exceptions.dart';
import 'package:smart_khata/features/customers/data/customer_repository.dart';
import 'package:smart_khata/features/customers/domain/services/ledger_service.dart';
import 'package:smart_khata/features/inventory/data/inventory_repository.dart';
import 'package:smart_khata/features/sales/data/sale_repository.dart';
import 'package:smart_khata/features/sales/domain/services/sale_service.dart';
import 'package:smart_khata/features/sales/presentation/providers/cart_provider.dart';
import 'package:smart_khata/features/sales/presentation/widgets/receipt_pdf.dart';

void main() {
  late AppDatabase db;
  late SaleService saleService;
  late LedgerService ledgerService;
  late CustomerRepository customerRepo;
  late InventoryRepository inventoryRepo;
  late SaleRepository saleRepo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    ledgerService = LedgerService(db);
    saleService = SaleService(db);
    customerRepo = CustomerRepository(db, ledgerService);
    inventoryRepo = InventoryRepository(db);
    saleRepo = SaleRepository(db);

    // Initial setup
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.into(db.shopSettings).insert(
          ShopSettingsCompanion.insert(
            shopName: 'Al-Madina General Store',
            phone: const Value('03001234567'),
            address: const Value('Shop # 12, Main Bazaar, Lahore'),
            setupDone: const Value(true),
            createdAt: now,
            updatedAt: now,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('Day 3: Cart Notifier Unit Tests', () {
    test('Add item to cart and calculate totals', () {
      final notifier = CartNotifier();

      final p1 = Product(
        id: 'p1',
        name: 'Basmati Rice',
        unit: 'kg',
        purchasePricePaisa: 20000,
        sellingPricePaisa: 28000, // PKR 280
        stockMilli: 50000,
        lowStockMilli: 5000,
        isActive: true,
        createdAt: 0,
        updatedAt: 0,
      );

      notifier.addProduct(p1, qtyDeltaMilli: 2000); // 2 kg
      expect(notifier.state.items.length, 1);
      expect(notifier.state.items.first.qtyMilli, 2000);
      expect(notifier.state.subtotalPaisa, 56000); // 2 * 28000 = 560.00 PKR
      expect(notifier.state.totalPaisa, 56000);
      expect(notifier.state.paidPaisa, 56000); // fullCash by default
      expect(notifier.state.duePaisa, 0);

      // Add same product again -> increments quantity
      notifier.addProduct(p1, qtyDeltaMilli: 1000); // +1 kg = 3 kg
      expect(notifier.state.items.first.qtyMilli, 3000);
      expect(notifier.state.subtotalPaisa, 84000);

      // Apply discount
      notifier.setDiscount(4000); // PKR 40 discount
      expect(notifier.state.totalPaisa, 80000); // PKR 800
      expect(notifier.state.paidPaisa, 80000);

      // Switch to Full Credit (Udhaar)
      notifier.setPaymentType(PaymentType.fullCredit);
      expect(notifier.state.paidPaisa, 0);
      expect(notifier.state.duePaisa, 80000);

      // Switch to Partial Payment
      notifier.setPaymentType(PaymentType.partial);
      notifier.setCustomPaidPaisa(30000); // Pays PKR 300
      expect(notifier.state.paidPaisa, 30000);
      expect(notifier.state.duePaisa, 50000); // PKR 500 remaining

      // Update unit price
      notifier.updateUnitPrice('p1', 25000); // Bargained to PKR 250
      expect(notifier.state.subtotalPaisa, 75000); // 3 * 250 = 750

      // Update quantity to 0 removes item
      notifier.updateQuantity('p1', 0);
      expect(notifier.state.items.isEmpty, true);
      expect(notifier.state.subtotalPaisa, 0);
    });
  });

  group('Day 3: Sales Service & Repository Integration Tests', () {
    test('Cash sale creates sale, payment, decreases stock, no ledger entry',
        () async {
      // 1. Create product
      await inventoryRepo.saveProduct(
        name: 'Cooking Oil 1L',
        unit: 'ltr',
        purchasePricePaisa: 40000,
        sellingPricePaisa: 52000,
        initialStockMilli: 10000, // 10 liters
      );
      final products = await db.select(db.products).get();
      final oil = products.first;

      // 2. Add to cart & checkout
      final cartNotifier = CartNotifier();
      cartNotifier.addProduct(oil, qtyDeltaMilli: 2000); // 2 liters = 1040 PKR
      expect(cartNotifier.state.totalPaisa, 104000);

      final sale = await saleService.createSale(
        cart: cartNotifier.state.items,
        discountPaisa: cartNotifier.state.discountPaisa,
        paidPaisa: cartNotifier.state.paidPaisa,
        customerId: null, // Walk-in customer allowed for cash sale
        method: 'cash',
      );

      expect(sale.invoiceNo, 'INV-0001');
      expect(sale.totalPaisa, 104000);
      expect(sale.paidPaisa, 104000);
      expect(sale.duePaisa, 0);
      expect(sale.status, 'completed');

      // Stock should have decreased by 2000 milli
      final updatedOil = await (db.select(db.products)
            ..where((p) => p.id.equals(oil.id)))
          .getSingle();
      expect(updatedOil.stockMilli, 8000); // 10 - 2 = 8

      // Payment row created
      final payments = await (db.select(db.payments)
            ..where((p) => p.saleId.equals(sale.id)))
          .get();
      expect(payments.length, 1);
      expect(payments.first.amountPaisa, 104000);

      // No customer ledger entry for cash sale
      final ledger = await db.select(db.ledgerEntries).get();
      expect(ledger.isEmpty, true);

      // Verify SaleRepository query
      final salesList = await saleRepo.watchSales().first;
      expect(salesList.length, 1);
      expect(salesList.first.sale.invoiceNo, 'INV-0001');
      expect(salesList.first.customer, isNull);

      // Verify SaleWithDetails
      final details = await saleRepo.getSaleWithDetails(sale.id);
      expect(details, isNotNull);
      expect(details!.items.length, 1);
      expect(details.items.first.productNameSnapshot, 'Cooking Oil 1L');
      expect(details.payment, isNotNull);
      expect(details.settings?.shopName, 'Al-Madina General Store');

      // Verify Receipt PDF Generation works without error
      final pdfBytes = await ReceiptPdfHelper.generate(details);
      expect(pdfBytes.isNotEmpty, true);
    });

    test('Credit sale updates customer ledger and requires customer', () async {
      // 1. Create customer
      final customer = await customerRepo.saveCustomer(
        name: 'Tariq Mehmood',
        phone: '03129876543',
      );

      // 2. Create product
      await inventoryRepo.saveProduct(
        name: 'Wheat Flour 10kg',
        unit: 'bag',
        purchasePricePaisa: 120000,
        sellingPricePaisa: 145000,
        initialStockMilli: 5000, // 5 bags
      );
      final product = (await db.select(db.products).get()).first;

      // 3. Attempt credit sale without customer -> throws CustomerRequiredException
      final cartNotifier = CartNotifier();
      cartNotifier.addProduct(product, qtyDeltaMilli: 1000); // 1 bag = 1450 PKR
      cartNotifier.setPaymentType(PaymentType.fullCredit);

      expect(
        () => saleService.createSale(
          cart: cartNotifier.state.items,
          discountPaisa: 0,
          paidPaisa: 0,
          customerId: null,
        ),
        throwsA(isA<CustomerRequiredException>()),
      );

      // 4. Complete credit sale with customer
      final sale = await saleService.createSale(
        cart: cartNotifier.state.items,
        discountPaisa: 0,
        paidPaisa: 0,
        customerId: customer.id,
      );

      expect(sale.duePaisa, 145000);

      // Verify customer ledger balance updated
      final balance = await ledgerService.getBalance(customer.id);
      expect(balance, 145000);

      // Verify SaleListItem has customer info
      final salesList = await saleRepo.watchSales().first;
      expect(salesList.first.customer?.name, 'Tariq Mehmood');

      // 5. Test Cancel Sale: restores stock and reverses customer ledger
      await saleService.cancelSale(sale.id, 'Customer returned items');

      final cancelledDetails = await saleRepo.getSaleWithDetails(sale.id);
      expect(cancelledDetails!.sale.status, 'cancelled');
      expect(cancelledDetails.sale.cancelReason, 'Customer returned items');

      // Customer balance should be 0 again
      final balanceAfterCancel = await ledgerService.getBalance(customer.id);
      expect(balanceAfterCancel, 0);

      // Product stock restored to 5000
      final productAfterCancel = await (db.select(db.products)
            ..where((p) => p.id.equals(product.id)))
          .getSingle();
      expect(productAfterCancel.stockMilli, 5000);
    });

    test('Filter and search sales', () async {
      final customer = await customerRepo.saveCustomer(name: 'Zahid Khan');

      await inventoryRepo.saveProduct(
        name: 'Tea 500g',
        unit: 'pack',
        purchasePricePaisa: 60000,
        sellingPricePaisa: 80000,
        initialStockMilli: 10000,
      );
      final product = (await db.select(db.products).get()).first;

      // Sale 1: Completed cash sale
      final cart1 = CartNotifier();
      cart1.addProduct(product, qtyDeltaMilli: 1000);
      final s1 = await saleService.createSale(
        cart: cart1.state.items,
        discountPaisa: 0,
        paidPaisa: 80000,
      );

      // Sale 2: Cancelled credit sale
      final cart2 = CartNotifier();
      cart2.addProduct(product, qtyDeltaMilli: 1000);
      final s2 = await saleService.createSale(
        cart: cart2.state.items,
        discountPaisa: 0,
        paidPaisa: 0,
        customerId: customer.id,
      );
      await saleService.cancelSale(s2.id, 'Wrong order');

      // Search by customer name
      final searchZahid = await saleRepo.watchSales(searchQuery: 'Zahid').first;
      expect(searchZahid.length, 1);
      expect(searchZahid.first.sale.id, s2.id);

      // Search by invoice prefix
      final searchInv =
          await saleRepo.watchSales(searchQuery: s1.invoiceNo).first;
      expect(searchInv.length, 1);
      expect(searchInv.first.sale.id, s1.id);

      // Filter by status completed
      final completed =
          await saleRepo.watchSales(statusFilter: 'completed').first;
      expect(completed.length, 1);
      expect(completed.first.sale.id, s1.id);

      // Filter by status cancelled
      final cancelled =
          await saleRepo.watchSales(statusFilter: 'cancelled').first;
      expect(cancelled.length, 1);
      expect(cancelled.first.sale.id, s2.id);
    });
  });
}
