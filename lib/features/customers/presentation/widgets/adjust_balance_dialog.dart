import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../../l10n/app_localizations.dart';

class AdjustBalanceDialog extends ConsumerStatefulWidget {
  final String customerId;

  const AdjustBalanceDialog({
    super.key,
    required this.customerId,
  });

  static Future<bool?> show(BuildContext context,
      {required String customerId}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AdjustBalanceDialog(customerId: customerId),
    );
  }

  @override
  ConsumerState<AdjustBalanceDialog> createState() =>
      _AdjustBalanceDialogState();
}

class _AdjustBalanceDialogState extends ConsumerState<AdjustBalanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isIncrease =
      true; // true = customer owes more (+), false = owes less (-)
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final paisa = Money.parse(_amountController.text.trim());
    if (paisa == null || paisa <= 0) return;

    final signedPaisa = _isIncrease ? paisa : -paisa;

    setState(() => _isLoading = true);
    try {
      await ref.read(ledgerServiceProvider).adjustBalance(
            customerId: widget.customerId,
            signedAmountPaisa: signedPaisa,
            reason: _reasonController.text.trim(),
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
      title: Text(l10n.adjustBalance),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: true,
                    label: Text('+ Increase'),
                    icon: Icon(Icons.arrow_upward, color: AppColors.error),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text('- Decrease'),
                    icon: Icon(Icons.arrow_downward, color: AppColors.success),
                  ),
                ],
                selected: {_isIncrease},
                onSelectionChanged: (val) {
                  setState(() => _isIncrease = val.first);
                },
              ),
              const SizedBox(height: kSpaceM),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.adjustmentAmount,
                  prefixText: 'PKR ',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10n.errorRequired;
                  }
                  final p = Money.parse(val.trim());
                  if (p == null || p <= 0) {
                    return l10n.errorInvalidNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: kSpaceM),
              TextFormField(
                controller: _reasonController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.adjustmentReason,
                  hintText: 'e.g., Ledger correction, agreed discount',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10n.errorRequired;
                  }
                  return null;
                },
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
