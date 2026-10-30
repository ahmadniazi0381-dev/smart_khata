import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/customer_providers.dart';
import 'customer_detail_screen.dart';
import 'customer_form_screen.dart';

class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final customersAsync = ref.watch(customersListStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navCustomers),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.all(kSpaceM),
            child: SearchField(
              hintText: l10n.searchHint,
              onChanged: (val) {
                ref.read(customerSearchQueryProvider.notifier).state = val;
              },
            ),
          ),
          Expanded(
            child: customersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text(e.toString())),
              data: (customers) {
                if (customers.isEmpty) {
                  return EmptyState(
                    icon: Icons.people_outline,
                    title: Text(l10n.emptyState),
                    action: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CustomerFormScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add_outlined),
                      label: Text(l10n.addCustomer),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: kSpaceM,
                    vertical: kSpaceS,
                  ),
                  itemCount: customers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: kSpaceXS),
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return _CustomerListTile(customer: customer);
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
              builder: (_) => const CustomerFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.person_add_outlined),
        label: Text(l10n.addCustomer),
      ),
    );
  }
}

class _CustomerListTile extends ConsumerWidget {
  final dynamic customer;

  const _CustomerListTile({required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync =
        ref.watch(customerBalanceProvider(customer.id as String));
    final balancePaisa = balanceAsync.asData?.value ?? 0;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Text(
            (customer.name as String).isNotEmpty
                ? (customer.name as String)[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          customer.name as String,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle:
            customer.phone != null && (customer.phone as String).isNotEmpty
                ? Text(customer.phone as String)
                : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            MoneyText(
              amountPaisa: balancePaisa,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              isNegative: balancePaisa > 0,
              isPositive: balancePaisa == 0,
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  CustomerDetailScreen(customerId: customer.id as String),
            ),
          );
        },
      ),
    );
  }
}
