import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/favorite_controller.dart';
import '../models/dating_tip_model.dart';
import '../services/dating_tips_service.dart';
import '../widgets/dating_tip_card.dart';

class DatingTipsScreen extends StatefulWidget {
  const DatingTipsScreen({super.key, this.initialCategory});

  final String? initialCategory;

  @override
  State<DatingTipsScreen> createState() => _DatingTipsScreenState();
}

class _DatingTipsScreenState extends State<DatingTipsScreen> {
  final DatingTipsService _service = DatingTipsService();

  int _selectedTab = 0; // 0: All Tips, 1: Favourites
  bool _isLoading = true;
  String? _errorMessage;
  List<DatingTipModel> _allTips = [];
  String? _activeCategoryFilter;

  static const Color _purple = Color(0xFF7C3AED);
  static const Color _bgLavender = Color(0xFFF7F5FA);

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      _activeCategoryFilter = widget.initialCategory;
    }
    _loadTips();
  }

  Future<void> _loadTips() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tips = await _service.getDatingTips();
      if (!mounted) return;
      setState(() {
        _allTips = tips;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load dating tips. Please try again.';
        _isLoading = false;
      });
    }
  }

  List<DatingTipModel> get _displayTips {
    if (_activeCategoryFilter == null || _activeCategoryFilter!.isEmpty) {
      return _allTips;
    }
    final filterLower = _activeCategoryFilter!.toLowerCase();
    final filtered = _allTips.where((tip) {
      final catLower = tip.category.toLowerCase();
      final textLower = tip.text.toLowerCase();
      return catLower.contains(filterLower) ||
          filterLower.contains(catLower) ||
          textLower.contains(filterLower);
    }).toList();

    return filtered.isNotEmpty ? filtered : _allTips;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLavender,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF222222),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Dating Tips',
          style: TextStyle(
            color: Color(0xFF222222),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // ── Segmented Tabs: [ All Tips ] [ ♥ Favourites (N) ] ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTabButton(
                  title: 'All Tips',
                  icon: Icons.grid_view_rounded,
                  isSelected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                ),
                const SizedBox(width: 12),
                Obx(() {
                  final count = FavoriteController.to.datingTipFavoriteCount;
                  return _buildTabButton(
                    title: 'Favourites ($count)',
                    icon: Icons.favorite,
                    isSelected: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  );
                }),
              ],
            ),
          ),

          if (_activeCategoryFilter != null) ...[
            const SizedBox(height: 8),
            _buildFilterBanner(),
          ],

          const SizedBox(height: 12),

          // ── Tab Content ──
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _purple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _purple.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_list_rounded, size: 14, color: _purple),
            const SizedBox(width: 6),
            Text(
              'Category: $_activeCategoryFilter',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _purple,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => setState(() => _activeCategoryFilter = null),
              child: const Icon(Icons.close_rounded, size: 16, color: _purple),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: _purple,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF444444),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadTips,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedTab == 0) {
      return _buildTipsList(_displayTips);
    } else {
      return _buildFavoritesList();
    }
  }

  Widget _buildTipsList(List<DatingTipModel> tips) {
    if (tips.isEmpty) {
      return const Center(
        child: Text(
          'No dating tips available.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: tips.length,
      itemBuilder: (context, index) {
        return DatingTipCard(
          key: ValueKey(tips[index].id),
          tip: tips[index],
        );
      },
    );
  }

  Widget _buildFavoritesList() {
    return Obx(() {
      final favList = FavoriteController.to.datingTipFavorites;

      if (favList.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border_rounded,
                  size: 64,
                  color: _purple.withValues(alpha: 0.35),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No favourites yet',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap the heart icon on any dating tip to save it here for quick reference.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final favTips = favList.map((f) {
        return DatingTipModel(
          id: f.id,
          text: f.text,
          category: f.category,
          colorIndex: f.colorIndex ?? 0,
        );
      }).toList();

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: favTips.length,
        itemBuilder: (context, index) {
          return DatingTipCard(
            key: ValueKey(favTips[index].id),
            tip: favTips[index],
          );
        },
      );
    });
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFFD946EF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFFE2D9F3), width: 1.2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : _purple,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : _purple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
