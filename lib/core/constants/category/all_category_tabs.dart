import 'package:flutter/material.dart';

import '../../../features/category/category_unified_screen.dart';
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
  @override
  Widget build(BuildContext context) {
    if (widget.pickupLines != null) {
      return _buildCategoryList(widget.pickupLines!);
    }

    final service = PickupLineService();
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
            onTap: () => _openCategory(context, category.name),
          );
        },
      ),
    );
  }

  void _openCategory(BuildContext context, String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryUnifiedScreen(category: categoryName),
      ),
    );
  }
}
