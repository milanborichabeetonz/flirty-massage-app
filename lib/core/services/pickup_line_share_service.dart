import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'image_download_service.dart';

/// Reusable service for sharing pickup lines as Text, as Image, or without Image.
class PickupLineShareService {
  /// Option 1: Share as Text
  static Future<void> shareAsText(String text) async {
    try {
      await SharePlus.instance.share(ShareParams(text: text));
    } catch (e) {
      debugPrint('[PickupLineShareService] shareAsText error: $e');
    }
  }

  /// Option 2: Share as Image — captures only the pickup line card using its GlobalKey,
  /// generates a temporary PNG file, and opens the native share sheet with image attached.
  static Future<void> shareAsImage({
    required BuildContext context,
    required GlobalKey cardKey,
    required String pickupLineText,
  }) async {
    try {
      final bytes = await ImageDownloadService.capturePngBytes(
        cardKey,
        pixelRatio: 3.0,
      );

      if (bytes == null || bytes.isEmpty) {
        if (context.mounted) {
          _showError(context);
        }
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${tempDir.path}/pickup_line_$ts.png');
      await tempFile.writeAsBytes(bytes);

      if (!context.mounted) return;

      await SharePlus.instance.share(
        ShareParams(
          text: pickupLineText,
          files: [XFile(tempFile.path)],
        ),
      );
    } catch (e) {
      debugPrint('[PickupLineShareService] shareAsImage error: $e');
      if (context.mounted) {
        _showError(context);
      }
    }
  }

  /// Option 3: Share without image — shares text only without image attachments.
  static Future<void> shareWithoutImage(String text) async {
    try {
      await SharePlus.instance.share(ShareParams(text: text));
    } catch (e) {
      debugPrint('[PickupLineShareService] shareWithoutImage error: $e');
    }
  }

  static void _showError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Unable to share pickup line'),
        backgroundColor: Color(0xFFEF4444),
      ),
    );
  }
}

/// Displays the 3-option share popup menu near the tapped share icon.
Future<void> showPickupLineShareMenu({
  required BuildContext context,
  required GlobalKey cardKey,
  required String pickupLineText,
  Offset? tapPosition,
}) async {
  final RenderBox? overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox?;

  final RelativeRect position = tapPosition != null && overlay != null
      ? RelativeRect.fromRect(
          Rect.fromLTWH(tapPosition.dx, tapPosition.dy, 0, 0),
          Offset.zero & overlay.size,
        )
      : const RelativeRect.fromLTRB(100, 300, 100, 0);

  final selected = await showMenu<String>(
    context: context,
    position: position,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 8,
    color: Colors.white,
    items: const [
      PopupMenuItem<String>(
        value: 'text',
        child: Row(
          children: [
            Icon(Icons.text_fields_rounded, color: Color(0xFF7C3AED), size: 20),
            SizedBox(width: 10),
            Text(
              'Share as Text',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'image',
        child: Row(
          children: [
            Icon(Icons.image_outlined, color: Color(0xFF7C3AED), size: 20),
            SizedBox(width: 10),
            Text(
              'Share as Image',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'no_image',
        child: Row(
          children: [
            Icon(Icons.notes_rounded, color: Color(0xFF7C3AED), size: 20),
            SizedBox(width: 10),
            Text(
              'Share without image',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  if (selected == null || !context.mounted) return;

  switch (selected) {
    case 'text':
      await PickupLineShareService.shareAsText(pickupLineText);
      break;
    case 'image':
      await PickupLineShareService.shareAsImage(
        context: context,
        cardKey: cardKey,
        pickupLineText: pickupLineText,
      );
      break;
    case 'no_image':
      await PickupLineShareService.shareWithoutImage(pickupLineText);
      break;
  }
}
