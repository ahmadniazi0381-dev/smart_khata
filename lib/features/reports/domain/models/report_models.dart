class DashboardSummary {
  final int todaySalesPaisa;
  final int todaySalesCount;
  final int outstandingCreditPaisa;
  final int lowStockCount;
  final int totalInventoryValuePaisa;
  final List<DailySalesPoint> last7DaysSales;

  const DashboardSummary({
    required this.todaySalesPaisa,
    required this.todaySalesCount,
    required this.outstandingCreditPaisa,
    required this.lowStockCount,
    required this.totalInventoryValuePaisa,
    required this.last7DaysSales,
  });
}

class DailySalesPoint {
  final String dateLabel;
  final int totalPaisa;
  final int count;
  final int epochMs;

  const DailySalesPoint({
    required this.dateLabel,
    required this.totalPaisa,
    required this.count,
    required this.epochMs,
  });
}

class SalesReport {
  final int totalSalesPaisa;
  final int completedSalesCount;
  final int cancelledSalesCount;
  final int totalDiscountPaisa;
  final int totalCostPaisa;
  final int estimatedGrossProfitPaisa;
  final int totalExpensesPaisa;
  final int estimatedNetProfitPaisa;
  final List<TopProductItem> topProducts;
  final List<DailySalesPoint> salesTrend;

  const SalesReport({
    required this.totalSalesPaisa,
    required this.completedSalesCount,
    required this.cancelledSalesCount,
    required this.totalDiscountPaisa,
    required this.totalCostPaisa,
    required this.estimatedGrossProfitPaisa,
    required this.totalExpensesPaisa,
    required this.estimatedNetProfitPaisa,
    required this.topProducts,
    required this.salesTrend,
  });
}

class TopProductItem {
  final String productName;
  final String unit;
  final int qtyMilli;
  final int totalRevenuePaisa;

  const TopProductItem({
    required this.productName,
    required this.unit,
    required this.qtyMilli,
    required this.totalRevenuePaisa,
  });
}
