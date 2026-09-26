import 'package:flutter/material.dart';

import '../../core/constants/category/category_tile.dart';
import '../../core/constants/pickup_line/pickup_line_card.dart';
import '../../core/network/data/pickup_line_local_data.dart';
import '../../core/network/models/pickup_line_model.dart';
import '../../core/network/services/pickup_line_service.dart';

class CategoryUnifiedScreen extends StatefulWidget {
  const CategoryUnifiedScreen({
    super.key,
    required this.category,
  });

  final String category;

  @override
  State<CategoryUnifiedScreen> createState() => _CategoryUnifiedScreenState();
}

class _CategoryUnifiedScreenState extends State<CategoryUnifiedScreen> {
  final PickupLineService _service = PickupLineService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<PickupLineModel>> _future;
  List<PickupLineModel> _all = const [];
  List<PickupLineModel> _filtered = const [];
  bool _loadedOnce = false;

  bool get _isRandom =>
      widget.category.trim().toLowerCase() ==
      PickupLineLocalData.kRandom.toLowerCase();

  String get _displayCategory {
    final name = widget.category.trim();
    if (_isRandom) return 'Random Pickup Lines';
    return '$name Lines';
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilter);
    _future = _load();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_applyFilter)
      ..dispose();
    super.dispose();
  }

  Future<List<PickupLineModel>> _load() async {
    final list = _isRandom
        ? await _service.getRandomPickupLines()
        : await _service.getCategoryPickupLines(widget.category);
    if (mounted) {
      setState(() {
        _all = list;
        _filtered = list;
        _loadedOnce = true;
      });
      _applyFilter();
    }
    return list;
  }

  void _applyFilter() {
    final q = _searchController.text.trim().toLowerCase();
    if (!mounted) return;
    setState(() {
      if (q.isEmpty) {
        _filtered = _all;
      } else {
        _filtered = _all.where((p) {
          return p.text.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  Future<void> _reroll() async {
    if (!_isRandom) return;
    FocusScope.of(context).unfocus();
    _searchController.clear();
    setState(() {
      _loadedOnce = false;
      _future = _service.getRandomPickupLines(forceRefresh: true);
      _all = const [];
      _filtered = const [];
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          _displayCategory,
          style: const TextStyle(
            color: Color(0xFF161616),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (_isRandom)
            IconButton(
              tooltip: 'Shuffle Random',
              icon: const Icon(Icons.shuffle_rounded, color: Colors.black),
              onPressed: _reroll,
            ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<PickupLineModel>>(
          future: _future,
          builder: (context, snapshot) {
            // Loading
            if (!_loadedOnce &&
                snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF8E61E8)),
                    SizedBox(height: 16),
                    Text(
                      'Loading pickup lines...',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            // Error
            final showError = snapshot.hasError && !_loadedOnce;
            if (showError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      const Text(
                        'Unable to load pickup lines. Please try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _loadedOnce = false;
                            _future = _load();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8E61E8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final displayList = _loadedOnce ? _filtered : _all;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search pickup lines...',
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Color(0xFF777777)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _applyFilter();
                              },
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide:
                            const BorderSide(color: Color(0xFFE2E2E2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide:
                            const BorderSide(color: Color(0xFFE2E2E2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide:
                            const BorderSide(color: Color(0xFF8E61E8)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Count badge
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _loadedOnce
                        ? '${displayList.length} lines'
                        : 'Loading...',
                    style: const TextStyle(
                      color: Color(0xFF6B6B6B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Unified list — ONE continuous list, no Browse / AI partition
                Expanded(
                  child: displayList.isEmpty && _loadedOnce
                      ? Center(
                          child: Text(
                            _searchController.text.isEmpty
                                ? 'No pickup lines found.'
                                : 'No results for "${_searchController.text}"',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                          ),
                        )
                      : PickupLineCard(
                          pickupLines: displayList,
                          mode: PickupLineCardMode.list,
                          emptyMessage: _searchController.text.isEmpty
                              ? 'No pickup lines found.'
                              : 'No results for "${_searchController.text}"',
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Ignore: CategorySummary imported only for discoverability / buildCategorySummaries
// ignore: unused_element
void _ref() => CategorySummary;
