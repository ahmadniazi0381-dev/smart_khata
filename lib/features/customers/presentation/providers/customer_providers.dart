import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/customer_repository.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final ledgerService = ref.watch(ledgerServiceProvider);
  return CustomerRepository(db, ledgerService);
});

final customerSearchQueryProvider = StateProvider<String>((ref) => '');

final customersListStreamProvider = StreamProvider<List<Customer>>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  final query = ref.watch(customerSearchQueryProvider);
  return repo.watchCustomers(searchQuery: query);
});

final customerDetailStreamProvider =
    StreamProvider.family<Customer?, String>((ref, id) {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.watchCustomer(id);
});

final customerLedgerStreamProvider =
    StreamProvider.family<List<LedgerEntry>, String>((ref, customerId) {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.watchLedgerEntries(customerId);
});

final customerBalanceProvider =
    FutureProvider.family<int, String>((ref, customerId) async {
  // Invalidate when ledger changes
  ref.watch(customerLedgerStreamProvider(customerId));
  final ledgerService = ref.watch(ledgerServiceProvider);
  return ledgerService.getBalance(customerId);
});
