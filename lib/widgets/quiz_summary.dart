import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../screens/quiz_screen.dart';

class QuizSummary extends StatefulWidget {
  final int score;
  final int total;

  const QuizSummary({required this.score, required this.total, super.key});

  @override
  State<QuizSummary> createState() => _QuizSummaryState();
}

class _QuizSummaryState extends State<QuizSummary> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(
      begin: 0,
      end: widget.score.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getPerformanceMessage() {
    final percentage = (widget.score / widget.total) * 100;
    if (percentage == 100) return "Perfect Score! 🏆";
    if (percentage >= 80) return "Excellent Work! 🌟";
    if (percentage >= 60) return "Good Job! 👍";
    if (percentage >= 40) return "Nice Try! 💪";
    return "Keep Practicing! 📚";
  }

  Color _getPerformanceColor() {
    final percentage = (widget.score / widget.total) * 100;
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.blue;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getPerformanceColor().withOpacity(0.3),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Quiz Complete!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Text(
                        _getPerformanceMessage(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: _getPerformanceColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: AnimatedBuilder(
                            animation: _scoreAnimation,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: CircularProgressPainter(
                                  progress: _scoreAnimation.value / widget.total,
                                  color: _getPerformanceColor(),
                                ),
                              );
                            },
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _scoreAnimation,
                              builder: (context, child) {
                                return Text(
                                  '${_scoreAnimation.value.toInt()}',
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: _getPerformanceColor(),
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                            Text(
                              'out of ${widget.total}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        children: [
                          _buildStatCard(
                            'Accuracy',
                            '${((widget.score / widget.total) * 100).toStringAsFixed(1)}%',
                            Icons.analytics_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildStatCard(
                            'Questions',
                            '${widget.total} completed',
                            Icons.check_circle_outline,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const QuizScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[200],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_sharp),
                      label: const Text(
                        'Try Again',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: _getPerformanceColor()),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}