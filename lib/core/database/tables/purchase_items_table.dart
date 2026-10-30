import 'package:drift/drift.dart';
import 'purchases_table.dart';
import 'products_table.dart';

class PurchaseItems extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseId => text().references(Purchases, #id)();
  TextColumn get productId => text().references(Products, #id)();
  IntColumn get qtyMilli => integer()();
  IntColumn get unitCostPaisa => integer()();
  IntColumn get lineTotalPaisa => integer()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
