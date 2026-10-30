import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/date_utils.dart';
import '../domain/services/ledger_service.dart';

class CustomerRepository {
  final AppDatabase _db;
  final LedgerService _ledgerService;
  final Uuid _uuid;

  CustomerRepository(this._db, this._ledgerService) : _uuid = const Uuid();

  /// Watch customers with optional search filter on name or phone
  Stream<List<Customer>> watchCustomers(
      {String? searchQuery, bool activeOnly = true}) {
    final query = _db.select(_db.customers);
    if (activeOnly) {
      query.where((c) => c.isActive.equals(true));
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = '%${searchQuery.trim()}%';
      query.where((c) => c.name.like(term) | c.phone.like(term));
    }
    query.orderBy([(c) => OrderingTerm.asc(c.name)]);
    return query.watch();
  }

  Stream<Customer?> watchCustomer(String id) {
    return (_db.select(_db.customers)..where((c) => c.id.equals(id)))
        .watchSingleOrNull();
  }

  Future<Customer?> getCustomer(String id) {
    return (_db.select(_db.customers)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  /// Watch ledger entries for customer sorted newest first
  Stream<List<LedgerEntry>> watchLedgerEntries(String customerId) {
    return (_db.select(_db.ledgerEntries)
          ..where((l) => l.customerId.equals(customerId))
          ..orderBy([
            (l) => OrderingTerm.desc(l.entryDate),
            (l) => OrderingTerm.desc(l.createdAt)
          ]))
        .watch();
  }

  /// Create or update customer.
  /// If creating a new customer with opening balance, creates an OPENING ledger entry.
  Future<Customer> saveCustomer({
    String? id,
    required String name,
    String? phone,
    String? address,
    int openingBalancePaisa = 0,
  }) async {
    final now = AppDateUtils.nowMs();

    if (id != null) {
      await (_db.update(_db.customers)..where((c) => c.id.equals(id))).write(
        CustomersCompanion(
          name: Value(name.trim()),
          phone: Value(phone?.trim()),
          address: Value(address?.trim()),
          updatedAt: Value(now),
        ),
      );
      return (_db.select(_db.customers)..where((c) => c.id.equals(id)))
          .getSingle();
    } else {
      final customerId = _uuid.v4();
      await _db.into(_db.customers).insert(
            CustomersCompanion(
              id: Value(customerId),
              name: Value(name.trim()),
              phone: Value(phone?.trim()),
              address: Value(address?.trim()),
              openingBalancePaisa: Value(openingBalancePaisa),
              isActive: const Value(true),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      if (openingBalancePaisa > 0) {
        await _ledgerService.setOpeningBalance(
          customerId: customerId,
          amountPaisa: openingBalancePaisa,
        );
      }

      return (_db.select(_db.customers)..where((c) => c.id.equals(customerId)))
          .getSingle();
    }
  }

  /// Archive customer instead of deleting
  Future<void> archiveCustomer(String id) async {
    final now = AppDateUtils.nowMs();
    await (_db.update(_db.customers)..where((c) => c.id.equals(id))).write(
      CustomersCompanion(
        isActive: const Value(false),
        updatedAt: Value(now),
      ),
    );
  }
}
