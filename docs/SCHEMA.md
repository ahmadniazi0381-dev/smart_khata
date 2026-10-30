# Smart Khata — Database Schema

SQLite via Drift. All timestamps are **epoch milliseconds** (INTEGER). All monetary values are **integer paisa**. All quantities are **integer milli-units**.

---

## Tables

### `shop_settings`
Single-row configuration table.

| Column           | Type    | Constraints              | Default    | Notes                            |
|------------------|---------|--------------------------|------------|----------------------------------|
| id               | INTEGER | PRIMARY KEY AUTOINCREMENT|            |                                  |
| shop_name        | TEXT    | NOT NULL, len 1–200      |            |                                  |
| phone            | TEXT    | nullable, max 20         |            |                                  |
| address          | TEXT    | nullable, max 500        |            |                                  |
| language         | TEXT    | NOT NULL                 | `'en'`     | `'en'` or `'ur'`                 |
| theme_mode       | TEXT    | NOT NULL                 | `'system'` | `'light'`, `'dark'`, `'system'`  |
| invoice_prefix   | TEXT    | NOT NULL                 | `'INV-'`   |                                  |
| next_invoice_no  | INTEGER | NOT NULL                 | `1`        | Incremented atomically per sale  |
| receipt_footer   | TEXT    | nullable                 |            |                                  |
| setup_done       | INTEGER | NOT NULL (BOOLEAN)       | `0`        |                                  |
| created_at       | INTEGER | NOT NULL                 |            | epoch ms                         |
| updated_at       | INTEGER | NOT NULL                 |            | epoch ms                         |

---

### `categories`

| Column     | Type    | Constraints              | Default | Notes |
|------------|---------|--------------------------|---------|-------|
| id         | TEXT    | PRIMARY KEY              |         | UUID  |
| name       | TEXT    | NOT NULL, UNIQUE, 1–100  |         |       |
| is_active  | INTEGER | NOT NULL (BOOLEAN)       | `1`     |       |
| created_at | INTEGER | NOT NULL                 |         |       |
| updated_at | INTEGER | NOT NULL                 |         |       |

---

### `products`

| Column               | Type    | Constraints              | Default  | Notes                        |
|----------------------|---------|--------------------------|----------|------------------------------|
| id                   | TEXT    | PRIMARY KEY              |          | UUID                         |
| category_id          | TEXT    | nullable, FK categories  |          |                              |
| name                 | TEXT    | NOT NULL, 1–200          |          |                              |
| sku                  | TEXT    | nullable                 |          |                              |
| unit                 | TEXT    | NOT NULL                 | `'pcs'`  | `'pcs'`, `'kg'`, `'g'`, etc. |
| purchase_price_paisa | INTEGER | NOT NULL                 | `0`      |                              |
| selling_price_paisa  | INTEGER | NOT NULL                 | `0`      |                              |
| stock_milli          | INTEGER | NOT NULL                 | `0`      | milli-units                  |
| low_stock_milli      | INTEGER | NOT NULL                 | `1000`   | alert threshold              |
| is_active            | INTEGER | NOT NULL (BOOLEAN)       | `1`      |                              |
| created_at           | INTEGER | NOT NULL                 |          |                              |
| updated_at           | INTEGER | NOT NULL                 |          |                              |

**Indexes:** `idx_products_name (name)`

---

### `customers`

| Column                | Type    | Constraints        | Default | Notes |
|-----------------------|---------|--------------------|---------|-------|
| id                    | TEXT    | PRIMARY KEY        |         | UUID  |
| name                  | TEXT    | NOT NULL, 1–200    |         |       |
| phone                 | TEXT    | nullable           |         |       |
| address               | TEXT    | nullable           |         |       |
| opening_balance_paisa | INTEGER | NOT NULL           | `0`     |       |
| is_active             | INTEGER | NOT NULL (BOOLEAN) | `1`     |       |
| created_at            | INTEGER | NOT NULL           |         |       |
| updated_at            | INTEGER | NOT NULL           |         |       |

**Indexes:** `idx_customers_name (name)`, `idx_customers_phone (phone)`

---

### `sales`

| Column          | Type    | Constraints              | Default       | Notes                          |
|-----------------|---------|--------------------------|---------------|--------------------------------|
| id              | TEXT    | PRIMARY KEY              |               | UUID                           |
| invoice_no      | TEXT    | NOT NULL                 |               | e.g. `INV-0001`                |
| customer_id     | TEXT    | nullable, FK customers   |               |                                |
| sale_date       | INTEGER | NOT NULL                 |               | epoch ms                       |
| subtotal_paisa  | INTEGER | NOT NULL                 |               |                                |
| discount_paisa  | INTEGER | NOT NULL                 | `0`           |                                |
| total_paisa     | INTEGER | NOT NULL                 |               | subtotal − discount            |
| paid_paisa      | INTEGER | NOT NULL                 | `0`           |                                |
| due_paisa       | INTEGER | NOT NULL                 | `0`           | total − paid                   |
| status          | TEXT    | NOT NULL                 | `'completed'` | `'completed'` or `'cancelled'` |
| cancelled_at    | INTEGER | nullable                 |               |                                |
| cancel_reason   | TEXT    | nullable                 |               |                                |
| note            | TEXT    | nullable                 |               |                                |
| created_at      | INTEGER | NOT NULL                 |               |                                |
| updated_at      | INTEGER | NOT NULL                 |               |                                |

**Indexes:** `idx_sales_sale_date (sale_date)`, `idx_sales_customer_id (customer_id)`

---

### `sale_items`

| Column                | Type    | Constraints         | Default | Notes                          |
|-----------------------|---------|---------------------|---------|--------------------------------|
| id                    | TEXT    | PRIMARY KEY         |         | UUID                           |
| sale_id               | TEXT    | NOT NULL, FK sales  |         |                                |
| product_id            | TEXT    | NOT NULL, FK products|        |                                |
| product_name_snapshot | TEXT    | NOT NULL            |         | captured at sale time          |
| unit_snapshot         | TEXT    | NOT NULL            |         | captured at sale time          |
| qty_milli             | INTEGER | NOT NULL            |         |                                |
| unit_price_paisa      | INTEGER | NOT NULL            |         | captured at sale time          |
| cost_price_paisa      | INTEGER | NOT NULL            |         | captured at sale time          |
| line_total_paisa      | INTEGER | NOT NULL            |         | round_half_up(price × qty/1000)|
| created_at            | INTEGER | NOT NULL            |         |                                |
| updated_at            | INTEGER | NOT NULL            |         |                                |

**Indexes:** `idx_sale_items_sale_id (sale_id)`

---

### `payments`

| Column               | Type    | Constraints              | Default  | Notes                          |
|----------------------|---------|--------------------------|----------|--------------------------------|
| id                   | TEXT    | PRIMARY KEY              |          | UUID                           |
| sale_id              | TEXT    | nullable, FK sales       |          |                                |
| customer_id          | TEXT    | nullable, FK customers   |          |                                |
| amount_paisa         | INTEGER | NOT NULL                 |          | negative for reversals         |
| method               | TEXT    | NOT NULL                 | `'cash'` | `'cash'`, `'bank'`, `'wallet'` |
| paid_at              | INTEGER | NOT NULL                 |          | epoch ms                       |
| note                 | TEXT    | nullable                 |          |                                |
| reverses_payment_id  | TEXT    | nullable, FK payments    |          | self-referential               |
| created_at           | INTEGER | NOT NULL                 |          |                                |
| updated_at           | INTEGER | NOT NULL                 |          |                                |

---

### `ledger_entries`

| Column             | Type    | Constraints               | Default | Notes                                          |
|--------------------|---------|---------------------------|---------|------------------------------------------------|
| id                 | TEXT    | PRIMARY KEY               |         | UUID                                           |
| customer_id        | TEXT    | NOT NULL, FK customers    |         |                                                |
| sale_id            | TEXT    | nullable, FK sales        |         |                                                |
| payment_id         | TEXT    | nullable, FK payments     |         |                                                |
| entry_type         | TEXT    | NOT NULL                  |         | `OPENING`, `CREDIT_SALE`, `PAYMENT`, `ADJUSTMENT`, `REVERSAL` |
| direction          | TEXT    | NOT NULL                  |         | `CREDIT` (owes more) or `DEBIT` (owes less)    |
| amount_paisa       | INTEGER | NOT NULL                  |         | always positive                                |
| entry_date         | INTEGER | NOT NULL                  |         | epoch ms                                       |
| note               | TEXT    | nullable                  |         |                                                |
| reverses_entry_id  | TEXT    | nullable, FK ledger_entries|        | self-referential                               |
| created_at         | INTEGER | NOT NULL                  |         |                                                |
| updated_at         | INTEGER | NOT NULL                  |         |                                                |

**Indexes:** `idx_ledger_customer_date (customer_id, entry_date)`

**Balance formula:** `balance = SUM(CREDIT amounts) - SUM(DEBIT amounts)` — positive means customer owes money.

---

### `stock_movements`

| Column           | Type    | Constraints            | Default | Notes                                                       |
|------------------|---------|------------------------|---------|-------------------------------------------------------------|
| id               | TEXT    | PRIMARY KEY            |         | UUID                                                        |
| product_id       | TEXT    | NOT NULL, FK products  |         |                                                             |
| movement_type    | TEXT    | NOT NULL               |         | `OPENING`, `PURCHASE`, `SALE`, `SALE_CANCEL`, `ADJUSTMENT`, `DAMAGE`, `RETURN` |
| qty_delta_milli  | INTEGER | NOT NULL               |         | signed; negative = outflow                                  |
| stock_after_milli| INTEGER | NOT NULL               |         | snapshot after movement                                     |
| ref_type         | TEXT    | nullable               |         | `'sale'`, `'purchase'`, etc.                                |
| ref_id           | TEXT    | nullable               |         | FK to referencing table (not enforced at DB level)          |
| note             | TEXT    | nullable               |         |                                                             |
| created_at       | INTEGER | NOT NULL               |         |                                                             |
| updated_at       | INTEGER | NOT NULL               |         |                                                             |

**Indexes:** `idx_stock_movements_product (product_id, created_at)`

---

### `expenses`

| Column       | Type    | Constraints     | Default | Notes |
|--------------|---------|-----------------|---------|-------|
| id           | TEXT    | PRIMARY KEY     |         | UUID  |
| title        | TEXT    | NOT NULL, 1–200 |         |       |
| category     | TEXT    | nullable        |         |       |
| amount_paisa | INTEGER | NOT NULL        |         |       |
| expense_date | INTEGER | NOT NULL        |         |       |
| note         | TEXT    | nullable        |         |       |
| created_at   | INTEGER | NOT NULL        |         |       |
| updated_at   | INTEGER | NOT NULL        |         |       |

---

### `purchases`

| Column        | Type    | Constraints     | Default | Notes |
|---------------|---------|-----------------|---------|-------|
| id            | TEXT    | PRIMARY KEY     |         | UUID  |
| supplier_name | TEXT    | NOT NULL, 1–200 |         |       |
| reference     | TEXT    | nullable        |         |       |
| total_paisa   | INTEGER | NOT NULL        |         |       |
| paid_paisa    | INTEGER | NOT NULL        | `0`     |       |
| purchase_date | INTEGER | NOT NULL        |         |       |
| note          | TEXT    | nullable        |         |       |
| created_at    | INTEGER | NOT NULL        |         |       |
| updated_at    | INTEGER | NOT NULL        |         |       |

---

### `purchase_items`

| Column          | Type    | Constraints            | Default | Notes |
|-----------------|---------|------------------------|---------|-------|
| id              | TEXT    | PRIMARY KEY            |         | UUID  |
| purchase_id     | TEXT    | NOT NULL, FK purchases |         |       |
| product_id      | TEXT    | NOT NULL, FK products  |         |       |
| qty_milli       | INTEGER | NOT NULL               |         |       |
| unit_cost_paisa | INTEGER | NOT NULL               |         |       |
| line_total_paisa| INTEGER | NOT NULL               |         |       |
| created_at      | INTEGER | NOT NULL               |         |       |
| updated_at      | INTEGER | NOT NULL               |         |       |

---

## Global Rules

1. `PRAGMA foreign_keys = ON` — enforced on every connection open.
2. `PRAGMA journal_mode = WAL` — enabled for performance.
3. No `DELETE` on financial tables (sales, payments, ledger_entries, stock_movements). Use reversal rows.
4. All multi-table writes inside `db.transaction(...)`.
5. Stock decrement is guarded: `UPDATE … WHERE stock_milli >= qty_delta` (via `customUpdate`).
6. `next_invoice_no` incremented atomically inside the sale transaction.
