import 'package:drift/drift.dart';
import 'products_table.dart';

class StockMovements extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().references(Products, #id)();
  // OPENING, PURCHASE, SALE, SALE_CANCEL, ADJUSTMENT, DAMAGE, RETURN
  TextColumn get movementType => text()();
  // signed — negative for outflows
  IntColumn get qtyDeltaMilli => integer()();
  IntColumn get stockAfterMilli => integer()();
  TextColumn get refType => text().nullable()();
  TextColumn get refId => text().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
