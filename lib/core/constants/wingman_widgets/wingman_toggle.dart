import 'package:flirtymessages/core/widgets/costume_card/costume_card_widget.dart';
import 'package:flirtymessages/core/widgets/costume_text/costume_text_widget.dart';
import 'package:flutter/material.dart';

class WingmanToggle extends StatefulWidget {
  final ValueChanged<bool> onChanged;

  const WingmanToggle({super.key,required this.onChanged});

  @override
  State<WingmanToggle> createState() => _WingmanToggleState();
}

class _WingmanToggleState extends State<WingmanToggle> {
  bool isScreenshotAnalyzer = true;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Card(
        color: Colors.pinkAccent.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isScreenshotAnalyzer = true;
                    });
                    widget.onChanged(true);
                  },
                  child: Card(
                    color: isScreenshotAnalyzer
                        ? Colors.white
                        : Colors.transparent,
                    child: Center(
                      child: CostumeTextWidget(
                        text: 'Screenshot Analyzer',
                        color: isScreenshotAnalyzer
                            ? Colors.black
                            : Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ),

              //   const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isScreenshotAnalyzer = false;
                    });
                    widget.onChanged(false);
                  },
                  child: Card(
                    color: !isScreenshotAnalyzer
                        ? Colors.white
                        : Colors.transparent,
                    child: Center(
                      child: CostumeTextWidget(
                        text: 'Personalized Openers',
                        color: !isScreenshotAnalyzer
                            ? Colors.black
                            : Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
