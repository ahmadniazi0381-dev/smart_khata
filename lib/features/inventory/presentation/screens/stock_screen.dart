import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/qty.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/inventory_providers.dart';
import 'categories_screen.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final productsAsync = ref.watch(productsListStreamProvider);
    final categoriesAsync = ref.watch(activeCategoriesStreamProvider);
    final selectedCategory = ref.watch(selectedCategoryIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navStock),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: l10n.categoriesTitle,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CategoriesScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
                kSpaceM, kSpaceM, kSpaceM, kSpaceS),
            child: SearchField(
              hintText: l10n.searchHint,
              onChanged: (val) {
                ref.read(productSearchQueryProvider.notifier).state = val;
              },
            ),
          ),

          // ── Category Filter Pills ─────────────────────────────────────────
          categoriesAsync.when(
            data: (categories) {
              if (categories.isEmpty) return const SizedBox.shrink();

              return SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: kSpaceM,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: kSpaceS),
                      child: FilterChip(
                        label: Text(l10n.allCategories),
                        selected: selectedCategory == null,
                        onSelected: (_) {
                          ref.read(selectedCategoryIdProvider.notifier).state =
                              null;
                        },
                      ),
                    ),
                    ...categories.map(
                      (cat) => Padding(
                        padding: const EdgeInsetsDirectional.only(end: kSpaceS),
                        child: FilterChip(
                          label: Text(cat.name),
                          selected: selectedCategory == cat.id,
                          onSelected: (selected) {
                            ref
                                .read(selectedCategoryIdProvider.notifier)
                                .state = selected ? cat.id : null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: kSpaceS),

          // ── Product List ──────────────────────────────────────────────────
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text(e.toString())),
              data: (products) {
                if (products.isEmpty) {
                  return EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: Text(l10n.emptyState),
                    action: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ProductFormScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addProduct),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: kSpaceM,
                    vertical: kSpaceS,
                  ),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: kSpaceXS),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final isLowStock =
                        product.stockMilli <= product.lowStockMilli;

                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isLowStock
                              ? AppColors.error.withValues(alpha: 0.1)
                              : AppColors.primaryLight,
                          child: Icon(
                            Icons.inventory_2_outlined,
                            color: isLowStock
                                ? AppColors.error
                                : AppColors.primary,
                          ),
                        ),
                        title: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          Money.format(product.sellingPricePaisa),
                          style: const TextStyle(color: AppColors.primary),
                        ),
                        trailing: Chip(
                          label: Text(
                            Qty.format(product.stockMilli, product.unit),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
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
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(productId: product.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ProductFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.addProduct),
      ),
    );
  }
}
