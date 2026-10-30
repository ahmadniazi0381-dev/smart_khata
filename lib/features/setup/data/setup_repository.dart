import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/date_utils.dart';

class SetupRepository {
  final AppDatabase _db;

  SetupRepository(this._db);

  Stream<ShopSetting?> watchSettings() {
    return _db.select(_db.shopSettings).watchSingleOrNull();
  }

  Future<ShopSetting?> getSettings() {
    return _db.select(_db.shopSettings).getSingleOrNull();
  }

  Future<void> saveSettings({
    required String shopName,
    String? phone,
    String? address,
  }) async {
    final now = AppDateUtils.nowMs();
    final existing = await getSettings();

    if (existing != null) {
      await (_db.update(_db.shopSettings)
            ..where((s) => s.id.equals(existing.id)))
          .write(ShopSettingsCompanion(
        shopName: Value(shopName),
        phone: Value(phone),
        address: Value(address),
        setupDone: const Value(true),
        updatedAt: Value(now),
      ));
    } else {
      await _db.into(_db.shopSettings).insert(ShopSettingsCompanion(
            shopName: Value(shopName),
            phone: Value(phone),
            address: Value(address),
            setupDone: const Value(true),
            createdAt: Value(now),
            updatedAt: Value(now),
          ));
    }
  }
}
