# Smart Khata — Product Specification

> Offline-first Android khata (credit ledger) app for Pakistani shopkeepers.

---

## Screens

| ID  | Screen Name             | Description |
|-----|-------------------------|-------------|
| S01 | Splash / Onboarding     | App launch; first-run setup wizard |
| S02 | Shop Setup              | Enter shop name, phone, address, invoice prefix |
| S03 | Dashboard / Home        | Today's sales, outstanding balance, quick actions |
| S04 | Customer List           | Searchable list of customers with outstanding balance |
| S05 | Customer Detail         | Ledger entries, balance, transaction history |
| S06 | Add / Edit Customer     | Form: name, phone, address, opening balance |
| S07 | Product List            | Searchable/filterable product catalogue |
| S08 | Add / Edit Product      | Form: name, category, SKU, unit, prices, stock |
| S09 | Category List           | Manage product categories |
| S10 | New Sale (Cart)         | Add items to cart, set qty and price, choose customer |
| S11 | Sale Checkout           | Discount, payment method, partial payment, confirm |
| S12 | Sale Receipt            | Printable/shareable receipt for a completed sale |
| S13 | Sales History           | Date-filtered list of all sales |
| S14 | Sale Detail             | Full sale breakdown, cancel action |
| S15 | Receive Payment         | Record khata payment from a customer |
| S16 | Ledger (Khata) Book     | Customer's full ledger with running balance |
| S17 | Stock Management        | Current stock levels, low-stock alerts |
| S18 | Stock Adjustment        | Add/remove stock with reason |
| S19 | Purchase Entry          | Record goods received from supplier |
| S20 | Expense Entry / List    | Shop expenses (rent, utilities, etc.) |
| S21 | Reports / Summary       | Daily/weekly/monthly P&L, top products, dues summary |

---

## Business Rules

### Money
- All monetary values stored as **integer paisa** (1 PKR = 100 paisa).
- Never use `double` for money calculations.
- Display: `Money.format(paisa)` → `"PKR 127.50"` with Pakistani grouping (1,00,000).

### Quantities
- All quantities stored as **integer milli-units** (1 kg = 1000, 0.75 kg = 750, 2 pcs = 2000).
- Never use `double` for quantity calculations.
- Display: `Qty.format(milli, unit)` → `"1.5 kg"`.

### Sales
- Cart must be non-empty; all item quantities must be > 0.
- Discount ∈ [0, subtotal].
- Paid amount ∈ [0, total].
- If `due > 0`, a customer must be selected.
- Invoice number auto-increments per shop settings prefix (e.g. `INV-0001`).
- Completed sale creates: `Sale`, `SaleItem`s, stock `SALE` movements, optional `Payment`, optional ledger `CREDIT_SALE` entry.

### Cancellations (No Hard Deletes)
- Never `DELETE` from sales, payments, ledger_entries, or stock_movements.
- Cancel a sale → mark `status = 'cancelled'`, restore stock (`SALE_CANCEL` movement), insert `REVERSAL` ledger entry, insert negative payment row.

### Ledger / Khata
- `direction = CREDIT` → customer owes more.
- `direction = DEBIT` → customer owes less (payment or reversal).
- Balance = Σ(CREDIT amounts) − Σ(DEBIT amounts). Positive = customer owes money.
- Advance payments (balance going negative) are **not supported in v1**.

### Stock
- Guarded decrement: `UPDATE … WHERE stock_milli >= qty` — never go negative.
- Stock movements record every change with signed delta and stock-after snapshot.

### Purchases
- Receiving stock inserts a `Purchase`, `PurchaseItem`s, and `PURCHASE` stock movements.
- Optionally updates product's `purchase_price_paisa`.

### Expenses
- Simple expense log; no sub-ledger required in v1.

### Settings
- Single-row `shop_settings` table (auto-increment PK, but only one row).
- `next_invoice_no` incremented atomically inside sale transaction.
