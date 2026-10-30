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

  Future<void> updateSettings({
    required String shopName,
    String? phone,
    String? address,
    String? language,
    String? themeMode,
    String? invoicePrefix,
    String? receiptFooter,
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
        language: language != null ? Value(language) : const Value.absent(),
        themeMode: themeMode != null ? Value(themeMode) : const Value.absent(),
        invoicePrefix:
            invoicePrefix != null ? Value(invoicePrefix) : const Value.absent(),
        receiptFooter:
            receiptFooter != null ? Value(receiptFooter) : const Value.absent(),
        setupDone: const Value(true),
        updatedAt: Value(now),
      ));
    } else {
      await _db.into(_db.shopSettings).insert(ShopSettingsCompanion(
            shopName: Value(shopName),
            phone: Value(phone),
            address: Value(address),
            language: language != null ? Value(language) : const Value('en'),
            themeMode:
                themeMode != null ? Value(themeMode) : const Value('system'),
            invoicePrefix: invoicePrefix != null
                ? Value(invoicePrefix)
                : const Value('INV-'),
            receiptFooter: Value(receiptFooter),
            setupDone: const Value(true),
            createdAt: Value(now),
            updatedAt: Value(now),
          ));
    }
  }

  Future<void> setThemeMode(String themeMode) async {
    final existing = await getSettings();
    final now = AppDateUtils.nowMs();
    if (existing != null) {
      await (_db.update(_db.shopSettings)
            ..where((s) => s.id.equals(existing.id)))
          .write(ShopSettingsCompanion(
        themeMode: Value(themeMode),
        updatedAt: Value(now),
      ));
    }
  }

  Future<void> setLanguage(String language) async {
    final existing = await getSettings();
    final now = AppDateUtils.nowMs();
    if (existing != null) {
      await (_db.update(_db.shopSettings)
            ..where((s) => s.id.equals(existing.id)))
          .write(ShopSettingsCompanion(
        language: Value(language),
        updatedAt: Value(now),
      ));
    }
  }
}
