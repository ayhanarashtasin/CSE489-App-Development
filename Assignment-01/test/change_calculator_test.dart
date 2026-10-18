import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/change_calculator.dart';

void main() {
  test('empty amount has all eight denominations with zero counts', () {
    final counts = calculateChange(BigInt.zero);

    expect(counts.keys, takaDenominations);
    expect(counts.values, everyElement(BigInt.zero));
  });

  for (final denomination in takaDenominations) {
    test('$denomination Taka uses exactly one matching note', () {
      final counts = calculateChange(BigInt.from(denomination));

      for (final note in takaDenominations) {
        expect(counts[note], note == denomination ? BigInt.one : BigInt.zero);
      }
    });
  }

  final examples = {
    6: [0, 0, 0, 0, 0, 1, 0, 1],
    68: [0, 0, 1, 0, 1, 1, 1, 1],
    688: [1, 1, 1, 1, 1, 1, 1, 1],
    6880: [13, 3, 1, 1, 1, 0, 0, 0],
  };
  for (final example in examples.entries) {
    test('${example.key} matches the assignment example', () {
      expect(
        calculateChange(BigInt.from(example.key)).values,
        example.value.map(BigInt.from),
      );
    });
  }

  test('all amounts through 1000 use the minimum number of notes', () {
    final minimumNotes = List<int>.filled(1001, 1001);
    minimumNotes[0] = 0;

    for (var amount = 1; amount <= 1000; amount++) {
      for (final note in takaDenominations.where((note) => note <= amount)) {
        final candidate = minimumNotes[amount - note] + 1;
        if (candidate < minimumNotes[amount]) {
          minimumNotes[amount] = candidate;
        }
      }

      final counts = calculateChange(BigInt.from(amount));
      final reconstructed = counts.entries.fold(
        BigInt.zero,
        (total, entry) => total + BigInt.from(entry.key) * entry.value,
      );
      final noteCount = counts.values.fold(BigInt.zero, (a, b) => a + b);

      expect(reconstructed, BigInt.from(amount));
      expect(noteCount, BigInt.from(minimumNotes[amount]));
    }
  });

  test('very large amounts do not overflow', () {
    final amount = BigInt.parse('999999999999999999999999999999');
    final counts = calculateChange(amount);

    expect(
      counts.entries.fold(
        BigInt.zero,
        (total, entry) => total + BigInt.from(entry.key) * entry.value,
      ),
      amount,
    );
  });

  test('negative amounts are rejected', () {
    expect(() => calculateChange(-BigInt.one), throwsArgumentError);
  });
}
