import 'package:flirtymessages/core/constants/wingman_widgets/wingman_toggle.dart';
import 'package:flirtymessages/core/widgets/costume_text/costume_text_widget.dart';
import 'package:flutter/material.dart';

import '../../core/constants/wingman_widgets/personalized_openers_view.dart' show PersonalizedOpenersView;
import '../../core/constants/wingman_widgets/screenshort_analyzer_view.dart';
import '../../core/widgets/exit_confirmation_dialog.dart';

class WingmanScreen extends StatefulWidget {
  const WingmanScreen({super.key});

  @override
  State<WingmanScreen> createState() => _WingmanScreenState();
}

class _WingmanScreenState extends State<WingmanScreen> {
  bool isScreenshotAnalyzer = true;

  Future<void> _handleExit() async {
    final screenName = isScreenshotAnalyzer
        ? 'Screenshot Analyzer'
        : 'Personalized Openers';
    final shouldExit = await showExitConfirmationDialog(
      context: context,
      screenName: screenName,
    );
    if (shouldExit && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _handleExit();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              //---------------------------------- header --------------------------------
              Container(
                height: 200,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Column(
                    children: [
                      const CostumeTextWidget(
                        text:
                            'Your AI Wingman \nAlways Know What to say \nwhat to say',
                        color: Colors.white,
                        size: 25,
                        fontWeight: FontWeight.bold,
                      ),
                      CostumeTextWidget(
                        text: "screenshort in. Smooth replies",
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ),
              // -------------------------------- toggle Button ------------------------------
              Flexible(
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                     WingmanToggle(
                       onChanged: (value) {
                         setState(() {
                           isScreenshotAnalyzer = value;
                         });
                       },
                     ),
                      Expanded(
                        child: isScreenshotAnalyzer
                            ? const ScreenshortAnalyzerView()
                            : const PersonalizedOpenersView(),
                      ),
                    ],
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
