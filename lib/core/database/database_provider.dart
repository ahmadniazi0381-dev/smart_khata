import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';
import '../../features/customers/domain/services/ledger_service.dart';
import '../../features/inventory/domain/services/inventory_service.dart';
import '../../features/sales/domain/services/sale_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final ledgerServiceProvider = Provider<LedgerService>((ref) {
  final db = ref.watch(databaseProvider);
  return LedgerService(db);
});

final inventoryServiceProvider = Provider<InventoryService>((ref) {
  final db = ref.watch(databaseProvider);
  return InventoryService(db);
});

final saleServiceProvider = Provider<SaleService>((ref) {
  final db = ref.watch(databaseProvider);
  return SaleService(db);
});
