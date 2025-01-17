import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/quiz_summary.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _hasError = false;
  bool _showGlow = false;
  bool _isCorrect = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _fetchQuizData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchQuizData() async {
    try {
      final response = await http.get(Uri.parse('https://api.jsonserve.com/Uw5CrX'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _questions = (data['questions'] as List<dynamic>).map((q) {
            return {
              'description': q['description'] ?? 'No question provided',
              'options': (q['options'] as List<dynamic>?)?.map((o) {
                return {
                  'description': o['description'] ?? 'No option provided',
                  'isCorrect': o['is_correct'] ?? false,
                };
              }).toList() ?? [],
            };
          }).toList();
          _isLoading = false;
        });
        _animationController.forward();
      } else {
        throw Exception('Failed to load quiz data');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _answerQuestion(bool isCorrect) async {
    setState(() {
      _showGlow = true;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      _score++;
    }

    await Future.delayed(const Duration(milliseconds: 1000));
    await _animationController.reverse();
    
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _showGlow = false;
      });
      _animationController.forward();
    } else {
      _showSummary();
    }
  }

  void _showSummary() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizSummary(score: _score, total: _questions.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade50,
                Colors.white,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading Quiz...',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_hasError) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.red.shade50,
                Colors.white,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Oops! Something went wrong.',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _fetchQuizData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Question ${_currentIndex + 1}/${_questions.length}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            'Score: $_score',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / _questions.length,
                  backgroundColor: Colors.blue.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 32),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _showGlow
                            ? (_isCorrect ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3))
                            : Colors.black.withOpacity(0.1),
                        blurRadius: _showGlow ? 20 : 8,
                        spreadRadius: _showGlow ? 4 : 0,
                      ),
                    ],
                  ),
                  child: Text(
                    question['description'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView.builder(
                      itemCount: question['options'].length,
                      itemBuilder: (context, index) {
                        final option = question['options'][index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ElevatedButton(
                            onPressed: () => _answerQuestion(option['isCorrect']),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 24,
                              ),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue.shade700,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              option['description'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}