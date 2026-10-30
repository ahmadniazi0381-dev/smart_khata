import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/qty.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customers/presentation/providers/customer_providers.dart';
import '../../../inventory/presentation/providers/inventory_providers.dart';
import '../providers/cart_provider.dart';

class NewSaleScreen extends ConsumerStatefulWidget {
  const NewSaleScreen({super.key});

  @override
  ConsumerState<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends ConsumerState<NewSaleScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _productSearchController =
      TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _paidController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _productSearchController.dispose();
    _discountController.dispose();
    _paidController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitSale() async {
    final l10n = AppLocalizations.of(context);
    final cart = ref.read(cartProvider);

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cartEmpty)),
      );
      return;
    }

    if (cart.duePaisa > 0 && cart.customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.customerRequiredForCredit)),
      );
      return;
    }

    if (cart.discountPaisa > cart.subtotalPaisa) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.discountExceedsSubtotal)),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final saleService = ref.read(saleServiceProvider);
      final sale = await saleService.createSale(
        cart: cart.items,
        discountPaisa: cart.discountPaisa,
        paidPaisa: cart.paidPaisa,
        customerId: cart.customerId,
        method: cart.paymentMethod,
        note: cart.note,
      );

      ref.read(cartProvider.notifier).clear();
      _discountController.clear();
      _paidController.clear();
      _noteController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.saleCreated)),
        );
        // Navigate to sale detail
        context.pushReplacement('/sales/${sale.id}');
      }
    } on InsufficientStockException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${e.productName}: ${l10n.insufficientStockAlert} (${Qty.formatNumber(e.availableMilli)})',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _showQuickAddCustomerDialog() async {
    final l10n = AppLocalizations.of(context);
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<Customer>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.quickAddCustomer),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: l10n.customerName,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? l10n.errorRequired
                    : null,
                autofocus: true,
              ),
              const SizedBox(height: kSpaceM),
              TextFormField(
                controller: phoneCtrl,
                decoration: InputDecoration(
                  labelText: l10n.customerPhone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.btnCancel),
          ),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final repo = ref.read(customerRepositoryProvider);
                final newCustomer = await repo.saveCustomer(
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim().isEmpty
                      ? null
                      : phoneCtrl.text.trim(),
                );
                if (ctx.mounted) Navigator.of(ctx).pop(newCustomer);
              }
            },
            child: Text(l10n.btnAdd),
          ),
        ],
      ),
    );

    if (saved != null) {
      ref.read(cartProvider.notifier).setCustomer(saved.id);
    }
  }

  Future<void> _editQuantityDialog(String productId, String productName,
      int currentQtyMilli, String unit) async {
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: Qty.formatNumber(currentQtyMilli));

    final newQtyMilli = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(productName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.unit}: $unit'),
            const SizedBox(height: kSpaceM),
            TextField(
              controller: ctrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.currentStock,
                suffixText: unit,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.btnCancel),
          ),
          FilledButton(
            onPressed: () {
              final parsed = Qty.parse(ctrl.text);
              Navigator.of(ctx).pop(parsed);
            },
            child: Text(l10n.btnConfirm),
          ),
        ],
      ),
    );

    if (newQtyMilli != null) {
      ref.read(cartProvider.notifier).updateQuantity(productId, newQtyMilli);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newSale),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.grid_view_outlined),
              text: l10n.products,
            ),
            Tab(
              icon: Badge(
                isLabelVisible: cart.itemCount > 0,
                label: Text('${cart.itemCount}'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              text: l10n.cart,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductsTab(),
          _buildCartTab(),
        ],
      ),
      bottomNavigationBar: cart.items.isNotEmpty && _tabController.index == 0
          ? SafeArea(
              child: Container(
                padding: const EdgeInsetsDirectional.all(kSpaceM),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.itemsCount(cart.itemCount),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          MoneyText(
                            amountPaisa: cart.totalPaisa,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _tabController.animateTo(1),
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(l10n.goToCart),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildProductsTab() {
    final l10n = AppLocalizations.of(context);
    final categoriesAsync = ref.watch(activeCategoriesStreamProvider);
    final selectedCatId = ref.watch(selectedCategoryIdProvider);
    final productsAsync = ref.watch(productsListStreamProvider);
    final cart = ref.watch(cartProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
              kSpaceM, kSpaceM, kSpaceM, kSpaceXS),
          child: SearchField(
            controller: _productSearchController,
            hintText: l10n.searchHint,
            onChanged: (val) {
              ref.read(productSearchQueryProvider.notifier).state = val;
            },
          ),
        ),
        categoriesAsync.when(
          data: (categories) {
            if (categories.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: kSpaceM, vertical: kSpaceXS),
                children: [
                  ChoiceChip(
                    label: Text(l10n.allCategories),
                    selected: selectedCatId == null,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(selectedCategoryIdProvider.notifier).state =
                            null;
                      }
                    },
                  ),
                  const SizedBox(width: kSpaceXS),
                  ...categories.map(
                    (cat) => Padding(
                      padding: const EdgeInsetsDirectional.only(end: kSpaceXS),
                      child: ChoiceChip(
                        label: Text(cat.name),
                        selected: selectedCatId == cat.id,
                        onSelected: (selected) {
                          ref.read(selectedCategoryIdProvider.notifier).state =
                              selected ? cat.id : null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox(height: 48),
          error: (_, __) => const SizedBox.shrink(),
        ),
        Expanded(
          child: productsAsync.when(
            data: (products) {
              if (products.isEmpty) {
                return EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: Text(l10n.emptyState),
                );
              }
              return ListView.builder(
                padding: const EdgeInsetsDirectional.all(kSpaceM),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final inCart = cart.getItem(product.id);
                  final isOutOfStock = product.stockMilli <= 0;

                  return Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: kSpaceS),
                    child: AppCard(
                      onTap: isOutOfStock
                          ? null
                          : () {
                              ref
                                  .read(cartProvider.notifier)
                                  .addProduct(product);
                            },
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isOutOfStock
                                  ? AppColors.error.withValues(alpha: 0.12)
                                  : inCart != null
                                      ? AppColors.primary
                                          .withValues(alpha: 0.12)
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: inCart != null
                                  ? Text(
                                      Qty.formatNumber(inCart.qtyMilli),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : Icon(
                                      Icons.inventory_2_outlined,
                                      color: isOutOfStock
                                          ? AppColors.error
                                          : AppColors.textSecondary,
                                    ),
                            ),
                          ),
                          const SizedBox(width: kSpaceM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isOutOfStock
                                      ? l10n.outOfStock
                                      : l10n.stockAvailable(Qty.format(
                                          product.stockMilli, product.unit)),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: isOutOfStock
                                            ? AppColors.error
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
                                amountPaisa: product.sellingPricePaisa,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              if (inCart != null)
                                Text(
                                  'In Cart',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                )
                              else
                                Text(
                                  '/${product.unit}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: AppColors.textSecondary),
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
    );
  }

  Widget _buildCartTab() {
    final l10n = AppLocalizations.of(context);
    final cart = ref.watch(cartProvider);
    final customersAsync = ref.watch(customersListStreamProvider);

    if (cart.items.isEmpty) {
      return EmptyState(
        icon: Icons.shopping_cart_outlined,
        title: Text(l10n.cartEmpty),
        subtitle: Text(l10n.cartEmptySubtitle),
        action: FilledButton(
          onPressed: () => _tabController.animateTo(0),
          child: Text(l10n.products),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsetsDirectional.all(kSpaceM),
      children: [
        Text(
          l10n.itemsPurchased,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: kSpaceS),
        ...cart.items.map((item) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(bottom: kSpaceS),
            child: AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.productName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      MoneyText(
                        amountPaisa: item.lineTotalPaisa,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: kSpaceS),
                  Row(
                    children: [
                      Text(
                        '${Money.format(item.unitPricePaisa)} / ${item.unit}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: AppColors.textSecondary,
                        onPressed: () {
                          ref.read(cartProvider.notifier).updateQuantity(
                                item.productId,
                                item.qtyMilli - 1000,
                              );
                        },
                      ),
                      InkWell(
                        onTap: () => _editQuantityDialog(
                          item.productId,
                          item.productName,
                          item.qtyMilli,
                          item.unit,
                        ),
                        child: Container(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: kSpaceS,
                            vertical: kSpaceXS,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).dividerColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            Qty.format(item.qtyMilli, item.unit),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppColors.primary,
                        onPressed: () {
                          ref.read(cartProvider.notifier).updateQuantity(
                                item.productId,
                                item.qtyMilli + 1000,
                              );
                        },
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.delete_outline),
                        color: AppColors.error,
                        onPressed: () {
                          ref
                              .read(cartProvider.notifier)
                              .removeItem(item.productId);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: kSpaceM),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Summary',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: kSpaceS),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.subtotal,
                      style: Theme.of(context).textTheme.bodyMedium),
                  MoneyText(amountPaisa: cart.subtotalPaisa),
                ],
              ),
              const SizedBox(height: kSpaceS),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.discount,
                      style: Theme.of(context).textTheme.bodyMedium),
                  SizedBox(
                    width: 140,
                    child: TextField(
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.end,
                      decoration: const InputDecoration(
                        prefixText: 'PKR ',
                        isDense: true,
                        contentPadding: EdgeInsetsDirectional.symmetric(
                            horizontal: kSpaceS, vertical: kSpaceXS),
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val) ?? 0;
                        ref
                            .read(cartProvider.notifier)
                            .setDiscount(parsed * 100);
                      },
                    ),
                  ),
                ],
              ),
              const Divider(height: kSpaceL),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.total,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  MoneyText(
                    amountPaisa: cart.totalPaisa,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: kSpaceM),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.selectCustomer,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _showQuickAddCustomerDialog,
                    icon: const Icon(Icons.person_add_alt_1, size: 18),
                    label: Text(l10n.btnAdd),
                  ),
                ],
              ),
              const SizedBox(height: kSpaceXS),
              customersAsync.when(
                data: (customers) {
                  return DropdownButtonFormField<String?>(
                    initialValue: cart.customerId,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline),
                      helperText: cart.duePaisa > 0
                          ? l10n.customerRequiredForCredit
                          : null,
                      helperStyle: cart.duePaisa > 0 && cart.customerId == null
                          ? const TextStyle(color: AppColors.error)
                          : null,
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(l10n.walkInCustomer),
                      ),
                      ...customers.map(
                        (c) => DropdownMenuItem<String?>(
                          value: c.id,
                          child: Text(
                              '${c.name}${c.phone != null ? ' (${c.phone})' : ''}'),
                        ),
                      ),
                    ],
                    onChanged: (id) {
                      ref.read(cartProvider.notifier).setCustomer(id);
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text(e.toString()),
              ),
              const SizedBox(height: kSpaceM),
              Text(
                l10n.paymentType,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: kSpaceXS),
              SegmentedButton<PaymentType>(
                segments: [
                  ButtonSegment(
                    value: PaymentType.fullCash,
                    label: Text(l10n.fullCash),
                  ),
                  ButtonSegment(
                    value: PaymentType.fullCredit,
                    label: Text(l10n.fullCredit),
                  ),
                  ButtonSegment(
                    value: PaymentType.partial,
                    label: Text(l10n.partialPayment),
                  ),
                ],
                selected: {cart.paymentType},
                onSelectionChanged: (selection) {
                  ref
                      .read(cartProvider.notifier)
                      .setPaymentType(selection.first);
                },
              ),
              if (cart.paymentType == PaymentType.partial) ...[
                const SizedBox(height: kSpaceM),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _paidController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.paymentAmount,
                          prefixText: 'PKR ',
                        ),
                        onChanged: (val) {
                          final parsed = int.tryParse(val) ?? 0;
                          ref
                              .read(cartProvider.notifier)
                              .setCustomPaidPaisa(parsed * 100);
                        },
                      ),
                    ),
                    const SizedBox(width: kSpaceM),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(l10n.due,
                            style: Theme.of(context).textTheme.bodySmall),
                        MoneyText(
                          amountPaisa: cart.duePaisa,
                          isNegative: cart.duePaisa > 0,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
              if (cart.paidPaisa > 0) ...[
                const SizedBox(height: kSpaceM),
                Text(
                  l10n.paymentMethod,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: kSpaceXS),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'cash',
                      label: Text(l10n.methodCash),
                    ),
                    ButtonSegment(
                      value: 'bank',
                      label: Text(l10n.methodBank),
                    ),
                    ButtonSegment(
                      value: 'wallet',
                      label: Text(l10n.methodWallet),
                    ),
                  ],
                  selected: {cart.paymentMethod},
                  onSelectionChanged: (selection) {
                    ref
                        .read(cartProvider.notifier)
                        .setPaymentMethod(selection.first);
                  },
                ),
              ],
              const SizedBox(height: kSpaceM),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: l10n.note,
                  prefixIcon: const Icon(Icons.note_alt_outlined),
                ),
                onChanged: (val) {
                  ref.read(cartProvider.notifier).setNote(val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: kSpaceL),
        FilledButton.icon(
          onPressed:
              _isSubmitting || (cart.duePaisa > 0 && cart.customerId == null)
                  ? null
                  : _submitSale,
          style: FilledButton.styleFrom(
            padding: const EdgeInsetsDirectional.symmetric(vertical: kSpaceM),
          ),
          icon: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_circle_outline),
          label: Text(
            l10n.completeSale,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: kSpaceXL),
      ],
    );
  }
}
