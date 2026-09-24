class StableHash {
  static const int _fnvOffsetBasis = 0x811C9DC5;
  static const int _fnvPrime = 0x01000193;
  static const int _mask32 = 0xFFFFFFFF;

  /// Normalizes input string:
  /// - trim whitespace
  /// - lowercase
  /// - collapse multiple whitespace into a single space
  static String normalizeInput(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Normalizes input to lowercase latin letters only (for name character analysis)
  static String normalizeLetters(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  }

  /// 32-bit FNV-1a hash algorithm (stable and cross-platform)
  static int fnv1a32(String input) {
    var hash = _fnvOffsetBasis;
    for (final unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * _fnvPrime) & _mask32;
    }
    return hash;
  }

  /// Generates a symmetric seed from two inputs regardless of order
  static int symmetricSeed(String val1, String val2, {bool lettersOnly = false}) {
    final s1 = lettersOnly ? normalizeLetters(val1) : normalizeInput(val1);
    final s2 = lettersOnly ? normalizeLetters(val2) : normalizeInput(val2);
    final first = s1.compareTo(s2) <= 0 ? s1 : s2;
    final second = s1.compareTo(s2) <= 0 ? s2 : s1;
    return fnv1a32('$first:$second');
  }
}
