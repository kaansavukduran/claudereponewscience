/// Converted values for display only (U012). A record keeps the value and
/// unit the person typed; when US units are chosen, a converted number is
/// shown beside it, marked with "≈" so it is never mistaken for what was
/// typed. Pure arithmetic, no rounding of the stored value.
library;

enum UnitSystem { metric, us }

/// "≈ 159.6 lb" for 72.4 kg when [system] is US; null when no conversion
/// applies (metric chosen, or a unit with no US form such as mmHg or %).
String? convertedFor(double value, String? unit, UnitSystem system) {
  if (system == UnitSystem.metric || unit == null) return null;
  final (double v, String u)? c = switch (unit) {
    'kg' => (value * 2.2046226218, 'lb'),
    'cm' => (value / 2.54, 'in'),
    '°C' => (value * 9 / 5 + 32, '°F'),
    _ => null,
  };
  if (c == null) return null;
  return '≈ ${c.$1.toStringAsFixed(1)} ${c.$2}';
}
