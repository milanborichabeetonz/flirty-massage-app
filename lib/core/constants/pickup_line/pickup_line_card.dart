import 'package:carousel_slider/carousel_slider.dart';
import 'package:flirtymessages/core/controllers/favorite_controller.dart';
import 'package:flirtymessages/core/widgets/header_icon_button.dart';
import 'package:flirtymessages/features/pickup_line/pickup_line_maker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/pickup_line_share_service.dart';
import '../../network/models/pickup_line_model.dart';
import '../../network/services/pickup_line_service.dart';
import '../../repositories/saved_content_repository.dart';

enum PickupLineCardMode { carousel, list }

class PickupLineCard extends StatefulWidget {
  const PickupLineCard({
    super.key,
    this.pickupLines,
    this.mode = PickupLineCardMode.carousel,
    this.emptyMessage = 'No pickup lines found.',
  });

  final List<PickupLineModel>? pickupLines;
  final PickupLineCardMode mode;
  final String emptyMessage;

  @override
  State<PickupLineCard> createState() => _PickupLineCardState();
}

class _PickupLineCardState extends State<PickupLineCard> {
  final PickupLineService service = PickupLineService();

  @override
  Widget build(BuildContext context) {
    if (widget.pickupLines != null) {
      return _buildContent(widget.pickupLines!);
    }

    return FutureBuilder<List<PickupLineModel>>(
      future: service.fetchPickUpLines(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Unable to load pickup lines.\n${snapshot.error}'),
          );
        }

        return _buildContent(snapshot.data ?? const <PickupLineModel>[]);
      },
    );
  }

  Widget _buildContent(List<PickupLineModel> pickupLines) {
    if (pickupLines.isEmpty) {
      return Center(child: Text(widget.emptyMessage));
    }

    if (widget.mode == PickupLineCardMode.list) {
      return ListView.separated(
        itemCount: pickupLines.length,
        separatorBuilder: (context, index) => const SizedBox(height: 18),
        itemBuilder: (context, index) {
          return _PickupLineListCard(pickupLine: pickupLines[index]);
        },
      );
    }

    return CarouselSlider.builder(
      itemCount: pickupLines.length,
      itemBuilder: (context, index, realIndex) {
        final pickupLine = pickupLines[index];
        return _PickupLineCarouselCard(pickupLine: pickupLine);
      },
      options: CarouselOptions(
        height: 200,
        viewportFraction: 0.86,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 6),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
      ),
    );
  }
}

class _PickupLineCarouselCard extends StatefulWidget {
  const _PickupLineCarouselCard({required this.pickupLine});

  final PickupLineModel pickupLine;

  @override
  State<_PickupLineCarouselCard> createState() =>
      _PickupLineCarouselCardState();
}

class _PickupLineCarouselCardState extends State<_PickupLineCarouselCard> {
  final GlobalKey _cardKey = GlobalKey();
  final SavedContentRepository _savedRepo = SavedContentRepository();
  bool _isFavorite = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _isFavorite =
        FavoriteController.to.isFavorite(widget.pickupLine.text);
    _checkSavedStatus();
  }

  Future<void> _checkSavedStatus() async {
    try {
      final saved = await _savedRepo.isPickupLineSaved(widget.pickupLine.text);
      if (mounted) setState(() => _isSaved = saved);
    } catch (e) {
      debugPrint('[SAVE] Failed to check saved pickup line: $e');
    }
  }

  void _toggleFavorite() {
    FavoriteController.to.toggleFavorite(
      widget.pickupLine.text,
      category: widget.pickupLine.category,
    );
    setState(() {
      _isFavorite =
          FavoriteController.to.isFavorite(widget.pickupLine.text);
    });
  }

  Future<void> _toggleSaved() async {
    final wasSaved = _isSaved;
    setState(() => _isSaved = !wasSaved);
    try {
      if (wasSaved) {
        await _savedRepo.removeSavedPickupLine(widget.pickupLine.text);
      } else {
        await _savedRepo.savePickupLine(
          text: widget.pickupLine.text,
          category: widget.pickupLine.category,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isSaved ? 'Pickup line saved' : 'Removed from saved'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      debugPrint('[SAVE] Failed to toggle saved pickup line: $e');
      if (!mounted) return;
      setState(() => _isSaved = wasSaved);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save pickup line'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _gradientForCategory(widget.pickupLine.category);

    return RepaintBoundary(
      key: _cardKey,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 16,
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Pickup Line of the Day',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              top: 48,
              child: Icon(
                Icons.format_quote_rounded,
                color: Colors.white.withValues(alpha: 0.92),
                size: 34,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Text(
                  widget.pickupLine.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 6,
              child: Row(
                children: [
                  HeaderIconButton(
                    icon: _isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    onPressed: _toggleFavorite,
                    iconColor: Colors.white,
                    iconSize: 24,
                  ),
                  HeaderIconButton(
                    icon: _isSaved
                        ? Icons.bookmark
                        : Icons.bookmark_border_rounded,
                    onPressed: _toggleSaved,
                    iconColor: Colors.white,
                    iconSize: 24,
                  ),
                  HeaderIconButton(
                    icon: Icons.mode_edit_outlined,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PickupLineMakerScreen(
                            initialText: widget.pickupLine.text,
                          ),
                        ),
                      );
                    },
                    iconColor: Colors.white,
                    iconSize: 24,
                  ),
                  GestureDetector(
                    onTapDown: (details) {
                      showPickupLineShareMenu(
                        context: context,
                        cardKey: _cardKey,
                        pickupLineText: widget.pickupLine.text,
                        tapPosition: details.globalPosition,
                      );
                    },
                    child: HeaderIconButton(
                      icon: Icons.share_outlined,
                      onPressed: () {},
                      iconColor: Colors.white,
                      iconSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickupLineListCard extends StatefulWidget {
  const _PickupLineListCard({required this.pickupLine});

  final PickupLineModel pickupLine;

  @override
  State<_PickupLineListCard> createState() => _PickupLineListCardState();
}

class _PickupLineListCardState extends State<_PickupLineListCard> {
  final GlobalKey _cardKey = GlobalKey();
  final SavedContentRepository _savedRepo = SavedContentRepository();
  late String _currentText;
  bool _isSaved = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _currentText = widget.pickupLine.text;
    _isFavorite = FavoriteController.to.isFavorite(widget.pickupLine.text);
    _checkSavedStatus();
  }

  Future<void> _checkSavedStatus() async {
    try {
      final saved = await _savedRepo.isPickupLineSaved(_currentText);
      if (mounted) setState(() => _isSaved = saved);
    } catch (e) {
      debugPrint('[SAVE] Failed to check saved pickup line: $e');
    }
  }

  // ── GLOBAL FAVORITE via GetX controller ──────────────────────
  void _toggleFavorite() {
    FavoriteController.to.toggleFavorite(
      widget.pickupLine.text,
      category: widget.pickupLine.category,
    );
    setState(() {
      _isFavorite = FavoriteController.to.isFavorite(widget.pickupLine.text);
    });
  }

  // ── EDIT → navigate to PickupLineMakerScreen ─────────────────
  void _editMessage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PickupLineMakerScreen(initialText: _currentText),
      ),
    );
  }

  void _copyMessage() {
    Clipboard.setData(ClipboardData(text: _currentText));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Pickup line copied!')));
  }

  // ── SAVE via common local Save/Store repository ──────────────
  Future<void> _saveMessage() async {
    final wasSaved = _isSaved;
    setState(() => _isSaved = !wasSaved);
    try {
      if (wasSaved) {
        await _savedRepo.removeSavedPickupLine(_currentText);
      } else {
        await _savedRepo.savePickupLine(
          text: _currentText,
          category: widget.pickupLine.category,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSaved ? 'Pickup line saved' : 'Removed from saved',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      debugPrint('[SAVE] Failed to toggle saved pickup line: $e');
      if (!mounted) return;
      setState(() => _isSaved = wasSaved);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save pickup line'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _gradientForCategory(widget.pickupLine.category);

    return RepaintBoundary(
      key: _cardKey,
      child: Container(
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
            Container(
              height: 245,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 18,
                    top: 16,
                    child: Icon(
                      Icons.format_quote_rounded,
                      color: Colors.white.withValues(alpha: 0.95),
                      size: 40,
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: IconButton(
                      onPressed: _toggleFavorite,
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        _currentText,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ActionChip(
                    icon: Icons.copy_rounded,
                    label: 'Copy',
                    onTap: _copyMessage,
                  ),
                  _ActionChip(
                    icon: Icons.edit_rounded,
                    label: 'Edit',
                    onTap: _editMessage,
                  ),
                  _ActionChip(
                    icon: _isSaved
                        ? Icons.bookmark
                        : Icons.bookmark_border_rounded,
                    label: 'Save',
                    onTap: _saveMessage,
                  ),
                  GestureDetector(
                    onTapDown: (details) {
                      showPickupLineShareMenu(
                        context: context,
                        cardKey: _cardKey,
                        pickupLineText: _currentText,
                        tapPosition: details.globalPosition,
                      );
                    },
                    child: _ActionChip(
                      icon: Icons.share_rounded,
                      label: 'Share',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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

LinearGradient _gradientForCategory(String category) {
  switch (category.trim().toLowerCase()) {
    case 'romantic':
      return const LinearGradient(
        colors: [Color(0xFFFF6584), Color(0xFFFF8FB1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case 'cheesy':
      return const LinearGradient(
        colors: [Color(0xFFFFA45C), Color(0xFFFFD45C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case 'funny':
      return const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case 'complimentary':
      return const LinearGradient(
        colors: [Color(0xFF0EA5A4), Color(0xFF34D399)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case 'clever':
      return const LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case 'flirty':
      return const LinearGradient(
        colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    default:
      return const LinearGradient(
        colors: [Color(0xFF111827), Color(0xFF374151)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
  }
}
