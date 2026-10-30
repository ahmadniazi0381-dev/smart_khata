import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/date_utils.dart';

class InventoryRepository {
  final AppDatabase _db;
  final Uuid _uuid;

  InventoryRepository(this._db) : _uuid = const Uuid();

  // ── Categories ─────────────────────────────────────────────────────────────

  Stream<List<Category>> watchActiveCategories() {
    return (_db.select(_db.categories)
          ..where((c) => c.isActive.equals(true))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  Future<void> saveCategory({String? id, required String name}) async {
    final now = AppDateUtils.nowMs();
    if (id != null) {
      await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
        CategoriesCompanion(
          name: Value(name.trim()),
          updatedAt: Value(now),
        ),
      );
    } else {
      await _db.into(_db.categories).insert(
            CategoriesCompanion(
              id: Value(_uuid.v4()),
              name: Value(name.trim()),
              isActive: const Value(true),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
    }
  }

  Future<void> archiveCategory(String id) async {
    final now = AppDateUtils.nowMs();
    await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        isActive: const Value(false),
        updatedAt: Value(now),
      ),
    );
  }

  // ── Products ───────────────────────────────────────────────────────────────

  Stream<List<Product>> watchProducts({
    String? categoryId,
    String? searchQuery,
    bool activeOnly = true,
  }) {
    final query = _db.select(_db.products);
    if (activeOnly) {
      query.where((p) => p.isActive.equals(true));
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      query.where((p) => p.categoryId.equals(categoryId));
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = '%${searchQuery.trim()}%';
      query.where((p) => p.name.like(term) | p.sku.like(term));
    }
    query.orderBy([(p) => OrderingTerm.asc(p.name)]);
    return query.watch();
  }

  Stream<Product?> watchProduct(String id) {
    return (_db.select(_db.products)..where((p) => p.id.equals(id)))
        .watchSingleOrNull();
  }

  Future<Product?> getProduct(String id) {
    return (_db.select(_db.products)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<List<StockMovement>> watchStockMovements(String productId) {
    return (_db.select(_db.stockMovements)
          ..where((s) => s.productId.equals(productId))
          ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
        .watch();
  }

  /// Create or update product.
  /// If creating new product with initialStockMilli > 0, records an OPENING movement.
  Future<Product> saveProduct({
    String? id,
    String? categoryId,
    required String name,
    String? sku,
    required String unit,
    required int purchasePricePaisa,
    required int sellingPricePaisa,
    int initialStockMilli = 0,
    int lowStockMilli = 1000,
  }) async {
    final now = AppDateUtils.nowMs();

    if (id != null) {
      await (_db.update(_db.products)..where((p) => p.id.equals(id))).write(
        ProductsCompanion(
          categoryId: Value(categoryId),
          name: Value(name.trim()),
          sku: Value(sku?.trim()),
          unit: Value(unit.trim()),
          purchasePricePaisa: Value(purchasePricePaisa),
          sellingPricePaisa: Value(sellingPricePaisa),
          lowStockMilli: Value(lowStockMilli),
          updatedAt: Value(now),
        ),
      );
      return (_db.select(_db.products)..where((p) => p.id.equals(id)))
          .getSingle();
    } else {
      final productId = _uuid.v4();

      return _db.transaction(() async {
        await _db.into(_db.products).insert(
              ProductsCompanion(
                id: Value(productId),
                categoryId: Value(categoryId),
                name: Value(name.trim()),
                sku: Value(sku?.trim()),
                unit: Value(unit.trim()),
                purchasePricePaisa: Value(purchasePricePaisa),
                sellingPricePaisa: Value(sellingPricePaisa),
                stockMilli: Value(initialStockMilli),
                lowStockMilli: Value(lowStockMilli),
                isActive: const Value(true),
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
            );

        if (initialStockMilli > 0) {
          await _db.into(_db.stockMovements).insert(
                StockMovementsCompanion(
                  id: Value(_uuid.v4()),
                  productId: Value(productId),
                  movementType: const Value('OPENING'),
                  qtyDeltaMilli: Value(initialStockMilli),
                  stockAfterMilli: Value(initialStockMilli),
                  note: const Value('Initial stock'),
                  createdAt: Value(now),
                  updatedAt: Value(now),
                ),
              );
        }

        return (_db.select(_db.products)..where((p) => p.id.equals(productId)))
            .getSingle();
      });
    }
  }

  Future<void> archiveProduct(String id) async {
    final now = AppDateUtils.nowMs();
    await (_db.update(_db.products)..where((p) => p.id.equals(id))).write(
      ProductsCompanion(
        isActive: const Value(false),
        updatedAt: Value(now),
      ),
    );
  }
}
