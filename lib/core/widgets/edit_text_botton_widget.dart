import 'package:flutter/material.dart';

class EditTextBottonWidget extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isSelected;

  const EditTextBottonWidget({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor =
        isSelected ? const Color(0xFF7C3AED) : const Color(0xFF374151);
    final bgColor = isSelected
        ? const Color(0xFF7C3AED).withValues(alpha: 0.08)
        : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 76,
          height: 72,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              width: isSelected ? 2 : 1,
              color: isSelected
                  ? const Color(0xFF7C3AED)
                  : const Color(0xFFE5E7EB),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: activeColor,
                size: 24,
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: activeColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
