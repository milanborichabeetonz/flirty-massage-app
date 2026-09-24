import 'package:flutter/material.dart';
import '../../../features/dating_tips/screens/dating_tips_screen.dart';
import '../../../features/love_tester/screens/love_tester_screen.dart';
import '../../widgets/costume_card/costume_card_widget.dart';
import '../../widgets/costume_text/costume_text_widget.dart';

class QuickUseButton extends StatelessWidget {
  const QuickUseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.pinkAccent.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            // ------------------------------------ Dating Tips ----------------------------------
            Expanded(
              child: CostumeCardWidget(
                color: Colors.pinkAccent.withValues(alpha: 0.4),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DatingTipsScreen(),
                  ),
                ),
                child: Column(
                  children: [
                    CostumeTextWidget(
                      text: ' Dating Tips',
                      color: Colors.black,
                      size: 12,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        CostumeTextWidget(
                          text: ' Improve your \nlove game',
                          color: Colors.black,
                          size: 12,
                        ),
                        const SizedBox(width: 40),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // -------------------------------------- Love Tester -----------------------------------
            Expanded(
              child: CostumeCardWidget(
                color: Colors.blueAccent.withValues(alpha: 0.4),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoveTesterScreen(),
                  ),
                ),
                child: Column(
                  children: [
                    CostumeTextWidget(
                      text: 'Love Tester',
                      color: Colors.black,
                      size: 12,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        CostumeTextWidget(
                          text: ' check your \n compatibility',
                          color: Colors.black,
                          size: 12,
                        ),
                        const SizedBox(width: 40),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
