// Quantity helper — all quantities are integer milli-units.
// 1 kg = 1000, 2 pcs = 2000, 0.75 kg = 750
class Qty {
  const Qty._();

  /// Format milli-units for display.
  /// 1000 → "1 kg", 2000 → "2 pcs", 750 → "0.75 kg"
  static String format(int milli, String unit) {
    final whole = milli ~/ 1000;
    final frac = (milli % 1000).toString().padLeft(3, '0');
    // Drop trailing zeros after decimal
    final fracTrimmed = frac.replaceAll(RegExp(r'0+$'), '');
    if (fracTrimmed.isEmpty) {
      return '$whole $unit';
    }
    return '$whole.$fracTrimmed $unit';
  }

  /// Parse user input to milli-units.
  /// "1" → 1000, "0.75" → 750, "2.5" → 2500
  static int? parse(String input) {
    final cleaned = input.trim().replaceAll(',', '');
    if (cleaned.isEmpty) return null;
    final parts = cleaned.split('.');
    if (parts.length > 2) return null;
    final whole = int.tryParse(parts[0]);
    if (whole == null) return null;
    int frac = 0;
    if (parts.length == 2) {
      final f = parts[1].padRight(3, '0').substring(0, 3);
      frac = int.tryParse(f) ?? 0;
    }
    return whole * 1000 + frac;
  }

  /// Display just the numeric value without unit
  static String formatNumber(int milli) {
    final whole = milli ~/ 1000;
    final frac = (milli % 1000).toString().padLeft(3, '0');
    final fracTrimmed = frac.replaceAll(RegExp(r'0+$'), '');
    if (fracTrimmed.isEmpty) return '$whole';
    return '$whole.$fracTrimmed';
  }
}
