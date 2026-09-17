import 'package:flutter/material.dart';

class CostumeCardWidget extends StatelessWidget {
  final Color color;
  final Widget child;
  final IconData? icon;
  final VoidCallback? onTap;

  const CostumeCardWidget({
    super.key,
    required this.color,
    required this.child,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              child,

              if (icon != null)
                Icon(icon),
            ],
          ),
        ),
      ),
    );
  }
}