import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/models/cart_item.dart';

enum PaymentType {
  fullCash,
  fullCredit,
  partial,
}

class CartState {
  final List<CartItem> items;
  final int discountPaisa;
  final String? customerId;
  final PaymentType paymentType;
  final int customPaidPaisa;
  final String paymentMethod;
  final String? note;

  const CartState({
    this.items = const [],
    this.discountPaisa = 0,
    this.customerId,
    this.paymentType = PaymentType.fullCash,
    this.customPaidPaisa = 0,
    this.paymentMethod = 'cash',
    this.note,
  });

  int get subtotalPaisa =>
      items.fold<int>(0, (sum, item) => sum + item.lineTotalPaisa);

  int get totalPaisa {
    final t = subtotalPaisa - discountPaisa;
    return t < 0 ? 0 : t;
  }

  int get paidPaisa {
    switch (paymentType) {
      case PaymentType.fullCash:
        return totalPaisa;
      case PaymentType.fullCredit:
        return 0;
      case PaymentType.partial:
        if (customPaidPaisa > totalPaisa) return totalPaisa;
        if (customPaidPaisa < 0) return 0;
        return customPaidPaisa;
    }
  }

  int get duePaisa => totalPaisa - paidPaisa;

  int get itemCount => items.length;

  int get totalQtyMilli =>
      items.fold<int>(0, (sum, item) => sum + item.qtyMilli);

  CartItem? getItem(String productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (_) {
      return null;
    }
  }

  CartState copyWith({
    List<CartItem>? items,
    int? discountPaisa,
    String? customerId,
    bool clearCustomer = false,
    PaymentType? paymentType,
    int? customPaidPaisa,
    String? paymentMethod,
    String? note,
    bool clearNote = false,
  }) {
    return CartState(
      items: items ?? this.items,
      discountPaisa: discountPaisa ?? this.discountPaisa,
      customerId: clearCustomer ? null : (customerId ?? this.customerId),
      paymentType: paymentType ?? this.paymentType,
      customPaidPaisa: customPaidPaisa ?? this.customPaidPaisa,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      note: clearNote ? null : (note ?? this.note),
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addProduct(Product product, {int qtyDeltaMilli = 1000}) {
    final existingIndex =
        state.items.indexWhere((i) => i.productId == product.id);

    if (existingIndex >= 0) {
      final existing = state.items[existingIndex];
      final newQty = existing.qtyMilli + qtyDeltaMilli;
      final updatedList = List<CartItem>.from(state.items);
      updatedList[existingIndex] = existing.copyWith(qtyMilli: newQty);
      state = state.copyWith(items: updatedList);
    } else {
      final newItem = CartItem(
        productId: product.id,
        productName: product.name,
        unit: product.unit,
        unitPricePaisa: product.sellingPricePaisa,
        costPricePaisa: product.purchasePricePaisa,
        qtyMilli: qtyDeltaMilli,
      );
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }

  void updateQuantity(String productId, int newQtyMilli) {
    if (newQtyMilli <= 0) {
      removeItem(productId);
      return;
    }
    final updatedList = state.items.map((item) {
      if (item.productId == productId) {
        return item.copyWith(qtyMilli: newQtyMilli);
      }
      return item;
    }).toList();
    state = state.copyWith(items: updatedList);
  }

  void updateUnitPrice(String productId, int unitPricePaisa) {
    if (unitPricePaisa < 0) return;
    final updatedList = state.items.map((item) {
      if (item.productId == productId) {
        return item.copyWith(unitPricePaisa: unitPricePaisa);
      }
      return item;
    }).toList();
    state = state.copyWith(items: updatedList);
  }

  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.productId != productId).toList(),
    );
  }

  void setDiscount(int discountPaisa) {
    state =
        state.copyWith(discountPaisa: discountPaisa < 0 ? 0 : discountPaisa);
  }

  void setCustomer(String? customerId) {
    if (customerId == null) {
      state = state.copyWith(clearCustomer: true);
    } else {
      state = state.copyWith(customerId: customerId);
    }
  }

  void setPaymentType(PaymentType type) {
    state = state.copyWith(paymentType: type);
  }

  void setCustomPaidPaisa(int paidPaisa) {
    state = state.copyWith(customPaidPaisa: paidPaisa < 0 ? 0 : paidPaisa);
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setNote(String? note) {
    if (note == null || note.isEmpty) {
      state = state.copyWith(clearNote: true);
    } else {
      state = state.copyWith(note: note);
    }
  }

  void clear() {
    state = const CartState();
  }
}

final cartProvider =
    StateNotifierProvider<CartNotifier, CartState>((ref) => CartNotifier());
