import 'package:flutter/material.dart';

class PickupLinePreviewWidget extends StatelessWidget {
  final Color backgroundColor; //  add ------------
  final double fontSize;
  final double latterSpacing;
  final String fontFamily;
  final double lineHeight;
  final Color textColor;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final TextDecoration textDecoration;
  final TextAlign textAlign;
  final TextEditingController? controller;
  final bool hasBorder;
  final Color borderColor;
  final double borderWidth;

  const PickupLinePreviewWidget({
    super.key,
    this.backgroundColor = Colors.white,
    this.fontSize = 25,
    this.latterSpacing = 1.0,
    this.lineHeight = 0,
    this.fontFamily = 'Roboto',
    this.textColor = Colors.black,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.center,
    this.fontStyle = FontStyle.normal,
    this.textDecoration = TextDecoration.none,
    this.controller,
    this.hasBorder =false,
     this.borderColor = Colors.yellow,
    this.borderWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Expanded(
            // main preview content receiver
            child: Card(
              color: backgroundColor,

              /// use for change background ----------
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),

                  ///  ----------------------------------------------------
                  ///  mian Text field ..... ------------------------------
                  /// ----------------------------------------------------
                  child: // Stack as TextField ka wrapper
                  Stack(
                    children: [

                      if (hasBorder)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Align(
                              alignment: Alignment.center,
                              child: ValueListenableBuilder(
                                valueListenable: controller!,
                                builder: (context, value, _) {
                                  return Text(
                                    value.text,
                                    textAlign: textAlign,
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontFamily: fontFamily,
                                      letterSpacing: latterSpacing,
                                      fontWeight: fontWeight,
                                      fontStyle: fontStyle,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = borderWidth
                                        ..color = borderColor,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        TextField(
                          controller: controller,
                          maxLines: null,
                          expands: true,
                          textAlign: textAlign,
                          textAlignVertical: TextAlignVertical.center,

                          style: TextStyle(
                            fontSize: fontSize,
                            height: lineHeight,
                            letterSpacing: latterSpacing,
                            fontFamily: fontFamily,
                            color: textColor, // -----------  add text
                            fontWeight: fontWeight,
                            fontStyle: fontStyle,
                            decoration: textDecoration,

                          ),
                          decoration: const InputDecoration(
                            hintText: "Type Here...",
                            hintStyle: TextStyle(fontSize: 20),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                    ],
                  )
//stack
                  //------------------------------------------------------
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
