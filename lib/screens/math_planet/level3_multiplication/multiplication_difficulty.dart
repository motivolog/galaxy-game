import 'package:flutter/material.dart';
import 'multiplication_page.dart';
import 'multiplication_question_generator.dart';

class MultiplicationDifficultyPage extends StatelessWidget {
  const MultiplicationDifficultyPage({super.key});

  void _start(
      BuildContext context, {
        required Difficulty difficulty,
        int targetCorrect = 8,
      }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiplicationLevelPage(
          targetCorrect: targetCorrect,
          difficulty: difficulty,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 600;

    Widget btn(String label, IconData icon, VoidCallback onTap) => SizedBox(
      width: isWide ? 540 : w * .86,
      height: 64,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1F2B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0E1224), Color(0xFF0B0F1D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Çarpma Zorluğu',
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  btn('Kolay', Icons.auto_awesome,
                          () => _start(context, difficulty: Difficulty.easy, targetCorrect: 10)),
                  const SizedBox(height: 16),

                  btn('Orta', Icons.psychology,
                          () => _start(context, difficulty: Difficulty.medium, targetCorrect: 10)),
                  const SizedBox(height: 16),

                  btn('Zor', Icons.rocket_launch,
                          () => _start(context, difficulty: Difficulty.hard, targetCorrect: 10)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}