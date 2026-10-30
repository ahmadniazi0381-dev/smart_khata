import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/qty.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/inventory_providers.dart';
import '../widgets/adjust_stock_dialog.dart';
import 'product_form_screen.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final productAsync = ref.watch(productDetailStreamProvider(productId));
    final movementsAsync =
        ref.watch(productStockMovementsStreamProvider(productId));

    return productAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.loading)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        appBar: AppBar(title: Text(l10n.errorGeneral)),
        body: Center(child: Text(e.toString())),
      ),
      data: (product) {
        if (product == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.emptyState)),
            body: Center(child: Text(l10n.emptyState)),
          );
        }

        final isLowStock = product.stockMilli <= product.lowStockMilli;

        return Scaffold(
          appBar: AppBar(
            title: Text(product.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n.btnEdit,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductFormScreen(product: product),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.archive_outlined),
                tooltip: l10n.archiveProduct,
                onPressed: () async {
                  final confirmed = await showConfirmDialog(
                    context,
                    title: l10n.archiveProduct,
                    message: l10n.confirmDelete,
                    confirmText: l10n.archiveProduct,
                    isDangerous: true,
                  );
                  if (confirmed) {
                    await ref
                        .read(inventoryRepositoryProvider)
                        .archiveProduct(product.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.productArchived)),
                      );
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // ── Header Card ───────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsetsDirectional.all(kSpaceM),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.sellingPrice,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              Money.format(product.sellingPricePaisa),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              l10n.purchasePrice,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              Money.format(product.purchasePricePaisa),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: kSpaceL),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 20),
                            const SizedBox(width: kSpaceXS),
                            Text(
                              '${l10n.currentStock}: ',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Chip(
                              label: Text(
                                Qty.format(product.stockMilli, product.unit),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isLowStock
                                      ? AppColors.error
                                      : AppColors.success,
                                ),
                              ),
                              backgroundColor: isLowStock
                                  ? AppColors.error.withValues(alpha: 0.1)
                                  : AppColors.success.withValues(alpha: 0.1),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        FilledButton.icon(
                          onPressed: () => AdjustStockDialog.show(
                            context,
                            productId: product.id,
                            productName: product.name,
                            unit: product.unit,
                            currentStockMilli: product.stockMilli,
                          ),
                          icon: const Icon(Icons.tune_outlined, size: 18),
                          label: Text(l10n.adjustStock),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Movement History Header ───────────────────────────────────
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    kSpaceM, kSpaceM, kSpaceM, kSpaceS),
                child: Row(
                  children: [
                    Text(
                      l10n.stockHistory,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),

              // ── Movement History List ─────────────────────────────────────
              Expanded(
                child: movementsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text(e.toString())),
                  data: (movements) {
                    if (movements.isEmpty) {
                      return EmptyState(
                        icon: Icons.history_outlined,
                        title: Text(l10n.emptyState),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: kSpaceM,
                        vertical: kSpaceS,
                      ),
                      itemCount: movements.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: kSpaceXS),
                      itemBuilder: (context, index) {
                        final m = movements[index];
                        final isPositive = m.qtyDeltaMilli > 0;

                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isPositive
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : AppColors.error.withValues(alpha: 0.1),
                              child: Icon(
                                isPositive ? Icons.add : Icons.remove,
                                color: isPositive
                                    ? AppColors.success
                                    : AppColors.error,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              m.movementType,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              '${AppDateUtils.formatDate(m.createdAt)}${m.note != null && m.note!.isNotEmpty ? ' • ${m.note}' : ''}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isPositive ? '+' : ''}${Qty.format(m.qtyDeltaMilli, product.unit)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isPositive
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                                Text(
                                  'After: ${Qty.format(m.stockAfterMilli, product.unit)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
