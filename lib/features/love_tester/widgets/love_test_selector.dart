import 'package:flutter/material.dart';

class LoveTestOption {
  final String id;
  final IconData icon;
  final String title;
  final String description;

  const LoveTestOption({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
  });
}

class LoveTestSelector extends StatelessWidget {
  final String selectedTest;
  final ValueChanged<String> onSelected;

  static const Color _purple = Color(0xFF7C3AED);

  static const List<LoveTestOption> options = [
    LoveTestOption(
      id: 'name',
      icon: Icons.abc_rounded,
      title: 'Name Match',
      description: 'Compare names and find your match.',
    ),
    LoveTestOption(
      id: 'zodiac',
      icon: Icons.water_drop_rounded,
      title: 'Zodiac Match',
      description: 'Check your zodiac compatibility.',
    ),
    LoveTestOption(
      id: 'chat',
      icon: Icons.chat_bubble_outline_rounded,
      title: 'Chat Chemistry',
      description: 'Test your chat chemistry.',
    ),
    LoveTestOption(
      id: 'personality',
      icon: Icons.extension_rounded,
      title: 'Personality Match',
      description: 'Discover your personality match.',
    ),
  ];

  const LoveTestSelector({
    super.key,
    required this.selectedTest,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: options.map((opt) {
        final isSelected = selectedTest == opt.id;
        return GestureDetector(
          onTap: () => onSelected(opt.id),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? _purple : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _purple.withValues(alpha: 0.12)
                        : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    opt.icon,
                    size: 20,
                    color: isSelected ? _purple : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        opt.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? _purple : const Color(0xFF222222),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        opt.description,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
