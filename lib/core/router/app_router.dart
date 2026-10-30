import 'package:go_router/go_router.dart';
import '../../features/backup/presentation/screens/backup_screen.dart';
import '../../features/customers/presentation/screens/customer_detail_screen.dart';
import '../../features/customers/presentation/screens/customers_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/expenses/presentation/screens/expenses_screen.dart';
import '../../features/inventory/presentation/screens/product_detail_screen.dart';
import '../../features/inventory/presentation/screens/stock_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/sales/presentation/screens/new_sale_screen.dart';
import '../../features/sales/presentation/screens/sale_detail_screen.dart';
import '../../features/sales/presentation/screens/sales_screen.dart';
import '../../features/setup/presentation/screens/shop_setup_screen.dart';
import 'shell_scaffold.dart';

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
  static const expenses = '/expenses';
  static const backup = '/backup';
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
          builder: (context, state) => const DashboardScreen(),
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
          builder: (context, state) => const ReportsScreen(),
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
    GoRoute(
      path: AppRoutes.expenses,
      builder: (context, state) => const ExpensesScreen(),
    ),
    GoRoute(
      path: AppRoutes.backup,
      builder: (context, state) => const BackupScreen(),
    ),
  ],
);
