import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/qty.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/inventory_providers.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _unitController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _initialStockController;
  late final TextEditingController _lowStockController;
  String? _selectedCategoryId;
  bool _isLoading = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _skuController = TextEditingController(text: p?.sku ?? '');
    _unitController = TextEditingController(text: p?.unit ?? 'pcs');
    _purchasePriceController = TextEditingController(
      text: p != null ? Money.formatAmount(p.purchasePricePaisa) : '',
    );
    _sellingPriceController = TextEditingController(
      text: p != null ? Money.formatAmount(p.sellingPricePaisa) : '',
    );
    _initialStockController = TextEditingController();
    _lowStockController = TextEditingController(
      text: p != null ? Qty.formatNumber(p.lowStockMilli) : '1',
    );
    _selectedCategoryId = p?.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _unitController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _initialStockController.dispose();
    _lowStockController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final purchasePricePaisa =
        Money.parse(_purchasePriceController.text.trim()) ?? 0;
    final sellingPricePaisa =
        Money.parse(_sellingPriceController.text.trim()) ?? 0;
    final initialStockMilli =
        !_isEditing && _initialStockController.text.trim().isNotEmpty
            ? Qty.parse(_initialStockController.text.trim()) ?? 0
            : 0;
    final lowStockMilli = Qty.parse(_lowStockController.text.trim()) ?? 1000;

    setState(() => _isLoading = true);
    try {
      await ref.read(inventoryRepositoryProvider).saveProduct(
            id: widget.product?.id,
            categoryId: _selectedCategoryId,
            name: _nameController.text.trim(),
            sku: _skuController.text.trim().isEmpty
                ? null
                : _skuController.text.trim(),
            unit: _unitController.text.trim().isEmpty
                ? 'pcs'
                : _unitController.text.trim(),
            purchasePricePaisa: purchasePricePaisa,
            sellingPricePaisa: sellingPricePaisa,
            initialStockMilli: initialStockMilli,
            lowStockMilli: lowStockMilli,
          );

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.productSaved),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categoriesAsync = ref.watch(activeCategoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editProduct : l10n.addProduct),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.all(kSpaceM),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  autofocus: !_isEditing,
                  decoration: InputDecoration(
                    labelText: l10n.productName,
                    prefixIcon: const Icon(Icons.inventory_2_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return l10n.errorRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: kSpaceM),

                // Category selector
                categoriesAsync.when(
                  data: (categories) => DropdownButtonFormField<String?>(
                    initialValue: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: l10n.category,
                      prefixIcon: const Icon(Icons.folder_outlined),
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(l10n.noCategory),
                      ),
                      ...categories.map(
                        (c) => DropdownMenuItem<String?>(
                          value: c.id,
                          child: Text(c.name),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedCategoryId = val);
                    },
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: kSpaceM),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _unitController,
                        decoration: InputDecoration(
                          labelText: l10n.unit,
                          hintText: 'pcs, kg, ltr...',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return l10n.errorRequired;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: kSpaceM),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _skuController,
                        decoration: InputDecoration(
                          labelText: l10n.sku,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: kSpaceM),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _sellingPriceController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          labelText: l10n.sellingPrice,
                          prefixText: 'PKR ',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return l10n.errorRequired;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: kSpaceM),
                    Expanded(
                      child: TextFormField(
                        controller: _purchasePriceController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          labelText: l10n.purchasePrice,
                          prefixText: 'PKR ',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: kSpaceM),

                Row(
                  children: [
                    if (!_isEditing) ...[
                      Expanded(
                        child: TextFormField(
                          controller: _initialStockController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: l10n.initialStock,
                            hintText: '0',
                          ),
                        ),
                      ),
                      const SizedBox(width: kSpaceM),
                    ],
                    Expanded(
                      child: TextFormField(
                        controller: _lowStockController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          labelText: l10n.lowStockThreshold,
                          hintText: '1',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: kSpaceXL),

                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsetsDirectional.symmetric(
                      vertical: kSpaceM,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          l10n.btnSave,
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
