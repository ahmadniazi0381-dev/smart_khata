// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smart Khata';

  @override
  String get navHome => 'Home';

  @override
  String get navCustomers => 'Customers';

  @override
  String get navStock => 'Stock';

  @override
  String get navSales => 'Sales';

  @override
  String get navReports => 'Reports';

  @override
  String get newSale => 'New Sale';

  @override
  String get btnSave => 'Save';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnDelete => 'Delete';

  @override
  String get btnEdit => 'Edit';

  @override
  String get btnClose => 'Close';

  @override
  String get btnConfirm => 'Confirm';

  @override
  String get btnAdd => 'Add';

  @override
  String get btnSearch => 'Search';

  @override
  String get searchHint => 'Search...';

  @override
  String get emptyState => 'No items found';

  @override
  String get loading => 'Loading...';

  @override
  String get errorGeneral => 'Something went wrong';

  @override
  String get errorRequired => 'This field is required';

  @override
  String get errorInvalidNumber => 'Invalid number';

  @override
  String get saleCreated => 'Sale created successfully';

  @override
  String get saleCancelled => 'Sale cancelled';

  @override
  String get paymentReceived => 'Payment received';

  @override
  String get stockAdjusted => 'Stock adjusted';

  @override
  String get customerSaved => 'Customer saved';

  @override
  String get productSaved => 'Product saved';

  @override
  String get confirmDelete => 'Are you sure you want to delete this?';

  @override
  String get confirmCancel => 'Are you sure you want to cancel?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get todaySales => 'Today\'s Sales';

  @override
  String get outstanding => 'Outstanding';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get inventoryValue => 'Inventory Value';

  @override
  String get shopSetupTitle => 'Shop Setup';

  @override
  String get shopNameLabel => 'Shop Name';

  @override
  String get phoneLabel => 'Phone Number';

  @override
  String get addressLabel => 'Address';

  @override
  String get setupComplete => 'Get Started';

  @override
  String get addCustomer => 'Add Customer';

  @override
  String get editCustomer => 'Edit Customer';

  @override
  String get customerName => 'Customer Name';

  @override
  String get customerPhone => 'Customer Phone';

  @override
  String get customerAddress => 'Customer Address';

  @override
  String get openingBalance => 'Opening Balance';

  @override
  String get archiveCustomer => 'Archive Customer';

  @override
  String get customerArchived => 'Customer archived';

  @override
  String get balance => 'Balance';

  @override
  String get ledger => 'Ledger';

  @override
  String get receivePayment => 'Receive Payment';

  @override
  String get adjustBalance => 'Adjust Balance';

  @override
  String get paymentAmount => 'Payment Amount';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get methodCash => 'Cash';

  @override
  String get methodBank => 'Bank';

  @override
  String get methodWallet => 'Wallet (EasyPaisa/JazzCash)';

  @override
  String get adjustmentAmount => 'Adjustment (+ / -)';

  @override
  String get adjustmentReason => 'Reason (Required)';

  @override
  String get addProduct => 'Add Product';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get productName => 'Product Name';

  @override
  String get category => 'Category';

  @override
  String get allCategories => 'All Categories';

  @override
  String get noCategory => 'Uncategorized';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get addCategory => 'Add Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get categorySaved => 'Category saved';

  @override
  String get sku => 'SKU / Barcode';

  @override
  String get unit => 'Unit';

  @override
  String get purchasePrice => 'Purchase Price (Cost)';

  @override
  String get sellingPrice => 'Selling Price';

  @override
  String get initialStock => 'Initial Stock';

  @override
  String get lowStockThreshold => 'Low Stock Alert Level';

  @override
  String get currentStock => 'Current Stock';

  @override
  String get stockHistory => 'Stock History';

  @override
  String get adjustStock => 'Adjust Stock';

  @override
  String get stockDelta => 'Quantity Change (+ / -)';

  @override
  String get note => 'Note';

  @override
  String get archiveProduct => 'Archive Product';

  @override
  String get productArchived => 'Product archived';

  @override
  String get walkInCustomer => 'Walk-in Customer';

  @override
  String get selectCustomer => 'Select Customer';

  @override
  String get cart => 'Cart';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get subtotal => 'Subtotal';

  @override
  String get discount => 'Discount';

  @override
  String get total => 'Total';

  @override
  String get paid => 'Paid';

  @override
  String get due => 'Due';

  @override
  String get paymentType => 'Payment Type';

  @override
  String get fullCash => 'Full Cash';

  @override
  String get fullCredit => 'Full Credit (Udhaar)';

  @override
  String get partialPayment => 'Partial Payment';

  @override
  String get completeSale => 'Complete Sale';

  @override
  String get cartEmpty => 'Cart is empty';

  @override
  String get cartEmptySubtitle =>
      'Select products from the catalog to start a sale';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get goToCart => 'View Cart';

  @override
  String get products => 'Products';

  @override
  String get invoiceNo => 'Invoice #';

  @override
  String get saleDate => 'Date';

  @override
  String get saleStatus => 'Status';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get cancelledOn => 'Cancelled on';

  @override
  String get cancelReasonLabel => 'Cancellation Reason';

  @override
  String get cancelSale => 'Cancel Sale';

  @override
  String get cancelSaleConfirmTitle => 'Cancel This Sale?';

  @override
  String get cancelSaleConfirmMsg =>
      'This will return all items to stock and reverse any ledger credit or payments. Enter a reason below:';

  @override
  String get printReceipt => 'Print Receipt';

  @override
  String get shareReceipt => 'Share Receipt';

  @override
  String get saleDetails => 'Sale Details';

  @override
  String get itemsPurchased => 'Purchased Items';

  @override
  String get filterAll => 'All';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get filterCancelled => 'Cancelled';

  @override
  String get quickAddCustomer => 'Quick Add Customer';

  @override
  String stockAvailable(String stock) {
    return 'Stock: $stock';
  }

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String get insufficientStockAlert => 'Not enough stock';

  @override
  String get customerRequiredForCredit =>
      'Customer selection is required when there is a remaining balance';

  @override
  String get discountExceedsSubtotal => 'Discount cannot exceed subtotal';

  @override
  String get invalidPaidAmount => 'Paid amount cannot exceed total';

  @override
  String get receiptThankYou => 'Thank you for your business!';
}
