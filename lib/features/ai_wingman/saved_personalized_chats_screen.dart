import 'package:flutter/material.dart';
import '../../core/constants/wingman_widgets/opener_chat_screen.dart';
import '../../core/models/saved_chat_model.dart';
import '../../core/repositories/personalized_chat_repository.dart';

class SavedPersonalizedChatsScreen extends StatefulWidget {
  const SavedPersonalizedChatsScreen({super.key});

  @override
  State<SavedPersonalizedChatsScreen> createState() =>
      _SavedPersonalizedChatsScreenState();
}

class _SavedPersonalizedChatsScreenState
    extends State<SavedPersonalizedChatsScreen> {
  final PersonalizedChatRepository _repository = PersonalizedChatRepository();
  List<SavedChatModel> _savedChats = [];
  bool _isLoading = true;

  static const Color _purple = Color(0xFF7C3AED);

  @override
  void initState() {
    super.initState();
    _loadSavedChats();
  }

  Future<void> _loadSavedChats() async {
    setState(() => _isLoading = true);
    final chats = await _repository.getSavedChats();
    if (!mounted) return;
    setState(() {
      _savedChats = chats;
      _isLoading = false;
    });
  }

  Future<void> _deleteChat(String id) async {
    await _repository.deleteChat(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chat removed from saved.'),
        duration: Duration(seconds: 1),
      ),
    );
    _loadSavedChats();
  }

  void _openChat(SavedChatModel chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OpenerChatScreen(
          name: chat.name,
          interests: chat.interests,
          tone: chat.tone,
          userId: chat.userId,
          conversationId: chat.id,
          initialChatHistory: chat.chatHistory,
        ),
      ),
    ).then((_) => _loadSavedChats());
  }

  String _getPreviewSnippet(List<Map<String, dynamic>> history) {
    for (final item in history.reversed) {
      if (item['type'] == 'ai' &&
          item['messages'] is List &&
          (item['messages'] as List).isNotEmpty) {
        return (item['messages'] as List).first.toString();
      }
      if (item['type'] == 'user_message' &&
          item['text'] != null &&
          item['text'].toString().isNotEmpty) {
        return item['text'].toString();
      }
    }
    return 'Chat conversation';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Saved Personalized Chats',
          style: TextStyle(
            color: Color(0xFF161616),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _purple))
          : _savedChats.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border_rounded,
                          size: 64,
                          color: _purple.withValues(alpha: 0.35),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No saved chats yet',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap the bookmark icon at the top right of any Personalized Openers chat screen to save it here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _savedChats.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final chat = _savedChats[index];
                    final snippet = _getPreviewSnippet(chat.chatHistory);

                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () => _openChat(chat),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE8E8E8)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [_purple, Color(0xFF9F67F0)],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.chat_bubble_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            chat.name,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF161616),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _purple.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            chat.tone,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: _purple,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Interests: ${chat.interests}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      snippet,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF444444),
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                onPressed: () => _deleteChat(chat.id),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
