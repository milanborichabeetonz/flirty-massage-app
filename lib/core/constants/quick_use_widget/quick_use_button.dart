import 'package:flutter/material.dart';
import '../../../features/dating_tips/screens/dating_tips_screen.dart';
import '../../../features/love_tester/screens/love_tester_screen.dart';
import '../../widgets/costume_card/costume_card_widget.dart';
import '../../widgets/costume_text/costume_text_widget.dart';

class QuickUseButton extends StatelessWidget {
  const QuickUseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // ------------------------------------ Dating Tips ----------------------------------
          Expanded(
            child: CostumeCardWidget(
              elevation: 0,
              color: const Color(0xFFFFF0F5),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DatingTipsScreen(),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CostumeTextWidget(
                    text: 'Dating Tips',
                    color: Color(0xFFE84393),
                    size: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Expanded(
                        child: CostumeTextWidget(
                          text: 'Improve your\nlove game',
                          color: Color(0xFF4A4A4A),
                          size: 11,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Color(0xFFE84393)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // -------------------------------------- Love Tester -----------------------------------
          Expanded(
            child: CostumeCardWidget(
              elevation: 0,
              color: const Color(0xFFF0F4FF),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoveTesterScreen(),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CostumeTextWidget(
                    text: 'Love Tester',
                    color: Color(0xFF3B82F6),
                    size: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Expanded(
                        child: CostumeTextWidget(
                          text: 'Check your\ncompatibility',
                          color: Color(0xFF4A4A4A),
                          size: 11,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Color(0xFF3B82F6)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
