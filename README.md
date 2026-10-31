# Smart Khata

![Flutter](https://img.shields.io/badge/Flutter-Stable-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-Null%20Safe-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)
![Offline](https://img.shields.io/badge/Works-Offline-orange)

Offline-first Android khata and POS app for small shops, built with Flutter. Manages inventory, customers, credit ledger (udhaar), sales and receipts in PKR. Works with no internet connection.

---

## Why Smart Khata?

Small shopkeepers often track stock on paper and credit in a notebook. Smart Khata replaces both with one app that runs fully on the phone: no account, no server, no internet. All data stays on the device in a local SQLite database.

## Features

- **Inventory:** categories, products, stock movements, low-stock alerts
- **Customers and Khata:** credit ledger with opening balance, payments and running balance
- **Sales:** product picker, cart, discount, cash / full credit / partial payment, sale cancellation with full reversal of stock, ledger and payments
- **Receipts:** 80mm thermal receipt PDF with print and share
- **Dashboard:** today's sales, outstanding khata, low stock, inventory valuation, 7-day trend
- **Expenses and Reports:** SQL-aggregated revenue, cost of goods, gross and net profit, top-selling products
- **Backup and Restore:** timestamped SQLite backup with header validation
- **Settings:** shop profile, invoice prefix, English and Urdu (RTL), light / dark / system theme

## Screenshots

<!-- Add your screenshots to docs/screenshots/ and update the file names below -->

| Dashboard | New Sale | Khata Ledger | Receipt |
|:---:|:---:|:---:|:---:|
| ![Dashboard](docs/screenshots/dashboard.png) | ![Sale](docs/screenshots/sale.png) | ![Khata](docs/screenshots/khata.png) | ![Receipt](docs/screenshots/receipt.png) |

## Tech Stack

| Area | Choice |
|---|---|
| Framework | Flutter (stable), Dart null-safe, Android only |
| State management | Riverpod (no code generation) |
| Navigation | go_router |
| Database | Drift on SQLite (`foreign_keys = ON`) |
| Localization | Flutter `gen-l10n` (English, Urdu) |
| Receipts | PDF generation with print and share |
| Testing | Unit tests and golden tests |

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- Android Studio or the Android SDK command-line tools
- An Android device or emulator (Android only)

Check your setup:

```bash
flutter doctor
```

### Installation

```bash
git clone https://github.com/ahmadniazi0381-dev/smart_khata.git
cd smart_khata
flutter pub get
```

If generated Drift files (`*.g.dart`) are not committed, generate them:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Generate localization files if needed:

```bash
flutter gen-l10n
```

### Run

```bash
flutter run
```

### Build a release APK

```bash
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

## Testing

```bash
flutter test
```

To regenerate golden test images after an intentional UI change:

```bash
flutter test --update-goldens
```

## Project Structure

<!-- Adjust this tree to match your actual folders -->

```
smart_khata/
├── lib/
│   ├── core/          # theme, routing, shared services, utilities
│   ├── data/          # Drift schema, tables, DAOs, repositories
│   ├── features/      # inventory, customers, sales, receipts, dashboard, reports, settings
│   ├── l10n/          # English and Urdu translations (.arb)
│   └── main.dart
├── test/              # unit and golden tests
├── android/
├── l10n.yaml
├── pubspec.yaml
└── README.md
```

## Data and Privacy

- All data is stored locally on the device in SQLite. Nothing is uploaded anywhere.
- Backups are plain SQLite files you can save or share. Keep them somewhere safe.
- Restoring a backup replaces the current data. The app validates the file header before restoring.

## Roadmap

- [x] Inventory, customers and khata ledger
- [x] Sales with cash, credit and partial payment
- [x] PDF receipts
- [x] Dashboard and reports
- [x] Backup and restore
- [x] English and Urdu support
- [ ] Planned: CSV / Excel export of reports
- [ ] Planned: Barcode scanning for products
- [ ] Planned: Bluetooth thermal printer support
- [ ] Planned: Automatic scheduled backups

<!-- Edit the Planned items to match your real plans, and only tick [x] for what works in the code -->

## Contributing

Suggestions and bug reports are welcome. Please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create a branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m "feat: add your feature"`
4. Push the branch and open a Pull Request

## License

<!-- Add a LICENSE file to the repo root, then keep this line in sync with it -->

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Author

**Ahmad Niazi**
GitHub: [@ahmadniazi0381-dev](https://github.com/ahmadniazi0381-dev)

---

If this project helps you, consider giving it a star.
