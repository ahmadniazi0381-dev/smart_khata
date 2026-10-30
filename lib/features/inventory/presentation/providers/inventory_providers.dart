import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/inventory_repository.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return InventoryRepository(db);
});

final productSearchQueryProvider = StateProvider<String>((ref) => '');

final selectedCategoryIdProvider = StateProvider<String?>((ref) => null);

final activeCategoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.watchActiveCategories();
});

final productsListStreamProvider = StreamProvider<List<Product>>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  final categoryId = ref.watch(selectedCategoryIdProvider);
  final searchQuery = ref.watch(productSearchQueryProvider);
  return repo.watchProducts(
    categoryId: categoryId,
    searchQuery: searchQuery,
  );
});

final productDetailStreamProvider =
    StreamProvider.family<Product?, String>((ref, id) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.watchProduct(id);
});

final productStockMovementsStreamProvider =
    StreamProvider.family<List<StockMovement>, String>((ref, productId) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.watchStockMovements(productId);
});
