import 'package:flirtymessages/core/widgets/costume_text/costume_text_widget.dart';
import 'package:flirtymessages/core/widgets/custom_button_widget.dart';
import 'package:flirtymessages/core/widgets/edit_text_botton_widget.dart';
import 'package:flutter/material.dart';

import '../../core/constants/line_text_maker_widget/pickup_line_preview_widget.dart';

class PickupLineMakerScreen extends StatefulWidget {
  const PickupLineMakerScreen({super.key});

  @override
  State<PickupLineMakerScreen> createState() => _PickupLineMakerScreenState();
}

class _PickupLineMakerScreenState extends State<PickupLineMakerScreen> {
  /// ====================
  ///  for text size ----------------------------------------------------------------------------
  /// ====================

  final TextEditingController _textController = TextEditingController();

  double fontSize = 25;
  double vSpacing = 0.0;
  double textSpacing = 0.0;
  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;
  TextAlign textAlign = TextAlign.center;
  int textCaseIndex = 0;

  // Pickup Line Text Size Bottom sheet---------------------------------------------------------------
  void _openTextSizeBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: 380,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40),
                  topLeft: Radius.circular(40),
                ),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Icon(Icons.close, size: 30),
                      ),
                      CostumeTextWidget(
                        text: "Text Size",
                        color: Colors.black,
                        size: 15,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Icon(Icons.check, size: 30),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.text_fields, size: 30),
                      Slider(
                        value: fontSize,
                        min: 12,
                        max: 60,
                        onChanged: (value) {
                          setState(() {
                            fontSize = value;
                          });
                          setSheetState(() {});
                        },
                      ),
                      CostumeTextWidget(
                        text: fontSize.toInt().toString(),
                        color: Colors.black,
                        size: 15,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.format_line_spacing, size: 30),
                      Slider(
                        value: vSpacing,
                        min: 0.0,
                        max: 4,
                        onChanged: (value) {
                          setState(() {
                            vSpacing = value;
                          });
                          setSheetState(() {});
                        },
                      ),
                      CostumeTextWidget(
                        text: vSpacing.toInt().toString(),
                        color: Colors.black,
                        size: 15,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.space_bar, size: 30),
                      Slider(
                        value: textSpacing,
                        min: 0,
                        max: 80,
                        onChanged: (value) {
                          setState(() {
                            textSpacing = value;
                          });
                          setSheetState(() {});
                        },
                      ),
                      CostumeTextWidget(
                        text: textSpacing.toInt().toString(),
                        color: Colors.black,
                        size: 15,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButtonWidget(
                        onPressed: () {
                          setState(() {
                            isBold = !isBold;
                          });
                          setSheetState(() {});
                        },
                        backgroundColor: isBold
                            ? Colors.deepPurple
                            : Colors.grey.shade200,
                        child: Icon(
                          Icons.format_bold,
                          color: isBold ? Colors.white : Colors.black87,
                        ),
                      ),
                      CustomButtonWidget(
                        onPressed: () {
                          setState(() {
                            isItalic = !isItalic;
                          });
                          setSheetState(() {});
                        },
                        backgroundColor: isItalic
                            ? Colors.deepPurple
                            : Colors.grey.shade200,
                        child: Icon(
                          Icons.format_italic,
                          color: isBold ? Colors.white : Colors.black87,
                        ),
                      ),
                      CustomButtonWidget(
                        onPressed: () {
                          setState(() {
                            isUnderline = !isUnderline;
                          });
                          setSheetState(() {});
                        },
                        backgroundColor: isUnderline
                            ? Colors.deepPurple
                            : Colors.grey.shade200,
                        child: Icon(
                          Icons.format_underline,
                          color: isBold ? Colors.white : Colors.black87,
                        ),
                      ),
                      CustomButtonWidget(
                        onPressed: () {
                          setState(() {
                            textCaseIndex =
                                (textCaseIndex + 1) %
                                3; // 0: normal, 1: UPPER, 2: lower
                          });

                          final currentText = _textController.text;
                          if (textCaseIndex == 1) {
                            _textController.text = currentText.toUpperCase();
                          } else if (textCaseIndex == 2) {
                            _textController.text = currentText.toLowerCase();
                          }

                          _textController
                              .selection = TextSelection.fromPosition(
                            TextPosition(offset: _textController.text.length),
                          );
                          setSheetState(() {});
                        },
                        backgroundColor: textCaseIndex != 0
                            ? Colors.deepPurple
                            : Colors.grey.shade200,
                        child: Icon(Icons.abc, color: Colors.black87),
                      ),
                      CustomButtonWidget(
                        onPressed: () {
                          setState(() {
                            if (textAlign == TextAlign.center) {
                              textAlign = TextAlign.left; // single = assignment
                            } else if (textAlign == TextAlign.left) {
                              textAlign = TextAlign.right;
                            } else {
                              textAlign = TextAlign.center;
                            }
                          });
                          setSheetState(() {});
                        },
                        backgroundColor: textAlign != TextAlign.center
                            ? Colors.deepPurple
                            : Colors.grey.shade200,
                        child: Icon(
                          Icons.format_align_center,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  ///==============================
  // for TEXT background Color------------------------------------------------------------------------
  ///=============================
  Color selectedColor = Colors.white;

  final List<Color> bgColor = [
    Colors.white,
    Colors.white,
    Colors.pink.shade100,
    Colors.purple.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.amber.shade100,
    Colors.red.shade100,
    Colors.teal.shade100,
    Colors.black87,
  ];

  // pickup Line Background Bottom sheet--------------------------------------------------------------
  void _openBackgroundBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            height: 500,
            width: double.infinity,
            child: Column(
              children: [
                // Text
                CostumeTextWidget(
                  text: "choose Background",
                  color: Colors.black,
                  size: 15,
                ),
                const SizedBox(height: 15),
                // colors option
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: bgColor.length,
                    itemBuilder: (context, index) {
                      final color = bgColor[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = color;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// =========================================
  // ----------- for font family ---------------
  /// =========================================
  String selectedFontFamily = 'Roboto';

  final List<String> fontFamilyList = [
    'Roboto',
    'Anton',
    'BebasNeue',
    'BlackOpsOne',
    'CinzelDecorative',
    'LobsterTwo',
    'MonsieurLaDoulaise',
    'PlayfairDisplay',
    'PlaywriteCUGuides',
    'SmoochSans',
  ];

  //Pickup Line FontFamily Bottom sheet -------------------------------------------------------------
  void _openFontFamilyBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(40),
              topLeft: Radius.circular(40),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Icon(Icons.close, size: 30),
                    ),
                    CostumeTextWidget(
                      text: "Choose Font Style",
                      color: Colors.black,
                      size: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Icon(Icons.check, size: 30),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: fontFamilyList.length,
                    itemBuilder: (context, index) {
                      final fonts = fontFamilyList[index];
                      final isSelectedFonts = selectedFontFamily == fonts;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedFontFamily = fonts;
                          });
                        },
                        child: Card(
                          child: Center(
                            child: CostumeTextWidget(
                              text: "Sample Text",
                              color: Colors.black,
                              size: 20,
                              fontFamily: fonts,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ///================================
  /// pickUp line Text Color
  /// =============================

  //selected textColor
  Color isSelectedTextColor = Colors.black;

  final List<Color> textColor = [
    Colors.white,
    Colors.white,
    Colors.pink.shade100,
    Colors.purple.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.amber.shade100,
    Colors.red.shade100,
    Colors.teal.shade100,
    Colors.black87,
  ];

  void _openTextColorBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(40),
              topLeft: Radius.circular(40),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Icon(Icons.close, size: 30),
                    ),
                    CostumeTextWidget(
                      text: "Choose Text Color",
                      color: Colors.black,
                      size: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Icon(Icons.check, size: 30),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: textColor.length,
                    itemBuilder: ((context, index) {
                      final color = textColor[index];
                      final isSelected = isSelectedTextColor == color;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            isSelectedTextColor = color;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  ///================================
  /// text border  Color---------------------------------------------------------------
  /// ===============================

  bool hasBorder = false;
  Color borderColor = Colors.transparent;
  double borderWidth = 3.0;

  final List<Color> borderColorList = [
    Colors.yellow,
    Colors.purple,
    Colors.red,
    Colors.green,
    Colors.indigo,
    Colors.blueGrey,
    Colors.blue,
    Colors.deepPurple,
    Colors.pink,
    Colors.black,
    Colors.white,
  ];

  void _openBorderBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // --- Header Row ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Icon(Icons.close, size: 28),
                      ),
                      Text("Text Border",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          setState(() {});
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.check, size: 28),
                      ),
                    ],
                  ),

                  // --- Color Picker Row ---
                  SizedBox(
                    height: 55,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      itemCount: borderColorList.length + 1, // +1 for eyedropper
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Eyedropper / No Border button
                          return GestureDetector(
                            onTap: () {
                              setState(() => hasBorder = false);
                              setSheetState(() {});
                            },
                            child: Container(
                              width: 45,
                              height: 45,
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.colorize, size: 22),
                            ),
                          );
                        }
                        final color = borderColorList[index - 1];
                        final isSelected = hasBorder && borderColor == color;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              hasBorder = true;
                              borderColor = color;
                            });
                            setSheetState(() {});
                          },
                          child: Container(
                            width: 45,
                            height: 45,
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.black, width: 3)
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 10),

                  // --- Width Slider Row ---
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Icon(Icons.water_drop_outlined, size: 28),
                      Expanded(
                        child: Slider(
                          value: borderWidth,
                          min: 1.0,
                          max: 10.0,
                          activeColor: Colors.deepPurple,
                          onChanged: (value) {
                            setState(() => borderWidth = value);
                            setSheetState(() {});
                          },
                        ),
                      ),
                      Text(
                        borderWidth.toInt().toString(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 15),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  ///================================
  /// shadow --------------------------------
  /// ==================================
  void _openShadowBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, size: 30),
                  ),

                  CostumeTextWidget(
                    text: "Text Shadow",
                    color: Colors.black,
                    size: 15,
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check, size: 30),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: borderColorList.length,
                  itemBuilder: (context, index) {
                    final shadowColor = borderColorList[index];

                    return Flexible(
                      child: Container(
                        height: 50,
                        width: 50,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: shadowColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //  text Controller dispose
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // ----------------------------------------------- main body --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pickup Line Maker"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.download, size: 30),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // preview screen ------------------
            Expanded(
              child: PickupLinePreviewWidget(

                controller: _textController,
                backgroundColor: selectedColor, // selected background color
                fontSize: fontSize, // font size set
                fontFamily: selectedFontFamily,
                latterSpacing: textSpacing,
                lineHeight: vSpacing,
                textColor: isSelectedTextColor,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                textDecoration: isUnderline
                    ? TextDecoration.underline
                    : TextDecoration.none,
                textAlign: textAlign,

              ),
            ),
            // Editor tool --------------------
            Padding(
              padding: const EdgeInsets.only(right: 20, left: 20, bottom: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    EditTextBottonWidget(
                      icon: Icons.format_color_fill,
                      text: 'Background',
                      onTap: () {
                        _openBackgroundBottomSheet();
                      },
                    ),

                    ///background
                    EditTextBottonWidget(
                      icon: Icons.text_fields,
                      text: "Size",
                      onTap: () {
                        setState(() {
                          _openTextSizeBottomSheet();
                        });
                      },
                    ),

                    ///text size
                    EditTextBottonWidget(
                      icon: Icons.text_format, //Font Size
                      text: "Font",
                      onTap: () {
                        setState(() {
                          _openFontFamilyBottomSheet();
                        });
                      },
                    ),

                    ///Font Family
                    EditTextBottonWidget(
                      icon: Icons.color_lens_outlined,
                      text: "Color",
                      onTap: () {
                        _openTextColorBottomSheet();
                      },
                    ),

                    ///Text Color
                    EditTextBottonWidget(
                      icon: Icons.border_style,
                      text: "Border",
                      onTap: () {
                        _openBorderBottomSheet();
                      },
                    ),

                    ///Border
                    EditTextBottonWidget(
                      icon: Icons.wb_shade,
                      text: "Shadow",
                      onTap: (){
                        _openShadowBottomSheet();
                      },
                    ), // shadow
                    EditTextBottonWidget(
                      icon: Icons.gradient,
                      text: "Gradient",
                    ), //Gradient
                    EditTextBottonWidget(
                      icon: Icons.opacity,
                      text: "Opacity",
                    ), //Opacity
                    EditTextBottonWidget(
                      icon: Icons.padding,
                      text: "Padding",
                    ), //Padding
                    EditTextBottonWidget(icon: Icons.crop, text: "Crop"), //crop
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
