import 'package:flutter/material.dart';

import '../../core/constants/pickup_line/pickup_line_card.dart';
import '../../core/network/models/pickup_line_model.dart';
import 'category_search_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({
    super.key,
    required this.initialCategory,
    required this.pickupLines,
  });

  final String initialCategory;
  final List<PickupLineModel> pickupLines;

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  List<PickupLineModel> get _filteredPickupLines {
    final selected = _selectedCategory.trim().toLowerCase();
    return widget.pickupLines.where((pickupLine) {
      return pickupLine.category.trim().toLowerCase() == selected;
    }).toList();
  }

  Future<void> _openCategorySearch() async {
    final selectedCategory = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CategorySearchScreen(pickupLines: widget.pickupLines),
      ),
    );

    if (!mounted || selectedCategory == null || selectedCategory.isEmpty) {
      return;
    }

    setState(() {
      _selectedCategory = selectedCategory;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredPickupLines = _filteredPickupLines;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          _selectedCategory,
          style: const TextStyle(
            color: Color(0xFF161616),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: _openCategorySearch,
                borderRadius: BorderRadius.circular(18),
                child: Ink(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E2E2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search_rounded, color: Color(0xFF343434)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Search pickup lines...',
                          style: TextStyle(
                            color: Color(0xFF343434),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '${filteredPickupLines.length} lines in $_selectedCategory',
                style: const TextStyle(
                  color: Color(0xFF6B6B6B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: PickupLineCard(
                  pickupLines: filteredPickupLines,
                  mode: PickupLineCardMode.list,
                  emptyMessage: 'No pickup lines found.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
