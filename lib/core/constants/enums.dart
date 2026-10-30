enum SaleStatus { completed, cancelled }

enum PaymentMethod { cash, bank, wallet }

enum LedgerEntryType { opening, creditSale, payment, adjustment, reversal }

enum LedgerDirection { credit, debit }

enum StockMovementType {
  opening,
  purchase,
  sale,
  saleCancel,
  adjustment,
  damage,
  returnStock,
}

extension SaleStatusX on SaleStatus {
  String get value => name;
  static SaleStatus fromString(String s) => SaleStatus.values
      .firstWhere((e) => e.name == s, orElse: () => SaleStatus.completed);
}

extension PaymentMethodX on PaymentMethod {
  String get value => name;
  static PaymentMethod fromString(String s) => PaymentMethod.values
      .firstWhere((e) => e.name == s, orElse: () => PaymentMethod.cash);
}

extension LedgerEntryTypeX on LedgerEntryType {
  String get dbValue {
    switch (this) {
      case LedgerEntryType.opening:
        return 'OPENING';
      case LedgerEntryType.creditSale:
        return 'CREDIT_SALE';
      case LedgerEntryType.payment:
        return 'PAYMENT';
      case LedgerEntryType.adjustment:
        return 'ADJUSTMENT';
      case LedgerEntryType.reversal:
        return 'REVERSAL';
    }
  }

  static LedgerEntryType fromString(String s) {
    switch (s) {
      case 'OPENING':
        return LedgerEntryType.opening;
      case 'CREDIT_SALE':
        return LedgerEntryType.creditSale;
      case 'PAYMENT':
        return LedgerEntryType.payment;
      case 'ADJUSTMENT':
        return LedgerEntryType.adjustment;
      case 'REVERSAL':
        return LedgerEntryType.reversal;
      default:
        return LedgerEntryType.payment;
    }
  }
}

extension LedgerDirectionX on LedgerDirection {
  String get dbValue => name.toUpperCase();
  static LedgerDirection fromString(String s) =>
      s == 'CREDIT' ? LedgerDirection.credit : LedgerDirection.debit;
}

extension StockMovementTypeX on StockMovementType {
  String get dbValue {
    switch (this) {
      case StockMovementType.opening:
        return 'OPENING';
      case StockMovementType.purchase:
        return 'PURCHASE';
      case StockMovementType.sale:
        return 'SALE';
      case StockMovementType.saleCancel:
        return 'SALE_CANCEL';
      case StockMovementType.adjustment:
        return 'ADJUSTMENT';
      case StockMovementType.damage:
        return 'DAMAGE';
      case StockMovementType.returnStock:
        return 'RETURN';
    }
  }
}
