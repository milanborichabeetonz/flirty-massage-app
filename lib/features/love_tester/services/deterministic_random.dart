/// Deterministic pseudo-random number generator using Linear Congruential Generator (LCG)
/// Parameters:
/// A = 1664525 (Numerical Recipes)
/// C = 1013904223
/// M = 2^32 (0x100000000)
/// Formula: X(n+1) = (A * X(n) + C) mod M
class DeterministicRandom {
  static const int _a = 1664525;
  static const int _c = 1013904223;
  static const int _mask32 = 0xFFFFFFFF;
  static const double _twoPow32 = 4294967296.0;

  int _state;

  DeterministicRandom(int seed) : _state = seed & _mask32;

  /// Returns next 32-bit unsigned integer
  int nextInt() {
    _state = (_a * _state + _c) & _mask32;
    return _state;
  }

  /// Returns next uniform double in [0.0, 1.0)
  double nextDouble() {
    return nextInt() / _twoPow32;
  }

  /// Returns next double in [min, max]
  double nextDoubleRange(double min, double max) {
    return min + nextDouble() * (max - min);
  }
}
