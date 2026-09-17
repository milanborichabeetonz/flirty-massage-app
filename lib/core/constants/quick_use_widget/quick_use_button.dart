import 'package:flutter/material.dart';

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
            color: Colors.pinkAccent.withOpacity(0.5),
            borderRadius: BorderRadius.circular(15)
        ),
        child: Row(
          children: [
            // ------------------------------------ Dating types ----------------------------------
            Expanded(
              child: CostumeCardWidget(
                color: Colors.pinkAccent.withOpacity(0.4),
                child: Column(
                  children: [
                    CostumeTextWidget(
                      text: ' Dating Tips',
                      color: Colors.black,
                      size: 12,
                    ),
                    SizedBox(height: 15,),
                    Row(
                      children: [
                        CostumeTextWidget(
                          text: ' Improve your \nlove game',
                          color: Colors.black,
                          size: 12,
                        ),
                        SizedBox(width: 50,),
                        Icon(Icons.chevron_right)
                      ],
                    )
                  ],
                ),
              ),
            ),
            // -------------------------------------- Love Tester -----------------------------------
            Expanded(
              child: CostumeCardWidget(
                color: Colors.blueAccent.withOpacity(0.4),
                child: Column(
                  children: [
                    CostumeTextWidget(
                      text: 'Love Tester',
                      color: Colors.black,
                      size: 12,
                    ),
                    SizedBox(height: 15,),
                    Row(
                      children: [
                        CostumeTextWidget(
                          text: ' check your \n compatibility',
                          color: Colors.black,
                          size: 12,
                        ),
                        SizedBox(width: 50,),
                        Icon(Icons.chevron_right)
                      ],
                    )
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
