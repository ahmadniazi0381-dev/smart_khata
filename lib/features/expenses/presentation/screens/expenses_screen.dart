import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/expense_providers.dart';
import '../widgets/expense_form_dialog.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  Future<void> _openExpenseDialog(BuildContext context, WidgetRef ref,
      [Expense? existing]) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => ExpenseFormDialog(existingExpense: existing),
    );

    if (result != null) {
      final repo = ref.read(expenseRepositoryProvider);
      await repo.saveExpense(
        id: existing?.id,
        title: result['title'] as String,
        category: result['category'] as String?,
        amountPaisa: result['amountPaisa'] as int,
        expenseDate: result['expenseDate'] as int,
        note: result['note'] as String?,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.expenseSaved)),
        );
      }
    }
  }

  Future<void> _deleteExpense(
      BuildContext context, WidgetRef ref, Expense expense) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.confirmDelete,
      message: expense.title,
      confirmText: l10n.btnDelete,
      isDangerous: true,
    );

    if (confirmed) {
      final repo = ref.read(expenseRepositoryProvider);
      await repo.deleteExpense(expense.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.expenseDeleted)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final expensesAsync = ref.watch(expensesListStreamProvider);
    final totalAsync = ref.watch(totalExpensesProvider);
    final selectedCategory = ref.watch(expenseSelectedCategoryProvider);

    final categories = [
      l10n.categoryRent,
      l10n.categoryElectricity,
      l10n.categorySalaries,
      l10n.categoryTransport,
      l10n.categoryMaintenance,
      l10n.categoryFoodTea,
      l10n.categoryOther,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.expenses),
      ),
      body: Column(
        children: [
          // Total Expenses summary card
          Padding(
            padding: const EdgeInsetsDirectional.all(kSpaceM),
            child: AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.totalExpenses,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      totalAsync.when(
                        data: (total) => MoneyText(
                          amountPaisa: total,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                        ),
                        loading: () => const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, __) => const Text('—'),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: AppColors.error.withValues(alpha: 0.12),
                    child: const Icon(Icons.receipt_outlined,
                        color: AppColors.error),
                  ),
                ],
              ),
            ),
          ),

          // Categories filter pills
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: kSpaceM, vertical: 2),
              children: [
                ChoiceChip(
                  label: Text(l10n.filterAll),
                  selected: selectedCategory == null,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(expenseSelectedCategoryProvider.notifier).state =
                          null;
                    }
                  },
                ),
                const SizedBox(width: kSpaceS),
                ...categories.map(
                  (cat) => Padding(
                    padding: const EdgeInsetsDirectional.only(end: kSpaceS),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: selectedCategory == cat,
                      onSelected: (selected) {
                        ref
                            .read(expenseSelectedCategoryProvider.notifier)
                            .state = selected ? cat : null;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: kSpaceS),

          // Expenses List
          Expanded(
            child: expensesAsync.when(
              data: (expenses) {
                if (expenses.isEmpty) {
                  return EmptyState(
                    icon: Icons.money_off_csred_outlined,
                    title: Text(l10n.emptyState),
                    action: FilledButton.icon(
                      onPressed: () => _openExpenseDialog(context, ref),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addExpense),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      kSpaceM, 0, kSpaceM, kSpaceXL),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final item = expenses[index];
                    return Padding(
                      padding:
                          const EdgeInsetsDirectional.only(bottom: kSpaceS),
                      child: AppCard(
                        onTap: () => _openExpenseDialog(context, ref, item),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      if (item.category != null) ...[
                                        Container(
                                          padding: const EdgeInsetsDirectional
                                              .symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item.category!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall,
                                          ),
                                        ),
                                        const SizedBox(width: kSpaceS),
                                      ],
                                      Text(
                                        AppDateUtils.formatDate(
                                            item.expenseDate),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                  if (item.note != null &&
                                      item.note!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      item.note!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              fontStyle: FontStyle.italic),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            MoneyText(
                              amountPaisa: item.amountPaisa,
                              isNegative: true,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.error, size: 20),
                              onPressed: () =>
                                  _deleteExpense(context, ref, item),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openExpenseDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
