import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/shop_settings_table.dart';
import 'tables/categories_table.dart';
import 'tables/products_table.dart';
import 'tables/customers_table.dart';
import 'tables/sales_table.dart';
import 'tables/sale_items_table.dart';
import 'tables/payments_table.dart';
import 'tables/ledger_entries_table.dart';
import 'tables/stock_movements_table.dart';
import 'tables/expenses_table.dart';
import 'tables/purchases_table.dart';
import 'tables/purchase_items_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    ShopSettings,
    Categories,
    Products,
    Customers,
    Sales,
    SaleItems,
    Payments,
    LedgerEntries,
    StockMovements,
    Expenses,
    Purchases,
    PurchaseItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// For tests: AppDatabase(NativeDatabase.memory())
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA journal_mode = WAL');
        },
        onCreate: (m) async {
          await m.createAll();
          // Create indexes
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_sales_sale_date ON sales (sale_date)');
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_sales_customer_id ON sales (customer_id)');
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_sale_items_sale_id ON sale_items (sale_id)');
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_ledger_customer_date ON ledger_entries (customer_id, entry_date)');
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_stock_movements_product ON stock_movements (product_id, created_at)');
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_products_name ON products (name)');
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_customers_name ON customers (name)');
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_customers_phone ON customers (phone)');
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'smart_khata');
  }
}
