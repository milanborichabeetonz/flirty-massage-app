import 'package:flutter/material.dart';

import '../../../features/category/category_detail_screen.dart';
import '../../../features/category/category_pickup_lines_screen.dart';
import '../../network/models/pickup_line_model.dart';
import '../../network/services/pickup_line_service.dart';
import 'category_tile.dart';

class AllCategoryTabs extends StatefulWidget {
  const AllCategoryTabs({super.key, this.pickupLines});

  final List<PickupLineModel>? pickupLines;

  @override
  State<AllCategoryTabs> createState() => _AllCategoryTabsState();
}

class _AllCategoryTabsState extends State<AllCategoryTabs> {
  final PickupLineService service = PickupLineService();

  @override
  Widget build(BuildContext context) {
    if (widget.pickupLines != null) {
      return _buildCategoryList(widget.pickupLines!);
    }

    return FutureBuilder<List<PickupLineModel>>(
      future: service.fetchPickUpLines(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 110,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            height: 110,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Unable to load categories.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          );
        }

        final pickupLines = snapshot.data ?? const <PickupLineModel>[];
        return _buildCategoryList(pickupLines);
      },
    );
  }

  Widget _buildCategoryList(List<PickupLineModel> pickupLines) {
    final categories = buildCategorySummaries(pickupLines);

    if (categories.isEmpty) {
      return const SizedBox(
        height: 110,
        child: Center(child: Text('No categories found.')),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryTile(
            category: category,
            width: 135,
            height: 105,
            onTap: () => _showCategoryOptions(context, category, pickupLines),
          );
        },
      ),
    );
  }

  void _showCategoryOptions(
    BuildContext context,
    CategorySummary category,
    List<PickupLineModel> pickupLines,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF161616),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.list_rounded, color: Color(0xFF8E61E8)),
                title: const Text('Browse pickup lines', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${category.itemCount} lines from our collection'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryDetailScreen(
                        initialCategory: category.name,
                        pickupLines: pickupLines,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF8E61E8)),
                title: const Text('AI Generate', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Generate fresh lines using AI'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryPickupLinesScreen(
                        category: category.name,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
