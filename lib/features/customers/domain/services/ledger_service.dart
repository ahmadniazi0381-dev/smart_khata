import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/utils/date_utils.dart';

class LedgerService {
  final AppDatabase _db;
  final Uuid _uuid;

  LedgerService(this._db) : _uuid = const Uuid();

  /// Get the current balance for a customer.
  /// Balance = sum(CREDIT amounts) - sum(DEBIT amounts)
  /// Positive = customer owes money
  Future<int> getBalance(String customerId) async {
    final result = await _db.customSelect(
      '''
      SELECT
        COALESCE(SUM(CASE WHEN direction = 'CREDIT' THEN amount_paisa ELSE 0 END), 0) -
        COALESCE(SUM(CASE WHEN direction = 'DEBIT' THEN amount_paisa ELSE 0 END), 0) AS balance
      FROM ledger_entries
      WHERE customer_id = ?
      ''',
      variables: [Variable.withString(customerId)],
    ).getSingleOrNull();

    if (result == null) return 0;
    return result.read<int>('balance');
  }

  /// Receive a payment from a customer (khata payment, not tied to one sale).
  Future<void> receivePayment({
    required String customerId,
    required int amountPaisa,
    required String method,
    String? note,
  }) async {
    if (amountPaisa <= 0) {
      throw const ValidationException(
          'Payment amount must be greater than zero');
    }

    final balance = await getBalance(customerId);
    if (amountPaisa > balance) {
      throw OverpaymentException(
          'Payment (${amountPaisa / 100}) exceeds balance (${balance / 100}). '
          'Advance balances are not supported in v1.');
    }

    await _db.transaction(() async {
      final now = AppDateUtils.nowMs();
      final paymentId = _uuid.v4();

      await _db.into(_db.payments).insert(PaymentsCompanion(
            id: Value(paymentId),
            customerId: Value(customerId),
            amountPaisa: Value(amountPaisa),
            method: Value(method),
            paidAt: Value(now),
            note: Value(note),
            createdAt: Value(now),
            updatedAt: Value(now),
          ));

      await _db.into(_db.ledgerEntries).insert(LedgerEntriesCompanion(
            id: Value(_uuid.v4()),
            customerId: Value(customerId),
            paymentId: Value(paymentId),
            entryType: const Value('PAYMENT'),
            direction: const Value('DEBIT'),
            amountPaisa: Value(amountPaisa),
            entryDate: Value(now),
            note: Value(note ?? 'Payment received'),
            createdAt: Value(now),
            updatedAt: Value(now),
          ));
    });
  }

  /// Adjust balance manually (audit trail required).
  Future<void> adjustBalance({
    required String customerId,
    required int signedAmountPaisa,
    required String reason,
  }) async {
    if (reason.trim().isEmpty) {
      throw const ValidationException(
          'Reason is required for balance adjustment');
    }
    if (signedAmountPaisa == 0) {
      throw const ValidationException('Adjustment amount cannot be zero');
    }

    await _db.transaction(() async {
      final now = AppDateUtils.nowMs();
      final direction = signedAmountPaisa > 0 ? 'CREDIT' : 'DEBIT';
      final amount = signedAmountPaisa.abs();

      await _db.into(_db.ledgerEntries).insert(LedgerEntriesCompanion(
            id: Value(_uuid.v4()),
            customerId: Value(customerId),
            entryType: const Value('ADJUSTMENT'),
            direction: Value(direction),
            amountPaisa: Value(amount),
            entryDate: Value(now),
            note: Value(reason),
            createdAt: Value(now),
            updatedAt: Value(now),
          ));
    });
  }

  /// Add an OPENING balance entry for a customer.
  Future<void> setOpeningBalance({
    required String customerId,
    required int amountPaisa,
    String note = 'Opening balance',
  }) async {
    if (amountPaisa <= 0) return;
    final now = AppDateUtils.nowMs();
    await _db.into(_db.ledgerEntries).insert(LedgerEntriesCompanion(
          id: Value(_uuid.v4()),
          customerId: Value(customerId),
          entryType: const Value('OPENING'),
          direction: const Value('CREDIT'),
          amountPaisa: Value(amountPaisa),
          entryDate: Value(now),
          note: Value(note),
          createdAt: Value(now),
          updatedAt: Value(now),
        ));
  }
}
