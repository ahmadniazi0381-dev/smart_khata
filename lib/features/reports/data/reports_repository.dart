import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/date_utils.dart';
import '../domain/models/report_models.dart';

class ReportsRepository {
  final AppDatabase _db;

  ReportsRepository(this._db);

  /// Fetch dashboard metrics using SQL aggregates
  Future<DashboardSummary> getDashboardSummary() async {
    final startToday = AppDateUtils.startOfToday();
    final endToday = AppDateUtils.endOfToday();

    // 1. Today's sales
    final todaySalesRow = await _db.customSelect(
      'SELECT COALESCE(SUM(total_paisa), 0) AS total, COUNT(*) AS count '
      'FROM sales '
      'WHERE status = ? AND sale_date >= ? AND sale_date <= ?',
      variables: [
        Variable.withString('completed'),
        Variable.withInt(startToday),
        Variable.withInt(endToday),
      ],
    ).getSingle();
    final todaySalesPaisa = todaySalesRow.read<int>('total');
    final todaySalesCount = todaySalesRow.read<int>('count');

    // 2. Outstanding credit (sum of positive customer ledger balances)
    final outstandingRow = await _db.customSelect(
      'SELECT COALESCE(SUM(customer_balance), 0) AS total FROM ('
      '  SELECT SUM(CASE WHEN direction = ? THEN amount_paisa ELSE -amount_paisa END) AS customer_balance '
      '  FROM ledger_entries '
      '  GROUP BY customer_id '
      '  HAVING customer_balance > 0'
      ')',
      variables: [Variable.withString('CREDIT')],
    ).getSingle();
    final outstandingCreditPaisa = outstandingRow.read<int>('total');

    // 3. Low stock count
    final lowStockRow = await _db
        .customSelect(
          'SELECT COUNT(*) AS count '
          'FROM products '
          'WHERE is_active = 1 AND stock_milli <= low_stock_milli',
        )
        .getSingle();
    final lowStockCount = lowStockRow.read<int>('count');

    // 4. Inventory valuation = sum of stock * purchase_price / 1000
    final inventoryRow = await _db
        .customSelect(
          'SELECT COALESCE(SUM(CAST((stock_milli * purchase_price_paisa) / 1000 AS INTEGER)), 0) AS val '
          'FROM products '
          'WHERE is_active = 1 AND stock_milli > 0',
        )
        .getSingle();
    final totalInventoryValuePaisa = inventoryRow.read<int>('val');

    // 5. Last 7 days daily sales
    final sevenDaysAgo =
        startToday - (6 * 24 * 60 * 60 * 1000); // 7 days inclusive

    final dailyPoints = <DailySalesPoint>[];
    for (int i = 0; i < 7; i++) {
      final dayStart = sevenDaysAgo + (i * 24 * 60 * 60 * 1000);
      final dayEnd = dayStart + (24 * 60 * 60 * 1000) - 1;

      final dayRow = await _db.customSelect(
        'SELECT COALESCE(SUM(total_paisa), 0) AS total, COUNT(*) AS count '
        'FROM sales '
        'WHERE status = ? AND sale_date >= ? AND sale_date <= ?',
        variables: [
          Variable.withString('completed'),
          Variable.withInt(dayStart),
          Variable.withInt(dayEnd),
        ],
      ).getSingle();

      final dayDt = AppDateUtils.fromMs(dayStart);
      final label = '${dayDt.day}/${dayDt.month}';

      dailyPoints.add(DailySalesPoint(
        dateLabel: label,
        totalPaisa: dayRow.read<int>('total'),
        count: dayRow.read<int>('count'),
        epochMs: dayStart,
      ));
    }

    return DashboardSummary(
      todaySalesPaisa: todaySalesPaisa,
      todaySalesCount: todaySalesCount,
      outstandingCreditPaisa: outstandingCreditPaisa,
      lowStockCount: lowStockCount,
      totalInventoryValuePaisa: totalInventoryValuePaisa,
      last7DaysSales: dailyPoints,
    );
  }

  /// Fetch comprehensive sales report for any date range using SQL aggregates
  Future<SalesReport> getSalesReport({
    required int fromDateMs,
    required int toDateMs,
  }) async {
    // 1. Sales totals
    final salesRow = await _db.customSelect(
      'SELECT COALESCE(SUM(total_paisa), 0) AS total_sales, '
      '       COALESCE(SUM(discount_paisa), 0) AS total_discount, '
      '       COUNT(*) AS comp_count '
      'FROM sales '
      'WHERE status = ? AND sale_date >= ? AND sale_date <= ?',
      variables: [
        Variable.withString('completed'),
        Variable.withInt(fromDateMs),
        Variable.withInt(toDateMs),
      ],
    ).getSingle();

    final totalSalesPaisa = salesRow.read<int>('total_sales');
    final totalDiscountPaisa = salesRow.read<int>('total_discount');
    final completedSalesCount = salesRow.read<int>('comp_count');

    // 2. Cancelled sales count
    final cancelledRow = await _db.customSelect(
      'SELECT COUNT(*) AS canc_count '
      'FROM sales '
      'WHERE status = ? AND sale_date >= ? AND sale_date <= ?',
      variables: [
        Variable.withString('cancelled'),
        Variable.withInt(fromDateMs),
        Variable.withInt(toDateMs),
      ],
    ).getSingle();
    final cancelledSalesCount = cancelledRow.read<int>('canc_count');

    // 3. Cost of goods sold (sum of line cost for completed sales)
    final costRow = await _db.customSelect(
      'SELECT COALESCE(SUM(CAST((si.qty_milli * si.cost_price_paisa) / 1000 AS INTEGER)), 0) AS total_cost '
      'FROM sale_items si '
      'INNER JOIN sales s ON s.id = si.sale_id '
      'WHERE s.status = ? AND s.sale_date >= ? AND s.sale_date <= ?',
      variables: [
        Variable.withString('completed'),
        Variable.withInt(fromDateMs),
        Variable.withInt(toDateMs),
      ],
    ).getSingle();
    final totalCostPaisa = costRow.read<int>('total_cost');

    // Estimated gross profit = sale totals - cost of goods
    final estimatedGrossProfitPaisa = totalSalesPaisa - totalCostPaisa;

    // 4. Expenses in period
    final expenseRow = await _db.customSelect(
      'SELECT COALESCE(SUM(amount_paisa), 0) AS total_exp '
      'FROM expenses '
      'WHERE expense_date >= ? AND expense_date <= ?',
      variables: [
        Variable.withInt(fromDateMs),
        Variable.withInt(toDateMs),
      ],
    ).getSingle();
    final totalExpensesPaisa = expenseRow.read<int>('total_exp');

    final estimatedNetProfitPaisa =
        estimatedGrossProfitPaisa - totalExpensesPaisa;

    // 5. Top selling products
    final topRows = await _db.customSelect(
      'SELECT si.product_name_snapshot, si.unit_snapshot, '
      '       COALESCE(SUM(si.qty_milli), 0) AS total_qty, '
      '       COALESCE(SUM(si.line_total_paisa), 0) AS total_revenue '
      'FROM sale_items si '
      'INNER JOIN sales s ON s.id = si.sale_id '
      'WHERE s.status = ? AND s.sale_date >= ? AND s.sale_date <= ? '
      'GROUP BY si.product_name_snapshot, si.unit_snapshot '
      'ORDER BY total_revenue DESC '
      'LIMIT 5',
      variables: [
        Variable.withString('completed'),
        Variable.withInt(fromDateMs),
        Variable.withInt(toDateMs),
      ],
    ).get();

    final topProducts = topRows.map((r) {
      return TopProductItem(
        productName: r.read<String>('product_name_snapshot'),
        unit: r.read<String>('unit_snapshot'),
        qtyMilli: r.read<int>('total_qty'),
        totalRevenuePaisa: r.read<int>('total_revenue'),
      );
    }).toList();

    // 6. Trend points (interval-based or daily)
    final trendPoints = <DailySalesPoint>[];
    final totalDays =
        ((toDateMs - fromDateMs) / (24 * 60 * 60 * 1000)).ceil().clamp(1, 30);
    final intervalMs = ((toDateMs - fromDateMs) / totalDays).round();

    for (int i = 0; i < totalDays; i++) {
      final pStart = fromDateMs + (i * intervalMs);
      final pEnd = (i == totalDays - 1) ? toDateMs : (pStart + intervalMs - 1);

      final row = await _db.customSelect(
        'SELECT COALESCE(SUM(total_paisa), 0) AS total, COUNT(*) AS count '
        'FROM sales '
        'WHERE status = ? AND sale_date >= ? AND sale_date <= ?',
        variables: [
          Variable.withString('completed'),
          Variable.withInt(pStart),
          Variable.withInt(pEnd),
        ],
      ).getSingle();

      final dt = AppDateUtils.fromMs(pStart);
      trendPoints.add(DailySalesPoint(
        dateLabel: '${dt.day}/${dt.month}',
        totalPaisa: row.read<int>('total'),
        count: row.read<int>('count'),
        epochMs: pStart,
      ));
    }

    return SalesReport(
      totalSalesPaisa: totalSalesPaisa,
      completedSalesCount: completedSalesCount,
      cancelledSalesCount: cancelledSalesCount,
      totalDiscountPaisa: totalDiscountPaisa,
      totalCostPaisa: totalCostPaisa,
      estimatedGrossProfitPaisa: estimatedGrossProfitPaisa,
      totalExpensesPaisa: totalExpensesPaisa,
      estimatedNetProfitPaisa: estimatedNetProfitPaisa,
      topProducts: topProducts,
      salesTrend: trendPoints,
    );
  }
}
