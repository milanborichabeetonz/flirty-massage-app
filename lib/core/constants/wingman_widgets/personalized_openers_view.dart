import 'package:flutter/material.dart';
import 'opener_chat_screen.dart';

class PersonalizedOpenersView extends StatefulWidget {
  const PersonalizedOpenersView({super.key});

  @override
  State<PersonalizedOpenersView> createState() =>
      _PersonalizedOpenersViewState();
}

class _PersonalizedOpenersViewState extends State<PersonalizedOpenersView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _customInterestsController =
      TextEditingController();
  final Set<String> _selectedInterests = {};
  String _selectedTone = 'Flirty';

  static const Color _purple = Color(0xFF7C3AED);
  static const Color _purpleLight = Color(0xFFF3EEFF);
  static const Color _purpleBorder = Color(0xFFD8B4FE);

  final List<Map<String, String>> _interests = const [
    {'label': 'Travel', 'emoji': '✈️'},
    {'label': 'Gym', 'emoji': '💪'},
    {'label': 'Coffee', 'emoji': '☕'},
    {'label': 'Music', 'emoji': '🎵'},
    {'label': 'Anime', 'emoji': '🎌'},
    {'label': 'Fashion', 'emoji': '👗'},
    {'label': 'Gaming', 'emoji': '🎮'},
    {'label': 'Pets', 'emoji': '🐾'},
  ];

  final List<Map<String, String>> _tones = const [
    {'label': 'Flirty', 'emoji': '💜', 'sub': 'Playful & charming'},
    {'label': 'Romantic', 'emoji': '❤️', 'sub': 'Sweet & heartfelt'},
    {'label': 'Funny', 'emoji': '😊', 'sub': 'Witty & light'},
    {'label': 'Confident', 'emoji': '👑', 'sub': 'Bold & assured'},
    {'label': 'Bold', 'emoji': '🔥', 'sub': 'Direct & daring'},
    {'label': 'Soft', 'emoji': '🌿', 'sub': 'Gentle & warm'},
  ];

  final List<String> _quickNames = const [
    'Emily',
    'Sophia',
    'Ava',
    'Isabella',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _customInterestsController.dispose();
    super.dispose();
  }

  void _generate() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name first')),
      );
      return;
    }

    final allInterests = [..._selectedInterests];
    final custom = _customInterestsController.text.trim();
    if (custom.isNotEmpty) allInterests.add(custom);
    final interestsStr =
        allInterests.isEmpty ? 'general' : allInterests.join(', ');

    final userId =
        'visitor_${DateTime.now().millisecondsSinceEpoch}_session';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OpenerChatScreen(
          name: name,
          interests: interestsStr,
          tone: _selectedTone,
          userId: userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF8F4FF),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameCard(),
            const SizedBox(height: 16),
            _buildInterestsCard(),
            const SizedBox(height: 16),
            _buildToneCard(),
            const SizedBox(height: 20),
            _buildGenerateButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ─── Card 1: Name ───────────────────────────────────────────────────────────

  Widget _buildNameCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Who are you messaging?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Enter their name',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: _purple, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Quick Suggestion',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF9F67F0),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickNames
                .map((name) => _nameChip(name))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _nameChip(String name) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _nameController.text = name;
          _nameController.selection = TextSelection.fromPosition(
            TextPosition(offset: name.length),
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: _purpleLight,
          border: Border.all(color: _purpleBorder),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          name,
          style: const TextStyle(
            color: _purple,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ─── Card 2: Interests ───────────────────────────────────────────────────────

  Widget _buildInterestsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What are they into?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _interests
                .map((item) => _interestChip(
                      item['label']!,
                      item['emoji']!,
                    ))
                .toList(),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _customInterestsController,
            decoration: InputDecoration(
              hintText: 'Or type interests (e.g., hiking, cooking)',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: _purple, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _interestChip(String label, String emoji) {
    final isSelected = _selectedInterests.contains(label);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedInterests.remove(label);
          } else {
            _selectedInterests.add(label);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? _purpleLight : Colors.white,
          border: Border.all(
            color: isSelected ? _purple : const Color(0xFFDDDDDD),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? _purple : const Color(0xFF555555),
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Card 3: Tone ────────────────────────────────────────────────────────────

  Widget _buildToneCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pick the tone',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.4,
            ),
            itemCount: _tones.length,
            itemBuilder: (context, index) {
              final tone = _tones[index];
              return _toneCard(
                tone['label']!,
                tone['emoji']!,
                tone['sub']!,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _toneCard(String label, String emoji, String sub) {
    final isSelected = _selectedTone == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTone = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? _purpleLight : Colors.white,
          border: Border.all(
            color: isSelected ? _purple : const Color(0xFFDDDDDD),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _purple.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? _purple
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF888888),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Generate button ─────────────────────────────────────────────────────────

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF9F67F0)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: ElevatedButton(
          onPressed: _generate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Generate My Opener ✨',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Helper: plain Card wrapper ──────────────────────────────────────────────

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
