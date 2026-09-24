import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/controllers/favorite_controller.dart';
import '../models/dating_tip_model.dart';

class DatingTipCard extends StatelessWidget {
  final DatingTipModel tip;

  static const Color _purple = Color(0xFF7C3AED);

  static const List<LinearGradient> _indicatorGradients = [
    // 0: Cyan / Teal
    LinearGradient(
      colors: [Color(0xFF00B4D8), Color(0xFF48CAE4)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    // 1: Violet / Purple
    LinearGradient(
      colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    // 2: Orange / Amber
    LinearGradient(
      colors: [Color(0xFFF97316), Color(0xFFFBBF24)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    // 3: Emerald / Green
    LinearGradient(
      colors: [Color(0xFF10B981), Color(0xFF34D399)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    // 4: Rose / Crimson
    LinearGradient(
      colors: [Color(0xFFF43F5E), Color(0xFFFB7185)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    // 5: Blue
    LinearGradient(
      colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  ];

  const DatingTipCard({
    super.key,
    required this.tip,
  });

  void _copyTip(BuildContext context) {
    Clipboard.setData(ClipboardData(text: tip.text));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Tip copied!',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFF222222),
      ),
    );
  }

  void _shareTip() {
    SharePlus.instance.share(ShareParams(text: tip.text));
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _indicatorGradients[
        (tip.colorIndex >= 0 && tip.colorIndex < _indicatorGradients.length)
            ? tip.colorIndex
            : 0];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Left vertical indicator bar
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 5,
            child: Container(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tip text
                Text(
                  tip.text,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),

                // Action buttons row (Favorite, Copy, Share)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Favorite button
                    Obx(() {
                      final isFav = FavoriteController.to.isDatingTipFavorite(tip.id);
                      return _actionButton(
                        icon: isFav
                            ? Icons.favorite
                            : Icons.favorite_outline_rounded,
                        color: isFav ? _purple : _purple,
                        onTap: () => FavoriteController.to.toggleDatingTipFavorite(
                          id: tip.id,
                          text: tip.text,
                          category: tip.category,
                          colorIndex: tip.colorIndex,
                        ),
                      );
                    }),
                    const SizedBox(width: 10),

                    // Copy button
                    _actionButton(
                      icon: Icons.copy_rounded,
                      color: _purple,
                      onTap: () => _copyTip(context),
                    ),
                    const SizedBox(width: 10),

                    // Share button
                    _actionButton(
                      icon: Icons.share_outlined,
                      color: _purple,
                      onTap: _shareTip,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEBE6F3), width: 1.2),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: color, size: 19),
      ),
    );
  }
}
