import 'dart:math' as math;
import 'package:flutter/material.dart';

class LoveScoreCard extends StatelessWidget {
  final int score;
  final String yourName;
  final String theirName;
  final Animation<double> animation;

  const LoveScoreCard({
    super.key,
    required this.score,
    required this.yourName,
    required this.theirName,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB6CF), Color(0xFFD5A0F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Column(
        children: [
          // Circular ring
          AnimatedBuilder(
            animation: animation,
            builder: (_, _) => SizedBox(
              width: 130,
              height: 130,
              child: CustomPaint(
                painter: _ScoreRingPainter(
                  progress: (animation.value * score / 100).clamp(0.0, 1.0),
                  trackColor: Colors.white.withValues(alpha: 0.35),
                  arcColor: const Color(0xFF7C3AED),
                ),
                child: Center(
                  child: Text(
                    '${(animation.value * score).round()}%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Names pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              '$yourName \u{1F495} $theirName',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color arcColor;

  _ScoreRingPainter({
    required this.progress,
    required this.trackColor,
    required this.arcColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 14) / 2;
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final arcPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) => old.progress != progress;
}
