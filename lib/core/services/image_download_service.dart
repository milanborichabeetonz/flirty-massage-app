import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

enum ImageExportFormat { png, jpeg }

class ImageDownloadResult {
  final bool success;
  final String? path;
  final String? userMessage;

  const ImageDownloadResult._({
    required this.success,
    this.path,
    this.userMessage,
  });

  factory ImageDownloadResult.success(String path) =>
      ImageDownloadResult._(success: true, path: path);

  factory ImageDownloadResult.failure(String message) =>
      ImageDownloadResult._(success: false, userMessage: message);
}

class ImageDownloadService {
  static const double _defaultPixelRatio = 3.0;
  static const int _jpegQuality = 95;

  static Future<Uint8List?> capturePngBytes(
    GlobalKey key, {
    double pixelRatio = _defaultPixelRatio,
  }) async {
    try {
      final renderObject = key.currentContext?.findRenderObject();
      if (renderObject == null) {
        debugPrint('[ImageDownloadService] No render object found for key.');
        return null;
      }
      if (renderObject is! RenderRepaintBoundary) {
        debugPrint(
            '[ImageDownloadService] Render object is not a RenderRepaintBoundary.');
        return null;
      }
      final image = await renderObject.toImage(pixelRatio: pixelRatio);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();
      if (bytes == null || bytes.isEmpty) {
        debugPrint('[ImageDownloadService] PNG bytes were empty.');
        return null;
      }
      return bytes;
    } catch (e, stackTrace) {
      debugPrint('[ImageDownloadService] capturePngBytes failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  static Uint8List? encodePng(Uint8List pngBytes) => pngBytes;

  static Uint8List? encodeJpeg(Uint8List pngBytes, {int quality = _jpegQuality}) {
    try {
      final decoded = img.decodeImage(pngBytes);
      if (decoded == null) {
        debugPrint('[ImageDownloadService] Could not decode PNG for JPEG encode.');
        return null;
      }
      final jpegBytes = img.encodeJpg(decoded, quality: quality);
      if (jpegBytes.isEmpty) {
        debugPrint('[ImageDownloadService] JPEG encode produced empty bytes.');
        return null;
      }
      return Uint8List.fromList(jpegBytes);
    } catch (e, stackTrace) {
      debugPrint('[ImageDownloadService] encodeJpeg failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  static Future<ImageDownloadResult> saveToGallery(
    Uint8List bytes, {
    required ImageExportFormat format,
  }) async {
    if (bytes.isEmpty) {
      return ImageDownloadResult.failure('Unable to save image');
    }
    final ts = DateTime.now().millisecondsSinceEpoch;
    final ext = switch (format) {
      ImageExportFormat.png => 'png',
      ImageExportFormat.jpeg => 'jpg',
    };
    final fileNameWithoutExt = 'pickup_line_$ts';

    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final requested = await Gal.requestAccess();
        if (!requested) {
          return ImageDownloadResult.failure(
              'Gallery permission denied');
        }
      }

      await Gal.putImageBytes(
        bytes,
        name: fileNameWithoutExt,
        album: 'Pickup Lines',
      );

      final tempDir = await getTemporaryDirectory();
      final savedPath =
          '${tempDir.path}/$fileNameWithoutExt.$ext';
      await File(savedPath).writeAsBytes(bytes);

      return ImageDownloadResult.success(savedPath);
    } catch (e, stackTrace) {
      debugPrint('[ImageDownloadService] saveToGallery failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      return ImageDownloadResult.failure('Unable to save image');
    }
  }

  static Future<ImageDownloadResult> downloadCard(
    GlobalKey key, {
    required ImageExportFormat format,
    double pixelRatio = _defaultPixelRatio,
  }) async {
    final pngBytes = await capturePngBytes(key, pixelRatio: pixelRatio);
    if (pngBytes == null) {
      return ImageDownloadResult.failure('Unable to save image');
    }

    final Uint8List? finalBytes = switch (format) {
      ImageExportFormat.png => encodePng(pngBytes),
      ImageExportFormat.jpeg => encodeJpeg(pngBytes),
    };

    if (finalBytes == null || finalBytes.isEmpty) {
      return ImageDownloadResult.failure('Unable to save image');
    }

    return saveToGallery(finalBytes, format: format);
  }
}
