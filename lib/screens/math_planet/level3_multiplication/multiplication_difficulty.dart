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
    final media = MediaQuery.of(context);
    final size = media.size;
    final shortest = size.shortestSide;
    final isTablet = shortest >= 600;

    final scale = isTablet ? 1.8 : 1.0;
    final titleSize = (22.0 * scale).clamp(22.0, 48.0);
    final buttonHeight = (56.0 * scale).clamp(56.0, 100.0);
    final buttonTextSize = (16.0 * scale).clamp(16.0, 34.0);
    final verticalGapLarge = (24.0 * scale).clamp(24.0, 54.0);
    final verticalGap = (12.0 * scale).clamp(12.0, 34.0);
    final radius = Radius.circular((22.0 * scale).clamp(22.0, 44.0));
    final maxContentWidth = isTablet ? 800.0 : 420.0;
    final horizontalPadding = EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20);

    Widget btn(String label, IconData icon, VoidCallback onTap) => SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1F2B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(radius)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: buttonTextSize + 2),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: buttonTextSize, fontWeight: FontWeight.w700),
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
          child: Stack(
            children: [
              // Top-left bigger back arrow
              Positioned(
                left: 4,
                top: 4,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  iconSize: isTablet ? 36 : 30,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
                ),
              ),

              // Centered content
              Center(
                child: SingleChildScrollView(
                  padding: horizontalPadding,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: isTablet ? 72 : 56,
                          child: Center(
                            child: Text(
                              'Çarpma Zorluğu',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: titleSize,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: verticalGapLarge),

                        btn('Kolay', Icons.auto_awesome,
                                () => _start(context, difficulty: Difficulty.easy, targetCorrect: 10)),
                        SizedBox(height: verticalGap),

                        btn('Orta', Icons.psychology,
                                () => _start(context, difficulty: Difficulty.medium, targetCorrect: 10)),
                        SizedBox(height: verticalGap),

                        btn('Zor', Icons.rocket_launch,
                                () => _start(context, difficulty: Difficulty.hard, targetCorrect: 10)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}