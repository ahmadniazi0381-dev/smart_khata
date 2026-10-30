import 'package:drift/drift.dart';

class ShopSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get shopName => text().withLength(min: 1, max: 200)();
  TextColumn get phone => text().withLength(max: 20).nullable()();
  TextColumn get address => text().withLength(max: 500).nullable()();
  TextColumn get language => text().withDefault(const Constant('en'))();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  TextColumn get invoicePrefix => text().withDefault(const Constant('INV-'))();
  IntColumn get nextInvoiceNo => integer().withDefault(const Constant(1))();
  TextColumn get receiptFooter => text().nullable()();
  BoolColumn get setupDone => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
}
