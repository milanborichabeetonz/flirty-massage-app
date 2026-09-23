import 'package:carousel_slider/carousel_slider.dart';
import 'package:flirtymessages/core/widgets/header_icon_button.dart';
import 'package:flirtymessages/features/favorite/favorite_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../network/models/pickup_line_model.dart';
import '../../network/services/pickup_line_service.dart';

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

class _PickupLineCarouselCard extends StatelessWidget {
  const _PickupLineCarouselCard({required this.pickupLine});

  final PickupLineModel pickupLine;

  @override
  Widget build(BuildContext context) {
    final gradient = _gradientForCategory(pickupLine.category);

    return Container(
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
                pickupLine.text,
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
                  icon: Icons.favorite_border,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavoriteScreen(),
                      ),
                    );
                  },
                  iconColor: Colors.white,
                  iconSize: 24,
                ),
                HeaderIconButton(
                  icon: Icons.mode_edit_outlined,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Open a category to edit this line.'),
                      ),
                    );
                  },
                  iconColor: Colors.white,
                  iconSize: 24,
                ),
                HeaderIconButton(
                  icon: Icons.share_outlined,
                  onPressed: () {
                    SharePlus.instance.share(
                      ShareParams(text: pickupLine.text),
                    );
                  },
                  iconColor: Colors.white,
                  iconSize: 24,
                ),
              ],
            ),
          ),
        ],
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
  late String _currentText;
  bool _isSaved = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _currentText = widget.pickupLine.text;
  }

  Future<void> _editMessage() async {
    final controller = TextEditingController(text: _currentText);

    final updatedText = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit pickup line'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Edit your pickup line...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (!mounted || updatedText == null || updatedText.isEmpty) {
      return;
    }

    setState(() {
      _currentText = updatedText;
    });
  }

  void _copyMessage() {
    Clipboard.setData(ClipboardData(text: _currentText));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Pickup line copied!')));
  }

  void _saveMessage() {
    setState(() {
      _isSaved = !_isSaved;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSaved ? 'Saved for later.' : 'Removed from saved list.',
        ),
      ),
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _gradientForCategory(widget.pickupLine.category);

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
                _ActionChip(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  onTap: () =>
                      SharePlus.instance.share(ShareParams(text: _currentText)),
                ),
              ],
            ),
          ),
        ],
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
