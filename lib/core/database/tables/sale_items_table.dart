import 'package:drift/drift.dart';
import 'sales_table.dart';
import 'products_table.dart';

class SaleItems extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text().references(Sales, #id)();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get productNameSnapshot => text()();
  TextColumn get unitSnapshot => text()();
  IntColumn get qtyMilli => integer()();
  IntColumn get unitPricePaisa => integer()();
  IntColumn get costPricePaisa => integer()();
  IntColumn get lineTotalPaisa => integer()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
