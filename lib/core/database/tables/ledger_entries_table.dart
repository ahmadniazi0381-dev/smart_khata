import 'package:drift/drift.dart';
import 'customers_table.dart';
import 'sales_table.dart';
import 'payments_table.dart';

class LedgerEntries extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text().references(Customers, #id)();
  TextColumn get saleId => text().nullable().references(Sales, #id)();
  TextColumn get paymentId => text().nullable().references(Payments, #id)();
  // OPENING, CREDIT_SALE, PAYMENT, ADJUSTMENT, REVERSAL
  TextColumn get entryType => text()();
  // CREDIT (customer owes more) | DEBIT (customer owes less)
  TextColumn get direction => text()();
  IntColumn get amountPaisa => integer()();
  IntColumn get entryDate => integer()();
  TextColumn get note => text().nullable()();
  TextColumn get reversesEntryId =>
      text().nullable().references(LedgerEntries, #id)();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
