// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => '';

  @override
  String get navHome => '';

  @override
  String get navCustomers => '';

  @override
  String get navStock => '';

  @override
  String get navSales => '';

  @override
  String get navReports => '';

  @override
  String get newSale => '';

  @override
  String get btnSave => '';

  @override
  String get btnCancel => '';

  @override
  String get btnDelete => '';

  @override
  String get btnEdit => '';

  @override
  String get btnClose => '';

  @override
  String get btnConfirm => '';

  @override
  String get btnAdd => '';

  @override
  String get btnSearch => '';

  @override
  String get searchHint => '';

  @override
  String get emptyState => '';

  @override
  String get loading => '';

  @override
  String get errorGeneral => '';

  @override
  String get errorRequired => '';

  @override
  String get errorInvalidNumber => '';

  @override
  String get saleCreated => '';

  @override
  String get saleCancelled => '';

  @override
  String get paymentReceived => '';

  @override
  String get stockAdjusted => '';

  @override
  String get customerSaved => '';

  @override
  String get productSaved => '';

  @override
  String get confirmDelete => '';

  @override
  String get confirmCancel => '';

  @override
  String get yes => '';

  @override
  String get no => '';

  @override
  String get dashboard => '';

  @override
  String get todaySales => '';

  @override
  String get outstanding => '';

  @override
  String get lowStock => '';

  @override
  String get inventoryValue => '';

  @override
  String get shopSetupTitle => '';

  @override
  String get shopNameLabel => '';

  @override
  String get phoneLabel => '';

  @override
  String get addressLabel => '';

  @override
  String get setupComplete => '';

  @override
  String get addCustomer => '';

  @override
  String get editCustomer => '';

  @override
  String get customerName => '';

  @override
  String get customerPhone => '';

  @override
  String get customerAddress => '';

  @override
  String get openingBalance => '';

  @override
  String get archiveCustomer => '';

  @override
  String get customerArchived => '';

  @override
  String get balance => '';

  @override
  String get ledger => '';

  @override
  String get receivePayment => '';

  @override
  String get adjustBalance => '';

  @override
  String get paymentAmount => '';

  @override
  String get paymentMethod => '';

  @override
  String get methodCash => '';

  @override
  String get methodBank => '';

  @override
  String get methodWallet => '';

  @override
  String get adjustmentAmount => '';

  @override
  String get adjustmentReason => '';

  @override
  String get addProduct => '';

  @override
  String get editProduct => '';

  @override
  String get productName => '';

  @override
  String get category => '';

  @override
  String get allCategories => '';

  @override
  String get noCategory => '';

  @override
  String get categoriesTitle => '';

  @override
  String get addCategory => '';

  @override
  String get categoryName => '';

  @override
  String get categorySaved => '';

  @override
  String get sku => '';

  @override
  String get unit => '';

  @override
  String get purchasePrice => '';

  @override
  String get sellingPrice => '';

  @override
  String get initialStock => '';

  @override
  String get lowStockThreshold => '';

  @override
  String get currentStock => '';

  @override
  String get stockHistory => '';

  @override
  String get adjustStock => '';

  @override
  String get stockDelta => '';

  @override
  String get note => '';

  @override
  String get archiveProduct => '';

  @override
  String get productArchived => '';

  @override
  String get walkInCustomer => '';

  @override
  String get selectCustomer => '';

  @override
  String get cart => '';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count آئٹمز',
      one: '1 آئٹم',
    );
    return '$_temp0';
  }

  @override
  String get subtotal => '';

  @override
  String get discount => '';

  @override
  String get total => '';

  @override
  String get paid => '';

  @override
  String get due => '';

  @override
  String get paymentType => '';

  @override
  String get fullCash => '';

  @override
  String get fullCredit => '';

  @override
  String get partialPayment => '';

  @override
  String get completeSale => '';

  @override
  String get cartEmpty => '';

  @override
  String get cartEmptySubtitle => '';

  @override
  String get addToCart => '';

  @override
  String get goToCart => '';

  @override
  String get products => '';

  @override
  String get invoiceNo => '';

  @override
  String get saleDate => '';

  @override
  String get saleStatus => '';

  @override
  String get statusCompleted => '';

  @override
  String get statusCancelled => '';

  @override
  String get cancelledOn => '';

  @override
  String get cancelReasonLabel => '';

  @override
  String get cancelSale => '';

  @override
  String get cancelSaleConfirmTitle => '';

  @override
  String get cancelSaleConfirmMsg => '';

  @override
  String get printReceipt => '';

  @override
  String get shareReceipt => '';

  @override
  String get saleDetails => '';

  @override
  String get itemsPurchased => '';

  @override
  String get filterAll => '';

  @override
  String get filterCompleted => '';

  @override
  String get filterCancelled => '';

  @override
  String get quickAddCustomer => '';

  @override
  String stockAvailable(String stock) {
    return '$stock اسٹاک';
  }

  @override
  String get outOfStock => '';

  @override
  String get insufficientStockAlert => '';

  @override
  String get customerRequiredForCredit => '';

  @override
  String get discountExceedsSubtotal => '';

  @override
  String get invalidPaidAmount => '';

  @override
  String get receiptThankYou => '';

  @override
  String get quickActions => '';

  @override
  String get recentSales => '';

  @override
  String get viewAll => '';

  @override
  String get salesWeeklyTrend => '';

  @override
  String get noRecentSales => '';

  @override
  String get expenses => '';

  @override
  String get addExpense => '';

  @override
  String get editExpense => '';

  @override
  String get expenseTitle => '';

  @override
  String get expenseCategory => '';

  @override
  String get expenseAmount => '';

  @override
  String get expenseDate => '';

  @override
  String get expenseSaved => '';

  @override
  String get expenseDeleted => '';

  @override
  String get totalExpenses => '';

  @override
  String get categoryRent => '';

  @override
  String get categoryElectricity => '';

  @override
  String get categorySalaries => '';

  @override
  String get categoryTransport => '';

  @override
  String get categoryMaintenance => '';

  @override
  String get categoryFoodTea => '';

  @override
  String get categoryOther => '';

  @override
  String get reportsTitle => '';

  @override
  String get periodToday => '';

  @override
  String get periodThisWeek => '';

  @override
  String get periodThisMonth => '';

  @override
  String get periodAllTime => '';

  @override
  String get salesSummary => '';

  @override
  String get grossProfit => '';

  @override
  String get netProfit => '';

  @override
  String get completedSales => '';

  @override
  String get totalRevenue => '';

  @override
  String get costOfGoods => '';

  @override
  String get topSellingProducts => '';

  @override
  String get noReportData => '';

  @override
  String get backupAndRestore => '';

  @override
  String get backupTitle => '';

  @override
  String get backupSubtitle => '';

  @override
  String get createBackup => '';

  @override
  String get backupCreated => '';

  @override
  String get restoreTitle => '';

  @override
  String get restoreSubtitle => '';

  @override
  String get restoreWarning => '';

  @override
  String get restoreSuccess => '';

  @override
  String get restoreFailed => '';

  @override
  String get btnRestore => '';
}
