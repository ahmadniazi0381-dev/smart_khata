import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/customers/presentation/screens/customer_detail_screen.dart';
import '../../features/customers/presentation/screens/customers_screen.dart';
import '../../features/inventory/presentation/screens/product_detail_screen.dart';
import '../../features/inventory/presentation/screens/stock_screen.dart';
import '../../features/sales/presentation/screens/new_sale_screen.dart';
import '../../features/sales/presentation/screens/sale_detail_screen.dart';
import '../../features/sales/presentation/screens/sales_screen.dart';
import '../../features/setup/presentation/screens/shop_setup_screen.dart';
import '../../l10n/app_localizations.dart';
import 'shell_scaffold.dart';

// ---------------------------------------------------------------------------
// Placeholder page factory
// ---------------------------------------------------------------------------
Widget _placeholder(String label) => Scaffold(
      body: Center(
        child: Text(
          'Coming soon — $label',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );

// ---------------------------------------------------------------------------
// Route name constants
// ---------------------------------------------------------------------------
abstract final class AppRoutes {
  static const home = '/';
  static const customers = '/customers';
  static const customerDetail = '/customers/:id';
  static const stock = '/stock';
  static const productDetail = '/products/:id';
  static const sales = '/sales';
  static const newSale = '/sales/new';
  static const saleDetail = '/sales/:id';
  static const reports = '/reports';
  static const setup = '/setup';
}

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: true,
  routes: [
    // ── Shell (bottom nav) ─────────────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) {
        return ShellScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) {
            final l10n = AppLocalizations.of(context);
            return Scaffold(
              appBar: AppBar(title: Text(l10n.dashboard)),
              body: _placeholder(l10n.dashboard),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.customers,
          builder: (context, state) => const CustomersScreen(),
        ),
        GoRoute(
          path: AppRoutes.stock,
          builder: (context, state) => const StockScreen(),
        ),
        GoRoute(
          path: AppRoutes.sales,
          builder: (context, state) => const SalesScreen(),
        ),
        GoRoute(
          path: AppRoutes.reports,
          builder: (context, state) {
            final l10n = AppLocalizations.of(context);
            return Scaffold(
              appBar: AppBar(title: Text(l10n.navReports)),
              body: _placeholder(l10n.navReports),
            );
          },
        ),
      ],
    ),

    // ── Detail / full-screen routes (outside shell) ────────────────────────
    GoRoute(
      path: AppRoutes.setup,
      builder: (context, state) => const ShopSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.newSale,
      builder: (context, state) => const NewSaleScreen(),
    ),
    GoRoute(
      path: AppRoutes.customerDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return CustomerDetailScreen(customerId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.productDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ProductDetailScreen(productId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.saleDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return SaleDetailScreen(saleId: id);
      },
    ),
  ],
);
