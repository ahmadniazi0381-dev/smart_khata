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
}
