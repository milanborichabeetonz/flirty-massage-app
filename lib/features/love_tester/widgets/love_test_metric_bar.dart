import 'package:flutter/material.dart';
import '../models/love_test_metric.dart';

class LoveTestMetricBar extends StatelessWidget {
  final LoveTestMetric metric;
  final Animation<double> animation;

  const LoveTestMetricBar({
    super.key,
    required this.metric,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                metric.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              AnimatedBuilder(
                animation: animation,
                builder: (_, _) => Text(
                  '${(animation.value * metric.percentage).round()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7C3AED),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Track background
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          // Gradient fill bar overlaid
          AnimatedBuilder(
            animation: animation,
            builder: (_, _) {
              return Transform.translate(
                offset: const Offset(0, -8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final fillWidth =
                        constraints.maxWidth * animation.value * metric.value;
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: fillWidth,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFFFF6CA1)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
