import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/wingman_widgets/opener_chat_screen.dart';
import '../../dating_tips/screens/dating_tips_screen.dart';
import '../models/love_test_result.dart';
import '../widgets/love_score_card.dart';
import '../widgets/love_test_metric_bar.dart';

class LoveTesterResultScreen extends StatefulWidget {
  final LoveTestResult result;

  const LoveTesterResultScreen({super.key, required this.result});

  @override
  State<LoveTesterResultScreen> createState() => _LoveTesterResultScreenState();
}

class _LoveTesterResultScreenState extends State<LoveTesterResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  static const Color _purple = Color(0xFF7C3AED);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _shareResult() {
    final r = widget.result;
    final buffer = StringBuffer();
    buffer.writeln('💕 Love Tester Result');
    buffer.writeln();
    buffer.writeln('${r.yourName} ❤️ ${r.theirName}');
    buffer.writeln('Love Score: ${r.score}%');
    buffer.writeln('Match: ${r.verdictLabel}');
    buffer.writeln('Category: ${r.category}');
    buffer.writeln();
    if (r.metrics.isNotEmpty) {
      buffer.writeln('Why you match:');
      for (final m in r.metrics) {
        final pct = (m.value * 100).round();
        buffer.writeln('• ${m.label}: $pct%');
      }
      buffer.writeln();
    }
    buffer.writeln('Check your match in Flirty Messages & Pickup Lines!');

    SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }

  void _generatePickupLine() {
    final r = widget.result;
    final userId = 'visitor_${DateTime.now().millisecondsSinceEpoch}_lovetester';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OpenerChatScreen(
          name: r.theirName,
          interests: r.category,
          tone: r.category,
          userId: userId,
        ),
      ),
    );
  }

  void _getDatingTips() {
    final r = widget.result;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DatingTipsScreen(
          initialCategory: r.category,
        ),
      ),
    );
  }

  void _tryAgain() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final all = r.allTests;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Love Tester',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        child: Column(
          children: [
            // ── Top Gradient Card with Circular Score & Names ──
            LoveScoreCard(
              score: r.score,
              yourName: r.yourName,
              theirName: r.theirName,
              animation: _animController,
            ),

            const SizedBox(height: 20),

            // ── Verdict label ──────────────────────────────────
            Text(
              r.verdictLabel,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF222222),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // ── Summary explanation ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                r.summary,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF555555),
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── All Tests Breakdown (if Calculate All was run) ──
            if (all != null) ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'All Tests Breakdown',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMiniTestCard(
                            icon: Icons.abc_rounded,
                            title: 'Name',
                            score: all.nameMatch.score,
                            subtitle: all.nameMatch.verdictLabel,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMiniTestCard(
                            icon: Icons.water_drop_rounded,
                            title: 'Zodiac',
                            score: all.zodiacMatch.score,
                            subtitle: '${all.zodiacMatch.sign1} & ${all.zodiacMatch.sign2}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMiniTestCard(
                            icon: Icons.chat_bubble_outline_rounded,
                            title: 'Chat',
                            score: all.chatChemistry.score,
                            subtitle: all.chatChemistry.verdictLabel,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMiniTestCard(
                            icon: Icons.extension_rounded,
                            title: 'Personality',
                            score: all.personalityMatch.score,
                            subtitle: all.personalityMatch.verdictLabel,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Why you match card ────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Why you match',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...r.metrics.map((m) => LoveTestMetricBar(
                        metric: m,
                        animation: _animController,
                      )),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Action Buttons ─────────────────────────────────
            // 1. Generate Pickup Line (Gradient Primary Button)
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF9F67F0)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _generatePickupLine,
                  icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                  label: const Text(
                    'Generate Pickup Line ✨',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 2. Row with Share Result & Get Dating Tips
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareResult,
                    icon: const Icon(Icons.share_rounded, color: _purple, size: 18),
                    label: const Text(
                      'Share Result',
                      style: TextStyle(
                        color: _purple,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: _purple, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _getDatingTips,
                    icon: const Icon(Icons.lightbulb_outline_rounded, color: _purple, size: 18),
                    label: const Text(
                      'Get Dating Tips',
                      style: TextStyle(
                        color: _purple,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: _purple, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 3. Try Again Button
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _tryAgain,
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF666666), size: 18),
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniTestCard({
    required IconData icon,
    required String title,
    required int score,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F8FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _purple.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 20, color: _purple),
              Text(
                '$score%',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: _purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
