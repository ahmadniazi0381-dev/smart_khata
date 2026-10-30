import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/money.dart';
import '../../../../l10n/app_localizations.dart';

class ExpenseFormDialog extends StatefulWidget {
  final Expense? existingExpense;

  const ExpenseFormDialog({this.existingExpense, super.key});

  @override
  State<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends State<ExpenseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  String? _selectedCategory;
  late int _expenseDateMs;

  @override
  void initState() {
    super.initState();
    final e = widget.existingExpense;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _amountCtrl = TextEditingController(
      text: e != null ? (e.amountPaisa / 100).toStringAsFixed(0) : '',
    );
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _selectedCategory = e?.category;
    _expenseDateMs = e?.expenseDate ?? AppDateUtils.nowMs();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final current = AppDateUtils.fromMs(_expenseDateMs);
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _expenseDateMs = picked.millisecondsSinceEpoch;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.existingExpense != null;

    final categories = [
      l10n.categoryRent,
      l10n.categoryElectricity,
      l10n.categorySalaries,
      l10n.categoryTransport,
      l10n.categoryMaintenance,
      l10n.categoryFoodTea,
      l10n.categoryOther,
    ];

    return AlertDialog(
      title: Text(isEditing ? l10n.editExpense : l10n.addExpense),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: l10n.expenseTitle,
                  prefixIcon: const Icon(Icons.edit_note_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? l10n.errorRequired
                    : null,
                autofocus: true,
              ),
              const SizedBox(height: kSpaceM),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: l10n.expenseCategory,
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
                items: categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (cat) => setState(() => _selectedCategory = cat),
              ),
              const SizedBox(height: kSpaceM),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.expenseAmount,
                  prefixText: 'PKR ',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10n.errorRequired;
                  }
                  final parsed = Money.parse(val);
                  if (parsed == null || parsed <= 0) {
                    return l10n.errorInvalidNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: kSpaceM),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.expenseDate,
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(AppDateUtils.formatDate(_expenseDateMs)),
                ),
              ),
              const SizedBox(height: kSpaceM),
              TextFormField(
                controller: _noteCtrl,
                decoration: InputDecoration(
                  labelText: l10n.note,
                  prefixIcon: const Icon(Icons.note_alt_outlined),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.btnCancel),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final amountPaisa = Money.parse(_amountCtrl.text) ?? 0;
              Navigator.of(context).pop({
                'title': _titleCtrl.text.trim(),
                'category': _selectedCategory,
                'amountPaisa': amountPaisa,
                'expenseDate': _expenseDateMs,
                'note': _noteCtrl.text.trim().isEmpty
                    ? null
                    : _noteCtrl.text.trim(),
              });
            }
          },
          child: Text(l10n.btnSave),
        ),
      ],
    );
  }
}
