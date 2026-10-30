import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/money.dart';
import '../models/cart_item.dart';

class SaleService {
  final AppDatabase _db;
  final Uuid _uuid;

  SaleService(this._db) : _uuid = const Uuid();

  /// Create a sale with optional discount and partial payment.
  ///
  /// [cart]          — list of items (non-empty, all qty > 0)
  /// [discountPaisa] — must be 0..subtotal
  /// [paidPaisa]     — must be 0..total
  /// [customerId]    — required if duePaisa > 0
  /// [method]        — payment method
  Future<Sale> createSale({
    required List<CartItem> cart,
    required int discountPaisa,
    required int paidPaisa,
    String? customerId,
    String method = 'cash',
    String? note,
  }) async {
    // ── Validation ────────────────────────────────────────────────────────
    if (cart.isEmpty) throw const EmptyCartException();
    for (final item in cart) {
      if (item.qtyMilli <= 0) {
        throw ValidationException(
            'Quantity must be above zero for ${item.productName}');
      }
    }

    final subtotalPaisa =
        cart.fold<int>(0, (sum, item) => sum + item.lineTotalPaisa);

    if (discountPaisa < 0 || discountPaisa > subtotalPaisa) {
      throw ValidationException(
          'Discount must be between 0 and subtotal (${Money.format(subtotalPaisa)})');
    }

    final totalPaisa = subtotalPaisa - discountPaisa;

    if (paidPaisa < 0 || paidPaisa > totalPaisa) {
      throw ValidationException(
          'Paid amount must be between 0 and total (${Money.format(totalPaisa)})');
    }

    final duePaisa = totalPaisa - paidPaisa;

    if (duePaisa > 0 && customerId == null) {
      throw const CustomerRequiredException();
    }

    // ── Stock check (before transaction) ──────────────────────────────────
    // Pre-check gives a better error message; guarded UPDATE inside enforces.
    for (final item in cart) {
      final product = await (_db.select(_db.products)
            ..where((p) => p.id.equals(item.productId)))
          .getSingleOrNull();
      if (product == null) {
        throw ValidationException('Product not found: ${item.productName}');
      }
      if (product.stockMilli < item.qtyMilli) {
        throw InsufficientStockException(
          productName: product.name,
          availableMilli: product.stockMilli,
          requestedMilli: item.qtyMilli,
        );
      }
    }

    // ── Transaction ───────────────────────────────────────────────────────
    return _db.transaction<Sale>(() async {
      final now = AppDateUtils.nowMs();

      // 1. Get next invoice number
      final settings = await _db.select(_db.shopSettings).getSingleOrNull();
      final prefix = settings?.invoicePrefix ?? 'INV-';
      final nextNo = settings?.nextInvoiceNo ?? 1;
      final invoiceNo = '$prefix${nextNo.toString().padLeft(4, '0')}';

      if (settings != null) {
        await (_db.update(_db.shopSettings)
              ..where((s) => s.id.equals(settings.id)))
            .write(ShopSettingsCompanion(
          nextInvoiceNo: Value(nextNo + 1),
          updatedAt: Value(now),
        ));
      }

      // 2. Insert sale
      final saleId = _uuid.v4();
      final saleCompanion = SalesCompanion(
        id: Value(saleId),
        invoiceNo: Value(invoiceNo),
        customerId: Value(customerId),
        saleDate: Value(now),
        subtotalPaisa: Value(subtotalPaisa),
        discountPaisa: Value(discountPaisa),
        totalPaisa: Value(totalPaisa),
        paidPaisa: Value(paidPaisa),
        duePaisa: Value(duePaisa),
        status: const Value('completed'),
        note: Value(note),
        createdAt: Value(now),
        updatedAt: Value(now),
      );
      await _db.into(_db.sales).insert(saleCompanion);

      // 3. Insert sale items + stock movements
      for (final item in cart) {
        final itemId = _uuid.v4();
        await _db.into(_db.saleItems).insert(SaleItemsCompanion(
              id: Value(itemId),
              saleId: Value(saleId),
              productId: Value(item.productId),
              productNameSnapshot: Value(item.productName),
              unitSnapshot: Value(item.unit),
              qtyMilli: Value(item.qtyMilli),
              unitPricePaisa: Value(item.unitPricePaisa),
              costPricePaisa: Value(item.costPricePaisa),
              lineTotalPaisa: Value(item.lineTotalPaisa),
              createdAt: Value(now),
              updatedAt: Value(now),
            ));

        // Guarded decrement: fails atomically if stock would go below zero
        final updated = await _db.customUpdate(
          'UPDATE products SET stock_milli = stock_milli - ?, updated_at = ? '
          'WHERE id = ? AND stock_milli >= ?',
          variables: [
            Variable.withInt(item.qtyMilli),
            Variable.withInt(now),
            Variable.withString(item.productId),
            Variable.withInt(item.qtyMilli),
          ],
          updates: {_db.products},
        );

        if (updated == 0) {
          throw InsufficientStockException(
            productName: item.productName,
            availableMilli: 0,
            requestedMilli: item.qtyMilli,
          );
        }

        // Get new stock level for movement record
        final updatedProduct = await (_db.select(_db.products)
              ..where((p) => p.id.equals(item.productId)))
            .getSingle();

        // Insert stock movement
        await _db.into(_db.stockMovements).insert(StockMovementsCompanion(
              id: Value(_uuid.v4()),
              productId: Value(item.productId),
              movementType: const Value('SALE'),
              qtyDeltaMilli: Value(-item.qtyMilli),
              stockAfterMilli: Value(updatedProduct.stockMilli),
              refType: const Value('sale'),
              refId: Value(saleId),
              createdAt: Value(now),
              updatedAt: Value(now),
            ));
      }

      // 4. Insert payment (if any paid)
      String? paymentId;
      if (paidPaisa > 0) {
        paymentId = _uuid.v4();
        await _db.into(_db.payments).insert(PaymentsCompanion(
              id: Value(paymentId),
              saleId: Value(saleId),
              customerId: Value(customerId),
              amountPaisa: Value(paidPaisa),
              method: Value(method),
              paidAt: Value(now),
              createdAt: Value(now),
              updatedAt: Value(now),
            ));
      }

      // 5. Insert ledger entry for due amount (credit sale)
      if (duePaisa > 0 && customerId != null) {
        await _db.into(_db.ledgerEntries).insert(LedgerEntriesCompanion(
              id: Value(_uuid.v4()),
              customerId: Value(customerId),
              saleId: Value(saleId),
              entryType: const Value('CREDIT_SALE'),
              direction: const Value('CREDIT'),
              amountPaisa: Value(duePaisa),
              entryDate: Value(now),
              note: Value('Sale $invoiceNo'),
              createdAt: Value(now),
              updatedAt: Value(now),
            ));
      }

      // Return the saved sale
      return (_db.select(_db.sales)..where((s) => s.id.equals(saleId)))
          .getSingle();
    });
  }

  /// Cancel a completed sale. Restores stock, reverses ledger and payment.
  Future<void> cancelSale(String saleId, String reason) async {
    final sale = await (_db.select(_db.sales)
          ..where((s) => s.id.equals(saleId)))
        .getSingleOrNull();

    if (sale == null) {
      throw ValidationException('Sale not found: $saleId');
    }
    if (sale.status == 'cancelled') {
      throw const SaleAlreadyCancelledException();
    }

    final items = await (_db.select(_db.saleItems)
          ..where((i) => i.saleId.equals(saleId)))
        .get();

    await _db.transaction(() async {
      final now = AppDateUtils.nowMs();

      // 1. Mark sale as cancelled
      await (_db.update(_db.sales)..where((s) => s.id.equals(saleId))).write(
        SalesCompanion(
          status: const Value('cancelled'),
          cancelledAt: Value(now),
          cancelReason: Value(reason),
          updatedAt: Value(now),
        ),
      );

      // 2. Restore stock for each item
      for (final item in items) {
        await _db.customUpdate(
          'UPDATE products SET stock_milli = stock_milli + ?, updated_at = ? WHERE id = ?',
          variables: [
            Variable.withInt(item.qtyMilli),
            Variable.withInt(now),
            Variable.withString(item.productId),
          ],
          updates: {_db.products},
        );

        final updatedProduct = await (_db.select(_db.products)
              ..where((p) => p.id.equals(item.productId)))
            .getSingle();

        await _db.into(_db.stockMovements).insert(StockMovementsCompanion(
              id: Value(_uuid.v4()),
              productId: Value(item.productId),
              movementType: const Value('SALE_CANCEL'),
              qtyDeltaMilli: Value(item.qtyMilli),
              stockAfterMilli: Value(updatedProduct.stockMilli),
              refType: const Value('sale'),
              refId: Value(saleId),
              note: Value('Cancel: $reason'),
              createdAt: Value(now),
              updatedAt: Value(now),
            ));
      }

      // 3. Reverse ledger entry for due amount
      final ledgerEntry = await (_db.select(_db.ledgerEntries)
            ..where((l) =>
                l.saleId.equals(saleId) & l.entryType.equals('CREDIT_SALE')))
          .getSingleOrNull();

      if (ledgerEntry != null) {
        await _db.into(_db.ledgerEntries).insert(LedgerEntriesCompanion(
              id: Value(_uuid.v4()),
              customerId: Value(ledgerEntry.customerId),
              saleId: Value(saleId),
              entryType: const Value('REVERSAL'),
              direction: const Value('DEBIT'),
              amountPaisa: Value(ledgerEntry.amountPaisa),
              entryDate: Value(now),
              note: Value('Cancel: $reason'),
              reversesEntryId: Value(ledgerEntry.id),
              createdAt: Value(now),
              updatedAt: Value(now),
            ));
      }

      // 4. Reverse payment (negative payment row)
      final payment = await (_db.select(_db.payments)
            ..where((p) => p.saleId.equals(saleId)))
          .getSingleOrNull();

      if (payment != null) {
        final reversalId = _uuid.v4();
        await _db.into(_db.payments).insert(PaymentsCompanion(
              id: Value(reversalId),
              saleId: Value(saleId),
              customerId: Value(payment.customerId),
              amountPaisa: Value(-payment.amountPaisa),
              method: Value(payment.method),
              paidAt: Value(now),
              note: Value('Reversal: $reason'),
              reversesPaymentId: Value(payment.id),
              createdAt: Value(now),
              updatedAt: Value(now),
            ));
      }
    });
  }
}
