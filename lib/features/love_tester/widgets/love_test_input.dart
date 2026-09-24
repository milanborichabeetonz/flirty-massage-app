import 'package:flutter/material.dart';

class LoveTextInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  static const Color _purple = Color(0xFF7C3AED);

  const LoveTextInputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _purple),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
      ),
    );
  }
}

class LoveTestMultilineField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const LoveTestMultilineField({
    super.key,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }
}

class LoveTestDatePickerTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  static const Color _purple = Color(0xFF7C3AED);

  const LoveTestDatePickerTile({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: _purple, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date == null
                    ? label
                    : '${date!.day}/${date!.month}/${date!.year}',
                style: TextStyle(
                  color: date == null ? Colors.grey : Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
