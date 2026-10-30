# Smart Khata (سمارٹ کھاتا)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20Only-3DDC84?logo=android)](https://android.com)
[![Offline First](https://img.shields.io/badge/Offline-100%25-green)](https://github.com)
[![Tests](https://img.shields.io/badge/Tests-71%20Passed-success)](https://github.com)

**Smart Khata** is an offline-first retail POS, stock manager, and customer ledger (*khata*) application crafted specifically for small retail businesses, *kiryana* stores, and shopkeepers across Pakistan.

Built with an uncompromising focus on financial accuracy, zero network dependency, and high performance on affordable Android smartphones.

---

## 🌟 Key Highlights

- **100% Offline-First**: No login, no accounts, and strictly **zero internet permissions** in `AndroidManifest.xml`. All data remains entirely on the owner's phone.
- **Integer-Only Financial Arithmetic**:
  - Money is strictly stored and calculated as **integer paisa** (`*_paisa` columns; 1 PKR = 100 paisa).
  - Quantities are strictly stored and calculated as **integer milli-units** (`*_milli` columns; 1 kg = 1,000 milli).
  - Floating point `double` is never used in calculations, guaranteeing zero IEEE-754 rounding drift.
- **Transactional Integrity**: Multi-table writes (sales, stock deductions, khata postings, reversal rows) execute inside atomic SQLite transactions.
- **Immutable Financial Ledger**: Financial rows (sales, payments, ledger movements) are never deleted. Mistakes or returns are recorded via signed reversal rows with audit trails.
- **Bilingual (English & Urdu)**: Comprehensive native Urdu translation with complete RTL layout support (`EdgeInsetsDirectional`, `AlignmentDirectional`).
- **Thermal Receipts**: Printable and shareable 80mm PDF invoices with itemized snapshots (prices and product names locked at time of sale).
- **Offline Backup & Restore**: One-tap export and import of the SQLite database with header validation and WAL checkpoints.

---

## 📱 Core Features

| Feature | Description |
|---------|-------------|
| **Dashboard** | 2×2 metric cards (Today's Sales, Outstanding Khata, Low Stock, Inventory Value), 7-day sales bar chart, quick actions, and recent sales stream. |
| **Point of Sale (POS)** | 2-tab sale creation (product picker + cart/checkout). Supports Cash, Full Credit (*Udhaar*), and Partial Payment with auto-calculated dues. |
| **Customer Khata** | Customer profiles, phone indexing, running balances, payment receipts, manual adjustments with mandatory audit reason, and soft archiving. |
| **Stock & Inventory** | Category tagging, SKU/barcode lookup, purchase/cost vs. selling prices, low stock alerts, stock movement logs, and adjustments. |
| **Business Reports** | Pure SQL-aggregated revenue, cost of goods sold (COGS), estimated gross and net profit, and top-selling products across Today, Week, Month, and All-Time. |
| **Expense Tracker** | Categorized expense logging (Rent, Utilities, Staff Salaries, Food/Tea, Transport) deducted from gross profit for net profit visibility. |
| **Settings & Appearance** | Shop details customization, custom invoice prefix, receipt footer, dynamic Light/Dark theme toggle, and language switcher. |
| **Demo Data Seeder** | Instant sample grocery store data generator for immediate testing and presentation. |

---

## 🏗️ Architecture

```
lib/
├── app.dart                          # Root MaterialApp with dynamic theme and locale
├── main.dart                         # App entry point
├── l10n/                             # ARB localisation files (app_en.arb, app_ur.arb)
├── core/
│   ├── constants/                    # Enums and core definitions
│   ├── database/                     # AppDatabase, 12 Drift tables, migrations, seeder
│   ├── errors/                       # Custom domain exceptions
│   ├── router/                       # GoRouter configuration & bottom nav ShellScaffold
│   ├── theme/                        # Light and Dark ThemeData, color palette, spacing
│   ├── utils/                        # Money (paisa), Qty (milli), DateUtils
│   └── widgets/                      # AppCard, MoneyText, ConfirmDialog, SearchField, EmptyState
└── features/
    ├── backup/                       # Offline backup export, import, header validation
    ├── customers/                    # Customer repository, ledger service, khata screens
    ├── dashboard/                    # KPI metrics, 7-day fl_chart trend, recent stream
    ├── expenses/                     # Expense tracking and category management
    ├── inventory/                    # Product catalog, categories, inventory service
    ├── reports/                      # SQL aggregate analytics and reporting screens
    ├── sales/                        # Sale service, cart notifier, POS, 80mm receipt PDF
    ├── settings/                     # Shop config, language, theme, and data management
    └── setup/                        # Initial onboarding shop setup wizard
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: Stable channel (>= 3.0.0)
- **Dart SDK**: Null-safe (>= 3.0.0)
- **JDK**: Java 17
- **Android SDK**: API level 21+ (Android 5.0 Lollipop or higher)

### Installation & Run

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/smart_khata.git
   cd smart_khata
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate code (Drift database & Localizations)**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   flutter gen-l10n
   ```

4. **Run test suite**:
   ```bash
   flutter test
   ```

5. **Run the application**:
   ```bash
   flutter run
   ```

6. **Build release APK**:
   ```bash
   flutter build apk --release
   ```

---

## 🧪 Testing

The test suite covers:
- **7 Golden Financial Scenarios**: Validates complex multi-item cart totals, credit sales, partial payments, overselling protection, mid-sale rollbacks, and cancellations.
- **Money & Quantity Helpers**: Validates integer paisa arithmetic, round-half-up math, Pakistani number formatting (`PKR 12,750.00`), and fractional unit conversion (e.g., 0.750 kg).
- **Repository & Service Integration**: Customer khata balances, stock movement chains, SQL aggregate queries, and backup validation.
- **Widget & Localization Tests**: Verifies complete bilingual string loading in both English and Urdu, form interactions, and reactive theme switching.

Run all tests:
```bash
flutter test
```

---

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.
