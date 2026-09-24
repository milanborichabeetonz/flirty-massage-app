import 'package:flutter/material.dart';

import '../../network/models/pickup_line_model.dart';

class CategorySummary {
  const CategorySummary({
    required this.name,
    required this.displayName,
    required this.itemCount,
    required this.backgroundColor,
    required this.accentColor,
    required this.icon,
  });

  final String name;
  final String displayName;
  final int itemCount;
  final Color backgroundColor;
  final Color accentColor;
  final IconData icon;
}

List<CategorySummary> buildCategorySummaries(
  List<PickupLineModel> pickupLines,
) {
  final counts = <String, int>{};
  final originalNames = <String, String>{};

  for (final pickupLine in pickupLines) {
    final rawCategory = pickupLine.category.trim();
    if (rawCategory.isEmpty) {
      continue;
    }

    final normalized = rawCategory.toLowerCase();
    counts[normalized] = (counts[normalized] ?? 0) + 1;
    originalNames.putIfAbsent(normalized, () => rawCategory);
  }

  final categories = counts.entries.map((entry) {
    final name = originalNames[entry.key]!;
    final palette = _paletteForCategory(entry.key);
    return CategorySummary(
      name: name,
      displayName: '$name Lines',
      itemCount: entry.value,
      backgroundColor: palette.backgroundColor,
      accentColor: palette.accentColor,
      icon: palette.icon,
    );
  }).toList();

  categories.sort(
    (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
  );
  return categories;
}

class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    required this.onTap,
    this.width,
    this.height,
  });

  final CategorySummary category;
  final VoidCallback onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: category.backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: category.accentColor.withValues(alpha: 0.18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category.icon,
                  color: category.accentColor,
                  size: 20,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${category.itemCount} lines',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: category.accentColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height,
        child: card,
      );
    }
    return card;
  }
}

class _CategoryPalette {
  const _CategoryPalette({
    required this.backgroundColor,
    required this.accentColor,
    required this.icon,
  });

  final Color backgroundColor;
  final Color accentColor;
  final IconData icon;
}

_CategoryPalette _paletteForCategory(String normalizedCategory) {
  switch (normalizedCategory) {
    case 'cute':
      return const _CategoryPalette(
        backgroundColor: Color(0xFFFFEFF5),
        accentColor: Color(0xFFE86A92),
        icon: Icons.favorite_outline_rounded,
      );
    case 'cheesy':
      return const _CategoryPalette(
        backgroundColor: Color(0xFFFFF3E6),
        accentColor: Color(0xFFF39C3D),
        icon: Icons.celebration_outlined,
      );
    case 'dirty':
      return const _CategoryPalette(
        backgroundColor: Color(0xFFF7EFFF),
        accentColor: Color(0xFF8E61E8),
        icon: Icons.local_fire_department_outlined,
      );
    case 'funny':
      return const _CategoryPalette(
        backgroundColor: Color(0xFFEFF9FF),
        accentColor: Color(0xFF2E9CCB),
        icon: Icons.sentiment_very_satisfied_outlined,
      );
    case 'romantic':
      return const _CategoryPalette(
        backgroundColor: Color(0xFFFFEFF2),
        accentColor: Color(0xFFE25C7A),
        icon: Icons.favorite_rounded,
      );
    case 'flirty':
      return const _CategoryPalette(
        backgroundColor: Color(0xFFF6F0FF),
        accentColor: Color(0xFF9055F8),
        icon: Icons.auto_awesome_outlined,
      );
    case 'complimentary':
      return const _CategoryPalette(
        backgroundColor: Color(0xFFEFFBF4),
        accentColor: Color(0xFF32A872),
        icon: Icons.thumb_up_alt_outlined,
      );
    case 'clever':
      return const _CategoryPalette(
        backgroundColor: Color(0xFFEFF3FF),
        accentColor: Color(0xFF4A72E3),
        icon: Icons.psychology_outlined,
      );
    default:
      final palettes = <_CategoryPalette>[
        const _CategoryPalette(
          backgroundColor: Color(0xFFFFEFF5),
          accentColor: Color(0xFFE86A92),
          icon: Icons.favorite_outline_rounded,
        ),
        const _CategoryPalette(
          backgroundColor: Color(0xFFF7EFFF),
          accentColor: Color(0xFF8E61E8),
          icon: Icons.bolt_outlined,
        ),
        const _CategoryPalette(
          backgroundColor: Color(0xFFEFFBF4),
          accentColor: Color(0xFF32A872),
          icon: Icons.chat_bubble_outline_rounded,
        ),
        const _CategoryPalette(
          backgroundColor: Color(0xFFEFF9FF),
          accentColor: Color(0xFF2E9CCB),
          icon: Icons.wb_sunny_outlined,
        ),
      ];
      return palettes[normalizedCategory.length % palettes.length];
  }
}
