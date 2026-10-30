import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/utils/money.dart';

void main() {
  group('Money.format', () {
    test('formats zero', () => expect(Money.format(0), 'PKR 0.00'));

    test('formats round rupees',
        () => expect(Money.format(50000), 'PKR 500.00'));

    test('formats with paise', () => expect(Money.format(12750), 'PKR 127.50'));

    test('formats negative', () => expect(Money.format(-5000), '-PKR 50.00'));

    test('formats 1 paisa', () => expect(Money.format(1), 'PKR 0.01'));

    test('formats large amount with Pakistani grouping', () {
      // 1,00,000 PKR = 10,000,000 paisa
      expect(Money.format(10000000), 'PKR 1,00,000.00');
    });
  });

  group('Money.formatAmount', () {
    test('no currency symbol',
        () => expect(Money.formatAmount(12750), '127.50'));
    test('negative without symbol',
        () => expect(Money.formatAmount(-500), '-5.00'));
  });

  group('Money.parse', () {
    test('parses whole rupees', () => expect(Money.parse('500'), 50000));

    test('parses with decimal', () => expect(Money.parse('127.50'), 12750));

    test('parses with one decimal digit',
        () => expect(Money.parse('127.5'), 12750));

    test('parses zero', () => expect(Money.parse('0'), 0));

    test(
        'returns null for empty string', () => expect(Money.parse(''), isNull));

    test('returns null for non-numeric',
        () => expect(Money.parse('abc'), isNull));

    test('strips commas before parsing',
        () => expect(Money.parse('1,000'), 100000));

    test('strips PKR prefix', () => expect(Money.parse('PKR 127.50'), 12750));
  });

  group('Money.lineTotal', () {
    test('2 kg Sugar @ 170 PKR/kg = 34000 paisa', () {
      // 2000 milli × 17000 paisa/unit ÷ 1000 = 34000
      expect(Money.lineTotal(17000, 2000), 34000);
    });

    test('1 kg Rice @ 290 PKR/kg = 29000 paisa', () {
      expect(Money.lineTotal(29000, 1000), 29000);
    });

    test('1 ltr Milk @ 200 PKR = 20000 paisa', () {
      expect(Money.lineTotal(20000, 1000), 20000);
    });

    test('0.750 kg @ 170 PKR/kg = 12750 paisa (PKR 127.50)', () {
      // 17000 × 750 = 12,750,000; (12,750,000 + 500) / 1000 = 12750
      expect(Money.lineTotal(17000, 750), 12750);
    });

    test('round half up: 1.5 paisa rounds to 2', () {
      // 1 paisa × 1500 milli → raw = 1500 → (1500+500)/1000 = 2
      expect(Money.lineTotal(1, 1500), 2);
    });

    test('round half up: 1.4 paisa rounds to 1', () {
      // 1 paisa × 1400 milli → raw = 1400 → (1400+500)/1000 = 1
      expect(Money.lineTotal(1, 1400), 1);
    });

    test('zero price gives zero total', () {
      expect(Money.lineTotal(0, 2000), 0);
    });

    test('zero quantity gives zero total', () {
      expect(Money.lineTotal(17000, 0), 0);
    });
  });
}
