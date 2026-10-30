import 'package:drift/drift.dart';

class Purchases extends Table {
  TextColumn get id => text()();
  TextColumn get supplierName => text().withLength(min: 1, max: 200)();
  TextColumn get reference => text().nullable()();
  IntColumn get totalPaisa => integer()();
  IntColumn get paidPaisa => integer().withDefault(const Constant(0))();
  IntColumn get purchaseDate => integer()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
