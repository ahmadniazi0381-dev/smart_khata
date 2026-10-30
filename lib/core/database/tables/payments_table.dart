import 'package:drift/drift.dart';
import 'sales_table.dart';
import 'customers_table.dart';

class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text().nullable().references(Sales, #id)();
  TextColumn get customerId => text().nullable().references(Customers, #id)();
  IntColumn get amountPaisa => integer()();
  TextColumn get method => text().withDefault(const Constant('cash'))();
  IntColumn get paidAt => integer()();
  TextColumn get note => text().nullable()();
  TextColumn get reversesPaymentId =>
      text().nullable().references(Payments, #id)();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
