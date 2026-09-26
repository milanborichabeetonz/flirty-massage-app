import 'package:flutter/material.dart';
import '../../../core/repositories/saved_content_repository.dart';
import '../models/love_test_result.dart';
import 'love_tester_result_screen.dart';

class SavedLoveTestsScreen extends StatefulWidget {
  const SavedLoveTestsScreen({super.key});

  @override
  State<SavedLoveTestsScreen> createState() => _SavedLoveTestsScreenState();
}

class _SavedLoveTestsScreenState extends State<SavedLoveTestsScreen> {
  final SavedContentRepository _repository = SavedContentRepository();
  List<LoveTestResult> _savedTests = [];
  bool _isLoading = true;

  static const Color _purple = Color(0xFF7C3AED);

  @override
  void initState() {
    super.initState();
    _loadSavedTests();
  }

  Future<void> _loadSavedTests() async {
    setState(() => _isLoading = true);
    final tests = await _repository.getSavedLoveTests();
    if (!mounted) return;
    setState(() {
      _savedTests = tests;
      _isLoading = false;
    });
  }

  Future<void> _deleteTest(LoveTestResult result) async {
    await _repository.deleteLoveTest(result);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Love test removed.'),
        duration: Duration(seconds: 1),
      ),
    );
    _loadSavedTests();
  }

  void _openResult(LoveTestResult result) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoveTesterResultScreen(result: result),
      ),
    ).then((_) => _loadSavedTests());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Saved Love Tests',
          style: TextStyle(
            color: Color(0xFF161616),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _purple))
          : _savedTests.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border_rounded,
                          size: 64,
                          color: _purple.withValues(alpha: 0.35),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No saved love tests yet',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap the bookmark icon on any Love Tester Result screen to save it here for offline viewing.',
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
                  itemCount: _savedTests.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final test = _savedTests[index];

                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        onTap: () => _openResult(test),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: _purple.withValues(alpha: 0.15)),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: _purple.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${test.score}%',
                                    style: const TextStyle(
                                      color: _purple,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${test.yourName} ❤️ ${test.theirName}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF161616),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${test.verdictLabel} • ${test.category}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
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
                                onPressed: () => _deleteTest(test),
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
