import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/craft_message_response.dart';

class CraftMessageService {
  Future<CraftMessageResponse> analyzeScreenshot({
    required File imageFile,
    required String instructions,
  }) async {
    final baseUrl = dotenv.env['FLIRT_COPILOT_BASE_URL'] ?? 'https://flirt-copilot.onrender.com';
    final uri = Uri.parse('$baseUrl/api/craft-message-text');

    // Read image bytes and convert to base64
    final bytes = await imageFile.readAsBytes();
    final mimeType = imageFile.path.toLowerCase().endsWith('.png')
        ? 'image/png'
        : 'image/jpeg';
    final base64Image = 'data:$mimeType;base64,${base64Encode(bytes)}';

    final body = jsonEncode({
      'image': base64Image,
      'instructions': instructions.toLowerCase(),
    });

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CraftMessageResponse.fromJson(json);
    } else {
      debugPrint('API error body: ${response.body}');
      throw Exception('API error: ${response.statusCode} — ${response.body}');
    }
  }

  Future<CraftMessageResponse> generateOpener({
    required String profileText,
    required String instructions,
    String? existingUserId,
  }) async {
    final baseUrl =
        dotenv.env['FLIRT_COPILOT_BASE_URL'] ?? 'https://flirt-copilot.onrender.com';
    final uri = Uri.parse('$baseUrl/api/craft-message-text');

    final userId = existingUserId ?? _generateUserId();
    final requestId = _generateRequestId();

    final body = jsonEncode({
      'userId': userId,
      'platform': 'guide',
      'requestId': requestId,
      'profileText': profileText,
      'instructions': instructions.toLowerCase(),
    });

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CraftMessageResponse.fromJson(json);
    } else {
      debugPrint('Opener API error: ${response.body}');
      throw Exception('API error: ${response.statusCode}');
    }
  }

  String _generateUserId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rand = math.Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final suffix =
        List.generate(10, (_) => chars[rand.nextInt(chars.length)]).join();
    return 'visitor_${ts}_$suffix';
  }

  String _generateRequestId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rand = math.Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final suffix =
        List.generate(10, (_) => chars[rand.nextInt(chars.length)]).join();
    return 'guide_${ts}_$suffix';
  }
}
