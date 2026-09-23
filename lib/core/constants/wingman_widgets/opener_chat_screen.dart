import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/network/services/craft_message_service.dart';

class OpenerChatScreen extends StatefulWidget {
  final String name;
  final String interests;
  final String tone;
  final String userId;

  const OpenerChatScreen({
    super.key,
    required this.name,
    required this.interests,
    required this.tone,
    required this.userId,
  });

  @override
  State<OpenerChatScreen> createState() => _OpenerChatScreenState();
}

class _OpenerChatScreenState extends State<OpenerChatScreen> {
  final CraftMessageService _service = CraftMessageService();
  final TextEditingController _followUpController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isFollowUpLoading = false;
  String? _errorMessage;

  // Chat history: list of maps with type: 'user_context' | 'user_message' | 'ai' | 'error'
  final List<Map<String, dynamic>> _chatHistory = [];

  @override
  void initState() {
    super.initState();
    _generateInitial();
  }

  @override
  void dispose() {
    _followUpController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String get _toneInstruction {
    switch (widget.tone.toLowerCase()) {
      case 'flirty':
        return 'bold and flirty';
      case 'romantic':
        return 'romantic and sweet';
      case 'funny':
        return 'funny and witty';
      case 'confident':
        return 'confident and bold';
      case 'bold':
        return 'bold and direct';
      case 'soft':
        return 'soft and gentle';
      default:
        return widget.tone.toLowerCase();
    }
  }

  Future<void> _generateInitial() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final profileText =
          'Generate opening messages for ${widget.name} who is interested in ${widget.interests}';
      final result = await _service.generateOpener(
        profileText: profileText,
        instructions: _toneInstruction,
        existingUserId: widget.userId,
      );
      if (!mounted) return;
      setState(() {
        _chatHistory.add({
          'type': 'user_context',
          'name': widget.name,
          'interests': widget.interests,
          'tone': widget.tone,
        });
        _chatHistory.add({
          'type': 'ai',
          'messages': result.messages,
        });
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to generate. Please try again.';
        _isLoading = false;
      });
      debugPrint('generateInitial error: $e');
    }
  }

  Future<void> _sendFollowUp() async {
    final text = _followUpController.text.trim();
    if (text.isEmpty) return;

    _followUpController.clear();
    setState(() {
      _isFollowUpLoading = true;
      _chatHistory.add({'type': 'user_message', 'text': text});
    });

    _scrollToBottom();

    try {
      final result = await _service.generateOpener(
        profileText: text,
        instructions: _toneInstruction,
        existingUserId: widget.userId,
      );
      if (!mounted) return;
      setState(() {
        _chatHistory.add({'type': 'ai', 'messages': result.messages});
        _isFollowUpLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _chatHistory.add({'type': 'error', 'text': 'Failed. Try again.'});
        _isFollowUpLoading = false;
      });
      debugPrint('followUp error: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _copyMessage(String msg) {
    Clipboard.setData(ClipboardData(text: msg));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _shareMessage(String msg) => SharePlus.instance.share(ShareParams(text: msg));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EEFF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF9F67F0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Personalized Openers',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Powered by AI ✨',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF7C3AED)),
                        SizedBox(height: 14),
                        Text(
                          'Generating openers...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : _errorMessage != null && _chatHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 40,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _generateInitial,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7C3AED),
                              ),
                              child: const Text(
                                'Retry',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(14),
                        itemCount:
                            _chatHistory.length + (_isFollowUpLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _chatHistory.length &&
                              _isFollowUpLoading) {
                            return _buildTypingIndicator();
                          }
                          final item = _chatHistory[index];
                          if (item['type'] == 'user_context') {
                            return _buildUserContextBubble(item);
                          } else if (item['type'] == 'user_message') {
                            return _buildUserMessageBubble(
                                item['text'] as String);
                          } else if (item['type'] == 'ai') {
                            return _buildAiResponseCard(
                                item['messages'] as List<String>);
                          } else if (item['type'] == 'error') {
                            return _buildErrorItem(item['text'] as String);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
          ),

          // Bottom bar: Try Again + follow-up input
          if (!_isLoading)
            Container(
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Try Again button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isFollowUpLoading
                            ? null
                            : () {
                                setState(() {
                                  _chatHistory.clear();
                                });
                                _generateInitial();
                              },
                        icon: const Icon(
                          Icons.refresh_rounded,
                          size: 18,
                          color: Color(0xFF7C3AED),
                        ),
                        label: const Text(
                          'Try Again',
                          style: TextStyle(
                            color: Color(0xFF7C3AED),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF7C3AED),
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
                  // Follow-up input
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      12,
                      4,
                      12,
                      MediaQuery.of(context).viewInsets.bottom + 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3EEFF),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFF7C3AED)
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: TextField(
                              controller: _followUpController,
                              decoration: const InputDecoration(
                                hintText: 'Ask a follow-up...',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                              onSubmitted: (_) => _sendFollowUp(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap:
                              _isFollowUpLoading ? null : _sendFollowUp,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF7C3AED),
                                  Color(0xFF9F67F0),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: _isFollowUpLoading
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
        ],
      ),
    );
  }

  // User context bubble (right side, purple gradient)
  Widget _buildUserContextBubble(Map<String, dynamic> item) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 60),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF9F67F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '👤 Name: ${item['name']}',
              style:
                  const TextStyle(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              '🎯 Interests: ${item['interests']}',
              style:
                  const TextStyle(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              '🎨 Tone: ${item['tone']}',
              style:
                  const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // User follow-up bubble (right side, purple gradient)
  Widget _buildUserMessageBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 60),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF9F67F0)],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }

  // AI response card (left side, white card with bot avatar)
  Widget _buildAiResponseCard(List<String> messages) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.only(top: 4, right: 8),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF9F67F0)],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.smart_toy_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16, right: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              children: messages.asMap().entries.map((entry) {
                final isLast = entry.key == messages.length - 1;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(14, 12, 14, 4),
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1A1A1A),
                          height: 1.5,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(10, 0, 10, 8),
                      child: Row(
                        children: [
                          _smallActionBtn(
                            Icons.copy_rounded,
                            () => _copyMessage(entry.value),
                          ),
                          const SizedBox(width: 6),
                          _smallActionBtn(
                            Icons.send_rounded,
                            () => _shareMessage(entry.value),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      const Divider(
                        height: 1,
                        color: Color(0xFFEEEEEE),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _smallActionBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDDDDDD)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: const Color(0xFF888888)),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF9F67F0)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF7C3AED),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Thinking...',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorItem(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          text,
          style: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      ),
    );
  }
}
