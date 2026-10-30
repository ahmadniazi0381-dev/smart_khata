import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/utils/date_utils.dart';
import 'package:smart_khata/features/customers/data/customer_repository.dart';
import 'package:smart_khata/features/customers/domain/services/ledger_service.dart';
import 'package:smart_khata/features/expenses/data/expense_repository.dart';
import 'package:smart_khata/features/inventory/data/inventory_repository.dart';
import 'package:smart_khata/features/reports/data/reports_repository.dart';
import 'package:smart_khata/features/sales/domain/models/cart_item.dart';
import 'package:smart_khata/features/sales/domain/services/sale_service.dart';

void main() {
  late AppDatabase db;
  late ExpenseRepository expenseRepo;
  late ReportsRepository reportsRepo;
  late InventoryRepository inventoryRepo;
  late CustomerRepository customerRepo;
  late LedgerService ledgerService;
  late SaleService saleService;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    expenseRepo = ExpenseRepository(db);
    reportsRepo = ReportsRepository(db);
    inventoryRepo = InventoryRepository(db);
    ledgerService = LedgerService(db);
    customerRepo = CustomerRepository(db, ledgerService);
    saleService = SaleService(db);

    // Seed settings
    final now = AppDateUtils.nowMs();
    await db.into(db.shopSettings).insert(
          ShopSettingsCompanion.insert(
            shopName: 'Test Shop',
            setupDone: const Value(true),
            createdAt: now,
            updatedAt: now,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('Day 4: Expense Repository Tests', () {
    test('Save, query, filter and delete expenses', () async {
      final now = AppDateUtils.nowMs();

      // 1. Add 3 expenses
      final e1 = await expenseRepo.saveExpense(
        title: 'Shop Rent',
        category: 'Rent',
        amountPaisa: 2500000, // PKR 25,000
        expenseDate: now,
      );

      await expenseRepo.saveExpense(
        title: 'Electricity Bill',
        category: 'Electricity / Utilities',
        amountPaisa: 850000, // PKR 8,500
        expenseDate: now,
      );

      await expenseRepo.saveExpense(
        title: 'Tea for guests',
        category: 'Food & Tea',
        amountPaisa: 35000, // PKR 350
        expenseDate: now,
      );

      // 2. Query all expenses
      final all = await expenseRepo.watchExpenses().first;
      expect(all.length, 3);

      // 3. Filter by category
      final rentOnly = await expenseRepo.watchExpenses(category: 'Rent').first;
      expect(rentOnly.length, 1);
      expect(rentOnly.first.title, 'Shop Rent');

      // 4. SQL aggregate total expenses
      final total = await expenseRepo.getTotalExpensesPaisa();
      expect(total, 3385000); // 25000 + 8500 + 350 = PKR 33,850

      // 5. Delete an expense
      await expenseRepo.deleteExpense(e1.id);
      final remaining = await expenseRepo.watchExpenses().first;
      expect(remaining.length, 2);

      final totalAfterDelete = await expenseRepo.getTotalExpensesPaisa();
      expect(totalAfterDelete, 885000);
    });
  });

  group('Day 4: Reports Repository SQL Aggregate Tests', () {
    test('Dashboard Summary calculates correct metrics via SQL', () async {
      // 1. Add customer with credit balance (Udhaar)
      final customer = await customerRepo.saveCustomer(
        name: 'Kamran Akmal',
        openingBalancePaisa: 500000, // PKR 5,000 opening credit
      );

      // 2. Add products with stock and purchase prices
      final p1 = await inventoryRepo.saveProduct(
        name: 'Sugar 50kg bag',
        unit: 'bag',
        purchasePricePaisa: 600000, // PKR 6,000 cost
        sellingPricePaisa: 750000, // PKR 7,500 selling
        initialStockMilli: 10000, // 10 bags
        lowStockMilli: 2000,
      );

      await inventoryRepo.saveProduct(
        name: 'Salt 1kg',
        unit: 'pack',
        purchasePricePaisa: 4000, // PKR 40 cost
        sellingPricePaisa: 6000, // PKR 60 selling
        initialStockMilli:
            1000, // 1 pack (<= lowStockMilli -> triggers low stock alert)
        lowStockMilli: 2000,
      );

      // 3. Make a sale today
      await saleService.createSale(
        cart: [
          CartItem(
            productId: p1.id,
            productName: p1.name,
            unit: p1.unit,
            unitPricePaisa: p1.sellingPricePaisa,
            costPricePaisa: p1.purchasePricePaisa,
            qtyMilli: 2000, // 2 bags = 15,000 PKR
          ),
        ],
        discountPaisa: 100000, // PKR 1,000 discount -> Total = 14,000 PKR
        paidPaisa: 1000000, // Paid 10,000 PKR
        customerId: customer.id, // Due 4,000 PKR added to customer ledger
      );

      // 4. Verify Dashboard Summary
      final summary = await reportsRepo.getDashboardSummary();

      // Today's Sales = 14,000 PKR (1400000 paisa)
      expect(summary.todaySalesPaisa, 1400000);
      expect(summary.todaySalesCount, 1);

      // Outstanding Credit = 5,000 opening + 4,000 due = 9,000 PKR (900000 paisa)
      expect(summary.outstandingCreditPaisa, 900000);

      // Low Stock Count: Salt has 1 pack remaining <= 2 packs threshold
      expect(summary.lowStockCount, 1);

      // Inventory Valuation:
      // Sugar remaining: 8 bags @ 6,000 PKR = 48,000 PKR (4800000 paisa)
      // Salt remaining: 1 pack @ 40 PKR = 40 PKR (4000 paisa)
      // Total inventory value = 4,804,000 paisa (PKR 48,040.00)
      expect(summary.totalInventoryValuePaisa, 4804000);

      // 7-day trend contains 7 points
      expect(summary.last7DaysSales.length, 7);
      expect(summary.last7DaysSales.last.totalPaisa, 1400000);
    });

    test('Sales Report calculates gross and net profit accurately', () async {
      final now = AppDateUtils.nowMs();
      final startToday = AppDateUtils.startOfToday();
      final endToday = AppDateUtils.endOfToday();

      // 1. Add product: Cost 80 PKR, Sell 100 PKR
      final product = await inventoryRepo.saveProduct(
        name: 'Biscuits',
        unit: 'pack',
        purchasePricePaisa: 8000, // 80 PKR cost
        sellingPricePaisa: 10000, // 100 PKR sell
        initialStockMilli: 100000, // 100 packs
      );

      // 2. Sell 10 packs:
      // Subtotal = 1,000 PKR (100000 paisa)
      // Cost = 10 * 80 PKR = 800 PKR (80000 paisa)
      // Discount = 50 PKR (5000 paisa)
      // Total Sales = 950 PKR (95000 paisa)
      // Gross Profit = Total Sales (950) - Total Cost (800) = 150 PKR (15000 paisa)
      await saleService.createSale(
        cart: [
          CartItem(
            productId: product.id,
            productName: product.name,
            unit: product.unit,
            unitPricePaisa: 10000,
            costPricePaisa: 8000,
            qtyMilli: 10000,
          ),
        ],
        discountPaisa: 5000,
        paidPaisa: 95000,
      );

      // 3. Record an expense today of 40 PKR (4000 paisa)
      await expenseRepo.saveExpense(
        title: 'Cleaner',
        amountPaisa: 4000,
        expenseDate: now,
      );

      // 4. Fetch Sales Report
      final report = await reportsRepo.getSalesReport(
        fromDateMs: startToday,
        toDateMs: endToday,
      );

      expect(report.totalSalesPaisa, 95000);
      expect(report.totalDiscountPaisa, 5000);
      expect(report.totalCostPaisa, 80000);
      expect(report.completedSalesCount, 1);
      expect(report.cancelledSalesCount, 0);

      // Estimated Gross Profit = 95,000 - 80,000 = 15,000 paisa (PKR 150)
      expect(report.estimatedGrossProfitPaisa, 15000);

      // Total Expenses = 4,000 paisa (PKR 40)
      expect(report.totalExpensesPaisa, 4000);

      // Estimated Net Profit = 15,000 - 4,000 = 11,000 paisa (PKR 110)
      expect(report.estimatedNetProfitPaisa, 11000);

      // Top Products list has Biscuits
      expect(report.topProducts.length, 1);
      expect(report.topProducts.first.productName, 'Biscuits');
      expect(report.topProducts.first.totalRevenuePaisa,
          100000); // 10 * 100 = 1000
    });
  });
}
