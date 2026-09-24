/// Represents one labeled metric bar in "Why you match"
class LoveTestMetric {
  final String label;
  final double value; // 0.0 – 1.0

  const LoveTestMetric({required this.label, required this.value});

  int get percentage => (value * 100).round().clamp(0, 100);
}
