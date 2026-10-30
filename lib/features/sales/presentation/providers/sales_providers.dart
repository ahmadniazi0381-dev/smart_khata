import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/sale_repository.dart';

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SaleRepository(db);
});

final saleSearchQueryProvider = StateProvider<String>((ref) => '');

final saleStatusFilterProvider = StateProvider<String?>((ref) => null);

final salesListStreamProvider = StreamProvider<List<SaleListItem>>((ref) {
  final repo = ref.watch(saleRepositoryProvider);
  final query = ref.watch(saleSearchQueryProvider);
  final status = ref.watch(saleStatusFilterProvider);
  return repo.watchSales(searchQuery: query, statusFilter: status);
});

final saleDetailStreamProvider =
    StreamProvider.family<SaleWithDetails?, String>((ref, saleId) {
  final repo = ref.watch(saleRepositoryProvider);
  return repo.watchSaleWithDetails(saleId);
});
