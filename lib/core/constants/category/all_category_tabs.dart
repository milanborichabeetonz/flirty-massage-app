import 'package:flutter/material.dart';

import '../../../features/category/category_detail_screen.dart';
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
      return _buildCategoryGrid(widget.pickupLines!);
    }

    return FutureBuilder<List<PickupLineModel>>(
      future: service.fetchPickUpLines(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Unable to load categories.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final pickupLines = snapshot.data ?? const <PickupLineModel>[];
        return _buildCategoryGrid(pickupLines);
      },
    );
  }

  Widget _buildCategoryGrid(List<PickupLineModel> pickupLines) {
    final categories = buildCategorySummaries(pickupLines);

    if (categories.isEmpty) {
      return const Center(child: Text('No categories found.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.04,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryTile(
          category: category,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryDetailScreen(
                  initialCategory: category.name,
                  pickupLines: pickupLines,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
