import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/core/router/shell_scaffold.dart';
import 'package:smart_khata/l10n/app_localizations.dart';

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
  static const sales = '/sales';
  static const newSale = '/sales/new';
  static const reports = '/reports';
  static const productDetail = '/products/:id';
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
          builder: (context, state) {
            final l10n = AppLocalizations.of(context);
            return Scaffold(
              appBar: AppBar(title: Text(l10n.navCustomers)),
              body: _placeholder(l10n.navCustomers),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.stock,
          builder: (context, state) {
            final l10n = AppLocalizations.of(context);
            return Scaffold(
              appBar: AppBar(title: Text(l10n.navStock)),
              body: _placeholder(l10n.navStock),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.sales,
          builder: (context, state) {
            final l10n = AppLocalizations.of(context);
            return Scaffold(
              appBar: AppBar(title: Text(l10n.navSales)),
              body: _placeholder(l10n.navSales),
            );
          },
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
      path: AppRoutes.newSale,
      builder: (context, state) {
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          appBar: AppBar(title: Text(l10n.newSale)),
          body: _placeholder(l10n.newSale),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.customerDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return Scaffold(
          appBar: AppBar(title: const Text('Customer Detail')),
          body: _placeholder('Customer #$id'),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.productDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return Scaffold(
          appBar: AppBar(title: const Text('Product Detail')),
          body: _placeholder('Product #$id'),
        );
      },
    ),
  ],
);
