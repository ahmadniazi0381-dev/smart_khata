import 'package:drift/drift.dart';
import 'categories_table.dart';

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get sku => text().nullable()();
  TextColumn get unit => text().withDefault(const Constant('pcs'))();
  IntColumn get purchasePricePaisa =>
      integer().withDefault(const Constant(0))();
  IntColumn get sellingPricePaisa => integer().withDefault(const Constant(0))();
  IntColumn get stockMilli => integer().withDefault(const Constant(0))();
  IntColumn get lowStockMilli => integer().withDefault(const Constant(1000))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
