// Money helper — all amounts are integer paisa (1 PKR = 100 paisa).
// Never use double for money calculations.
// ignore: unused_import
import 'dart:math';

class Money {
  const Money._();

  /// Format paisa as PKR string: 12750 → "PKR 127.50"
  static String format(int paisa) {
    final sign = paisa < 0 ? '-' : '';
    final abs = paisa.abs();
    final rupees = abs ~/ 100;
    final paise = abs % 100;
    return '${sign}PKR ${_formatRupees(rupees)}.${paise.toString().padLeft(2, '0')}';
  }

  /// Format without currency symbol: 12750 → "127.50"
  static String formatAmount(int paisa) {
    final sign = paisa < 0 ? '-' : '';
    final abs = paisa.abs();
    final rupees = abs ~/ 100;
    final paise = abs % 100;
    return '$sign${_formatRupees(rupees)}.${paise.toString().padLeft(2, '0')}';
  }

  static String _formatRupees(int rupees) {
    // Pakistani number format: 1,00,000 grouping
    final s = rupees.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final buf = StringBuffer();
    for (var i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) buf.write(',');
      buf.write(rest[i]);
    }
    return '${buf.toString()},$last3';
  }

  /// Convert PKR string input to paisa (for form fields).
  /// "127.50" → 12750, "127" → 12700
  static int? parse(String input) {
    final cleaned =
        input.trim().replaceAll(',', '').replaceAll('PKR', '').trim();
    if (cleaned.isEmpty) return null;
    final parts = cleaned.split('.');
    if (parts.length > 2) return null;
    final rupees = int.tryParse(parts[0]);
    if (rupees == null) return null;
    int paise = 0;
    if (parts.length == 2) {
      final p = parts[1].padRight(2, '0').substring(0, 2);
      paise = int.tryParse(p) ?? 0;
    }
    return rupees * 100 + paise;
  }

  /// Compute line total: roundHalfUp(unitPricePaisa * qtyMilli / 1000)
  /// e.g. 170 PKR/kg * 750 g = 127.50 PKR = 12750 paisa
  static int lineTotal(int unitPricePaisa, int qtyMilli) {
    // Use integer arithmetic: (price * qty + 500) ~/ 1000
    // This gives round-half-up behaviour
    final raw = unitPricePaisa * qtyMilli;
    // raw is in paisa * milli; divide by 1000 to get paisa
    // round half up: add 500 before integer division
    return (raw + 500) ~/ 1000;
  }
}
