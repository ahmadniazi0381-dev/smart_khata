import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/qty.dart';
import '../../../../l10n/app_localizations.dart';

class AdjustStockDialog extends ConsumerStatefulWidget {
  final String productId;
  final String productName;
  final String unit;
  final int currentStockMilli;

  const AdjustStockDialog({
    super.key,
    required this.productId,
    required this.productName,
    required this.unit,
    required this.currentStockMilli,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String productId,
    required String productName,
    required String unit,
    required int currentStockMilli,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AdjustStockDialog(
        productId: productId,
        productName: productName,
        unit: unit,
        currentStockMilli: currentStockMilli,
      ),
    );
  }

  @override
  ConsumerState<AdjustStockDialog> createState() => _AdjustStockDialogState();
}

class _AdjustStockDialogState extends ConsumerState<AdjustStockDialog> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isAddition = true; // true = stock in (+), false = stock out (-)
  String _movementType = 'ADJUSTMENT';
  bool _isLoading = false;

  @override
  void dispose() {
    _qtyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final milli = Qty.parse(_qtyController.text.trim());
    if (milli == null || milli <= 0) return;

    final delta = _isAddition ? milli : -milli;

    setState(() => _isLoading = true);
    try {
      await ref.read(inventoryServiceProvider).adjustStock(
            productId: widget.productId,
            deltaMilli: delta,
            movementType: _movementType,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text('${l10n.adjustStock}: ${widget.productName}'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${l10n.currentStock}: ${Qty.format(widget.currentStockMilli, widget.unit)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: kSpaceM),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: true,
                    label: Text('+ Add Stock'),
                    icon: Icon(Icons.add, color: AppColors.success),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text('- Reduce Stock'),
                    icon: Icon(Icons.remove, color: AppColors.error),
                  ),
                ],
                selected: {_isAddition},
                onSelectionChanged: (val) {
                  setState(() => _isAddition = val.first);
                },
              ),
              const SizedBox(height: kSpaceM),
              TextFormField(
                controller: _qtyController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.stockDelta,
                  suffixText: widget.unit,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10n.errorRequired;
                  }
                  final m = Qty.parse(val.trim());
                  if (m == null || m <= 0) {
                    return l10n.errorInvalidNumber;
                  }
                  if (!_isAddition && m > widget.currentStockMilli) {
                    return 'Cannot reduce more than current stock';
                  }
                  return null;
                },
              ),
              const SizedBox(height: kSpaceM),
              DropdownButtonFormField<String>(
                initialValue: _movementType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(
                      value: 'ADJUSTMENT', child: Text('Adjustment / Count')),
                  DropdownMenuItem(
                      value: 'DAMAGE', child: Text('Damaged / Expired')),
                  DropdownMenuItem(
                      value: 'RETURN', child: Text('Customer Return')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _movementType = val);
                },
              ),
              const SizedBox(height: kSpaceM),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(labelText: l10n.note),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.btnCancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.btnSave),
        ),
      ],
    );
  }
}
