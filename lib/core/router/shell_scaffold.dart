import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/core/router/app_router.dart';
import 'package:smart_khata/l10n/app_localizations.dart';

/// Bottom-navigation shell that wraps every tab page.
///
/// The [child] is the currently active tab's page, supplied by [ShellRoute].
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({required this.child, super.key});

  final Widget child;

  // The ordered list of tab root paths must match the [ShellRoute] children
  // order in [appRouter].
  static const _tabPaths = [
    AppRoutes.home,
    AppRoutes.customers,
    AppRoutes.stock,
    AppRoutes.sales,
    AppRoutes.reports,
  ];

  int _locationToIndex(String location) {
    // Match by prefix so sub-routes within a tab keep the right tab selected.
    for (int i = _tabPaths.length - 1; i >= 0; i--) {
      final path = _tabPaths[i];
      if (path == AppRoutes.home) {
        // Exact match only for home to avoid matching everything.
        if (location == AppRoutes.home) return i;
      } else if (location.startsWith(path)) {
        return i;
      }
    }
    return 0; // default to Home
  }

  void _onTabTapped(BuildContext context, int index) {
    context.go(_tabPaths[index]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.newSale),
        tooltip: l10n.newSale,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTabTapped(context, index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_outline),
            activeIcon: const Icon(Icons.people),
            label: l10n.navCustomers,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2_outlined),
            activeIcon: const Icon(Icons.inventory_2),
            label: l10n.navStock,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_outlined),
            activeIcon: const Icon(Icons.receipt_long),
            label: l10n.navSales,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart_outlined),
            activeIcon: const Icon(Icons.bar_chart),
            label: l10n.navReports,
          ),
        ],
      ),
    );
  }
}
