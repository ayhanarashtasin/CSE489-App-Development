const takaDenominations = <int>[500, 100, 50, 20, 10, 5, 2, 1];

/// Returns the minimum note breakdown, including denominations with zero notes.
Map<int, BigInt> calculateChange(BigInt amount) {
  if (amount.isNegative) {
    throw ArgumentError.value(amount, 'amount', 'Must not be negative');
  }

  final counts = <int, BigInt>{};
  var remainder = amount;
  for (final denomination in takaDenominations) {
    final note = BigInt.from(denomination);
    counts[denomination] = remainder ~/ note;
    remainder %= note;
  }
  return counts;
}
