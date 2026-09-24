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

  // New: independent padding (replaces contentPadding)
  final EdgeInsets previewPadding;

  // New: background image support
  final File? galleryImage;
  final String? presetImagePath;

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
    if (presetImagePath != null) {
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
        borderRadius: BorderRadius.circular(12),
      );
    }
    if (gradientBackground != null) {
      return BoxDecoration(
        gradient: gradientBackground,
        borderRadius: BorderRadius.circular(12),
      );
    }
    return BoxDecoration(
      color: backgroundColor.withValues(alpha: backgroundOpacity),
      borderRadius: BorderRadius.circular(12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Padding(
        padding: previewPadding,
        child: Container(
          decoration: _resolveDecoration(),
          child: Card(
            color: Colors.transparent,
            elevation: 0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
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
                            : [],
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
