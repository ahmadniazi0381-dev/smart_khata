import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../reports/presentation/providers/reports_providers.dart';
import '../../../reports/presentation/widgets/sales_trend_chart.dart';
import '../../../sales/presentation/providers/sales_providers.dart';
import '../../../setup/presentation/providers/setup_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(shopSettingsStreamProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final recentSalesAsync = ref.watch(salesListStreamProvider);

    final shopName = settingsAsync.valueOrNull?.shopName ?? l10n.appTitle;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shopName),
            Text(
              AppDateUtils.formatDate(AppDateUtils.nowMs()),
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: l10n.expenses,
            onPressed: () => context.push('/expenses'),
          ),
          IconButton(
            icon: const Icon(Icons.backup_outlined),
            tooltip: l10n.backupAndRestore,
            onPressed: () => context.push('/backup'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTitle,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(salesListStreamProvider);
        },
        child: ListView(
          padding: const EdgeInsetsDirectional.all(kSpaceM),
          children: [
            // ── 2x2 Metric Cards Grid ───────────────────────────────────────
            summaryAsync.when(
              data: (summary) => Column(
                children: [
                  Row(
                    children: [
                      // 1. Today's Sales
                      Expanded(
                        child: _MetricCard(
                          title: l10n.todaySales,
                          content: MoneyText(
                            amountPaisa: summary.todaySalesPaisa,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                          ),
                          subtitle: l10n.itemsCount(summary.todaySalesCount),
                          icon: Icons.point_of_sale_outlined,
                          accentColor: AppColors.primary,
                          onTap: () => context.push('/sales'),
                        ),
                      ),
                      const SizedBox(width: kSpaceM),
                      // 2. Outstanding Khata
                      Expanded(
                        child: _MetricCard(
                          title: l10n.outstanding,
                          content: MoneyText(
                            amountPaisa: summary.outstandingCreditPaisa,
                            isNegative: summary.outstandingCreditPaisa > 0,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          subtitle: 'Total Udhaar',
                          icon: Icons.account_balance_wallet_outlined,
                          accentColor: AppColors.warning,
                          onTap: () => context.push('/customers'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: kSpaceM),
                  Row(
                    children: [
                      // 3. Low Stock Alert
                      Expanded(
                        child: _MetricCard(
                          title: l10n.lowStock,
                          content: Text(
                            '${summary.lowStockCount}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: summary.lowStockCount > 0
                                      ? AppColors.error
                                      : AppColors.success,
                                ),
                          ),
                          subtitle: summary.lowStockCount > 0
                              ? 'Needs Reorder'
                              : 'Healthy Stock',
                          icon: Icons.warning_amber_rounded,
                          accentColor: summary.lowStockCount > 0
                              ? AppColors.error
                              : AppColors.success,
                          onTap: () => context.push('/stock'),
                        ),
                      ),
                      const SizedBox(width: kSpaceM),
                      // 4. Inventory Valuation
                      Expanded(
                        child: _MetricCard(
                          title: l10n.inventoryValue,
                          content: MoneyText(
                            amountPaisa: summary.totalInventoryValuePaisa,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          subtitle: 'At Cost Price',
                          icon: Icons.inventory_2_outlined,
                          accentColor: AppColors.primaryDark,
                          onTap: () => context.push('/stock'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: kSpaceL),

                  // ── Sales Trend (7 Days) ──────────────────────────────────
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.salesWeeklyTrend,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () => context.push('/reports'),
                              child: Text(l10n.viewAll),
                            ),
                          ],
                        ),
                        const SizedBox(height: kSpaceS),
                        SalesTrendChart(
                          points: summary.last7DaysSales,
                          height: 150,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: kSpaceXL),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Center(child: Text(err.toString())),
            ),

            const SizedBox(height: kSpaceL),

            // ── Quick Actions ───────────────────────────────────────────────
            Text(
              l10n.quickActions,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: kSpaceS),
            Row(
              children: [
                _QuickActionButton(
                  icon: Icons.add_shopping_cart,
                  label: l10n.newSale,
                  color: AppColors.primary,
                  onTap: () => context.push('/sales/new'),
                ),
                const SizedBox(width: kSpaceS),
                _QuickActionButton(
                  icon: Icons.person_add_alt_1,
                  label: l10n.addCustomer,
                  color: AppColors.primaryDark,
                  onTap: () => context.push('/customers'),
                ),
                const SizedBox(width: kSpaceS),
                _QuickActionButton(
                  icon: Icons.add_box_outlined,
                  label: l10n.addProduct,
                  color: AppColors.success,
                  onTap: () => context.push('/stock'),
                ),
                const SizedBox(width: kSpaceS),
                _QuickActionButton(
                  icon: Icons.receipt_long_outlined,
                  label: l10n.expenses,
                  color: AppColors.error,
                  onTap: () => context.push('/expenses'),
                ),
              ],
            ),

            const SizedBox(height: kSpaceL),

            // ── Recent Sales ────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.recentSales,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.push('/sales'),
                  child: Text(l10n.viewAll),
                ),
              ],
            ),
            const SizedBox(height: kSpaceXS),
            recentSalesAsync.when(
              data: (sales) {
                if (sales.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: kSpaceM),
                    child: Center(
                      child: Text(
                        l10n.noRecentSales,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }

                final displaySales = sales.take(5).toList();
                return Column(
                  children: displaySales.map((item) {
                    final sale = item.sale;
                    final isCancelled = sale.status == 'cancelled';
                    return Padding(
                      padding:
                          const EdgeInsetsDirectional.only(bottom: kSpaceS),
                      child: AppCard(
                        onTap: () => context.push('/sales/${sale.id}'),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isCancelled
                                    ? AppColors.error.withValues(alpha: 0.12)
                                    : AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isCancelled
                                    ? Icons.cancel_outlined
                                    : Icons.receipt_outlined,
                                color: isCancelled
                                    ? AppColors.error
                                    : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: kSpaceM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sale.invoiceNo,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    item.customer?.name ?? l10n.walkInCustomer,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: item.customer != null
                                          ? null
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                MoneyText(
                                  amountPaisa: sale.totalPaisa,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  AppDateUtils.formatTime(sale.saleDate),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text(err.toString())),
            ),

            const SizedBox(height: kSpaceXL),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final Widget content;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _MetricCard({
    required this.title,
    required this.content,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Icon(icon, size: 18, color: accentColor),
            ],
          ),
          const SizedBox(height: kSpaceS),
          content,
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: kSpaceM),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
