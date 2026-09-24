import 'dart:io';

import 'package:flirtymessages/core/services/image_download_service.dart';
import 'package:flirtymessages/core/widgets/costume_text/costume_text_widget.dart';
import 'package:flirtymessages/core/widgets/custom_button_widget.dart';
import 'package:flirtymessages/core/widgets/edit_text_botton_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/line_text_maker_widget/pickup_line_preview_widget.dart';

class PickupLineMakerScreen extends StatefulWidget {
  const PickupLineMakerScreen({super.key, this.initialText});

  final String? initialText;

  @override
  State<PickupLineMakerScreen> createState() => _PickupLineMakerScreenState();
}

class _PickupLineMakerScreenState extends State<PickupLineMakerScreen> {
  // ====================
  //  Preview key for screenshot
  // ====================
  final GlobalKey _previewKey = GlobalKey();

  bool _isDownloading = false;

  // ====================
  //  Text controller
  // ====================
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _textController.text = widget.initialText!;
    }
  }

  // ====================
  //  Text styling
  // ====================
  double fontSize = 25;
  double vSpacing = 0.0;
  double textSpacing = 0.0;
  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;
  TextAlign textAlign = TextAlign.center;
  int textCaseIndex = 0;

  // ====================
  //  Background
  // ====================
  Color selectedColor = Colors.white;
  Gradient? selectedGradient;
  File? selectedGalleryImage;
  String? selectedBackgroundImagePath;

  // ====================
  //  Font
  // ====================
  String selectedFontFamily = 'Roboto';

  // ====================
  //  Text color
  // ====================
  Color isSelectedTextColor = Colors.black;

  // ====================
  //  Border
  // ====================
  bool hasBorder = false;
  Color borderColor = Colors.transparent;
  double borderWidth = 3.0;

  // ====================
  //  Shadow
  // ====================
  bool hasShadow = false;
  Color selectedShadowColor = Colors.black;
  double shadowOffsetX = 2.0;
  double shadowOffsetY = 2.0;
  double shadowBlur = 8.0;

  // ====================
  //  Opacity
  // ====================
  double selectedOpacity = 1.0;

  // ====================
  //  Padding (4 independent)
  // ====================
  double topPadding = 20.0;
  double bottomPadding = 20.0;
  double leftPadding = 20.0;
  double rightPadding = 20.0;

  // ====================
  //  Color lists
  // ====================
  final List<Color> bgColor = [
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

  final List<Color> textColor = [
    Colors.white,
    Colors.black,
    Colors.pink.shade100,
    Colors.purple.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.amber.shade100,
    Colors.red.shade100,
    Colors.teal.shade100,
    Colors.black87,
  ];

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

  final List<LinearGradient> gradientList = [
    const LinearGradient(colors: [Colors.pink, Colors.purple]),
    const LinearGradient(colors: [Colors.blue, Colors.cyan]),
    const LinearGradient(colors: [Colors.orange, Colors.red]),
    const LinearGradient(colors: [Colors.green, Colors.teal]),
    const LinearGradient(colors: [Colors.indigo, Colors.purple]),
    const LinearGradient(colors: [Colors.pinkAccent, Colors.orange]),
    const LinearGradient(colors: [Colors.deepPurple, Colors.blue]),
    const LinearGradient(colors: [Colors.redAccent, Colors.pink]),
    const LinearGradient(colors: [Colors.cyan, Colors.green]),
    const LinearGradient(colors: [Colors.amber, Colors.orange]),
    const LinearGradient(colors: [Colors.blueAccent, Colors.indigo]),
    const LinearGradient(colors: [Colors.purpleAccent, Colors.pinkAccent]),
  ];

  /// Preset gradient placeholders (no asset images available)
  final List<LinearGradient> presetPlaceholders = [
    const LinearGradient(
        colors: [Color(0xFFf8b4c8), Color(0xFFd88ae5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
    const LinearGradient(
        colors: [Color(0xFF84c5f4), Color(0xFF5e9cf3)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
    const LinearGradient(
        colors: [Color(0xFFffd580), Color(0xFFff9f43)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
    const LinearGradient(
        colors: [Color(0xFF55efc4), Color(0xFF00b894)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
    const LinearGradient(
        colors: [Color(0xFFfd79a8), Color(0xFFe84393)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
    const LinearGradient(
        colors: [Color(0xFFa29bfe), Color(0xFF6c5ce7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
  ];

  // ============================================================
  //  A. BACKGROUND BOTTOM SHEET
  // ============================================================
  void _openBackgroundBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: 480,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Icon(Icons.close, size: 28),
                      ),
                      const Text(
                        "Background",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Icon(Icons.check, size: 28),
                      ),
                    ],
                  ),

                  // Section 1 — Color row
                  const Padding(
                    padding: EdgeInsets.only(left: 16, bottom: 6),
                    child: Text("Colors",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                  SizedBox(
                    height: 54,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: bgColor.length,
                      itemBuilder: (context, index) {
                        final color = bgColor[index];
                        final isSelected = selectedGalleryImage == null &&
                            selectedBackgroundImagePath == null &&
                            selectedGradient == null &&
                            selectedColor == color;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = color;
                              selectedGradient = null;
                              selectedGalleryImage = null;
                              selectedBackgroundImagePath = null;
                            });
                            setSheetState(() {});
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 46,
                            height: 46,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: Colors.deepPurple, width: 3)
                                  : Border.all(
                                      color: Colors.grey.shade300, width: 1),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Section 2 — Action buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Choose Photo
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.photo_library_outlined,
                                size: 20),
                            label: const Text("Choose Photo"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.deepPurple,
                              side: const BorderSide(
                                  color: Colors.deepPurple, width: 1.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? picked = await picker.pickImage(
                                  source: ImageSource.gallery);
                              if (picked != null) {
                                setState(() {
                                  selectedGalleryImage = File(picked.path);
                                  selectedGradient = null;
                                  selectedBackgroundImagePath = null;
                                });
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Remove Background
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.format_color_reset_outlined,
                                size: 20),
                            label: const Text("Remove BG"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(
                                  color: Colors.redAccent, width: 1.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              setState(() {
                                selectedColor = Colors.white;
                                selectedGradient = null;
                                selectedGalleryImage = null;
                                selectedBackgroundImagePath = null;
                              });
                              setSheetState(() {});
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Section 3 — Preset placeholders grid
                  const Padding(
                    padding: EdgeInsets.only(left: 16, bottom: 6),
                    child: Text("Presets",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.6,
                        ),
                        itemCount: presetPlaceholders.length,
                        itemBuilder: (context, index) {
                          final gradient = presetPlaceholders[index];
                          final isSelected =
                              selectedBackgroundImagePath == 'preset_$index';
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                // Use gradient as preset background
                                selectedGradient = gradient;
                                selectedColor = Colors.white;
                                selectedGalleryImage = null;
                                selectedBackgroundImagePath = 'preset_$index';
                              });
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: gradient,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                        color: Colors.deepPurple, width: 3)
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  //  TEXT SIZE BOTTOM SHEET (unchanged logic)
  // ============================================================
  void _openTextSizeBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: 380,
              decoration: const BoxDecoration(
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
                        onPressed: () => Navigator.pop(context),
                        child: const Icon(Icons.close, size: 30),
                      ),
                      CostumeTextWidget(
                        text: "Text Size",
                        color: Colors.black,
                        size: 15,
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Icon(Icons.check, size: 30),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(Icons.text_fields, size: 30),
                      Slider(
                        value: fontSize,
                        min: 12,
                        max: 60,
                        onChanged: (value) {
                          setState(() => fontSize = value);
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
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(Icons.format_line_spacing, size: 30),
                      Slider(
                        value: vSpacing,
                        min: 0.0,
                        max: 4,
                        onChanged: (value) {
                          setState(() => vSpacing = value);
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
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(Icons.space_bar, size: 30),
                      Slider(
                        value: textSpacing,
                        min: 0,
                        max: 80,
                        onChanged: (value) {
                          setState(() => textSpacing = value);
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
                          setState(() => isBold = !isBold);
                          setSheetState(() {});
                        },
                        backgroundColor:
                            isBold ? Colors.deepPurple : Colors.grey.shade200,
                        child: Icon(
                          Icons.format_bold,
                          color: isBold ? Colors.white : Colors.black87,
                        ),
                      ),
                      CustomButtonWidget(
                        onPressed: () {
                          setState(() => isItalic = !isItalic);
                          setSheetState(() {});
                        },
                        backgroundColor:
                            isItalic ? Colors.deepPurple : Colors.grey.shade200,
                        child: Icon(
                          Icons.format_italic,
                          color: isItalic ? Colors.white : Colors.black87,
                        ),
                      ),
                      CustomButtonWidget(
                        onPressed: () {
                          setState(() => isUnderline = !isUnderline);
                          setSheetState(() {});
                        },
                        backgroundColor: isUnderline
                            ? Colors.deepPurple
                            : Colors.grey.shade200,
                        child: Icon(
                          Icons.format_underline,
                          color: isUnderline ? Colors.white : Colors.black87,
                        ),
                      ),
                      CustomButtonWidget(
                        onPressed: () {
                          setState(() {
                            textCaseIndex = (textCaseIndex + 1) % 3;
                          });
                          final currentText = _textController.text;
                          if (textCaseIndex == 1) {
                            _textController.text = currentText.toUpperCase();
                          } else if (textCaseIndex == 2) {
                            _textController.text = currentText.toLowerCase();
                          }
                          _textController.selection =
                              TextSelection.fromPosition(
                            TextPosition(offset: _textController.text.length),
                          );
                          setSheetState(() {});
                        },
                        backgroundColor: textCaseIndex != 0
                            ? Colors.deepPurple
                            : Colors.grey.shade200,
                        child:
                            const Icon(Icons.abc, color: Colors.black87),
                      ),
                      CustomButtonWidget(
                        onPressed: () {
                          setState(() {
                            if (textAlign == TextAlign.center) {
                              textAlign = TextAlign.left;
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
                        child: const Icon(
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

  // ============================================================
  //  FONT FAMILY BOTTOM SHEET (unchanged)
  // ============================================================
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

  void _openFontFamilyBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 400,
          decoration: const BoxDecoration(
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
                      onPressed: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 30),
                    ),
                    CostumeTextWidget(
                      text: "Choose Font Style",
                      color: Colors.black,
                      size: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Icon(Icons.check, size: 30),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: fontFamilyList.length,
                    itemBuilder: (context, index) {
                      final fonts = fontFamilyList[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedFontFamily = fonts);
                          Navigator.pop(context);
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

  // ============================================================
  //  TEXT COLOR BOTTOM SHEET (unchanged)
  // ============================================================
  void _openTextColorBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          decoration: const BoxDecoration(
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
                      onPressed: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 30),
                    ),
                    CostumeTextWidget(
                      text: "Choose Text Color",
                      color: Colors.black,
                      size: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Icon(Icons.check, size: 30),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: textColor.length,
                    itemBuilder: (context, index) {
                      final color = textColor[index];
                      final isSelected = isSelectedTextColor == color;
                      return GestureDetector(
                        onTap: () {
                          setState(() => isSelectedTextColor = color);
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(50),
                            border: isSelected
                                ? Border.all(
                                    color: Colors.deepPurple, width: 3)
                                : Border.all(
                                    color: Colors.grey.shade300, width: 1),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  //  B. BORDER BOTTOM SHEET (unchanged)
  // ============================================================
  void _openBorderBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: 220,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Icon(Icons.close, size: 28),
                      ),
                      const Text(
                        "Text Border",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {});
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.check, size: 28),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 55,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: borderColorList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return GestureDetector(
                            onTap: () {
                              setState(() => hasBorder = false);
                              setSheetState(() {});
                            },
                            child: Container(
                              width: 45,
                              height: 45,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.colorize, size: 22),
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
                            margin:
                                const EdgeInsets.symmetric(horizontal: 5),
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
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      const Icon(Icons.water_drop_outlined, size: 28),
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
                        style:
                            const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 15),
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

  // ============================================================
  //  SHADOW BOTTOM SHEET (unchanged)
  // ============================================================
  void _openShadowBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SizedBox(
              height: 290,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 30),
                      ),
                      const Text(
                        "Shadow",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {});
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.check, size: 30),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 12),
                      const Text("X",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Slider(
                          value: shadowOffsetX,
                          min: -20.0,
                          max: 20.0,
                          activeColor: Colors.deepPurple,
                          onChanged: (value) {
                            setState(() => shadowOffsetX = value);
                            setSheetState(() {});
                          },
                        ),
                      ),
                      const Text("Y",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Slider(
                          value: shadowOffsetY,
                          min: -20.0,
                          max: 20.0,
                          activeColor: Colors.deepPurple,
                          onChanged: (value) {
                            setState(() => shadowOffsetY = value);
                            setSheetState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 12),
                      const Icon(Icons.format_color_fill_outlined, size: 26),
                      Expanded(
                        child: Slider(
                          value: shadowBlur,
                          min: 0.0,
                          max: 30.0,
                          activeColor: Colors.deepPurple,
                          onChanged: (value) {
                            setState(() => shadowBlur = value);
                            setSheetState(() {});
                          },
                        ),
                      ),
                      Text(
                        shadowBlur.toInt().toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: borderColorList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return GestureDetector(
                            onTap: () {
                              setState(() => hasShadow = false);
                              setSheetState(() {});
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.grey.shade200,
                                border: !hasShadow
                                    ? Border.all(
                                        color: Colors.deepPurple, width: 3)
                                    : null,
                              ),
                              child: const Icon(Icons.colorize, size: 22),
                            ),
                          );
                        }
                        final shadowColor = borderColorList[index - 1];
                        final isSelected =
                            hasShadow && selectedShadowColor == shadowColor;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              hasShadow = true;
                              selectedShadowColor = shadowColor;
                            });
                            setSheetState(() {});
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: shadowColor,
                              border: isSelected
                                  ? Border.all(
                                      color: Colors.deepPurple, width: 3)
                                  : null,
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
      },
    );
  }

  // ============================================================
  //  B. GRADIENT BOTTOM SHEET — fixed layout (SizedBox not Expanded)
  // ============================================================
  void _openGradientBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 450,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 30),
                  ),
                  CostumeTextWidget(
                    text: "Choose Gradient",
                    color: Colors.black,
                    size: 15,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check, size: 30),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: gradientList.length,
                    itemBuilder: (context, index) {
                      final gradient = gradientList[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedGradient = gradient;
                            selectedColor = Colors.white;
                            selectedGalleryImage = null;
                            selectedBackgroundImagePath = null;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: gradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  //  OPACITY BOTTOM SHEET (unchanged)
  // ============================================================
  void _openOpacityBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: 200,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Icon(Icons.close, size: 28),
                      ),
                      const Text(
                        "Background Opacity",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {});
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.check, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      const Icon(Icons.opacity, size: 28),
                      Expanded(
                        child: Slider(
                          value: selectedOpacity,
                          min: 0.1,
                          max: 1.0,
                          activeColor: Colors.deepPurple,
                          onChanged: (value) {
                            setState(() => selectedOpacity = value);
                            setSheetState(() {});
                          },
                        ),
                      ),
                      Text(
                        '${(selectedOpacity * 100).toInt()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 15),
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

  // ============================================================
  //  C. PADDING BOTTOM SHEET — 4 independent sliders
  // ============================================================
  void _openPaddingBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: 380,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Icon(Icons.close, size: 28),
                      ),
                      const Text(
                        "Content Padding",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {});
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.check, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Top
                  _buildPaddingRow(
                    label: "Top",
                    value: topPadding,
                    onChanged: (v) {
                      setState(() => topPadding = v);
                      setSheetState(() {});
                    },
                  ),
                  // Bottom
                  _buildPaddingRow(
                    label: "Bot",
                    value: bottomPadding,
                    onChanged: (v) {
                      setState(() => bottomPadding = v);
                      setSheetState(() {});
                    },
                  ),
                  // Left
                  _buildPaddingRow(
                    label: "Left",
                    value: leftPadding,
                    onChanged: (v) {
                      setState(() => leftPadding = v);
                      setSheetState(() {});
                    },
                  ),
                  // Right
                  _buildPaddingRow(
                    label: "Right",
                    value: rightPadding,
                    onChanged: (v) {
                      setState(() => rightPadding = v);
                      setSheetState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaddingRow({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        const SizedBox(width: 10),
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0.0,
            max: 80.0,
            activeColor: Colors.deepPurple,
            onChanged: onChanged,
          ),
        ),
        Text(
          value.toInt().toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 15),
      ],
    );
  }

  // ============================================================
  //  CROP BOTTOM SHEET (unchanged)
  // ============================================================
  void _openCropBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 28),
                  ),
                  const Text(
                    "Crop",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 20),
              CostumeTextWidget(
                text: "Crop feature coming soon",
                color: Colors.black54,
                size: 16,
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  //  E. DOWNLOAD — Format picker + gallery save (via service)
  // ============================================================
  Future<void> _onDownloadTapped() async {
    if (_isDownloading) return;
    FocusScope.of(context).unfocus();
    final format = await _showFormatPicker();
    if (format == null || !mounted) return;
    await _executeDownload(format);
  }

  Future<ImageExportFormat?> _showFormatPicker() {
    return showModalBottomSheet<ImageExportFormat>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                const Text(
                  'Choose Image Format',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _FormatTile(
                        title: 'PNG',
                        subtitle: 'Lossless, supports transparency',
                        icon: Icons.image_outlined,
                        onTap: () => Navigator.pop(
                            context, ImageExportFormat.png),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FormatTile(
                        title: 'JPEG',
                        subtitle: 'Smaller file, great quality',
                        icon: Icons.photo_outlined,
                        onTap: () => Navigator.pop(
                            context, ImageExportFormat.jpeg),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _executeDownload(ImageExportFormat format) async {
    setState(() => _isDownloading = true);
    try {
      final result = await ImageDownloadService.downloadCard(
        _previewKey,
        format: format,
      );
      if (!mounted) return;
      final message = result.success
          ? 'Saved to Gallery'
          : (result.userMessage ?? 'Unable to save image');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(
                result.success
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: result.success
              ? const Color(0xFF10B981)
              : const Color(0xFFEF4444),
        ),
      );
    } catch (e) {
      debugPrint('[PickupLineMaker] Download error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFFEF4444),
            content: Row(
              children: [
                Icon(Icons.error_outline,
                    color: Colors.white, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('Unable to save image')),
              ],
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  // ============================================================
  //  Dispose
  // ============================================================
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // ============================================================
  //  BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pickup Line Maker"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: _isDownloading ? null : _onDownloadTapped,
              icon: _isDownloading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF7C3AED)),
                      ),
                    )
                  : const Icon(Icons.download, size: 30),
              tooltip: _isDownloading ? 'Downloading...' : 'Download',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // F. Preview widget with all new params
            Expanded(
              child: RepaintBoundary(
                key: _previewKey,
                child: PickupLinePreviewWidget(
                controller: _textController,
                backgroundColor: selectedColor,
                gradientBackground: selectedGradient,
                galleryImage: selectedGalleryImage,
                presetImagePath: selectedBackgroundImagePath != null &&
                        !selectedBackgroundImagePath!.startsWith('preset_')
                    ? selectedBackgroundImagePath
                    : null,
                previewPadding: EdgeInsets.only(
                  top: topPadding,
                  bottom: bottomPadding,
                  left: leftPadding,
                  right: rightPadding,
                ),
                fontSize: fontSize,
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
                hasBorder: hasBorder,
                borderColor: borderColor,
                borderWidth: borderWidth,
                hasShadow: hasShadow,
                shadowColor: selectedShadowColor,
                shadowOffsetX: shadowOffsetX,
                shadowOffsetY: shadowOffsetY,
                shadowBlur: shadowBlur,
                backgroundOpacity: selectedOpacity,
              ),
            ),
            ),

            // Editor tool bar
            Padding(
              padding:
                  const EdgeInsets.only(right: 20, left: 20, bottom: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    EditTextBottonWidget(
                      icon: Icons.format_color_fill,
                      text: 'Background',
                      onTap: _openBackgroundBottomSheet,
                    ),
                    EditTextBottonWidget(
                      icon: Icons.text_fields,
                      text: "Size",
                      onTap: _openTextSizeBottomSheet,
                    ),
                    EditTextBottonWidget(
                      icon: Icons.text_format,
                      text: "Font",
                      onTap: _openFontFamilyBottomSheet,
                    ),
                    EditTextBottonWidget(
                      icon: Icons.color_lens_outlined,
                      text: "Color",
                      onTap: _openTextColorBottomSheet,
                    ),
                    EditTextBottonWidget(
                      icon: Icons.border_style,
                      text: "Border",
                      onTap: _openBorderBottomSheet,
                    ),
                    EditTextBottonWidget(
                      icon: Icons.wb_shade,
                      text: "Shadow",
                      onTap: _openShadowBottomSheet,
                    ),
                    EditTextBottonWidget(
                      icon: Icons.gradient,
                      text: "Gradient",
                      onTap: _openGradientBottomSheet,
                    ),
                    EditTextBottonWidget(
                      icon: Icons.opacity,
                      text: "Opacity",
                      onTap: _openOpacityBottomSheet,
                    ),
                    EditTextBottonWidget(
                      icon: Icons.padding,
                      text: "Padding",
                      onTap: _openPaddingBottomSheet,
                    ),
                    EditTextBottonWidget(
                      icon: Icons.crop,
                      text: "Crop",
                      onTap: _openCropBottomSheet,
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

class _FormatTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _FormatTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7C3AED);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: purple.withValues(alpha: 0.2), width: 1.2),
            color: purple.withValues(alpha: 0.04),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: purple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: purple, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF666666),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
