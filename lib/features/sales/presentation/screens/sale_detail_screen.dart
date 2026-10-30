import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/qty.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/sales_providers.dart';
import '../widgets/receipt_pdf.dart';

class SaleDetailScreen extends ConsumerStatefulWidget {
  final String saleId;

  const SaleDetailScreen({required this.saleId, super.key});

  @override
  ConsumerState<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends ConsumerState<SaleDetailScreen> {
  bool _isCancelling = false;

  Future<void> _handleCancelSale() async {
    final l10n = AppLocalizations.of(context);
    final reasonCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancelSaleConfirmTitle),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.cancelSaleConfirmMsg,
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: kSpaceM),
              TextFormField(
                controller: reasonCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.cancelReasonLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? l10n.errorRequired
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.btnCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(ctx).pop(true);
              }
            },
            child: Text(l10n.cancelSale),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isCancelling = true);
      try {
        final saleService = ref.read(saleServiceProvider);
        await saleService.cancelSale(widget.saleId, reasonCtrl.text.trim());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.saleCancelled)),
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
          setState(() => _isCancelling = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final saleAsync = ref.watch(saleDetailStreamProvider(widget.saleId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          saleAsync.valueOrNull?.sale.invoiceNo ?? l10n.saleDetails,
        ),
        actions: [
          if (saleAsync.valueOrNull != null) ...[
            IconButton(
              icon: const Icon(Icons.print_outlined),
              tooltip: l10n.printReceipt,
              onPressed: () =>
                  ReceiptPdfHelper.printReceipt(saleAsync.valueOrNull!),
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: l10n.shareReceipt,
              onPressed: () =>
                  ReceiptPdfHelper.shareReceipt(saleAsync.valueOrNull!),
            ),
          ],
        ],
      ),
      body: saleAsync.when(
        data: (details) {
          if (details == null) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: Text(l10n.emptyState),
            );
          }

          final sale = details.sale;
          final isCancelled = sale.status == 'cancelled';

          return ListView(
            padding: const EdgeInsetsDirectional.all(kSpaceM),
            children: [
              if (isCancelled)
                Container(
                  padding: const EdgeInsetsDirectional.all(kSpaceM),
                  margin: const EdgeInsetsDirectional.only(bottom: kSpaceM),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cancel_outlined, color: AppColors.error),
                      const SizedBox(width: kSpaceM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.statusCancelled,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.error,
                                  ),
                            ),
                            if (sale.cancelledAt != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                '${l10n.cancelledOn} ${AppDateUtils.formatDateTime(sale.cancelledAt!)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                            if (sale.cancelReason != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                '${l10n.cancelReasonLabel}: ${sale.cancelReason}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsetsDirectional.all(kSpaceM),
                  margin: const EdgeInsetsDirectional.only(bottom: kSpaceM),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: AppColors.success),
                      const SizedBox(width: kSpaceM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.statusCompleted,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                            ),
                            Text(
                              AppDateUtils.formatDateTime(sale.saleDate),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (details.customer != null) ...[
                AppCard(
                  onTap: () =>
                      context.push('/customers/${details.customer!.id}'),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.12),
                        child:
                            const Icon(Icons.person, color: AppColors.primary),
                      ),
                      const SizedBox(width: kSpaceM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              details.customer!.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (details.customer!.phone != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                details.customer!.phone!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
                const SizedBox(height: kSpaceM),
              ],
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.itemsPurchased,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: kSpaceL),
                    ...details.items.map((item) {
                      return Padding(
                        padding:
                            const EdgeInsetsDirectional.only(bottom: kSpaceM),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productNameSnapshot,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${Qty.format(item.qtyMilli, item.unitSnapshot)} × ${Money.format(item.unitPricePaisa)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: AppColors.textSecondary),
                                  ),
                                ],
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
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: kSpaceM),
              AppCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.subtotal),
                        MoneyText(amountPaisa: sale.subtotalPaisa),
                      ],
                    ),
                    if (sale.discountPaisa > 0) ...[
                      const SizedBox(height: kSpaceS),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.discount),
                          Text('- ${Money.format(sale.discountPaisa)}'),
                        ],
                      ),
                    ],
                    const Divider(height: kSpaceL),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.total,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        MoneyText(
                          amountPaisa: sale.totalPaisa,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: kSpaceS),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '${l10n.paid} (${details.payment?.method ?? 'Cash'})'),
                        MoneyText(
                          amountPaisa: sale.paidPaisa,
                          isPositive: sale.paidPaisa > 0,
                        ),
                      ],
                    ),
                    if (sale.duePaisa > 0) ...[
                      const SizedBox(height: kSpaceS),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.due,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                          MoneyText(
                            amountPaisa: sale.duePaisa,
                            isNegative: true,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (sale.note != null && sale.note!.isNotEmpty) ...[
                const SizedBox(height: kSpaceM),
                AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.note_outlined,
                          size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: kSpaceS),
                      Expanded(
                        child: Text(
                          sale.note!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: kSpaceL),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => ReceiptPdfHelper.printReceipt(details),
                      icon: const Icon(Icons.print_outlined),
                      label: Text(l10n.printReceipt),
                    ),
                  ),
                  const SizedBox(width: kSpaceM),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => ReceiptPdfHelper.shareReceipt(details),
                      icon: const Icon(Icons.share_outlined),
                      label: Text(l10n.shareReceipt),
                    ),
                  ),
                ],
              ),
              if (!isCancelled) ...[
                const SizedBox(height: kSpaceM),
                OutlinedButton.icon(
                  onPressed: _isCancelling ? null : _handleCancelSale,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  icon: _isCancelling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cancel_outlined),
                  label: Text(l10n.cancelSale),
                ),
              ],
              const SizedBox(height: kSpaceXL),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
      ),
    );
  }
}
