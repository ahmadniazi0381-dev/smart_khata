import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

class SaleListItem {
  final Sale sale;
  final Customer? customer;

  const SaleListItem({
    required this.sale,
    this.customer,
  });
}

class SaleWithDetails {
  final Sale sale;
  final List<SaleItem> items;
  final Customer? customer;
  final Payment? payment;
  final ShopSetting? settings;

  const SaleWithDetails({
    required this.sale,
    required this.items,
    this.customer,
    this.payment,
    this.settings,
  });
}

class SaleRepository {
  final AppDatabase _db;

  SaleRepository(this._db);

  /// Watch sales list with customer joined, optional search filter and status filter.
  Stream<List<SaleListItem>> watchSales({
    String? searchQuery,
    String? statusFilter,
  }) {
    final query = _db.select(_db.sales).join([
      leftOuterJoin(
        _db.customers,
        _db.customers.id.equalsExp(_db.sales.customerId),
      ),
    ]);

    if (statusFilter != null && statusFilter.isNotEmpty) {
      query.where(_db.sales.status.equals(statusFilter));
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = '%${searchQuery.trim()}%';
      query.where(
        _db.sales.invoiceNo.like(term) | _db.customers.name.like(term),
      );
    }

    query.orderBy([
      OrderingTerm.desc(_db.sales.saleDate),
      OrderingTerm.desc(_db.sales.createdAt),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return SaleListItem(
          sale: row.readTable(_db.sales),
          customer: row.readTableOrNull(_db.customers),
        );
      }).toList();
    });
  }

  /// Watch a single sale with its items, customer, payment and shop settings.
  Stream<SaleWithDetails?> watchSaleWithDetails(String saleId) {
    final saleStream = (_db.select(_db.sales)
          ..where((s) => s.id.equals(saleId)))
        .watchSingleOrNull();

    return saleStream.asyncMap((sale) async {
      if (sale == null) return null;
      return _buildSaleWithDetails(sale);
    });
  }

  /// One-off fetch of sale with details.
  Future<SaleWithDetails?> getSaleWithDetails(String saleId) async {
    final sale = await (_db.select(_db.sales)
          ..where((s) => s.id.equals(saleId)))
        .getSingleOrNull();

    if (sale == null) return null;
    return _buildSaleWithDetails(sale);
  }

  Future<SaleWithDetails> _buildSaleWithDetails(Sale sale) async {
    final items = await (_db.select(_db.saleItems)
          ..where((i) => i.saleId.equals(sale.id))
          ..orderBy([(i) => OrderingTerm.asc(i.createdAt)]))
        .get();

    Customer? customer;
    if (sale.customerId != null) {
      customer = await (_db.select(_db.customers)
            ..where((c) => c.id.equals(sale.customerId!)))
          .getSingleOrNull();
    }

    // Get the primary payment for this sale (where reversesPaymentId is null)
    final payment = await (_db.select(_db.payments)
          ..where(
              (p) => p.saleId.equals(sale.id) & p.reversesPaymentId.isNull()))
        .getSingleOrNull();

    final settings = await _db.select(_db.shopSettings).getSingleOrNull();

    return SaleWithDetails(
      sale: sale,
      items: items,
      customer: customer,
      payment: payment,
      settings: settings,
    );
  }
}
