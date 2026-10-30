/// Base class for all Smart Khata domain exceptions.
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);
  @override
  String toString() => '$runtimeType: $message';
}

class InsufficientStockException extends AppException {
  final String productName;
  final int availableMilli;
  final int requestedMilli;
  const InsufficientStockException({
    required this.productName,
    required this.availableMilli,
    required this.requestedMilli,
  }) : super('Insufficient stock for $productName: '
            'available ${availableMilli / 1000}, requested ${requestedMilli / 1000}');
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class OverpaymentException extends AppException {
  const OverpaymentException(super.message);
}

class CustomerRequiredException extends AppException {
  const CustomerRequiredException()
      : super('Customer is required when there is a due amount');
}

class EmptyCartException extends AppException {
  const EmptyCartException() : super('Cart cannot be empty');
}

class SaleAlreadyCancelledException extends AppException {
  const SaleAlreadyCancelledException() : super('Sale is already cancelled');
}

class DatabaseException extends AppException {
  const DatabaseException(super.message);
}
