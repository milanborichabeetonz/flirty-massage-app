import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/controllers/favorite_controller.dart';
import '../../core/network/services/craft_message_service.dart';
import '../../core/services/pickup_line_share_service.dart';
import '../../core/widgets/costume_text/costume_text_widget.dart';
import '../pickup_line/pickup_line_maker_screen.dart';

class CategoryPickupLinesScreen extends StatefulWidget {
  const CategoryPickupLinesScreen({
    super.key,
    required this.category,
  });

  final String category;

  @override
  State<CategoryPickupLinesScreen> createState() =>
      _CategoryPickupLinesScreenState();
}

class _CategoryPickupLinesScreenState
    extends State<CategoryPickupLinesScreen> {
  final CraftMessageService _service = CraftMessageService();
  final TextEditingController _searchController = TextEditingController();

  List<String> _allMessages = [];
  List<String> _filtered = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Card gradient list — cycles through
  static const List<List<Color>> _gradients = [
    [Color(0xFF111827), Color(0xFF374151)],
    [Color(0xFF1565C0), Color(0xFF42A5F5)],
    [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
    [Color(0xFF00695C), Color(0xFF26A69A)],
    [Color(0xFFBF360C), Color(0xFFFF7043)],
    [Color(0xFF37474F), Color(0xFF78909C)],
    [Color(0xFF4A148C), Color(0xFF7B1FA2)],
    [Color(0xFF1B5E20), Color(0xFF43A047)],
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterMessages);
    _loadMessages();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_filterMessages)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final messages =
          await _service.generatePickupLines(category: widget.category);
      if (!mounted) return;
      setState(() {
        _allMessages = messages;
        _filtered = messages;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to generate pickup lines. Please try again.';
        _isLoading = false;
      });
      debugPrint('CategoryPickupLinesScreen error: $e');
    }
  }

  void _filterMessages() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = _allMessages;
      } else {
        _filtered = _allMessages
            .where((msg) => msg.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _shareMessage(String text) =>
      SharePlus.instance.share(ShareParams(text: text));

  void _editInMaker(String text) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PickupLineMakerScreen(initialText: text),
      ),
    );
  }

  List<Color> _gradientForIndex(int index) {
    return _gradients[index % _gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          widget.category,
          style: const TextStyle(
            color: Color(0xFF161616),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (!_isLoading && _errorMessage == null)
            IconButton(
              tooltip: 'Regenerate',
              icon: const Icon(Icons.refresh_rounded, color: Colors.black),
              onPressed: () {
                _searchController.clear();
                _loadMessages();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search pickup lines...',
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: Color(0xFF777777)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: _searchController.clear,
                          icon: const Icon(Icons.close_rounded),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
            ),
            const SizedBox(height: 12),

            // Body
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    // Loading
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF8E61E8)),
            SizedBox(height: 16),
            Text(
              'Generating pickup lines...',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Error
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadMessages,
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

    // Empty search result
    if (_filtered.isEmpty) {
      return Center(
        child: CostumeTextWidget(
          text: _searchController.text.isEmpty
              ? 'No pickup lines found.'
              : 'No results for "${_searchController.text}"',
          color: Colors.grey,
          size: 14,
        ),
      );
    }

    // List
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      itemCount: _filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        return _AIPickupLineCard(
          text: _filtered[index],
          gradientColors: _gradientForIndex(index),
          onCopy: () => _copyMessage(_filtered[index]),
          onEdit: () => _editInMaker(_filtered[index]),
          onShare: () => _shareMessage(_filtered[index]),
        );
      },
    );
  }
}

class _AIPickupLineCard extends StatefulWidget {
  const _AIPickupLineCard({
    required this.text,
    required this.gradientColors,
    required this.onCopy,
    required this.onEdit,
    required this.onShare,
  });

  final String text;
  final List<Color> gradientColors;
  final VoidCallback onCopy;
  final VoidCallback onEdit;
  final VoidCallback onShare;

  @override
  State<_AIPickupLineCard> createState() => _AIPickupLineCardState();
}

class _AIPickupLineCardState extends State<_AIPickupLineCard> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isFavorite = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = FavoriteController.to.isFavorite(widget.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient top card
          RepaintBoundary(
            key: _cardKey,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
              ),
              child: Stack(
                children: [
                  // Quote open
                  Positioned(
                    left: 18,
                    top: 16,
                    child: Icon(
                      Icons.format_quote_rounded,
                      color: Colors.white.withValues(alpha: 0.95),
                      size: 40,
                    ),
                  ),
                  // Favorite
                  Positioned(
                    right: 12,
                    top: 12,
                    child: IconButton(
                      onPressed: () {
                        FavoriteController.to.toggleFavorite(widget.text);
                        setState(() {
                          _isFavorite = FavoriteController.to.isFavorite(widget.text);
                        });
                      },
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Text
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        widget.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ),
                  // Quote close
                  Positioned(
                    right: 18,
                    bottom: 16,
                    child: Transform.rotate(
                      angle: 3.14159,
                      child: Icon(
                        Icons.format_quote_rounded,
                        color: Colors.white.withValues(alpha: 0.95),
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _chip(Icons.copy_rounded, 'Copy', widget.onCopy),
                _chip(Icons.edit_rounded, 'Edit', widget.onEdit),
                _chip(
                  _isSaved ? Icons.bookmark : Icons.bookmark_border_rounded,
                  'Save',
                  () {
                    setState(() => _isSaved = !_isSaved);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isSaved ? 'Saved!' : 'Removed from saved.',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                GestureDetector(
                  onTapDown: (details) {
                    showPickupLineShareMenu(
                      context: context,
                      cardKey: _cardKey,
                      pickupLineText: widget.text,
                      tapPosition: details.globalPosition,
                    );
                  },
                  child: _chip(Icons.share_rounded, 'Share', () {}),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE4E4E4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF2B2B2B)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2B2B2B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
