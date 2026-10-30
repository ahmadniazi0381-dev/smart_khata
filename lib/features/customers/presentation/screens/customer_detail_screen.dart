import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/customer_providers.dart';
import '../widgets/adjust_balance_dialog.dart';
import '../widgets/receive_payment_dialog.dart';
import 'customer_form_screen.dart';

class CustomerDetailScreen extends ConsumerWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final customerAsync = ref.watch(customerDetailStreamProvider(customerId));
    final balanceAsync = ref.watch(customerBalanceProvider(customerId));
    final ledgerAsync = ref.watch(customerLedgerStreamProvider(customerId));

    return customerAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.loading)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        appBar: AppBar(title: Text(l10n.errorGeneral)),
        body: Center(child: Text(e.toString())),
      ),
      data: (customer) {
        if (customer == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.emptyState)),
            body: Center(child: Text(l10n.emptyState)),
          );
        }

        final balancePaisa = balanceAsync.asData?.value ?? 0;

        return Scaffold(
          appBar: AppBar(
            title: Text(customer.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n.btnEdit,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CustomerFormScreen(customer: customer),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.archive_outlined),
                tooltip: l10n.archiveCustomer,
                onPressed: () async {
                  final confirmed = await showConfirmDialog(
                    context,
                    title: l10n.archiveCustomer,
                    message: l10n.confirmDelete,
                    confirmText: l10n.archiveCustomer,
                    isDangerous: true,
                  );
                  if (confirmed) {
                    await ref
                        .read(customerRepositoryProvider)
                        .archiveCustomer(customer.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.customerArchived)),
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
                    if (customer.phone != null &&
                        customer.phone!.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.phone_outlined,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: kSpaceXS),
                          Text(
                            customer.phone!,
                            style:
                                const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: kSpaceXS),
                    ],
                    if (customer.address != null &&
                        customer.address!.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: kSpaceXS),
                          Text(
                            customer.address!,
                            style:
                                const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: kSpaceS),
                    ],
                    Text(
                      l10n.balance,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: kSpaceXS),
                    MoneyText(
                      amountPaisa: balancePaisa,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                      isNegative: balancePaisa > 0, // customer owes = debt
                      isPositive: balancePaisa == 0,
                    ),
                    const SizedBox(height: kSpaceM),
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: balancePaisa > 0
                              ? () => ReceivePaymentDialog.show(
                                    context,
                                    customerId: customer.id,
                                    currentBalancePaisa: balancePaisa,
                                  )
                              : null,
                          icon: const Icon(Icons.payments_outlined),
                          label: Text(l10n.receivePayment),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: kSpaceS),
                        OutlinedButton.icon(
                          onPressed: () => AdjustBalanceDialog.show(
                            context,
                            customerId: customer.id,
                          ),
                          icon: const Icon(Icons.tune_outlined),
                          label: Text(l10n.adjustBalance),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Ledger Header ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    kSpaceM, kSpaceM, kSpaceM, kSpaceS),
                child: Row(
                  children: [
                    Text(
                      l10n.ledger,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),

              // ── Ledger Entries List ───────────────────────────────────────
              Expanded(
                child: ledgerAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text(e.toString())),
                  data: (entries) {
                    if (entries.isEmpty) {
                      return EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: Text(l10n.emptyState),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: kSpaceM,
                        vertical: kSpaceS,
                      ),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: kSpaceXS),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        final isCredit = entry.direction == 'CREDIT';

                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isCredit
                                  ? AppColors.error.withValues(alpha: 0.1)
                                  : AppColors.success.withValues(alpha: 0.1),
                              child: Icon(
                                isCredit
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: isCredit
                                    ? AppColors.error
                                    : AppColors.success,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              entry.entryType,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              '${AppDateUtils.formatDate(entry.entryDate)}${entry.note != null && entry.note!.isNotEmpty ? ' • ${entry.note}' : ''}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Text(
                              '${isCredit ? '+' : '-'}${Money.format(entry.amountPaisa)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isCredit
                                    ? AppColors.error
                                    : AppColors.success,
                              ),
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
