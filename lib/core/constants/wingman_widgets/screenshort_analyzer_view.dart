import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../network/models/craft_message_response.dart';
import '../../network/services/craft_message_service.dart';
import '../../widgets/costume_text/costume_text_widget.dart';
import 'reply_card.dart';

class ScreenshortAnalyzerView extends StatefulWidget {
  const ScreenshortAnalyzerView({super.key});

  @override
  State<ScreenshortAnalyzerView> createState() => _ScreenshortAnalyzerViewState();
}

class _ScreenshortAnalyzerViewState extends State<ScreenshortAnalyzerView> {
  // ---- State ----
  File? selectedImage;
  String selectedTone = 'Funny';
  bool isLoading = false;
  CraftMessageResponse? response;
  String? errorMessage;

  // ---- Service (created once, not in build) ----
  final CraftMessageService _service = CraftMessageService();
  final ImagePicker _picker = ImagePicker();

  // ---- Tone options ----
  final List<Map<String, dynamic>> tones = [
    {'label': 'Funny',    'icon': Icons.sentiment_very_satisfied, 'color': Colors.orange},
    {'label': 'Flirty',   'icon': Icons.favorite,                  'color': Colors.pink},
    {'label': 'Angry',    'icon': Icons.local_fire_department,      'color': Colors.red},
    {'label': 'Cute',     'icon': Icons.face,                       'color': Colors.purple},
    {'label': 'Savage',   'icon': Icons.bolt,                       'color': Colors.deepOrange},
    {'label': 'Romantic', 'icon': Icons.favorite_border,            'color': Colors.red},
    {'label': 'Casual',   'icon': Icons.coffee,                     'color': Colors.brown},
  ];

  // ---- Pick image from gallery ----
  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
        response = null;       // clear old response when new image selected
        errorMessage = null;
      });
    }
  }

  // ---- Remove selected image ----
  void _removeImage() {
    setState(() {
      selectedImage = null;
      response = null;
      errorMessage = null;
    });
  }

  // ---- Generate replies ----
  Future<void> _generateReplies() async {
    if (selectedImage == null) {
      setState(() => errorMessage = 'Please select a screenshot first.');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      response = null;
    });

    try {
      final result = await _service.analyzeScreenshot(
        imageFile: selectedImage!,
        instructions: selectedTone,
      );

      if (!mounted) return;

      if (result.success && result.messages.isNotEmpty) {
        setState(() {
          response = result;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'No replies generated. Please try again.';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('CraftMessageService error details: $e');
      // Also show more specific error message to user based on error type
      setState(() {
        if (e.toString().contains('SocketException') || e.toString().contains('NetworkException')) {
          errorMessage = 'Network error. Please check your internet connection.';
        } else if (e.toString().contains('API error: 4')) {
          errorMessage = 'Server rejected the request. Please try again.';
        } else if (e.toString().contains('TimeoutException')) {
          errorMessage = 'Request timed out. The server may be slow. Try again.';
        } else {
          errorMessage = 'Error: ${e.toString()}'; // show real error during development
        }
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.pinkAccent.withOpacity(0.07),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- SECTION 1: Upload Card ----
            _buildUploadCard(),
            const SizedBox(height: 16),

            // ---- SECTION 2: Tone Selector ----
            _buildToneSelector(),
            const SizedBox(height: 16),

            // ---- SECTION 3: Error message ----
            if (errorMessage != null) _buildErrorBanner(),

            // ---- SECTION 4: Generate Button ----
            _buildGenerateButton(),
            const SizedBox(height: 20),

            // ---- SECTION 5: Results ----
            if (response != null) _buildResultsSection(),
          ],
        ),
      ),
    );
  }

  // =========================================================
  //  Upload Card
  // =========================================================
  Widget _buildUploadCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.file_upload_outlined, color: Colors.blue, size: 22),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CostumeTextWidget(
                      text: 'Upload Screenshot',
                      color: Colors.black,
                      size: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    CostumeTextWidget(
                      text: 'PNG, JPG up to 10MB',
                      color: Colors.grey,
                      size: 11,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Show image preview OR upload area
            selectedImage == null ? _buildUploadArea() : _buildImagePreview(),

            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.lock_outline, color: Colors.blue, size: 12),
                const SizedBox(width: 4),
                CostumeTextWidget(
                  text: 'Your data is private & secure',
                  color: Colors.blue,
                  size: 11,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1.5, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.blue.withOpacity(0.6)),
            const SizedBox(height: 8),
            CostumeTextWidget(
              text: 'Tap to upload a screenshot',
              color: Colors.blue,
              size: 13,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 4),
            CostumeTextWidget(
              text: 'of your chat conversation',
              color: Colors.grey,
              size: 11,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            selectedImage!,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              // Change button
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.edit, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text('Change', style: TextStyle(color: Colors.white, fontSize: 11)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Remove button
              GestureDetector(
                onTap: _removeImage,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  //  Tone Selector
  // =========================================================
  Widget _buildToneSelector() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CostumeTextWidget(
              text: 'Choose Tone',
              color: Colors.black,
              size: 14,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tones.map((tone) {
                final bool isSelected = selectedTone == tone['label'];
                final Color toneColor = tone['color'] as Color;
                return GestureDetector(
                  onTap: () => setState(() => selectedTone = tone['label'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? toneColor : toneColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? toneColor : toneColor.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tone['icon'] as IconData,
                          size: 14,
                          color: isSelected ? Colors.white : toneColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          tone['label'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : toneColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  //  Error Banner
  // =========================================================
  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  //  Generate Button
  // =========================================================
  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _generateReplies,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink,
          disabledBackgroundColor: Colors.pink.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        child: isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text('Analyzing...', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              )
            : const Text(
                'Generate Replies ✨',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  // =========================================================
  //  Results Section
  // =========================================================
  Widget _buildResultsSection() {
    final r = response!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Context card ----
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.pink.shade50,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.pink, size: 18),
                    const SizedBox(width: 6),
                    CostumeTextWidget(
                      text: 'AI understood the conversation',
                      color: Colors.pink,
                      size: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
                if (r.recipientName != null && r.recipientName!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _infoRow(Icons.person_outline, 'Recipient', r.recipientName!),
                ],
                if (r.situation != null && r.situation!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _infoRow(Icons.chat_bubble_outline, 'Situation', r.situation!),
                ],
                if (r.processingTime != null) ...[
                  const SizedBox(height: 6),
                  _infoRow(Icons.timer_outlined, 'Processed in', '${r.processingTime}ms'),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ---- Replies heading ----
        Row(
          children: [
            const Icon(Icons.chat_rounded, color: Colors.pink, size: 18),
            const SizedBox(width: 6),
            CostumeTextWidget(
              text: 'Suggested Replies (${r.messages.length})',
              color: Colors.black87,
              size: 14,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ---- Reply cards ----
        ...r.messages.map((msg) => ReplyCard(message: msg)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
