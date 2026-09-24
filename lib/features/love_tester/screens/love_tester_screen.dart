import 'package:flutter/material.dart';
import '../models/love_test_result.dart';
import '../services/love_tester_service.dart';
import '../widgets/love_test_input.dart';
import '../widgets/love_test_selector.dart';
import 'love_tester_result_screen.dart';

class LoveTesterScreen extends StatefulWidget {
  const LoveTesterScreen({super.key});

  @override
  State<LoveTesterScreen> createState() => _LoveTesterScreenState();
}

class _LoveTesterScreenState extends State<LoveTesterScreen> {
  final _yourNameCtrl = TextEditingController();
  final _theirNameCtrl = TextEditingController();
  final _msg1Ctrl = TextEditingController();
  final _msg2Ctrl = TextEditingController();
  final _service = LoveTesterService();

  String _selectedTest = 'name'; // name | zodiac | chat | personality

  DateTime? _dob1;
  DateTime? _dob2;

  // Personality answers (8 questions, each 0–3 for A–D)
  final List<int?> _answers1 = List.filled(8, null);
  final List<int?> _answers2 = List.filled(8, null);

  String? _validationMsg;

  static const Color _purple = Color(0xFF7C3AED);
  static const Color _lightPurple = Color(0xFFF3F0FF);

  @override
  void dispose() {
    _yourNameCtrl.dispose();
    _theirNameCtrl.dispose();
    _msg1Ctrl.dispose();
    _msg2Ctrl.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() => _validationMsg = null);

    switch (_selectedTest) {
      case 'name':
        _calculateNameMatch();
        break;
      case 'zodiac':
        _calculateZodiacMatch();
        break;
      case 'chat':
        _calculateChatChemistry();
        break;
      case 'personality':
        _calculatePersonalityMatch();
        break;
    }
  }

  void _calculateNameMatch() {
    final your = _yourNameCtrl.text.trim();
    final their = _theirNameCtrl.text.trim();

    if (your.isEmpty && their.isEmpty) {
      setState(() => _validationMsg = 'Please enter both names.');
      return;
    }
    if (your.isEmpty) {
      setState(() => _validationMsg = 'Please enter your name.');
      return;
    }
    if (their.isEmpty) {
      setState(() => _validationMsg = 'Please enter their name.');
      return;
    }

    final normA = your.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    final normB = their.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (normA.isEmpty || normB.isEmpty) {
      setState(() => _validationMsg = 'Please enter valid names containing letters.');
      return;
    }

    final res = _service.calculateNameMatch(your, their);
    final loveResult = LoveTestResult(
      yourName: your,
      theirName: their,
      testType: 'name',
      score: res.score,
      verdictLabel: res.verdictLabel,
      summary: res.summary,
      metrics: res.metrics,
    );
    _navigateToResult(loveResult);
  }

  void _calculateZodiacMatch() {
    final your = _yourNameCtrl.text.trim().isEmpty ? 'You' : _yourNameCtrl.text.trim();
    final their = _theirNameCtrl.text.trim().isEmpty ? 'Them' : _theirNameCtrl.text.trim();

    if (_dob1 == null && _dob2 == null) {
      setState(() => _validationMsg = 'Please select both dates of birth.');
      return;
    }
    if (_dob1 == null) {
      setState(() => _validationMsg = 'Please select your date of birth.');
      return;
    }
    if (_dob2 == null) {
      setState(() => _validationMsg = 'Please select their date of birth.');
      return;
    }

    final res = _service.calculateZodiacMatch(_dob1!, _dob2!);
    final loveResult = LoveTestResult(
      yourName: '$your (${res.sign1})',
      theirName: '$their (${res.sign2})',
      testType: 'zodiac',
      score: res.score,
      verdictLabel: res.verdictLabel,
      summary: res.summary,
      metrics: res.metrics,
    );
    _navigateToResult(loveResult);
  }

  void _calculateChatChemistry() {
    final your = _yourNameCtrl.text.trim().isEmpty ? 'You' : _yourNameCtrl.text.trim();
    final their = _theirNameCtrl.text.trim().isEmpty ? 'Them' : _theirNameCtrl.text.trim();

    final m1 = _msg1Ctrl.text.trim();
    final m2 = _msg2Ctrl.text.trim();

    if (m1.isEmpty && m2.isEmpty) {
      setState(() => _validationMsg = 'Please enter both chat messages.');
      return;
    }
    if (m1.isEmpty) {
      setState(() => _validationMsg = 'Please enter your message.');
      return;
    }
    if (m2.isEmpty) {
      setState(() => _validationMsg = 'Please enter their message.');
      return;
    }

    final res = _service.calculateChatChemistry(m1, m2);
    final loveResult = LoveTestResult(
      yourName: your,
      theirName: their,
      testType: 'chat',
      score: res.score,
      verdictLabel: res.verdictLabel,
      summary: res.summary,
      metrics: res.metrics,
    );
    _navigateToResult(loveResult);
  }

  void _calculatePersonalityMatch() {
    final your = _yourNameCtrl.text.trim().isEmpty ? 'You' : _yourNameCtrl.text.trim();
    final their = _theirNameCtrl.text.trim().isEmpty ? 'Them' : _theirNameCtrl.text.trim();

    if (_answers1.any((a) => a == null) || _answers2.any((a) => a == null)) {
      setState(() => _validationMsg = 'Please answer all questions for both people.');
      return;
    }

    final res = _service.calculatePersonalityMatch(
      _answers1.map((a) => a!).toList(),
      _answers2.map((a) => a!).toList(),
    );

    final loveResult = LoveTestResult(
      yourName: your,
      theirName: their,
      testType: 'personality',
      score: res.score,
      verdictLabel: res.verdictLabel,
      summary: res.summary,
      metrics: res.metrics,
    );
    _navigateToResult(loveResult);
  }

  void _calculateAll() {
    final your = _yourNameCtrl.text.trim();
    final their = _theirNameCtrl.text.trim();

    if (your.isEmpty || their.isEmpty) {
      setState(() {
        _selectedTest = 'name';
        _validationMsg = 'Please enter both names first to calculate all tests.';
      });
      return;
    }

    if (_dob1 == null || _dob2 == null) {
      setState(() {
        _selectedTest = 'zodiac';
        _validationMsg = 'Please select both dates of birth for Zodiac Match.';
      });
      return;
    }

    if (_msg1Ctrl.text.trim().isEmpty || _msg2Ctrl.text.trim().isEmpty) {
      setState(() {
        _selectedTest = 'chat';
        _validationMsg = 'Please enter both chat messages for Chat Chemistry.';
      });
      return;
    }

    if (_answers1.any((a) => a == null) || _answers2.any((a) => a == null)) {
      setState(() {
        _selectedTest = 'personality';
        _validationMsg = 'Please answer all personality questions for both people.';
      });
      return;
    }

    setState(() => _validationMsg = null);

    final allResult = _service.calculateAllTests(
      yourName: your,
      theirName: their,
      dob1: _dob1!,
      dob2: _dob2!,
      msg1: _msg1Ctrl.text.trim(),
      msg2: _msg2Ctrl.text.trim(),
      answers1: _answers1.map((a) => a!).toList(),
      answers2: _answers2.map((a) => a!).toList(),
    );

    _navigateToResult(allResult);
  }

  void _navigateToResult(LoveTestResult result) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoveTesterResultScreen(result: result),
      ),
    );
  }

  Future<void> _pickDate(bool isFirst) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      if (isFirst) {
        _dob1 = picked;
      } else {
        _dob2 = picked;
      }
      _validationMsg = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightPurple,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Love Tester',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header card ────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD6E7), Color(0xFFE8D5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Are You a Match?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF222222),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Enter two names and test your compatibility.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF555555),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text('\u{1F495}', style: TextStyle(fontSize: 40)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Name fields (always visible) ───────────────────
            LoveTextInputField(
              controller: _yourNameCtrl,
              hint: 'Your Name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            LoveTextInputField(
              controller: _theirNameCtrl,
              hint: 'Their Name',
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 16),

            // ── Test selector ──────────────────────────────────
            const Text(
              'Choose a test',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 12),
            LoveTestSelector(
              selectedTest: _selectedTest,
              onSelected: (id) => setState(() {
                _selectedTest = id;
                _validationMsg = null;
              }),
            ),

            const SizedBox(height: 16),

            // ── Dynamic input ──────────────────────────────────
            if (_selectedTest == 'zodiac') _buildZodiacInputs(),
            if (_selectedTest == 'chat') _buildChatInputs(),
            if (_selectedTest == 'personality') _buildPersonalityInputs(),

            // ── Validation message ─────────────────────────────
            if (_validationMsg != null)
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _validationMsg!,
                        style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // ── Calculate button ───────────────────────────────
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9B59B6), Color(0xFFFF6CA1)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9B59B6).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _calculate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Calculate Love Score',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('\u2728', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Calculate All button ───────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _calculateAll,
                icon: const Icon(Icons.favorite_border, color: _purple),
                label: const Text(
                  'Calculate All Tests',
                  style: TextStyle(color: _purple, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: _purple, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Center(
              child: Text(
                'Your data is 100% private and used only for calculations.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZodiacInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        const Text(
          'Date of Birth',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 8),
        LoveTestDatePickerTile(
          label: 'Your Date of Birth',
          date: _dob1,
          onTap: () => _pickDate(true),
        ),
        const SizedBox(height: 10),
        LoveTestDatePickerTile(
          label: 'Their Date of Birth',
          date: _dob2,
          onTap: () => _pickDate(false),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildChatInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        const Text(
          'Chat Messages',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 8),
        LoveTestMultilineField(
          controller: _msg1Ctrl,
          hint: 'Your message or chat text...',
        ),
        const SizedBox(height: 10),
        LoveTestMultilineField(
          controller: _msg2Ctrl,
          hint: 'Their message or chat text...',
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildPersonalityInputs() {
    final questions = PersonalityMatchService.questions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        const Text(
          'Personality Questionnaire',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 4),
        const Text(
          'Select the best answers for both people to evaluate compatibility.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        ...List.generate(questions.length, (i) => _buildQuestionCard(i, questions[i])),
      ],
    );
  }

  Widget _buildQuestionCard(int idx, PersonalityQuestion q) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Q${idx + 1}',
                  style: const TextStyle(
                    color: _purple,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  q.question,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF222222),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // You column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'You:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _purple,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...List.generate(4, (j) {
                      final isSelected = _answers1[idx] == j;
                      return GestureDetector(
                        onTap: () => setState(() => _answers1[idx] = j),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _purple.withValues(alpha: 0.1)
                                : const Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? _purple : const Color(0xFFE5E5E5),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            q.options[j],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? _purple : const Color(0xFF333333),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Them column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Them:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF6CA1),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...List.generate(4, (j) {
                      final isSelected = _answers2[idx] == j;
                      return GestureDetector(
                        onTap: () => setState(() => _answers2[idx] = j),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFF6CA1).withValues(alpha: 0.1)
                                : const Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFF6CA1)
                                  : const Color(0xFFE5E5E5),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            q.options[j],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFFFF6CA1)
                                  : const Color(0xFF333333),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
