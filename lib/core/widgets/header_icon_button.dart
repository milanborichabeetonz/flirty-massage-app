import 'package:flutter/material.dart';

class HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double? iconSize;
  final Color iconColor;

  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconSize = 30,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: onPressed,
        icon: Icon(icon,
        size: iconSize,
        color: iconColor,),
    );
  }
}
