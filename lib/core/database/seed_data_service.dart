import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../utils/date_utils.dart';
import 'app_database.dart';

class SeedDataService {
  final AppDatabase _db;
  static const _uuid = Uuid();

  SeedDataService(this._db);

  Future<void> seedDemoData() async {
    final now = AppDateUtils.nowMs();

    await _db.transaction(() async {
      // 1. Categories
      final catGroceriesId = _uuid.v4();
      await _db.into(_db.categories).insert(
            CategoriesCompanion.insert(
              id: catGroceriesId,
              name: 'Groceries (کرانہ)',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final catDairyId = _uuid.v4();
      await _db.into(_db.categories).insert(
            CategoriesCompanion.insert(
              id: catDairyId,
              name: 'Dairy & Beverages (ڈیری اور مشروبات)',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final catSnacksId = _uuid.v4();
      await _db.into(_db.categories).insert(
            CategoriesCompanion.insert(
              id: catSnacksId,
              name: 'Snacks & Bakery (بسکٹ اور نمکو)',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // 2. Products
      final productsData = [
        {
          'catId': catGroceriesId,
          'name': 'Sugar (چینی)',
          'sku': 'GRO-001',
          'unit': 'kg',
          'purchase': 14000,
          'selling': 17000,
          'stock': 50000,
          'lowStock': 10000,
        },
        {
          'catId': catGroceriesId,
          'name': 'Basmati Rice (باسمتی چاول)',
          'sku': 'GRO-002',
          'unit': 'kg',
          'purchase': 24000,
          'selling': 29000,
          'stock': 40000,
          'lowStock': 10000,
        },
        {
          'catId': catDairyId,
          'name': 'Milk Pack 1 Litre (دودھ)',
          'sku': 'DRY-001',
          'unit': 'pcs',
          'purchase': 18000,
          'selling': 20000,
          'stock': 30000,
          'lowStock': 6000,
        },
        {
          'catId': catGroceriesId,
          'name': 'Cooking Oil 1L (کوکنگ آئل)',
          'sku': 'GRO-003',
          'unit': 'ltr',
          'purchase': 45000,
          'selling': 52000,
          'stock': 20000,
          'lowStock': 5000,
        },
        {
          'catId': catSnacksId,
          'name': 'Tapal Danedar Tea 475g (چائے)',
          'sku': 'SNK-001',
          'unit': 'pcs',
          'purchase': 58000,
          'selling': 65000,
          'stock': 15000,
          'lowStock': 4000,
        },
        {
          'catId': catGroceriesId,
          'name': 'Wheat Flour 10kg (آٹا)',
          'sku': 'GRO-004',
          'unit': 'pcs',
          'purchase': 120000,
          'selling': 135000,
          'stock': 4000, // low stock!
          'lowStock': 10000,
        },
      ];

      for (final p in productsData) {
        final prodId = _uuid.v4();
        final stockMilli = p['stock'] as int;
        await _db.into(_db.products).insert(
              ProductsCompanion.insert(
                id: prodId,
                categoryId: Value(p['catId'] as String),
                name: p['name'] as String,
                sku: Value(p['sku'] as String),
                unit: Value(p['unit'] as String),
                purchasePricePaisa: Value(p['purchase'] as int),
                sellingPricePaisa: Value(p['selling'] as int),
                stockMilli: Value(stockMilli),
                lowStockMilli: Value(p['lowStock'] as int),
                createdAt: now,
                updatedAt: now,
              ),
            );

        // Record opening stock movement
        await _db.into(_db.stockMovements).insert(
              StockMovementsCompanion.insert(
                id: _uuid.v4(),
                productId: prodId,
                movementType: 'OPENING',
                qtyDeltaMilli: stockMilli,
                stockAfterMilli: stockMilli,
                refType: const Value('INITIAL'),
                note: const Value('Demo opening inventory'),
                createdAt: now,
                updatedAt: now,
              ),
            );
      }

      // 3. Customers
      final customersData = [
        {
          'name': 'Muhammad Tariq (محمد طارق)',
          'phone': '03011112233',
          'address': 'Main Bazar, Shop 12',
          'opening': 150000,
        },
        {
          'name': 'Rashid Ahmed (راشد احمد)',
          'phone': '03214445566',
          'address': 'Street 4, Sector G',
          'opening': 0,
        },
        {
          'name': 'Bilal Khan (بلال خان)',
          'phone': '03337778899',
          'address': 'Chowk Yadgar, Peshawar',
          'opening': 320000,
        },
      ];

      for (final c in customersData) {
        final custId = _uuid.v4();
        final openingPaisa = c['opening'] as int;

        await _db.into(_db.customers).insert(
              CustomersCompanion.insert(
                id: custId,
                name: c['name'] as String,
                phone: Value(c['phone'] as String),
                address: Value(c['address'] as String),
                openingBalancePaisa: Value(openingPaisa),
                createdAt: now,
                updatedAt: now,
              ),
            );

        if (openingPaisa > 0) {
          await _db.into(_db.ledgerEntries).insert(
                LedgerEntriesCompanion.insert(
                  id: _uuid.v4(),
                  customerId: custId,
                  entryType: 'OPENING',
                  direction: 'CREDIT',
                  amountPaisa: openingPaisa,
                  entryDate: now,
                  note: const Value('Demo opening balance'),
                  createdAt: now,
                  updatedAt: now,
                ),
              );
        }
      }

      // 4. Expenses
      await _db.into(_db.expenses).insert(
            ExpensesCompanion.insert(
              id: _uuid.v4(),
              title: 'Shop Rent (دکان کا کرایہ)',
              category: const Value('Rent'),
              amountPaisa: 2500000,
              expenseDate: now - 86400000 * 2,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await _db.into(_db.expenses).insert(
            ExpensesCompanion.insert(
              id: _uuid.v4(),
              title: 'Electricity Bill (بجلی کا بل)',
              category: const Value('Electricity / Utilities'),
              amountPaisa: 1250000,
              expenseDate: now - 86400000,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await _db.into(_db.expenses).insert(
            ExpensesCompanion.insert(
              id: _uuid.v4(),
              title: 'Staff Tea & Refreshments (چائے پانی)',
              category: const Value('Food & Tea'),
              amountPaisa: 45000,
              expenseDate: now,
              createdAt: now,
              updatedAt: now,
            ),
          );
    });
  }
}
