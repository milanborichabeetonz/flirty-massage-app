import 'package:flirtymessages/core/widgets/costume_card/costume_card_widget.dart';
import 'package:flirtymessages/core/widgets/costume_text/costume_text_widget.dart';
import 'package:flutter/material.dart';

class PickToneCardWidget extends StatelessWidget {
  final Widget? child;
  final IconData icon;
  final String text;

  final Color textColor;
  final Color titleColor;

  final String titleText;

  final double textSize;
  final double titleSize;

  const PickToneCardWidget({
    super.key,
     this.child,
    required this.icon,
    required this.text,
    this.textColor = Colors.blue,
    this.titleColor = Colors.black,
    required this.titleText,
    this.textSize = 10,
    this.titleSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CostumeCardWidget(
        color: Colors.white.withOpacity(0.5),
        child: Column(
          children: [
            Icon(icon),

            const SizedBox(height: 5),

            CostumeTextWidget(
              text: titleText,
              color: titleColor,
              size: titleSize,
            ),

            const SizedBox(height: 5),

            CostumeTextWidget(
              text: text,
              color: textColor,
              size: textSize,
            ),


          ],
        ),
      ),
    );
  }
}