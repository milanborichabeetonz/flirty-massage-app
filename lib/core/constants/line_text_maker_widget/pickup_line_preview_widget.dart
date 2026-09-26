import 'dart:io';

import 'package:flutter/material.dart';

class PickupLinePreviewWidget extends StatelessWidget {
  final Color backgroundColor;
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
  final Gradient? gradientBackground;

  // Shadow support
  final bool hasShadow;
  final Color shadowColor;
  final double shadowOffsetX;
  final double shadowOffsetY;
  final double shadowBlur;

  // Opacity support
  final double backgroundOpacity;

  // Inner content padding
  final EdgeInsets previewPadding;

  // Background image support
  final File? galleryImage;
  final String? presetImagePath;

  const PickupLinePreviewWidget({
    super.key,
    this.backgroundColor = Colors.white,
    this.fontSize = 24,
    this.latterSpacing = 0.0,
    this.lineHeight = 0.0,
    this.fontFamily = 'Roboto',
    this.textColor = Colors.black,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.center,
    this.fontStyle = FontStyle.normal,
    this.textDecoration = TextDecoration.none,
    this.controller,
    this.hasBorder = false,
    this.borderColor = Colors.yellow,
    this.borderWidth = 3.0,
    this.gradientBackground,
    this.hasShadow = false,
    this.shadowColor = Colors.black,
    this.shadowOffsetX = 2.0,
    this.shadowOffsetY = 2.0,
    this.shadowBlur = 8.0,
    this.backgroundOpacity = 1.0,
    this.previewPadding = const EdgeInsets.all(20.0),
    this.galleryImage,
    this.presetImagePath,
  });

  DecorationImage? _resolveDecorationImage() {
    if (galleryImage != null) {
      return DecorationImage(
        image: FileImage(galleryImage!),
        fit: BoxFit.cover,
      );
    }
    if (presetImagePath != null && presetImagePath!.isNotEmpty) {
      return DecorationImage(
        image: AssetImage(presetImagePath!),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  BoxDecoration _resolveDecoration() {
    final image = _resolveDecorationImage();
    if (image != null) {
      return BoxDecoration(
        image: image,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      );
    }
    if (gradientBackground != null) {
      return BoxDecoration(
        gradient: gradientBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      );
    }
    return BoxDecoration(
      color: backgroundColor.withValues(alpha: backgroundOpacity),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: fontSize,
      height: lineHeight > 0 ? (1.0 + lineHeight * 0.3) : null,
      letterSpacing: latterSpacing > 0 ? latterSpacing : null,
      fontFamily: fontFamily,
      color: textColor,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: textDecoration,
      shadows: hasShadow
          ? [
              Shadow(
                color: shadowColor,
                blurRadius: shadowBlur,
                offset: Offset(shadowOffsetX, shadowOffsetY),
              ),
            ]
          : null,
    );

    return Container(
      decoration: _resolveDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: previewPadding,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (hasBorder && controller != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: controller!,
                        builder: (context, value, _) {
                          return Text(
                            value.text.isEmpty ? "Type Here..." : value.text,
                            textAlign: textAlign,
                            style: textStyle.copyWith(
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = borderWidth
                                ..color = borderColor,
                              color: null,
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
                textAlign: textAlign,
                textAlignVertical: TextAlignVertical.center,
                style: textStyle,
                cursorColor: textColor,
                decoration: const InputDecoration(
                  hintText: "Type Here...",
                  hintStyle: TextStyle(fontSize: 20, color: Colors.black38),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
