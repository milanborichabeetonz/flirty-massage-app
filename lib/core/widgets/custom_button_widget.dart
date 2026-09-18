import 'package:flutter/material.dart';

class CustomButtonWidget extends StatelessWidget {
   final VoidCallback onPressed;
   final Color? backgroundColor;
   final Widget child;

  const CustomButtonWidget({super.key,
  required this.onPressed,
    this.backgroundColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.blue.withOpacity(0.3),
              shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(20),
        )
        ),
        child: child);
  }
}
