import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/expense_repository.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ExpenseRepository(db);
});

final expenseSelectedCategoryProvider = StateProvider<String?>((ref) => null);

final expensesListStreamProvider = StreamProvider<List<Expense>>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  final category = ref.watch(expenseSelectedCategoryProvider);
  return repo.watchExpenses(category: category);
});

final totalExpensesProvider = FutureProvider<int>((ref) async {
  ref.watch(expensesListStreamProvider);
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.getTotalExpensesPaisa();
});
