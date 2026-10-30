import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/date_utils.dart';

class ExpenseRepository {
  final AppDatabase _db;
  final Uuid _uuid;

  ExpenseRepository(this._db) : _uuid = const Uuid();

  /// Watch expenses optionally filtered by date range and category.
  Stream<List<Expense>> watchExpenses({
    int? fromDateMs,
    int? toDateMs,
    String? category,
  }) {
    final query = _db.select(_db.expenses);

    if (fromDateMs != null) {
      query.where((e) => e.expenseDate.isBiggerOrEqualValue(fromDateMs));
    }
    if (toDateMs != null) {
      query.where((e) => e.expenseDate.isSmallerOrEqualValue(toDateMs));
    }
    if (category != null && category.isNotEmpty) {
      query.where((e) => e.category.equals(category));
    }

    query.orderBy([
      (e) => OrderingTerm.desc(e.expenseDate),
      (e) => OrderingTerm.desc(e.createdAt),
    ]);

    return query.watch();
  }

  /// Create or update an expense
  Future<Expense> saveExpense({
    String? id,
    required String title,
    String? category,
    required int amountPaisa,
    required int expenseDate,
    String? note,
  }) async {
    final now = AppDateUtils.nowMs();

    if (id != null) {
      await (_db.update(_db.expenses)..where((e) => e.id.equals(id))).write(
        ExpensesCompanion(
          title: Value(title.trim()),
          category: Value(category),
          amountPaisa: Value(amountPaisa),
          expenseDate: Value(expenseDate),
          note: Value(note?.trim()),
          updatedAt: Value(now),
        ),
      );
      return (_db.select(_db.expenses)..where((e) => e.id.equals(id)))
          .getSingle();
    } else {
      final newId = _uuid.v4();
      final companion = ExpensesCompanion(
        id: Value(newId),
        title: Value(title.trim()),
        category: Value(category),
        amountPaisa: Value(amountPaisa),
        expenseDate: Value(expenseDate),
        note: Value(note?.trim()),
        createdAt: Value(now),
        updatedAt: Value(now),
      );
      await _db.into(_db.expenses).insert(companion);
      return (_db.select(_db.expenses)..where((e) => e.id.equals(newId)))
          .getSingle();
    }
  }

  /// Delete an expense by ID
  Future<void> deleteExpense(String id) async {
    await (_db.delete(_db.expenses)..where((e) => e.id.equals(id))).go();
  }

  /// Get total expenses within date range via SQL aggregate
  Future<int> getTotalExpensesPaisa({int? fromDateMs, int? toDateMs}) async {
    final query = _db.selectOnly(_db.expenses)
      ..addColumns([_db.expenses.amountPaisa.sum()]);

    if (fromDateMs != null) {
      query.where(_db.expenses.expenseDate.isBiggerOrEqualValue(fromDateMs));
    }
    if (toDateMs != null) {
      query.where(_db.expenses.expenseDate.isSmallerOrEqualValue(toDateMs));
    }

    final row = await query.getSingle();
    return row.read(_db.expenses.amountPaisa.sum()) ?? 0;
  }
}
