import 'package:flutter/material.dart';

/// Shows the premium upsell dialog.
void showPremiumDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => const _PremiumDialog(),
  );
}

class _PremiumDialog extends StatelessWidget {
  const _PremiumDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Heart-in-chat-bubble icon ────────────────────
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF7C3AED),
                      width: 2.5,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFF7C3AED),
                      size: 42,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Title ───────────────────────────────────────
                const Text(
                  'Flirty Messages & Pickup Lines',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 12),

                // ── Body text ───────────────────────────────────
                const Text(
                  '🎬 Watch a quick video to unlock the whole app FREE for 24 hours — no ads, everything unlocked! Or go Premium forever. 💎',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF555577),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                // ── Watch Video button ───────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: hook up rewarded ad
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF7C3AED),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Watch Video',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Subscribe Now button ─────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: hook up in-app purchase
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Subscribe Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Close (✕) button ─────────────────────────────────
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEEEEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: Color(0xFF444444),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Keep PremiumScreen for any existing route references
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showPremiumDialog(context);
      Navigator.of(context).pop();
    });
    return const SizedBox.shrink();
  }
}
