import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AspectRatioOption {
  final String label;
  final double ratio;
  final IconData icon;

  const AspectRatioOption({
    required this.label,
    required this.ratio,
    required this.icon,
  });
}

class PickupLineMakerController extends GetxController {
  static PickupLineMakerController get to =>
      Get.find<PickupLineMakerController>();

  // ====================
  //  Text State
  // ====================
  final RxString text = ''.obs;
  final RxDouble fontSize = 24.0.obs;
  final RxDouble vSpacing = 0.0.obs;
  final RxDouble textSpacing = 0.0.obs;
  final RxBool isBold = false.obs;
  final RxBool isItalic = false.obs;
  final RxBool isUnderline = false.obs;
  final Rx<TextAlign> textAlign = TextAlign.center.obs;
  final RxInt textCaseIndex = 0.obs; // 0: original, 1: UPPERCASE, 2: lowercase
  String _originalCaseText = '';

  // ====================
  //  Background State
  // ====================
  final Rx<Color> selectedColor = Colors.white.obs;
  final Rxn<Gradient> selectedGradient = Rxn<Gradient>();
  final Rxn<File> selectedGalleryImage = Rxn<File>();
  final RxnString selectedBackgroundImagePath = RxnString();

  // ====================
  //  Font & Color
  // ====================
  final RxString selectedFontFamily = 'Roboto'.obs;
  final Rx<Color> isSelectedTextColor = Colors.black.obs;

  // ====================
  //  Border
  // ====================
  final RxBool hasBorder = false.obs;
  final Rx<Color> borderColor = Colors.yellow.obs;
  final RxDouble borderWidth = 3.0.obs;

  // ====================
  //  Shadow
  // ====================
  final RxBool hasShadow = false.obs;
  final Rx<Color> selectedShadowColor = Colors.black.obs;
  final RxDouble shadowOffsetX = 2.0.obs;
  final RxDouble shadowOffsetY = 2.0.obs;
  final RxDouble shadowBlur = 8.0.obs;

  // ====================
  //  Opacity & Padding
  // ====================
  final RxDouble selectedOpacity = 1.0.obs;
  final RxDouble topPadding = 20.0.obs;
  final RxDouble bottomPadding = 20.0.obs;
  final RxDouble leftPadding = 20.0.obs;
  final RxDouble rightPadding = 20.0.obs;

  // ====================
  //  Crop / Aspect Ratio
  // ====================
  final RxDouble cardAspectRatio = 0.0.obs; // 0.0 = free / auto

  // ====================
  //  Status
  // ====================
  final RxBool isDownloading = false.obs;

  // ====================
  //  Presets and Palettes
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

  final List<LinearGradient> gradientList = const [
    LinearGradient(colors: [Colors.pink, Colors.purple]),
    LinearGradient(colors: [Colors.blue, Colors.cyan]),
    LinearGradient(colors: [Colors.orange, Colors.red]),
    LinearGradient(colors: [Colors.green, Colors.teal]),
    LinearGradient(colors: [Colors.indigo, Colors.purple]),
    LinearGradient(colors: [Colors.pinkAccent, Colors.orange]),
    LinearGradient(colors: [Colors.deepPurple, Colors.blue]),
    LinearGradient(colors: [Colors.redAccent, Colors.pink]),
    LinearGradient(colors: [Colors.cyan, Colors.green]),
    LinearGradient(colors: [Colors.amber, Colors.orange]),
    LinearGradient(colors: [Colors.blueAccent, Colors.indigo]),
    LinearGradient(colors: [Colors.purpleAccent, Colors.pinkAccent]),
  ];

  final List<LinearGradient> presetPlaceholders = const [
    LinearGradient(
      colors: [Color(0xFFf8b4c8), Color(0xFFd88ae5)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF84c5f4), Color(0xFF5e9cf3)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFffd580), Color(0xFFff9f43)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF55efc4), Color(0xFF00b894)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFfd79a8), Color(0xFFe84393)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFa29bfe), Color(0xFF6c5ce7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  final List<String> fontFamilyList = const [
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

  final List<AspectRatioOption> aspectRatioOptions = const [
    AspectRatioOption(label: 'Auto', ratio: 0.0, icon: Icons.crop_free),
    AspectRatioOption(label: '1:1 Square', ratio: 1.0, icon: Icons.crop_square),
    AspectRatioOption(label: '4:5 Portrait', ratio: 0.8, icon: Icons.crop_portrait),
    AspectRatioOption(label: '9:16 Story', ratio: 9 / 16, icon: Icons.crop_portrait),
    AspectRatioOption(label: '16:9 Banner', ratio: 16 / 9, icon: Icons.crop_16_9),
  ];

  // ====================
  //  Actions
  // ====================

  void initText(String? initial) {
    final value = initial ?? '';
    text.value = value;
    _originalCaseText = value;
    textCaseIndex.value = 0;
  }

  void updateText(String newText) {
    text.value = newText;
    if (textCaseIndex.value == 0) {
      _originalCaseText = newText;
    }
  }

  void setFontSize(double size) => fontSize.value = size;
  void setLineSpacing(double spacing) => vSpacing.value = spacing;
  void setTextSpacing(double spacing) => textSpacing.value = spacing;

  void toggleBold() => isBold.value = !isBold.value;
  void toggleItalic() => isItalic.value = !isItalic.value;
  void toggleUnderline() => isUnderline.value = !isUnderline.value;

  void cycleTextCase(TextEditingController textCtrl) {
    textCaseIndex.value = (textCaseIndex.value + 1) % 3;
    if (textCaseIndex.value == 0) {
      text.value = _originalCaseText;
      textCtrl.text = _originalCaseText;
    } else if (textCaseIndex.value == 1) {
      final upper = text.value.toUpperCase();
      text.value = upper;
      textCtrl.text = upper;
    } else {
      final lower = text.value.toLowerCase();
      text.value = lower;
      textCtrl.text = lower;
    }
    textCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: textCtrl.text.length),
    );
  }

  void cycleTextAlign() {
    if (textAlign.value == TextAlign.center) {
      textAlign.value = TextAlign.left;
    } else if (textAlign.value == TextAlign.left) {
      textAlign.value = TextAlign.right;
    } else {
      textAlign.value = TextAlign.center;
    }
  }

  void setBackgroundColor(Color color) {
    selectedColor.value = color;
    selectedGradient.value = null;
    selectedGalleryImage.value = null;
    selectedBackgroundImagePath.value = null;
  }

  void setGradient(Gradient? gradient) {
    selectedGradient.value = gradient;
    selectedColor.value = Colors.white;
    selectedGalleryImage.value = null;
    selectedBackgroundImagePath.value = null;
  }

  void setGalleryImage(File? file) {
    selectedGalleryImage.value = file;
    selectedGradient.value = null;
    selectedBackgroundImagePath.value = null;
  }

  void setPreset(LinearGradient gradient, String presetId) {
    selectedGradient.value = gradient;
    selectedColor.value = Colors.white;
    selectedGalleryImage.value = null;
    selectedBackgroundImagePath.value = presetId;
  }

  void removeBackground() {
    selectedColor.value = Colors.white;
    selectedGradient.value = null;
    selectedGalleryImage.value = null;
    selectedBackgroundImagePath.value = null;
  }

  void setFontFamily(String font) => selectedFontFamily.value = font;
  void setTextColor(Color color) => isSelectedTextColor.value = color;

  void setBorder({required bool enabled, Color? color, double? width}) {
    hasBorder.value = enabled;
    if (color != null) borderColor.value = color;
    if (width != null) borderWidth.value = width;
  }

  void setBorderWidth(double width) => borderWidth.value = width;

  void setShadow({
    required bool enabled,
    Color? color,
    double? dx,
    double? dy,
    double? blur,
  }) {
    hasShadow.value = enabled;
    if (color != null) selectedShadowColor.value = color;
    if (dx != null) shadowOffsetX.value = dx;
    if (dy != null) shadowOffsetY.value = dy;
    if (blur != null) shadowBlur.value = blur;
  }

  void setShadowOffset({double? dx, double? dy}) {
    if (dx != null) shadowOffsetX.value = dx;
    if (dy != null) shadowOffsetY.value = dy;
  }

  void setShadowBlur(double blur) => shadowBlur.value = blur;

  void setOpacity(double opacity) => selectedOpacity.value = opacity;

  void setPadding({double? top, double? bottom, double? left, double? right}) {
    if (top != null) topPadding.value = top;
    if (bottom != null) bottomPadding.value = bottom;
    if (left != null) leftPadding.value = left;
    if (right != null) rightPadding.value = right;
  }

  void setAspectRatio(double ratio) => cardAspectRatio.value = ratio;

  void setDownloading(bool downloading) => isDownloading.value = downloading;
}
