import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur')
  ];

  /// Application name shown in app bar and splash.
  ///
  /// In en, this message translates to:
  /// **'Smart Khata'**
  String get appTitle;

  /// Bottom nav label for the Home/Dashboard tab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom nav label for Customers tab.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get navCustomers;

  /// Bottom nav label for Stock/Inventory tab.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get navStock;

  /// Bottom nav label for Sales tab.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get navSales;

  /// Bottom nav label for Reports tab.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// FAB label / page title for creating a new sale.
  ///
  /// In en, this message translates to:
  /// **'New Sale'**
  String get newSale;

  /// Generic save button label.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnSave;

  /// Generic cancel button label.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// Generic delete button label.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btnDelete;

  /// Generic edit button label.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get btnEdit;

  /// Generic close button label.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get btnClose;

  /// Generic confirm button label.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get btnConfirm;

  /// Generic add button label.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get btnAdd;

  /// Generic search button label.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get btnSearch;

  /// Placeholder text in search fields.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;

  /// Generic message shown when a list is empty.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get emptyState;

  /// Generic loading indicator label.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Generic error message.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneral;

  /// Validation error for empty required field.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get errorRequired;

  /// Validation error for non-numeric input.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get errorInvalidNumber;

  /// Snackbar message after a sale is created.
  ///
  /// In en, this message translates to:
  /// **'Sale created successfully'**
  String get saleCreated;

  /// Snackbar message after a sale is cancelled.
  ///
  /// In en, this message translates to:
  /// **'Sale cancelled'**
  String get saleCancelled;

  /// Snackbar message after a payment is recorded.
  ///
  /// In en, this message translates to:
  /// **'Payment received'**
  String get paymentReceived;

  /// Snackbar message after stock is adjusted.
  ///
  /// In en, this message translates to:
  /// **'Stock adjusted'**
  String get stockAdjusted;

  /// Snackbar message after a customer record is saved.
  ///
  /// In en, this message translates to:
  /// **'Customer saved'**
  String get customerSaved;

  /// Snackbar message after a product record is saved.
  ///
  /// In en, this message translates to:
  /// **'Product saved'**
  String get productSaved;

  /// Confirmation dialog message for destructive delete action.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this?'**
  String get confirmDelete;

  /// Confirmation dialog message for cancel action.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel?'**
  String get confirmCancel;

  /// Affirmative dialog option.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// Negative dialog option.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Dashboard page title.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Dashboard metric label for today's total sales.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Sales'**
  String get todaySales;

  /// Dashboard metric label for outstanding receivables.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get outstanding;

  /// Dashboard metric label for low-stock product count.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// Dashboard metric label for total inventory value.
  ///
  /// In en, this message translates to:
  /// **'Inventory Value'**
  String get inventoryValue;

  /// Title for the initial shop setup screen.
  ///
  /// In en, this message translates to:
  /// **'Shop Setup'**
  String get shopSetupTitle;

  /// Label for shop name input.
  ///
  /// In en, this message translates to:
  /// **'Shop Name'**
  String get shopNameLabel;

  /// Label for phone number input.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneLabel;

  /// Label for address input.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// Button to complete setup.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get setupComplete;

  /// Button/Title to add new customer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// Title to edit customer.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get editCustomer;

  /// Label for customer name.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// Label for customer phone.
  ///
  /// In en, this message translates to:
  /// **'Customer Phone'**
  String get customerPhone;

  /// Label for customer address.
  ///
  /// In en, this message translates to:
  /// **'Customer Address'**
  String get customerAddress;

  /// Label for opening balance (customer owes you).
  ///
  /// In en, this message translates to:
  /// **'Opening Balance'**
  String get openingBalance;

  /// Button to archive customer instead of deleting.
  ///
  /// In en, this message translates to:
  /// **'Archive Customer'**
  String get archiveCustomer;

  /// Message after customer is archived.
  ///
  /// In en, this message translates to:
  /// **'Customer archived'**
  String get customerArchived;

  /// Customer balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// Customer ledger title.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get ledger;

  /// Action to record khata payment from customer.
  ///
  /// In en, this message translates to:
  /// **'Receive Payment'**
  String get receivePayment;

  /// Action to manually adjust customer balance.
  ///
  /// In en, this message translates to:
  /// **'Adjust Balance'**
  String get adjustBalance;

  /// Label for payment amount.
  ///
  /// In en, this message translates to:
  /// **'Payment Amount'**
  String get paymentAmount;

  /// Payment method selection.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// Cash payment method.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get methodCash;

  /// Bank transfer payment method.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get methodBank;

  /// Mobile wallet payment method.
  ///
  /// In en, this message translates to:
  /// **'Wallet (EasyPaisa/JazzCash)'**
  String get methodWallet;

  /// Amount to adjust balance.
  ///
  /// In en, this message translates to:
  /// **'Adjustment (+ / -)'**
  String get adjustmentAmount;

  /// Reason for balance adjustment.
  ///
  /// In en, this message translates to:
  /// **'Reason (Required)'**
  String get adjustmentReason;

  /// Title/Button to add product.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// Title to edit product.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// Label for product name.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// Label for category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Filter option for all categories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// Label for products with no category.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get noCategory;

  /// Categories screen title.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// Action to add category.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// Label for category name.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// Message after category is saved.
  ///
  /// In en, this message translates to:
  /// **'Category saved'**
  String get categorySaved;

  /// Label for SKU/barcode.
  ///
  /// In en, this message translates to:
  /// **'SKU / Barcode'**
  String get sku;

  /// Label for product unit (pcs, kg, ltr, etc).
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// Label for purchase/cost price.
  ///
  /// In en, this message translates to:
  /// **'Purchase Price (Cost)'**
  String get purchasePrice;

  /// Label for selling price.
  ///
  /// In en, this message translates to:
  /// **'Selling Price'**
  String get sellingPrice;

  /// Label for initial stock.
  ///
  /// In en, this message translates to:
  /// **'Initial Stock'**
  String get initialStock;

  /// Label for low stock threshold.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alert Level'**
  String get lowStockThreshold;

  /// Label for current stock level.
  ///
  /// In en, this message translates to:
  /// **'Current Stock'**
  String get currentStock;

  /// Title for stock movements history.
  ///
  /// In en, this message translates to:
  /// **'Stock History'**
  String get stockHistory;

  /// Action to manually adjust stock.
  ///
  /// In en, this message translates to:
  /// **'Adjust Stock'**
  String get adjustStock;

  /// Quantity delta for stock adjustment.
  ///
  /// In en, this message translates to:
  /// **'Quantity Change (+ / -)'**
  String get stockDelta;

  /// Optional note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// Action to archive product.
  ///
  /// In en, this message translates to:
  /// **'Archive Product'**
  String get archiveProduct;

  /// Message after product archived.
  ///
  /// In en, this message translates to:
  /// **'Product archived'**
  String get productArchived;

  /// Label for a sale without a registered customer.
  ///
  /// In en, this message translates to:
  /// **'Walk-in Customer'**
  String get walkInCustomer;

  /// Placeholder/action to select customer.
  ///
  /// In en, this message translates to:
  /// **'Select Customer'**
  String get selectCustomer;

  /// Cart label / tab title.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// Item count badge
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemsCount(int count);

  /// Cart/Sale subtotal before discount.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// Discount applied to a sale.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// Final total amount for a sale.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Amount paid by customer.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// Remaining balance due from customer.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// Selector for payment type.
  ///
  /// In en, this message translates to:
  /// **'Payment Type'**
  String get paymentType;

  /// Payment mode where full amount is paid immediately.
  ///
  /// In en, this message translates to:
  /// **'Full Cash'**
  String get fullCash;

  /// Payment mode where entire amount is on credit.
  ///
  /// In en, this message translates to:
  /// **'Full Credit (Udhaar)'**
  String get fullCredit;

  /// Payment mode where customer pays part now and owes the rest.
  ///
  /// In en, this message translates to:
  /// **'Partial Payment'**
  String get partialPayment;

  /// Button to finalize and record the sale.
  ///
  /// In en, this message translates to:
  /// **'Complete Sale'**
  String get completeSale;

  /// Empty state title when cart has no items.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get cartEmpty;

  /// Empty state subtitle for cart.
  ///
  /// In en, this message translates to:
  /// **'Select products from the catalog to start a sale'**
  String get cartEmptySubtitle;

  /// Action to add item to cart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// Action button to view cart.
  ///
  /// In en, this message translates to:
  /// **'View Cart'**
  String get goToCart;

  /// Products catalog tab/label.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// Invoice number label.
  ///
  /// In en, this message translates to:
  /// **'Invoice #'**
  String get invoiceNo;

  /// Date of sale.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get saleDate;

  /// Sale status label.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get saleStatus;

  /// Status indicating completed sale.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// Status indicating cancelled sale.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// Prefix for cancellation timestamp.
  ///
  /// In en, this message translates to:
  /// **'Cancelled on'**
  String get cancelledOn;

  /// Label for why sale was cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Reason'**
  String get cancelReasonLabel;

  /// Action to cancel a completed sale.
  ///
  /// In en, this message translates to:
  /// **'Cancel Sale'**
  String get cancelSale;

  /// Dialog title for cancelling a sale.
  ///
  /// In en, this message translates to:
  /// **'Cancel This Sale?'**
  String get cancelSaleConfirmTitle;

  /// Dialog message for cancelling a sale.
  ///
  /// In en, this message translates to:
  /// **'This will return all items to stock and reverse any ledger credit or payments. Enter a reason below:'**
  String get cancelSaleConfirmMsg;

  /// Action to print thermal receipt.
  ///
  /// In en, this message translates to:
  /// **'Print Receipt'**
  String get printReceipt;

  /// Action to share receipt as PDF.
  ///
  /// In en, this message translates to:
  /// **'Share Receipt'**
  String get shareReceipt;

  /// Title for sale details screen.
  ///
  /// In en, this message translates to:
  /// **'Sale Details'**
  String get saleDetails;

  /// Section header for items in a sale.
  ///
  /// In en, this message translates to:
  /// **'Purchased Items'**
  String get itemsPurchased;

  /// Filter tab for all records.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Filter tab for completed sales.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get filterCompleted;

  /// Filter tab for cancelled sales.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get filterCancelled;

  /// Button to quickly register a new customer during checkout.
  ///
  /// In en, this message translates to:
  /// **'Quick Add Customer'**
  String get quickAddCustomer;

  /// Available stock quantity
  ///
  /// In en, this message translates to:
  /// **'Stock: {stock}'**
  String stockAvailable(String stock);

  /// Label when stock is 0.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// Alert when item has insufficient stock.
  ///
  /// In en, this message translates to:
  /// **'Not enough stock'**
  String get insufficientStockAlert;

  /// Validation message when trying to make credit sale without customer.
  ///
  /// In en, this message translates to:
  /// **'Customer selection is required when there is a remaining balance'**
  String get customerRequiredForCredit;

  /// Validation error for discount.
  ///
  /// In en, this message translates to:
  /// **'Discount cannot exceed subtotal'**
  String get discountExceedsSubtotal;

  /// Validation error for paid amount.
  ///
  /// In en, this message translates to:
  /// **'Paid amount cannot exceed total'**
  String get invalidPaidAmount;

  /// Default receipt footer.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your business!'**
  String get receiptThankYou;

  /// Section header for quick actions on dashboard.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Dashboard section for recent sales.
  ///
  /// In en, this message translates to:
  /// **'Recent Sales'**
  String get recentSales;

  /// Button to view all records in a list.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Title for weekly sales chart.
  ///
  /// In en, this message translates to:
  /// **'Sales (Last 7 Days)'**
  String get salesWeeklyTrend;

  /// Empty state for recent sales.
  ///
  /// In en, this message translates to:
  /// **'No sales recorded yet'**
  String get noRecentSales;

  /// Expenses title and nav item.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// Button to record an expense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// Dialog title to edit an expense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// Title or reason for expense.
  ///
  /// In en, this message translates to:
  /// **'Expense Title'**
  String get expenseTitle;

  /// Category of the expense.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expenseCategory;

  /// Amount of expense.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expenseAmount;

  /// Date of expense.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get expenseDate;

  /// Snackbar after saving expense.
  ///
  /// In en, this message translates to:
  /// **'Expense saved successfully'**
  String get expenseSaved;

  /// Snackbar after deleting expense.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get expenseDeleted;

  /// Total amount spent on expenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// Expense category for rent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get categoryRent;

  /// Expense category for bills.
  ///
  /// In en, this message translates to:
  /// **'Electricity / Utilities'**
  String get categoryElectricity;

  /// Expense category for salaries.
  ///
  /// In en, this message translates to:
  /// **'Staff Salaries'**
  String get categorySalaries;

  /// Expense category for transport.
  ///
  /// In en, this message translates to:
  /// **'Transport / Delivery'**
  String get categoryTransport;

  /// Expense category for repair.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get categoryMaintenance;

  /// Expense category for tea and food.
  ///
  /// In en, this message translates to:
  /// **'Food & Tea'**
  String get categoryFoodTea;

  /// Expense category for other expenses.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// Reports screen title.
  ///
  /// In en, this message translates to:
  /// **'Business Reports'**
  String get reportsTitle;

  /// Filter period today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get periodToday;

  /// Filter period this week.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get periodThisWeek;

  /// Filter period this month.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get periodThisMonth;

  /// Filter period all time.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get periodAllTime;

  /// Sales summary section title.
  ///
  /// In en, this message translates to:
  /// **'Sales Summary'**
  String get salesSummary;

  /// Estimated gross profit label.
  ///
  /// In en, this message translates to:
  /// **'Estimated Gross Profit'**
  String get grossProfit;

  /// Estimated net profit label.
  ///
  /// In en, this message translates to:
  /// **'Estimated Net Profit'**
  String get netProfit;

  /// Count of completed sales.
  ///
  /// In en, this message translates to:
  /// **'Completed Sales'**
  String get completedSales;

  /// Total sales revenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// Cost of goods sold.
  ///
  /// In en, this message translates to:
  /// **'Cost of Goods Sold'**
  String get costOfGoods;

  /// Section header for top products.
  ///
  /// In en, this message translates to:
  /// **'Top Selling Products'**
  String get topSellingProducts;

  /// Empty state for reports.
  ///
  /// In en, this message translates to:
  /// **'No data available for selected period'**
  String get noReportData;

  /// Backup & restore title.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupAndRestore;

  /// Card title for backup.
  ///
  /// In en, this message translates to:
  /// **'Database Backup'**
  String get backupTitle;

  /// Subtitle describing backup.
  ///
  /// In en, this message translates to:
  /// **'Export an offline copy of all your shop data'**
  String get backupSubtitle;

  /// Action to export backup file.
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get createBackup;

  /// Snackbar when backup created.
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully'**
  String get backupCreated;

  /// Card title for restore.
  ///
  /// In en, this message translates to:
  /// **'Restore Database'**
  String get restoreTitle;

  /// Subtitle describing restore.
  ///
  /// In en, this message translates to:
  /// **'Restore data from a previously saved backup file'**
  String get restoreSubtitle;

  /// Warning message before restore.
  ///
  /// In en, this message translates to:
  /// **'Restoring will overwrite all current data with the selected backup. Make sure you have a recent backup first.'**
  String get restoreWarning;

  /// Success message after restore.
  ///
  /// In en, this message translates to:
  /// **'Database restored successfully. Please restart the app.'**
  String get restoreSuccess;

  /// Error message when restore fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore backup: invalid file'**
  String get restoreFailed;

  /// No description provided for @btnRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get btnRestore;

  /// Settings screen title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Label for invoice prefix field.
  ///
  /// In en, this message translates to:
  /// **'Invoice Prefix'**
  String get invoicePrefixLabel;

  /// Label for receipt footer text.
  ///
  /// In en, this message translates to:
  /// **'Receipt Footer'**
  String get receiptFooterLabel;

  /// Label for language selection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// English language option.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Urdu language option.
  ///
  /// In en, this message translates to:
  /// **'اردو (Urdu)'**
  String get languageUrdu;

  /// Label for theme mode selection.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeModeLabel;

  /// Follow system theme.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeModeSystem;

  /// Light theme option.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// Dark theme option.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// Snackbar after saving settings.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// Settings section header for shop details.
  ///
  /// In en, this message translates to:
  /// **'Shop Information'**
  String get shopInfoSection;

  /// Settings section header for invoice settings.
  ///
  /// In en, this message translates to:
  /// **'Invoice & Receipt'**
  String get invoiceSection;

  /// Settings section header for theme and language.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSection;

  /// Settings section header for backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataSection;

  /// App version display
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
