import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../../l10n/app_localizations.dart';

class ReceivePaymentDialog extends ConsumerStatefulWidget {
  final String customerId;
  final int currentBalancePaisa;

  const ReceivePaymentDialog({
    super.key,
    required this.customerId,
    required this.currentBalancePaisa,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String customerId,
    required int currentBalancePaisa,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ReceivePaymentDialog(
        customerId: customerId,
        currentBalancePaisa: currentBalancePaisa,
      ),
    );
  }

  @override
  ConsumerState<ReceivePaymentDialog> createState() =>
      _ReceivePaymentDialogState();
}

class _ReceivePaymentDialogState extends ConsumerState<ReceivePaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _method = 'cash';
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final paisa = Money.parse(_amountController.text.trim());
    if (paisa == null || paisa <= 0) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(ledgerServiceProvider).receivePayment(
            customerId: widget.customerId,
            amountPaisa: paisa,
            method: _method,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(true);
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

    return AlertDialog(
      title: Text(l10n.receivePayment),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${l10n.balance}: ${Money.format(widget.currentBalancePaisa)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: kSpaceM),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.paymentAmount,
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
                  if (p > widget.currentBalancePaisa) {
                    return 'Cannot exceed balance (${Money.format(widget.currentBalancePaisa)})';
                  }
                  return null;
                },
              ),
              const SizedBox(height: kSpaceM),
              DropdownButtonFormField<String>(
                initialValue: _method,
                decoration: InputDecoration(labelText: l10n.paymentMethod),
                items: [
                  DropdownMenuItem(value: 'cash', child: Text(l10n.methodCash)),
                  DropdownMenuItem(value: 'bank', child: Text(l10n.methodBank)),
                  DropdownMenuItem(
                      value: 'wallet', child: Text(l10n.methodWallet)),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _method = val);
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
