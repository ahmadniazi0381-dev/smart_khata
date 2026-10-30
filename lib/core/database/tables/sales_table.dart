import 'package:drift/drift.dart';
import 'customers_table.dart';

class Sales extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceNo => text()();
  TextColumn get customerId => text().nullable().references(Customers, #id)();
  IntColumn get saleDate => integer()();
  IntColumn get subtotalPaisa => integer()();
  IntColumn get discountPaisa => integer().withDefault(const Constant(0))();
  IntColumn get totalPaisa => integer()();
  IntColumn get paidPaisa => integer().withDefault(const Constant(0))();
  IntColumn get duePaisa => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('completed'))();
  IntColumn get cancelledAt => integer().nullable()();
  TextColumn get cancelReason => text().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
