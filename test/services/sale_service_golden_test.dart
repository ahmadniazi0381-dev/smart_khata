import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/errors/app_exceptions.dart';
import 'package:smart_khata/features/customers/domain/services/ledger_service.dart';
import 'package:smart_khata/features/sales/domain/models/cart_item.dart';
import 'package:smart_khata/features/sales/domain/services/sale_service.dart';
import 'package:uuid/uuid.dart';

// ────────────────────────────────────────────────────────────────────────────
// Helpers
// ────────────────────────────────────────────────────────────────────────────

AppDatabase _openTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

Future<void> _seedSettings(AppDatabase db) async {
  final now = DateTime.now().millisecondsSinceEpoch;
  await db.into(db.shopSettings).insert(ShopSettingsCompanion(
        shopName: const Value('Test Shop'),
        invoicePrefix: const Value('INV-'),
        nextInvoiceNo: const Value(1),
        setupDone: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
}

Future<String> _addProduct(
  AppDatabase db, {
  required String name,
  required int sellingPricePaisa,
  int purchasePricePaisa = 0,
  int stockMilli = 5000,
  String unit = 'kg',
}) async {
  final id = const Uuid().v4();
  final now = DateTime.now().millisecondsSinceEpoch;
  await db.into(db.products).insert(ProductsCompanion(
        id: Value(id),
        name: Value(name),
        unit: Value(unit),
        sellingPricePaisa: Value(sellingPricePaisa),
        purchasePricePaisa: Value(purchasePricePaisa),
        stockMilli: Value(stockMilli),
        lowStockMilli: const Value(1000),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
  return id;
}

Future<String> _addCustomer(AppDatabase db, String name) async {
  final id = const Uuid().v4();
  final now = DateTime.now().millisecondsSinceEpoch;
  await db.into(db.customers).insert(CustomersCompanion(
        id: Value(id),
        name: Value(name),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
  return id;
}

CartItem _item(String productId, String name, int pricePaisa, int qtyMilli,
        {String unit = 'kg', int costPaisa = 0}) =>
    CartItem(
      productId: productId,
      productName: name,
      unit: unit,
      unitPricePaisa: pricePaisa,
      costPricePaisa: costPaisa,
      qtyMilli: qtyMilli,
    );

// ────────────────────────────────────────────────────────────────────────────
// Tests
// ────────────────────────────────────────────────────────────────────────────

void main() {
  late AppDatabase db;
  late SaleService saleService;
  late LedgerService ledgerService;

  setUp(() async {
    db = _openTestDb();
    saleService = SaleService(db);
    ledgerService = LedgerService(db);
    await _seedSettings(db);
  });

  tearDown(() => db.close());

  // ── Golden 1 ─────────────────────────────────────────────────────────────
  test(
    'G1: Sugar 2×170 + Rice 1×290 + Milk 1×200 = 830 PKR, pay 500, credit 330',
    () async {
      final sugarId = await _addProduct(db,
          name: 'Sugar', sellingPricePaisa: 17000, stockMilli: 5000);
      final riceId = await _addProduct(db,
          name: 'Rice', sellingPricePaisa: 29000, stockMilli: 3000);
      final milkId = await _addProduct(db,
          name: 'Milk',
          sellingPricePaisa: 20000,
          stockMilli: 4000,
          unit: 'ltr');
      final customerId = await _addCustomer(db, 'Ali');

      final sale = await saleService.createSale(
        cart: [
          _item(sugarId, 'Sugar', 17000, 2000), // 2 kg × 170 = 340
          _item(riceId, 'Rice', 29000, 1000), // 1 kg × 290 = 290
          _item(milkId, 'Milk', 20000, 1000, unit: 'ltr'), // 1 ltr × 200 = 200
        ],
        discountPaisa: 0,
        paidPaisa: 50000, // PKR 500
        customerId: customerId,
        method: 'cash',
      );

      // Sale totals
      expect(sale.subtotalPaisa, 83000, reason: '340+290+200 = 830 PKR');
      expect(sale.paidPaisa, 50000);
      expect(sale.duePaisa, 33000);
      expect(sale.status, 'completed');

      // Stock reduced
      final sugar = await (db.select(db.products)
            ..where((p) => p.id.equals(sugarId)))
          .getSingle();
      expect(sugar.stockMilli, 3000, reason: '5000 - 2000 = 3000 milli');

      // One CREDIT_SALE ledger entry of 33000
      final entries = await (db.select(db.ledgerEntries)
            ..where((l) => l.customerId.equals(customerId)))
          .get();
      expect(entries.length, 1);
      expect(entries.first.entryType, 'CREDIT_SALE');
      expect(entries.first.direction, 'CREDIT');
      expect(entries.first.amountPaisa, 33000);

      // One payment row of 50000
      final payments = await (db.select(db.payments)
            ..where((p) => p.saleId.equals(sale.id)))
          .get();
      expect(payments.length, 1);
      expect(payments.first.amountPaisa, 50000);

      // Customer balance = 33000 (PKR 330)
      expect(await ledgerService.getBalance(customerId), 33000);
    },
  );

  // ── Golden 2 ─────────────────────────────────────────────────────────────
  test(
    'G2: OPENING 1000 → CREDIT +2500 → PAYMENT −1000 → CREDIT +500 = 3000',
    () async {
      final customerId = await _addCustomer(db, 'Kamran');

      // Opening balance PKR 1,000
      await ledgerService.setOpeningBalance(
          customerId: customerId, amountPaisa: 100000);

      // Credit sale PKR 2,500 (no cash paid)
      final p1 = await _addProduct(db,
          name: 'Oil',
          sellingPricePaisa: 250000,
          stockMilli: 5000,
          unit: 'ltr');
      await saleService.createSale(
        cart: [_item(p1, 'Oil', 250000, 1000, unit: 'ltr')],
        discountPaisa: 0,
        paidPaisa: 0,
        customerId: customerId,
      );

      // Payment PKR 1,000 — balance at this point = 1000+2500 = 3500
      await ledgerService.receivePayment(
          customerId: customerId, amountPaisa: 100000, method: 'cash');

      // Credit sale PKR 500 (no cash paid)
      final p2 = await _addProduct(db,
          name: 'Tea', sellingPricePaisa: 50000, stockMilli: 5000, unit: 'pcs');
      await saleService.createSale(
        cart: [_item(p2, 'Tea', 50000, 1000, unit: 'pcs')],
        discountPaisa: 0,
        paidPaisa: 0,
        customerId: customerId,
      );

      // Final balance: 100000 + 250000 - 100000 + 50000 = 300000 paisa = PKR 3000
      expect(await ledgerService.getBalance(customerId), 300000);
    },
  );

  // ── Golden 3 ─────────────────────────────────────────────────────────────
  test(
    'G3: Subtotal 1500, discount 100, paid 900 → total 1400, due 500',
    () async {
      final pId = await _addProduct(db,
          name: 'Flour', sellingPricePaisa: 15000, stockMilli: 10000);
      final cId = await _addCustomer(db, 'Bilal');

      final sale = await saleService.createSale(
        cart: [_item(pId, 'Flour', 15000, 10000)], // 10 kg × 150 = 1500
        discountPaisa: 10000, // PKR 100
        paidPaisa: 90000, // PKR 900
        customerId: cId,
      );

      expect(sale.subtotalPaisa, 150000);
      expect(sale.discountPaisa, 10000);
      expect(sale.totalPaisa, 140000);
      expect(sale.paidPaisa, 90000);
      expect(sale.duePaisa, 50000);
    },
  );

  // ── Golden 4 ─────────────────────────────────────────────────────────────
  test('G4: Selling more than available stock is rejected', () async {
    final pId = await _addProduct(db,
        name: 'Salt', sellingPricePaisa: 5000, stockMilli: 3000); // 3 kg only

    await expectLater(
      () => saleService.createSale(
        cart: [_item(pId, 'Salt', 5000, 5000)], // wants 5 kg
        discountPaisa: 0,
        paidPaisa: 25000, // paying full 250 PKR
      ),
      throwsA(isA<InsufficientStockException>()),
    );

    // Stock must remain unchanged
    final product = await (db.select(db.products)
          ..where((p) => p.id.equals(pId)))
        .getSingle();
    expect(product.stockMilli, 3000,
        reason: 'Stock must not change on rejection');
  });

  // ── Golden 5 ─────────────────────────────────────────────────────────────
  test('G5: Forced failure (non-existent product) leaves no partial rows',
      () async {
    await expectLater(
      () => saleService.createSale(
        cart: [_item('non-existent-id', 'Ghost', 1000, 1000)],
        discountPaisa: 0,
        paidPaisa: 1000,
      ),
      throwsA(isA<AppException>()),
    );

    final sales = await db.select(db.sales).get();
    final items = await db.select(db.saleItems).get();
    final movements = await db.select(db.stockMovements).get();

    expect(sales, isEmpty, reason: 'No sale row should remain');
    expect(items, isEmpty, reason: 'No sale_item row should remain');
    expect(movements, isEmpty, reason: 'No stock_movement row should remain');
  });

  // ── Golden 6 ─────────────────────────────────────────────────────────────
  test('G6: Cancel sale restores stock and customer balance', () async {
    final pId = await _addProduct(db,
        name: 'Ghee',
        sellingPricePaisa: 80000,
        purchasePricePaisa: 65000,
        stockMilli: 5000);
    final cId = await _addCustomer(db, 'Rashid');

    // Create sale: 2 kg Ghee, no cash paid (full credit)
    final sale = await saleService.createSale(
      cart: [_item(pId, 'Ghee', 80000, 2000, costPaisa: 65000)],
      discountPaisa: 0,
      paidPaisa: 0,
      customerId: cId,
    );

    // Stock = 5000 - 2000 = 3000; balance = 160 PKR
    var product = await (db.select(db.products)..where((p) => p.id.equals(pId)))
        .getSingle();
    expect(product.stockMilli, 3000);
    expect(await ledgerService.getBalance(cId), 160000);

    // Cancel
    await saleService.cancelSale(sale.id, 'Customer changed mind');

    // Restored
    product = await (db.select(db.products)..where((p) => p.id.equals(pId)))
        .getSingle();
    expect(product.stockMilli, 5000, reason: 'Stock fully restored');
    expect(await ledgerService.getBalance(cId), 0, reason: 'Balance cleared');

    // Sale marked cancelled
    final cancelledSale = await (db.select(db.sales)
          ..where((s) => s.id.equals(sale.id)))
        .getSingle();
    expect(cancelledSale.status, 'cancelled');
    expect(cancelledSale.cancelReason, 'Customer changed mind');
  });

  // ── Golden 7 ─────────────────────────────────────────────────────────────
  test('G7: 0.750 kg @ PKR 170/kg = PKR 127.50 = 12750 paisa', () async {
    final pId = await _addProduct(db,
        name: 'Basmati', sellingPricePaisa: 17000, stockMilli: 5000);

    final sale = await saleService.createSale(
      cart: [_item(pId, 'Basmati', 17000, 750)], // 0.75 kg
      discountPaisa: 0,
      paidPaisa: 12750, // paying full PKR 127.50
    );

    expect(sale.subtotalPaisa, 12750,
        reason: '17000 × 750 / 1000 = 12750 paisa');
    expect(sale.duePaisa, 0);
    expect(sale.paidPaisa, 12750);
  });
}
