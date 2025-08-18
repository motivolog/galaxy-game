import 'package:flutter/material.dart';
import 'subtraction_page.dart' show SubtractionLevelPage;

class SubtractionDifficultyPage extends StatelessWidget {
  const SubtractionDifficultyPage({super.key});

  void _start(
      BuildContext context, {
        required int maxA,
        required int maxB,
        required String title,
      }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubtractionLevelPage(
          maxA: maxA,
          maxB: maxB,
          targetCorrect: 6,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    Widget btn(String t, VoidCallback onTap) => SizedBox(
      width: w * .8,
      height: 64,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1F2B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: Text(t, style: const TextStyle(fontSize: 18)),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1D),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Text(
                'Çıkarma • Zorluk Seviyesi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              btn('Kolay', () => _start(context, maxA: 10, maxB: 10, title: 'Kolay')),
              const SizedBox(height: 16),
              btn('Orta', () => _start(context, maxA: 50, maxB: 50, title: 'Orta')),
              const SizedBox(height: 16),
              btn('Zor', () => _start(context, maxA: 100, maxB: 100, title: 'Zor')),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
