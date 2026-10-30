import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/database/database_provider.dart';
import 'package:smart_khata/core/utils/date_utils.dart';
import 'package:smart_khata/features/settings/presentation/screens/settings_screen.dart';
import 'package:smart_khata/features/setup/data/setup_repository.dart';
import 'package:smart_khata/features/setup/presentation/providers/setup_providers.dart';
import 'package:smart_khata/l10n/app_localizations.dart';

void main() {
  late AppDatabase db;
  late SetupRepository setupRepo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    setupRepo = SetupRepository(db);

    final now = AppDateUtils.nowMs();
    await db.into(db.shopSettings).insert(
          ShopSettingsCompanion.insert(
            shopName: 'Ali General Store',
            phone: const Value('03001234567'),
            address: const Value('Shop 5, Main Bazar, Lahore'),
            invoicePrefix: const Value('INV-'),
            receiptFooter: const Value('Shukriya'),
            language: const Value('en'),
            themeMode: const Value('system'),
            setupDone: const Value(true),
            createdAt: now,
            updatedAt: now,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('Day 5: Setup & Settings Repository Tests', () {
    test('Get current settings returns seeded data', () async {
      final settings = await setupRepo.getSettings();
      expect(settings, isNotNull);
      expect(settings!.shopName, 'Ali General Store');
      expect(settings.phone, '03001234567');
      expect(settings.address, 'Shop 5, Main Bazar, Lahore');
      expect(settings.invoicePrefix, 'INV-');
      expect(settings.receiptFooter, 'Shukriya');
      expect(settings.language, 'en');
      expect(settings.themeMode, 'system');
      expect(settings.setupDone, isTrue);
    });

    test('updateSettings updates all fields including language and theme',
        () async {
      await setupRepo.updateSettings(
        shopName: 'Khan Super Store',
        phone: '03219876543',
        address: 'G-9 Markaz, Islamabad',
        invoicePrefix: 'KSS-',
        receiptFooter: 'Dobara Tashreef Layen',
        language: 'ur',
        themeMode: 'dark',
      );

      final updated = await setupRepo.getSettings();
      expect(updated, isNotNull);
      expect(updated!.shopName, 'Khan Super Store');
      expect(updated.phone, '03219876543');
      expect(updated.address, 'G-9 Markaz, Islamabad');
      expect(updated.invoicePrefix, 'KSS-');
      expect(updated.receiptFooter, 'Dobara Tashreef Layen');
      expect(updated.language, 'ur');
      expect(updated.themeMode, 'dark');
    });

    test('setLanguage updates language only', () async {
      await setupRepo.setLanguage('ur');
      var settings = await setupRepo.getSettings();
      expect(settings!.language, 'ur');

      await setupRepo.setLanguage('en');
      settings = await setupRepo.getSettings();
      expect(settings!.language, 'en');
    });

    test('setThemeMode updates themeMode only', () async {
      await setupRepo.setThemeMode('light');
      var settings = await setupRepo.getSettings();
      expect(settings!.themeMode, 'light');

      await setupRepo.setThemeMode('dark');
      settings = await setupRepo.getSettings();
      expect(settings!.themeMode, 'dark');
    });
  });

  group('Day 5: Localizations & Urdu Tests', () {
    testWidgets('AppLocalizations loads English strings correctly',
        (tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(l10n.appTitle, 'Smart Khata');
      expect(l10n.newSale, 'New Sale');
      expect(l10n.navCustomers, 'Customers');
      expect(l10n.settingsTitle, 'Settings');
      expect(l10n.themeModeLabel, 'Theme');
    });

    testWidgets('AppLocalizations loads Urdu strings correctly',
        (tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ur'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(l10n.appTitle, 'سمارٹ کھاتا');
      expect(l10n.newSale, 'نئی فروخت');
      expect(l10n.navCustomers, 'گاہک');
      expect(l10n.navStock, 'اسٹاک');
      expect(l10n.navSales, 'فروخت');
      expect(l10n.navReports, 'رپورٹس');
      expect(l10n.settingsTitle, 'ترتیبات');
      expect(l10n.themeModeLabel, 'تھیم');
      expect(l10n.languageLabel, 'زبان');
      expect(l10n.todaySales, 'آج کی فروخت');
    });
  });

  group('Day 5: SettingsScreen Widget Test', () {
    testWidgets('Renders settings form and allows modifying fields',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final initialSettings = await setupRepo.getSettings();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            setupRepositoryProvider.overrideWithValue(setupRepo),
            shopSettingsStreamProvider.overrideWith(
              (ref) => Stream.value(initialSettings),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify form elements exist
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Shop Information'), findsOneWidget);
      expect(find.text('Ali General Store'), findsOneWidget);
      expect(find.text('03001234567'), findsOneWidget);

      final saveButton = find.widgetWithText(ElevatedButton, 'Save');
      expect(saveButton, findsOneWidget);

      // Edit shop name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Ali General Store'),
        'Updated General Store',
      );

      // Tap Save
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Advance SnackBar auto-dismiss timer
      await tester.pump(const Duration(seconds: 5));

      // Verify DB was updated
      final updated = await setupRepo.getSettings();
      expect(updated!.shopName, 'Updated General Store');
    });
  });
}
