import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/qty.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/report_models.dart';
import '../providers/reports_providers.dart';
import '../widgets/sales_trend_chart.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedPeriod = ref.watch(reportPeriodProvider);
    final reportAsync = ref.watch(salesReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportsTitle),
      ),
      body: Column(
        children: [
          // Period Selector Chips
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
                kSpaceM, kSpaceM, kSpaceM, kSpaceS),
            child: Row(
              children: [
                _buildPeriodChip(
                  context,
                  ref,
                  ReportPeriod.today,
                  l10n.periodToday,
                  selectedPeriod,
                ),
                const SizedBox(width: kSpaceS),
                _buildPeriodChip(
                  context,
                  ref,
                  ReportPeriod.thisWeek,
                  l10n.periodThisWeek,
                  selectedPeriod,
                ),
                const SizedBox(width: kSpaceS),
                _buildPeriodChip(
                  context,
                  ref,
                  ReportPeriod.thisMonth,
                  l10n.periodThisMonth,
                  selectedPeriod,
                ),
                const SizedBox(width: kSpaceS),
                _buildPeriodChip(
                  context,
                  ref,
                  ReportPeriod.allTime,
                  l10n.periodAllTime,
                  selectedPeriod,
                ),
              ],
            ),
          ),

          // Report Content
          Expanded(
            child: reportAsync.when(
              data: (report) => _buildReportContent(context, l10n, report),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text(err.toString())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(
    BuildContext context,
    WidgetRef ref,
    ReportPeriod period,
    String label,
    ReportPeriod selected,
  ) {
    final isSelected = period == selected;
    return Expanded(
      child: ChoiceChip(
        label: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        selected: isSelected,
        showCheckmark: false,
        onSelected: (val) {
          if (val) {
            ref.read(reportPeriodProvider.notifier).state = period;
          }
        },
      ),
    );
  }

  Widget _buildReportContent(
    BuildContext context,
    AppLocalizations l10n,
    SalesReport report,
  ) {
    if (report.completedSalesCount == 0 &&
        report.totalExpensesPaisa == 0 &&
        report.totalSalesPaisa == 0) {
      return EmptyState(
        icon: Icons.bar_chart_outlined,
        title: Text(l10n.noReportData),
      );
    }

    return ListView(
      padding:
          const EdgeInsetsDirectional.fromSTEB(kSpaceM, 0, kSpaceM, kSpaceXL),
      children: [
        // ── Profit & Loss Highlights ────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.grossProfit,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    MoneyText(
                      amountPaisa: report.estimatedGrossProfitPaisa,
                      isPositive: report.estimatedGrossProfitPaisa > 0,
                      isNegative: report.estimatedGrossProfitPaisa < 0,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: kSpaceM),
            Expanded(
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.netProfit,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    MoneyText(
                      amountPaisa: report.estimatedNetProfitPaisa,
                      isPositive: report.estimatedNetProfitPaisa > 0,
                      isNegative: report.estimatedNetProfitPaisa < 0,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: kSpaceM),

        // ── Sales Trend Chart ───────────────────────────────────────────────
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sales Trend',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: kSpaceM),
              SalesTrendChart(points: report.salesTrend),
            ],
          ),
        ),

        const SizedBox(height: kSpaceM),

        // ── Detailed Metrics ────────────────────────────────────────────────
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.salesSummary,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Divider(height: kSpaceL),
              _buildRow(
                l10n.totalRevenue,
                Money.format(report.totalSalesPaisa),
                isBold: true,
              ),
              const SizedBox(height: kSpaceS),
              _buildRow(
                l10n.completedSales,
                '${report.completedSalesCount}',
              ),
              if (report.cancelledSalesCount > 0) ...[
                const SizedBox(height: kSpaceS),
                _buildRow(
                  'Cancelled Sales',
                  '${report.cancelledSalesCount}',
                  valueColor: AppColors.error,
                ),
              ],
              const SizedBox(height: kSpaceS),
              _buildRow(
                l10n.costOfGoods,
                Money.format(report.totalCostPaisa),
              ),
              if (report.totalDiscountPaisa > 0) ...[
                const SizedBox(height: kSpaceS),
                _buildRow(
                  'Total Discounts Given',
                  '- ${Money.format(report.totalDiscountPaisa)}',
                ),
              ],
              const SizedBox(height: kSpaceS),
              _buildRow(
                l10n.totalExpenses,
                Money.format(report.totalExpensesPaisa),
                valueColor: AppColors.error,
              ),
            ],
          ),
        ),

        const SizedBox(height: kSpaceM),

        // ── Top Selling Products ────────────────────────────────────────────
        if (report.topProducts.isNotEmpty)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.topSellingProducts,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(height: kSpaceL),
                ...report.topProducts.map((p) {
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: kSpaceS),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.productName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${Qty.format(p.qtyMilli, p.unit)} sold',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        MoneyText(
                          amountPaisa: p.totalRevenuePaisa,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? null : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
