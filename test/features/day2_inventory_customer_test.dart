import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/errors/app_exceptions.dart';
import 'package:smart_khata/features/customers/data/customer_repository.dart';
import 'package:smart_khata/features/customers/domain/services/ledger_service.dart';
import 'package:smart_khata/features/inventory/data/inventory_repository.dart';
import 'package:smart_khata/features/inventory/domain/services/inventory_service.dart';

void main() {
  late AppDatabase db;
  late LedgerService ledgerService;
  late InventoryService inventoryService;
  late CustomerRepository customerRepo;
  late InventoryRepository inventoryRepo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    ledgerService = LedgerService(db);
    inventoryService = InventoryService(db);
    customerRepo = CustomerRepository(db, ledgerService);
    inventoryRepo = InventoryRepository(db);
  });

  tearDown(() => db.close());

  group('Day 2: Customer & Ledger Tests', () {
    test('Add 5 customers, verify search and opening balance ledger entry',
        () async {
      final c1 = await customerRepo.saveCustomer(
        name: 'Muhammad Ali',
        phone: '03001234567',
        openingBalancePaisa: 50000, // PKR 500
      );
      final c2 = await customerRepo.saveCustomer(
        name: 'Usman Khan',
        phone: '03217654321',
      );
      final c3 = await customerRepo.saveCustomer(
        name: 'Bilal Ahmed',
        phone: '03339876543',
        openingBalancePaisa: 120000, // PKR 1200
      );
      final c4 = await customerRepo.saveCustomer(
        name: 'Tariq Mahmood',
        phone: '03451122334',
      );
      final c5 = await customerRepo.saveCustomer(
        name: 'Hamza Farooq',
        phone: '03125566778',
      );

      // Verify 5 active customers
      final all = await customerRepo.watchCustomers().first;
      expect(all.length, 5);

      // Verify search by name
      final searchAli =
          await customerRepo.watchCustomers(searchQuery: 'Ali').first;
      expect(searchAli.length, 1);
      expect(searchAli.first.id, c1.id);

      // Verify search by phone
      final searchPhone =
          await customerRepo.watchCustomers(searchQuery: '0321').first;
      expect(searchPhone.length, 1);
      expect(searchPhone.first.id, c2.id);

      // Verify opening balances
      expect(await ledgerService.getBalance(c1.id), 50000);
      expect(await ledgerService.getBalance(c2.id), 0);
      expect(await ledgerService.getBalance(c3.id), 120000);
      expect(await ledgerService.getBalance(c4.id), 0);
      expect(await ledgerService.getBalance(c5.id), 0);
    });

    test('Record payment, balance reduces and audit trail recorded', () async {
      final customer = await customerRepo.saveCustomer(
        name: 'Zahid Hussain',
        openingBalancePaisa: 100000, // PKR 1,000
      );

      expect(await ledgerService.getBalance(customer.id), 100000);

      // Pay PKR 400
      await ledgerService.receivePayment(
        customerId: customer.id,
        amountPaisa: 40000,
        method: 'cash',
        note: 'Cash payment counter',
      );

      // Balance = 1000 - 400 = 600 PKR (60,000 paisa)
      expect(await ledgerService.getBalance(customer.id), 60000);

      // Overpayment rejected
      expect(
        () => ledgerService.receivePayment(
          customerId: customer.id,
          amountPaisa: 70000, // exceeds 60000
          method: 'cash',
        ),
        throwsA(isA<OverpaymentException>()),
      );

      // Verify ledger entries
      final entries = await customerRepo.watchLedgerEntries(customer.id).first;
      expect(entries.length, 2); // OPENING and PAYMENT
    });

    test('Adjust balance requires reason and provides audit trail', () async {
      final customer = await customerRepo.saveCustomer(
        name: 'Imran Khan',
        openingBalancePaisa: 50000,
      );

      // Increase balance by PKR 200 with reason
      await ledgerService.adjustBalance(
        customerId: customer.id,
        signedAmountPaisa: 20000,
        reason: 'Omitted previous bill #45',
      );
      expect(await ledgerService.getBalance(customer.id), 70000);

      // Decrease balance by PKR 100 with reason
      await ledgerService.adjustBalance(
        customerId: customer.id,
        signedAmountPaisa: -10000,
        reason: 'Agreed loyalty discount',
      );
      expect(await ledgerService.getBalance(customer.id), 60000);

      // Empty reason rejected
      expect(
        () => ledgerService.adjustBalance(
          customerId: customer.id,
          signedAmountPaisa: 5000,
          reason: '  ',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Archive customer hides from active list but preserves ledger',
        () async {
      final customer = await customerRepo.saveCustomer(
        name: 'Archived Customer',
        openingBalancePaisa: 30000,
      );

      expect((await customerRepo.watchCustomers().first).length, 1);

      // Archive
      await customerRepo.archiveCustomer(customer.id);

      // Not in active list
      expect((await customerRepo.watchCustomers().first), isEmpty);

      // Ledger balance still intact
      expect(await ledgerService.getBalance(customer.id), 30000);
    });
  });

  group('Day 2: Inventory & Products Tests', () {
    test('Add 10 products with categories and initial stock', () async {
      // Create categories
      await inventoryRepo.saveCategory(name: 'Grocery');
      await inventoryRepo.saveCategory(name: 'Dairy');
      await inventoryRepo.saveCategory(name: 'Beverages');

      final categories = await inventoryRepo.watchActiveCategories().first;
      expect(categories.length, 3);
      final groceryId = categories.firstWhere((c) => c.name == 'Grocery').id;
      final dairyId = categories.firstWhere((c) => c.name == 'Dairy').id;
      final beverageId = categories.firstWhere((c) => c.name == 'Beverages').id;

      // Add 10 products
      final p1 = await inventoryRepo.saveProduct(
        categoryId: groceryId,
        name: 'Sugar 1kg',
        unit: 'kg',
        purchasePricePaisa: 14000,
        sellingPricePaisa: 16000,
        initialStockMilli: 50000, // 50 kg
      );
      await inventoryRepo.saveProduct(
        categoryId: groceryId,
        name: 'Flour 5kg',
        unit: 'bag',
        purchasePricePaisa: 55000,
        sellingPricePaisa: 62000,
        initialStockMilli: 20000,
      );
      await inventoryRepo.saveProduct(
        categoryId: groceryId,
        name: 'Rice Basmati',
        unit: 'kg',
        purchasePricePaisa: 28000,
        sellingPricePaisa: 32000,
        initialStockMilli: 40000,
      );
      await inventoryRepo.saveProduct(
        categoryId: groceryId,
        name: 'Cooking Oil 1L',
        unit: 'ltr',
        purchasePricePaisa: 42000,
        sellingPricePaisa: 47000,
        initialStockMilli: 15000,
      );
      await inventoryRepo.saveProduct(
        categoryId: dairyId,
        name: 'Fresh Milk',
        unit: 'ltr',
        purchasePricePaisa: 18000,
        sellingPricePaisa: 21000,
        initialStockMilli: 30000,
      );
      await inventoryRepo.saveProduct(
        categoryId: dairyId,
        name: 'Yogurt 500g',
        unit: 'cup',
        purchasePricePaisa: 9000,
        sellingPricePaisa: 11000,
        initialStockMilli: 25000,
      );
      await inventoryRepo.saveProduct(
        categoryId: dairyId,
        name: 'Butter 200g',
        unit: 'pcs',
        purchasePricePaisa: 22000,
        sellingPricePaisa: 26000,
        initialStockMilli: 10000,
      );
      await inventoryRepo.saveProduct(
        categoryId: beverageId,
        name: 'Black Tea 250g',
        unit: 'box',
        purchasePricePaisa: 31000,
        sellingPricePaisa: 36000,
        initialStockMilli: 18000,
      );
      await inventoryRepo.saveProduct(
        categoryId: beverageId,
        name: 'Green Tea 100g',
        unit: 'box',
        purchasePricePaisa: 19000,
        sellingPricePaisa: 23000,
        initialStockMilli: 12000,
      );
      await inventoryRepo.saveProduct(
        categoryId: beverageId,
        name: 'Mineral Water 1.5L',
        unit: 'bottle',
        purchasePricePaisa: 6000,
        sellingPricePaisa: 9000,
        initialStockMilli: 48000,
      );

      // Total products
      final allProducts = await inventoryRepo.watchProducts().first;
      expect(allProducts.length, 10);

      // Filter by category
      final dairyProducts =
          await inventoryRepo.watchProducts(categoryId: dairyId).first;
      expect(dairyProducts.length, 3);

      // Search
      final teaProducts =
          await inventoryRepo.watchProducts(searchQuery: 'Tea').first;
      expect(teaProducts.length, 2);

      // Initial stock movement created
      final movements = await inventoryRepo.watchStockMovements(p1.id).first;
      expect(movements.length, 1);
      expect(movements.first.movementType, 'OPENING');
      expect(movements.first.qtyDeltaMilli, 50000);
      expect(movements.first.stockAfterMilli, 50000);
    });

    test(
        'Stock adjustments update stock and movement log, reject negative stock',
        () async {
      final p = await inventoryRepo.saveProduct(
        name: 'Salt 800g',
        unit: 'pack',
        purchasePricePaisa: 4000,
        sellingPricePaisa: 5000,
        initialStockMilli: 10000, // 10 packs
      );

      // Stock in +5 packs
      await inventoryService.adjustStock(
        productId: p.id,
        deltaMilli: 5000,
        movementType: 'ADJUSTMENT',
        note: 'Restock',
      );

      var updated = await inventoryRepo.getProduct(p.id);
      expect(updated?.stockMilli, 15000);

      // Reduce stock -3 packs
      await inventoryService.adjustStock(
        productId: p.id,
        deltaMilli: -3000,
        movementType: 'DAMAGE',
        note: 'Torn packaging',
      );

      updated = await inventoryRepo.getProduct(p.id);
      expect(updated?.stockMilli, 12000);

      // Attempt to reduce more than available (15 packs when only 12 available)
      expect(
        () => inventoryService.adjustStock(
          productId: p.id,
          deltaMilli: -15000,
          movementType: 'ADJUSTMENT',
        ),
        throwsA(isA<ValidationException>()),
      );

      // Stock unchanged after failed adjustment
      updated = await inventoryRepo.getProduct(p.id);
      expect(updated?.stockMilli, 12000);
    });

    test('Archive product removes from active listing', () async {
      final p = await inventoryRepo.saveProduct(
        name: 'Discontinued Item',
        unit: 'pcs',
        purchasePricePaisa: 1000,
        sellingPricePaisa: 1500,
      );

      expect((await inventoryRepo.watchProducts().first).length, 1);

      await inventoryRepo.archiveProduct(p.id);

      expect(await inventoryRepo.watchProducts().first, isEmpty);
      // Product still readable by ID
      final archived = await inventoryRepo.getProduct(p.id);
      expect(archived?.isActive, false);
    });
  });
}
