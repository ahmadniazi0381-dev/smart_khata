import '../../../../core/utils/money.dart';

class CartItem {
  final String productId;
  final String productName;
  final String unit;
  final int unitPricePaisa;
  final int costPricePaisa;
  final int qtyMilli;

  const CartItem({
    required this.productId,
    required this.productName,
    required this.unit,
    required this.unitPricePaisa,
    required this.costPricePaisa,
    required this.qtyMilli,
  });

  int get lineTotalPaisa => Money.lineTotal(unitPricePaisa, qtyMilli);

  CartItem copyWith({int? qtyMilli, int? unitPricePaisa}) => CartItem(
        productId: productId,
        productName: productName,
        unit: unit,
        unitPricePaisa: unitPricePaisa ?? this.unitPricePaisa,
        costPricePaisa: costPricePaisa,
        qtyMilli: qtyMilli ?? this.qtyMilli,
      );
}
