# Smart Khata

Offline-first Android khata and POS app for small shops, built with Flutter. Manages inventory, customers, credit ledger (udhaar), sales and receipts in PKR. Works with no internet connection.

## Features

- **Inventory:** categories, products, stock movements, low-stock alerts
- **Customers and khata:** credit ledger with opening balance, payments and running balance
- **Sales:** product picker, cart, discount, cash / full credit / partial payment, sale cancellation with full reversal of stock, ledger and payments
- **Receipts:** 80mm thermal receipt PDF with print and share
- **Dashboard:** today's sales, outstanding khata, low stock, inventory valuation, 7-day trend
- **Expenses and reports:** SQL-aggregated revenue, cost of goods, gross and net profit, top-selling products
- **Backup and restore:** timestamped SQLite backup with header validation
- **Settings:** shop profile, invoice prefix, English and Urdu (RTL), light / dark / system theme

## Tech Stack

| Area | Choice |
|---|---|
| Framework | Flutter (stable), Dart null-safe, Android only |
| State | Riverpod (no code generation) |
| Navigation | go_router |
| Database | Drift on SQLite (`foreign_keys = ON`) |
| PDF and printing | pdf, printing |
| Charts | fl_chart |
| Backup and sharing | file_picker, share_plus |
| Localization | ARB files (`en`, `ur`) |

## Engineering Rules

- Money is stored as integer paisa (`*_paisa`), quantity as integer milli-units (`*_milli`). `double` is never used in business logic.
- Line total is `roundHalfUp(unit_price_paisa * qty_milli / 1000)`.
- Every multi-table write runs through a service inside a database transaction.
- Financial rows are never deleted. Cancellations create reversal rows.
- Sale items store name, unit, price and cost snapshots, so old receipts are unaffected by later price edits.
- The app has no internet permission.

## Project Structure

```
lib/
├── main.dart
├── app.dart
├── l10n/              app_en.arb, app_ur.arb
├── core/              database, router, theme, constants, errors, utils
└── features/          setup, dashboard, customers, inventory, sales,
                       expenses, reports, settings
```

## Getting Started

Requirements: Flutter stable, Android SDK 34, JDK 17.

```powershell
git clone https://github.com/ahmadniazi0381-dev/smart_khata.git
cd smart_khata
flutter pub get
flutter run
```

If Drift generated files are missing:

```powershell
dart run build_runner build --delete-conflicting-outputs
```

## Testing

```powershell
dart format .
flutter analyze
flutter test
```

The suite includes golden financial scenarios (credit sale, discount, ledger balance, overselling rejection, atomic rollback, cancel-and-restore, milli-unit rounding).

## Release Build

```powershell
flutter build apk --release
```

Release signing needs `android/key.properties` and a keystore. Both are git-ignored and must never be committed.

## Status

MVP complete: foundation, inventory, customers, sales, receipts, dashboard, reports, backup, settings and Urdu localization.
