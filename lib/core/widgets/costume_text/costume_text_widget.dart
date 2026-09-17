import 'package:flutter/material.dart';

class CostumeTextWidget extends StatelessWidget {
  final String text;
  final Color color;
  final EdgeInsets padding;
  final double size;
  final FontWeight? fontWeight;

  const CostumeTextWidget({
    super.key,
    required this.text,
    required this.color,
    required this.size,
    this.padding = EdgeInsets.zero,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: size, fontWeight: fontWeight),
      ),
    );
  }
}
