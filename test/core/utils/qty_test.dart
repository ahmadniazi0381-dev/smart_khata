import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/utils/qty.dart';

void main() {
  group('Qty.format', () {
    test('formats 1 kg', () => expect(Qty.format(1000, 'kg'), '1 kg'));
    test('formats 2 pcs', () => expect(Qty.format(2000, 'pcs'), '2 pcs'));
    test('formats 0.75 kg', () => expect(Qty.format(750, 'kg'), '0.75 kg'));
    test('formats 0.5 kg', () => expect(Qty.format(500, 'kg'), '0.5 kg'));
    test('formats 2.5 kg', () => expect(Qty.format(2500, 'kg'), '2.5 kg'));
    test('formats 1.250 kg', () => expect(Qty.format(1250, 'kg'), '1.25 kg'));
  });

  group('Qty.formatNumber', () {
    test('whole number', () => expect(Qty.formatNumber(1000), '1'));
    test('decimal', () => expect(Qty.formatNumber(750), '0.75'));
    test('two decimals', () => expect(Qty.formatNumber(1500), '1.5'));
  });

  group('Qty.parse', () {
    test('parses "1"', () => expect(Qty.parse('1'), 1000));
    test('parses "2"', () => expect(Qty.parse('2'), 2000));
    test('parses "0.75"', () => expect(Qty.parse('0.75'), 750));
    test('parses "0.5"', () => expect(Qty.parse('0.5'), 500));
    test('parses "2.5"', () => expect(Qty.parse('2.5'), 2500));
    test('parses "1.250"', () => expect(Qty.parse('1.250'), 1250));
    test('returns null for empty', () => expect(Qty.parse(''), isNull));
    test('returns null for invalid', () => expect(Qty.parse('abc'), isNull));
    test('parses "0"', () => expect(Qty.parse('0'), 0));
  });

  group('Qty round-trip', () {
    test('parse then formatNumber gives back original', () {
      const inputs = ['1', '0.75', '2.5', '1.25'];
      for (final s in inputs) {
        final milli = Qty.parse(s);
        expect(milli, isNotNull);
        expect(Qty.formatNumber(milli!), s);
      }
    });
  });
}
