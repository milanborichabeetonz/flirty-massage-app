import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../core/constants/line_text_maker_widget/pickup_line_preview_widget.dart';
import '../../core/controllers/pickup_line_maker_controller.dart';
import '../../core/services/image_download_service.dart';
import '../../core/services/pickup_line_share_service.dart';
import '../../core/widgets/costume_text/costume_text_widget.dart';
import '../../core/widgets/custom_button_widget.dart';
import '../../core/widgets/edit_text_botton_widget.dart';
import '../../core/widgets/exit_confirmation_dialog.dart';

class PickupLineMakerScreen extends StatefulWidget {
  const PickupLineMakerScreen({super.key, this.initialText});

  final String? initialText;

  @override
  State<PickupLineMakerScreen> createState() => _PickupLineMakerScreenState();
}

class _PickupLineMakerScreenState extends State<PickupLineMakerScreen> {
  final GlobalKey _previewKey = GlobalKey();
  late final TextEditingController _textController;
  late final PickupLineMakerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<PickupLineMakerController>()
        ? Get.find<PickupLineMakerController>()
        : Get.put(PickupLineMakerController());

    _controller.initText(widget.initialText);
    _textController = TextEditingController(text: _controller.text.value);
    _textController.addListener(() {
      _controller.updateText(_textController.text);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleExit() async {
    final shouldExit = await showExitConfirmationDialog(
      context: context,
      screenName: 'Pickup Line Maker',
    );
    if (shouldExit && mounted) {
      Navigator.pop(context);
    }
  }

  // ============================================================
  //  SHARE
  // ============================================================
  void _onShareTapped(Offset? tapPosition) {
    FocusScope.of(context).unfocus();
    final textToShare = _controller.text.value.trim().isEmpty
        ? 'Pickup line'
        : _controller.text.value;

    showPickupLineShareMenu(
      context: context,
      cardKey: _previewKey,
      pickupLineText: textToShare,
      tapPosition: tapPosition,
    );
  }

  // ============================================================
  //  DOWNLOAD
  // ============================================================
  Future<void> _onDownloadTapped() async {
    if (_controller.isDownloading.value) return;
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                        onTap: () => Navigator.pop(context, ImageExportFormat.png),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FormatTile(
                        title: 'JPEG',
                        subtitle: 'Smaller file, great quality',
                        icon: Icons.photo_outlined,
                        onTap: () => Navigator.pop(context, ImageExportFormat.jpeg),
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
    _controller.setDownloading(true);
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
                Icon(Icons.error_outline, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('Unable to save image')),
              ],
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        _controller.setDownloading(false);
      }
    }
  }

  // ============================================================
  //  BOTTOM SHEETS
  // ============================================================

  // 1. Background Bottom Sheet
  void _openBackgroundBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.check, size: 28),
                  ),
                ],
              ),

              // Colors
              const Padding(
                padding: EdgeInsets.only(left: 16, bottom: 6),
                child: Text(
                  "Colors",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
              SizedBox(
                height: 54,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _controller.bgColor.length,
                  itemBuilder: (context, index) {
                    final color = _controller.bgColor[index];
                    return Obx(() {
                      final isSelected =
                          _controller.selectedGalleryImage.value == null &&
                              _controller.selectedBackgroundImagePath.value == null &&
                              _controller.selectedGradient.value == null &&
                              _controller.selectedColor.value == color;
                      return GestureDetector(
                        onTap: () {
                          _controller.setBackgroundColor(color);
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
                                ? Border.all(color: Colors.deepPurple, width: 3)
                                : Border.all(color: Colors.grey.shade300, width: 1),
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Action Buttons: Choose Photo & Remove BG
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.photo_library_outlined, size: 20),
                        label: const Text("Choose Photo"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          side: const BorderSide(color: Colors.deepPurple, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? picked = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (picked != null) {
                            _controller.setGalleryImage(File(picked.path));
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.format_color_reset_outlined, size: 20),
                        label: const Text("Remove BG"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          _controller.removeBackground();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Presets
              const Padding(
                padding: EdgeInsets.only(left: 16, bottom: 6),
                child: Text(
                  "Presets",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.6,
                    ),
                    itemCount: _controller.presetPlaceholders.length,
                    itemBuilder: (context, index) {
                      final gradient = _controller.presetPlaceholders[index];
                      return Obx(() {
                        final isSelected =
                            _controller.selectedBackgroundImagePath.value == 'preset_$index';
                        return GestureDetector(
                          onTap: () {
                            _controller.setPreset(gradient, 'preset_$index');
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: gradient,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(color: Colors.deepPurple, width: 3)
                                  : null,
                            ),
                          ),
                        );
                      });
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
  }

  // 2. Text Size & Style Bottom Sheet
  void _openTextSizeBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 380,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(40),
              topLeft: Radius.circular(40),
            ),
            color: Colors.white,
          ),
          child: Obx(
            () => Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 30),
                    ),
                    const CostumeTextWidget(
                      text: "Text Size & Style",
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
                      value: _controller.fontSize.value,
                      min: 12,
                      max: 60,
                      activeColor: Colors.deepPurple,
                      onChanged: _controller.setFontSize,
                    ),
                    CostumeTextWidget(
                      text: _controller.fontSize.value.toInt().toString(),
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
                      value: _controller.vSpacing.value,
                      min: 0.0,
                      max: 4.0,
                      activeColor: Colors.deepPurple,
                      onChanged: _controller.setLineSpacing,
                    ),
                    CostumeTextWidget(
                      text: _controller.vSpacing.value.toStringAsFixed(1),
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
                      value: _controller.textSpacing.value,
                      min: 0.0,
                      max: 20.0,
                      activeColor: Colors.deepPurple,
                      onChanged: _controller.setTextSpacing,
                    ),
                    CostumeTextWidget(
                      text: _controller.textSpacing.value.toInt().toString(),
                      color: Colors.black,
                      size: 15,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButtonWidget(
                      onPressed: _controller.toggleBold,
                      backgroundColor: _controller.isBold.value
                          ? Colors.deepPurple
                          : Colors.grey.shade200,
                      child: Icon(
                        Icons.format_bold,
                        color: _controller.isBold.value
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    CustomButtonWidget(
                      onPressed: _controller.toggleItalic,
                      backgroundColor: _controller.isItalic.value
                          ? Colors.deepPurple
                          : Colors.grey.shade200,
                      child: Icon(
                        Icons.format_italic,
                        color: _controller.isItalic.value
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    CustomButtonWidget(
                      onPressed: _controller.toggleUnderline,
                      backgroundColor: _controller.isUnderline.value
                          ? Colors.deepPurple
                          : Colors.grey.shade200,
                      child: Icon(
                        Icons.format_underline,
                        color: _controller.isUnderline.value
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    CustomButtonWidget(
                      onPressed: () => _controller.cycleTextCase(_textController),
                      backgroundColor: _controller.textCaseIndex.value != 0
                          ? Colors.deepPurple
                          : Colors.grey.shade200,
                      child: Icon(
                        Icons.abc,
                        color: _controller.textCaseIndex.value != 0
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    CustomButtonWidget(
                      onPressed: _controller.cycleTextAlign,
                      backgroundColor:
                          _controller.textAlign.value != TextAlign.center
                              ? Colors.deepPurple
                              : Colors.grey.shade200,
                      child: Icon(
                        _controller.textAlign.value == TextAlign.left
                            ? Icons.format_align_left
                            : _controller.textAlign.value == TextAlign.right
                                ? Icons.format_align_right
                                : Icons.format_align_center,
                        color: _controller.textAlign.value != TextAlign.center
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 3. Font Family Bottom Sheet
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
                    const CostumeTextWidget(
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.6,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _controller.fontFamilyList.length,
                    itemBuilder: (context, index) {
                      final fonts = _controller.fontFamilyList[index];
                      return Obx(() {
                        final isSelected =
                            _controller.selectedFontFamily.value == fonts;
                        return GestureDetector(
                          onTap: () {
                            _controller.setFontFamily(fonts);
                            Navigator.pop(context);
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: isSelected
                                  ? const BorderSide(
                                      color: Colors.deepPurple, width: 2.5)
                                  : BorderSide.none,
                            ),
                            child: Center(
                              child: CostumeTextWidget(
                                text: fonts,
                                color: isSelected
                                    ? Colors.deepPurple
                                    : Colors.black87,
                                size: 16,
                                fontFamily: fonts,
                              ),
                            ),
                          ),
                        );
                      });
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

  // 4. Text Color Bottom Sheet
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
                    const CostumeTextWidget(
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: _controller.textColor.length,
                    itemBuilder: (context, index) {
                      final color = _controller.textColor[index];
                      return Obx(() {
                        final isSelected =
                            _controller.isSelectedTextColor.value == color;
                        return GestureDetector(
                          onTap: () {
                            _controller.setTextColor(color);
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.deepPurple, width: 3)
                                  : Border.all(color: Colors.grey.shade300, width: 1),
                            ),
                          ),
                        );
                      });
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

  // 5. Border Bottom Sheet
  void _openBorderBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 240,
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.check, size: 28),
                  ),
                ],
              ),
              SizedBox(
                height: 55,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: _controller.borderColorList.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Obx(() {
                        final isDisabled = !_controller.hasBorder.value;
                        return GestureDetector(
                          onTap: () => _controller.setBorder(enabled: false),
                          child: Container(
                            width: 45,
                            height: 45,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                              border: isDisabled
                                  ? Border.all(color: Colors.deepPurple, width: 3)
                                  : null,
                            ),
                            child: const Icon(Icons.format_color_reset, size: 22),
                          ),
                        );
                      });
                    }
                    final color = _controller.borderColorList[index - 1];
                    return Obx(() {
                      final isSelected = _controller.hasBorder.value &&
                          _controller.borderColor.value == color;
                      return GestureDetector(
                        onTap: () => _controller.setBorder(enabled: true, color: color),
                        child: Container(
                          width: 45,
                          height: 45,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 3)
                                : null,
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => Row(
                  children: [
                    const SizedBox(width: 15),
                    const Icon(Icons.line_weight, size: 24),
                    Expanded(
                      child: Slider(
                        value: _controller.borderWidth.value,
                        min: 1.0,
                        max: 10.0,
                        activeColor: Colors.deepPurple,
                        onChanged: (v) => _controller.setBorder(
                          enabled: true,
                          width: v,
                        ),
                      ),
                    ),
                    Text(
                      _controller.borderWidth.value.toInt().toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 15),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 6. Shadow Bottom Sheet
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
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 28),
                  ),
                  const Text(
                    "Shadow",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check, size: 28),
                  ),
                ],
              ),
              Obx(
                () => Row(
                  children: [
                    const SizedBox(width: 12),
                    const Text("X", style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Slider(
                        value: _controller.shadowOffsetX.value,
                        min: -20.0,
                        max: 20.0,
                        activeColor: Colors.deepPurple,
                        onChanged: (v) => _controller.setShadow(
                          enabled: true,
                          dx: v,
                        ),
                      ),
                    ),
                    const Text("Y", style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Slider(
                        value: _controller.shadowOffsetY.value,
                        min: -20.0,
                        max: 20.0,
                        activeColor: Colors.deepPurple,
                        onChanged: (v) => _controller.setShadow(
                          enabled: true,
                          dy: v,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
              Obx(
                () => Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.blur_on, size: 26),
                    Expanded(
                      child: Slider(
                        value: _controller.shadowBlur.value,
                        min: 0.0,
                        max: 30.0,
                        activeColor: Colors.deepPurple,
                        onChanged: (v) => _controller.setShadow(
                          enabled: true,
                          blur: v,
                        ),
                      ),
                    ),
                    Text(
                      _controller.shadowBlur.value.toInt().toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: _controller.borderColorList.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Obx(() {
                        final isDisabled = !_controller.hasShadow.value;
                        return GestureDetector(
                          onTap: () => _controller.setShadow(enabled: false),
                          child: Container(
                            height: 44,
                            width: 44,
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade200,
                              border: isDisabled
                                  ? Border.all(color: Colors.deepPurple, width: 3)
                                  : null,
                            ),
                            child: const Icon(Icons.format_color_reset, size: 20),
                          ),
                        );
                      });
                    }
                    final shadowColor = _controller.borderColorList[index - 1];
                    return Obx(() {
                      final isSelected = _controller.hasShadow.value &&
                          _controller.selectedShadowColor.value == shadowColor;
                      return GestureDetector(
                        onTap: () => _controller.setShadow(
                          enabled: true,
                          color: shadowColor,
                        ),
                        child: Container(
                          height: 44,
                          width: 44,
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: shadowColor,
                            border: isSelected
                                ? Border.all(color: Colors.deepPurple, width: 3)
                                : null,
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 7. Gradient Bottom Sheet
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
                    icon: const Icon(Icons.close, size: 28),
                  ),
                  const CostumeTextWidget(
                    text: "Choose Gradient",
                    color: Colors.black,
                    size: 15,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _controller.gradientList.length,
                    itemBuilder: (context, index) {
                      final gradient = _controller.gradientList[index];
                      return Obx(() {
                        final isSelected =
                            _controller.selectedGradient.value == gradient;
                        return GestureDetector(
                          onTap: () {
                            _controller.setGradient(gradient);
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: gradient,
                              borderRadius: BorderRadius.circular(16),
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 3.5)
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
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

  // 8. Opacity Bottom Sheet
  void _openOpacityBottomSheet() {
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.check, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Obx(
                () => Row(
                  children: [
                    const SizedBox(width: 15),
                    const Icon(Icons.opacity, size: 28),
                    Expanded(
                      child: Slider(
                        value: _controller.selectedOpacity.value,
                        min: 0.1,
                        max: 1.0,
                        activeColor: Colors.deepPurple,
                        onChanged: _controller.setOpacity,
                      ),
                    ),
                    Text(
                      '${(_controller.selectedOpacity.value * 100).toInt()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 15),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 9. Padding Bottom Sheet
  void _openPaddingBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.check, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Obx(
                () => Column(
                  children: [
                    _buildPaddingRow(
                      label: "Top",
                      value: _controller.topPadding.value,
                      onChanged: (v) => _controller.setPadding(top: v),
                    ),
                    _buildPaddingRow(
                      label: "Bot",
                      value: _controller.bottomPadding.value,
                      onChanged: (v) => _controller.setPadding(bottom: v),
                    ),
                    _buildPaddingRow(
                      label: "Left",
                      value: _controller.leftPadding.value,
                      onChanged: (v) => _controller.setPadding(left: v),
                    ),
                    _buildPaddingRow(
                      label: "Right",
                      value: _controller.rightPadding.value,
                      onChanged: (v) => _controller.setPadding(right: v),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
        const SizedBox(width: 15),
        SizedBox(
          width: 44,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0.0,
            max: 60.0,
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

  // 10. Crop / Aspect Ratio Bottom Sheet
  void _openCropBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 240,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 28),
                  ),
                  const Text(
                    "Card Aspect Ratio",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.check, size: 28),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  "Choose a shape for your card export",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 85,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _controller.aspectRatioOptions.length,
                  itemBuilder: (context, index) {
                    final opt = _controller.aspectRatioOptions[index];
                    return Obx(() {
                      final isSelected =
                          (_controller.cardAspectRatio.value == opt.ratio);
                      return GestureDetector(
                        onTap: () {
                          _controller.setAspectRatio(opt.ratio);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF7C3AED).withValues(alpha: 0.1)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF7C3AED)
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                opt.icon,
                                color: isSelected
                                    ? const Color(0xFF7C3AED)
                                    : Colors.black87,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                opt.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFF7C3AED)
                                      : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  //  BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _handleExit();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: const Color(0xFF7C3AED),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _handleExit,
          ),
          title: const Text(
            "Pickup Line Maker",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [
            GestureDetector(
              onTapDown: (details) => _onShareTapped(details.globalPosition),
              child: const IconButton(
                onPressed: null,
                icon: Icon(Icons.share_outlined, color: Colors.white, size: 24),
                tooltip: 'Share',
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Obx(
                () => IconButton(
                  onPressed: _controller.isDownloading.value
                      ? null
                      : _onDownloadTapped,
                  icon: _controller.isDownloading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.download_rounded,
                          color: Colors.white, size: 26),
                  tooltip: _controller.isDownloading.value
                      ? 'Downloading...'
                      : 'Download',
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Card preview area
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Obx(() {
                      final ratio = _controller.cardAspectRatio.value;
                      final cardWidget = RepaintBoundary(
                        key: _previewKey,
                        child: PickupLinePreviewWidget(
                          controller: _textController,
                          backgroundColor: _controller.selectedColor.value,
                          gradientBackground: _controller.selectedGradient.value,
                          galleryImage: _controller.selectedGalleryImage.value,
                          presetImagePath: _controller
                                          .selectedBackgroundImagePath.value !=
                                      null &&
                                  !_controller.selectedBackgroundImagePath.value!
                                      .startsWith('preset_')
                              ? _controller.selectedBackgroundImagePath.value
                              : null,
                          previewPadding: EdgeInsets.only(
                            top: _controller.topPadding.value,
                            bottom: _controller.bottomPadding.value,
                            left: _controller.leftPadding.value,
                            right: _controller.rightPadding.value,
                          ),
                          fontSize: _controller.fontSize.value,
                          fontFamily: _controller.selectedFontFamily.value,
                          latterSpacing: _controller.textSpacing.value,
                          lineHeight: _controller.vSpacing.value,
                          textColor: _controller.isSelectedTextColor.value,
                          fontWeight: _controller.isBold.value
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontStyle: _controller.isItalic.value
                              ? FontStyle.italic
                              : FontStyle.normal,
                          textDecoration: _controller.isUnderline.value
                              ? TextDecoration.underline
                              : TextDecoration.none,
                          textAlign: _controller.textAlign.value,
                          hasBorder: _controller.hasBorder.value,
                          borderColor: _controller.borderColor.value,
                          borderWidth: _controller.borderWidth.value,
                          hasShadow: _controller.hasShadow.value,
                          shadowColor: _controller.selectedShadowColor.value,
                          shadowOffsetX: _controller.shadowOffsetX.value,
                          shadowOffsetY: _controller.shadowOffsetY.value,
                          shadowBlur: _controller.shadowBlur.value,
                          backgroundOpacity: _controller.selectedOpacity.value,
                        ),
                      );

                      if (ratio > 0) {
                        return AspectRatio(
                          aspectRatio: ratio,
                          child: cardWidget,
                        );
                      }

                      return ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 240,
                          minWidth: double.infinity,
                        ),
                        child: cardWidget,
                      );
                    }),
                  ),
                ),
              ),

              // Editor tool bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
