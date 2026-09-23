import 'package:flutter/material.dart';

import '../../core/constants/category/category_tile.dart';
import '../../core/network/models/pickup_line_model.dart';

class CategorySearchScreen extends StatefulWidget {
  const CategorySearchScreen({
    super.key,
    required this.pickupLines,
    this.initialQuery = '',
  });

  final List<PickupLineModel> pickupLines;
  final String initialQuery;

  @override
  State<CategorySearchScreen> createState() => _CategorySearchScreenState();
}

class _CategorySearchScreenState extends State<CategorySearchScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    super.dispose();
  }

  List<CategorySummary> get _filteredCategories {
    final query = _searchController.text.trim().toLowerCase();
    final categories = buildCategorySummaries(widget.pickupLines);

    if (query.isEmpty) {
      return categories;
    }

    return categories.where((category) {
      return category.name.toLowerCase().contains(query) ||
          category.displayName.toLowerCase().contains(query);
    }).toList();
  }

  void _handleSearchChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = _filteredCategories;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Search',
          style: TextStyle(
            color: Color(0xFF161616),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search Category',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: _searchController.clear,
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFF8E61E8)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: filteredCategories.isEmpty
                    ? const Center(
                        child: Text(
                          'No categories found.',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : GridView.builder(
                        itemCount: filteredCategories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 1.04,
                            ),
                        itemBuilder: (context, index) {
                          final category = filteredCategories[index];
                          return CategoryTile(
                            category: category,
                            onTap: () => Navigator.pop(context, category.name),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
