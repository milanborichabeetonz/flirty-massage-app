import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Reusable follow-up chat input widget supporting:
/// - Text input (multiline 1..4 lines)
/// - Image upload (gallery or camera)
/// - Image preview with remove button
/// - Keyboard & SafeArea safe layout
/// - Disabled send button when empty
class FollowUpInputWidget extends StatefulWidget {
  const FollowUpInputWidget({
    super.key,
    required this.onSend,
    this.controller,
    this.isLoading = false,
    this.onTryAgain,
    this.hintText = 'Ask a follow-up...',
    this.primaryColor = const Color(0xFF7C3AED),
    this.gradientColors = const [Color(0xFF7C3AED), Color(0xFF9F67F0)],
  });

  final Function(String text, File? imageFile) onSend;
  final TextEditingController? controller;
  final bool isLoading;
  final VoidCallback? onTryAgain;
  final String hintText;
  final Color primaryColor;
  final List<Color> gradientColors;

  @override
  State<FollowUpInputWidget> createState() => _FollowUpInputWidgetState();
}

class _FollowUpInputWidgetState extends State<FollowUpInputWidget> {
  late final TextEditingController _controller;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isTextEmpty = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _isTextEmpty = _controller.text.trim().isEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final empty = _controller.text.trim().isEmpty;
    if (empty != _isTextEmpty) {
      setState(() {
        _isTextEmpty = empty;
      });
    }
  }

  bool get _canSend =>
      !widget.isLoading && (!_isTextEmpty || _selectedImage != null);

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library_rounded, color: widget.primaryColor),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_rounded, color: widget.primaryColor),
                title: const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _handleSend() {
    if (!_canSend) return;

    final text = _controller.text.trim();
    final image = _selectedImage;

    _controller.clear();
    setState(() {
      _selectedImage = null;
      _isTextEmpty = true;
    });

    widget.onSend(text, image);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Optional Try Again button
            if (widget.onTryAgain != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: widget.isLoading ? null : widget.onTryAgain,
                    icon: Icon(
                      Icons.refresh_rounded,
                      size: 18,
                      color: widget.primaryColor,
                    ),
                    label: Text(
                      'Try Again',
                      style: TextStyle(
                        color: widget.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: widget.primaryColor,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

            // Image Preview Bar
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: _removeImage,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Image attached',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            _selectedImage!.path.split('/').last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _removeImage,
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                      tooltip: 'Remove Image',
                    ),
                  ],
                ),
              ),

            // Input Row: [ Image Picker ] [ TextField ] [ Send ]
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Image Upload Button on the left
                  IconButton(
                    onPressed: widget.isLoading ? null : _showImagePickerOptions,
                    icon: Icon(
                      _selectedImage != null
                          ? Icons.add_photo_alternate_rounded
                          : Icons.add_photo_alternate_outlined,
                      color: _selectedImage != null ? widget.primaryColor : Colors.grey.shade600,
                      size: 24,
                    ),
                    tooltip: 'Attach Image',
                  ),
                  const SizedBox(width: 4),

                  // Text Field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EEFF),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: widget.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        textAlignVertical: TextAlignVertical.center,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send Button
                  GestureDetector(
                    onTap: _canSend ? _handleSend : null,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _canSend
                              ? widget.gradientColors
                              : [Colors.grey.shade300, Colors.grey.shade400],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: widget.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
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
