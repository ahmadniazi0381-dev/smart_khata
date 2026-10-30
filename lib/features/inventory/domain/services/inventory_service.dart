import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/money.dart';

class InventoryService {
  final AppDatabase _db;
  final Uuid _uuid;

  InventoryService(this._db) : _uuid = const Uuid();

  /// Adjust stock for a product. [deltaMilli] can be positive (stock-in) or
  /// negative (stock-out / write-off). A negative result is always rejected.
  Future<void> adjustStock({
    required String productId,
    required int deltaMilli,
    required String movementType,
    String? note,
  }) async {
    if (deltaMilli == 0) {
      throw const ValidationException('Stock adjustment delta cannot be zero');
    }

    await _db.transaction(() async {
      final now = AppDateUtils.nowMs();

      if (deltaMilli > 0) {
        // Simple increment — always safe
        await _db.customUpdate(
          'UPDATE products SET stock_milli = stock_milli + ?, updated_at = ? WHERE id = ?',
          variables: [
            Variable.withInt(deltaMilli),
            Variable.withInt(now),
            Variable.withString(productId),
          ],
          updates: {_db.products},
        );
      } else {
        // Guarded decrement — rejects if stock would go below zero
        final updated = await _db.customUpdate(
          'UPDATE products SET stock_milli = stock_milli + ?, updated_at = ? '
          'WHERE id = ? AND stock_milli >= ?',
          variables: [
            Variable.withInt(deltaMilli), // negative
            Variable.withInt(now),
            Variable.withString(productId),
            Variable.withInt(-deltaMilli), // positive threshold
          ],
          updates: {_db.products},
        );

        if (updated == 0) {
          // Distinguish "product not found" from "insufficient stock"
          final product = await (_db.select(_db.products)
                ..where((p) => p.id.equals(productId)))
              .getSingleOrNull();
          if (product == null) {
            throw ValidationException('Product not found: $productId');
          }
          throw ValidationException(
              'Stock adjustment would result in negative stock. '
              'Available: ${product.stockMilli / 1000}');
        }
      }

      final updatedProduct = await (_db.select(_db.products)
            ..where((p) => p.id.equals(productId)))
          .getSingle();

      await _db.into(_db.stockMovements).insert(StockMovementsCompanion(
            id: Value(_uuid.v4()),
            productId: Value(productId),
            movementType: Value(movementType),
            qtyDeltaMilli: Value(deltaMilli),
            stockAfterMilli: Value(updatedProduct.stockMilli),
            note: Value(note),
            createdAt: Value(now),
            updatedAt: Value(now),
          ));
    });
  }

  /// Record a purchase: inserts the purchase + items, adds PURCHASE stock
  /// movements, and optionally updates each product's latest purchase price.
  Future<Purchase> receivePurchase({
    required String supplierName,
    String? reference,
    required List<({String productId, int qtyMilli, int unitCostPaisa})> items,
    required int paidPaisa,
    String? note,
    bool updateProductCost = true,
  }) async {
    if (items.isEmpty) {
      throw const ValidationException('Purchase must have at least one item');
    }

    // Total uses integer milli-unit division (same round-half-up as line total)
    final totalPaisa = items.fold<int>(
      0,
      (sum, i) => sum + Money.lineTotal(i.unitCostPaisa, i.qtyMilli),
    );

    if (paidPaisa < 0 || paidPaisa > totalPaisa) {
      throw ValidationException(
          'Paid amount must be between 0 and total (${Money.format(totalPaisa)})');
    }

    return _db.transaction<Purchase>(() async {
      final now = AppDateUtils.nowMs();
      final purchaseId = _uuid.v4();

      await _db.into(_db.purchases).insert(PurchasesCompanion(
            id: Value(purchaseId),
            supplierName: Value(supplierName),
            reference: Value(reference),
            totalPaisa: Value(totalPaisa),
            paidPaisa: Value(paidPaisa),
            purchaseDate: Value(now),
            note: Value(note),
            createdAt: Value(now),
            updatedAt: Value(now),
          ));

      for (final item in items) {
        final lineTotalPaisa =
            Money.lineTotal(item.unitCostPaisa, item.qtyMilli);

        await _db.into(_db.purchaseItems).insert(PurchaseItemsCompanion(
              id: Value(_uuid.v4()),
              purchaseId: Value(purchaseId),
              productId: Value(item.productId),
              qtyMilli: Value(item.qtyMilli),
              unitCostPaisa: Value(item.unitCostPaisa),
              lineTotalPaisa: Value(lineTotalPaisa),
              createdAt: Value(now),
              updatedAt: Value(now),
            ));

        // Add stock (always safe — purchases increase stock)
        await _db.customUpdate(
          'UPDATE products SET stock_milli = stock_milli + ?, updated_at = ? WHERE id = ?',
          variables: [
            Variable.withInt(item.qtyMilli),
            Variable.withInt(now),
            Variable.withString(item.productId),
          ],
          updates: {_db.products},
        );

        // Optionally update product's latest purchase cost
        if (updateProductCost) {
          await (_db.update(_db.products)
                ..where((p) => p.id.equals(item.productId)))
              .write(ProductsCompanion(
            purchasePricePaisa: Value(item.unitCostPaisa),
            updatedAt: Value(now),
          ));
        }

        final updatedProduct = await (_db.select(_db.products)
              ..where((p) => p.id.equals(item.productId)))
            .getSingle();

        await _db.into(_db.stockMovements).insert(StockMovementsCompanion(
              id: Value(_uuid.v4()),
              productId: Value(item.productId),
              movementType: const Value('PURCHASE'),
              qtyDeltaMilli: Value(item.qtyMilli),
              stockAfterMilli: Value(updatedProduct.stockMilli),
              refType: const Value('purchase'),
              refId: Value(purchaseId),
              createdAt: Value(now),
              updatedAt: Value(now),
            ));
      }

      return (_db.select(_db.purchases)..where((p) => p.id.equals(purchaseId)))
          .getSingle();
    });
  }
}
