import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/sales_providers.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final salesAsync = ref.watch(salesListStreamProvider);
    final statusFilter = ref.watch(saleStatusFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navSales),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
                kSpaceM, kSpaceM, kSpaceM, kSpaceXS),
            child: SearchField(
              controller: _searchController,
              hintText: l10n.searchHint,
              onChanged: (val) {
                ref.read(saleSearchQueryProvider.notifier).state = val;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: kSpaceM, vertical: kSpaceXS),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text(l10n.filterAll),
                  selected: statusFilter == null,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(saleStatusFilterProvider.notifier).state = null;
                    }
                  },
                ),
                const SizedBox(width: kSpaceS),
                ChoiceChip(
                  label: Text(l10n.filterCompleted),
                  selected: statusFilter == 'completed',
                  onSelected: (selected) {
                    ref.read(saleStatusFilterProvider.notifier).state =
                        selected ? 'completed' : null;
                  },
                ),
                const SizedBox(width: kSpaceS),
                ChoiceChip(
                  label: Text(l10n.filterCancelled),
                  selected: statusFilter == 'cancelled',
                  onSelected: (selected) {
                    ref.read(saleStatusFilterProvider.notifier).state =
                        selected ? 'cancelled' : null;
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: salesAsync.when(
              data: (sales) {
                if (sales.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: Text(l10n.emptyState),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsetsDirectional.all(kSpaceM),
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    final item = sales[index];
                    final sale = item.sale;
                    final isCancelled = sale.status == 'cancelled';

                    return Padding(
                      padding:
                          const EdgeInsetsDirectional.only(bottom: kSpaceS),
                      child: AppCard(
                        onTap: () => context.push('/sales/${sale.id}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  sale.invoiceNo,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsetsDirectional.symmetric(
                                    horizontal: kSpaceS,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isCancelled
                                        ? AppColors.error
                                            .withValues(alpha: 0.12)
                                        : AppColors.success
                                            .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isCancelled
                                        ? l10n.statusCancelled
                                        : l10n.statusCompleted,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isCancelled
                                          ? AppColors.error
                                          : AppColors.success,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: kSpaceXS),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.customer?.name ?? l10n.walkInCustomer,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: item.customer != null
                                              ? null
                                              : AppColors.textSecondary,
                                          fontStyle: item.customer != null
                                              ? FontStyle.normal
                                              : FontStyle.italic,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  AppDateUtils.formatDateTime(sale.saleDate),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            const Divider(height: kSpaceM),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MoneyText(
                                  amountPaisa: sale.totalPaisa,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                if (sale.duePaisa > 0)
                                  Text(
                                    '${l10n.due}: ${Money.format(sale.duePaisa)}',
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  )
                                else
                                  Text(
                                    l10n.paid,
                                    style: const TextStyle(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text(err.toString())),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/sales/new'),
        icon: const Icon(Icons.add_shopping_cart),
        label: Text(l10n.newSale),
      ),
    );
  }
}
