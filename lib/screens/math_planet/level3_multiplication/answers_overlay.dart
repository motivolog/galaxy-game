import 'dart:ui';
import 'package:flutter/material.dart';
import 'multiplication_question_generator.dart';
import 'cosmic_pirates_game.dart';

class AnswersOverlay extends StatelessWidget {
  const AnswersOverlay({super.key, required this.game});
  final PiratesMultiplyGame game;

  @override
  Widget build(BuildContext context) {
    final q = game.currentQuestion;
    final disabled = game.state != QuizState.presenting || q == null;
    final options = q?.options ?? const <int>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(3, (i) {
                  final filled = i < game.lives;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      filled ? Icons.favorite : Icons.favorite_border,
                      color: filled ? Colors.pinkAccent : Colors.white54,
                    ),
                  );
                }),
              ),

              Builder(builder: (context) {
                final total = game.targetCorrect.clamp(1, 999);
                final done = game.correctCount.clamp(0, total);
                final ratio = done / total;

                final screenW = MediaQuery.of(context).size.width;
                final double barWidth = (screenW > 700) ? 240.0 : 180.0;
                const double barHeight = 12.0;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      Container(
                        width: barWidth,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: const Color(0x22000000),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFFFA726), width: 2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                width: barWidth * ratio,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  gradient: const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(0xFFFFA726),
                                      Color(0xFFFFD180),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          "$done/$total",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                constraints: const BoxConstraints(minHeight: 64),
                decoration: BoxDecoration(
                  color: const Color(0xB30B0F1D),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0x3300D1FF), Color(0x1100FFAA), Color(0x00000000)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      q?.text ?? "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        shadows: [
                          Shadow(blurRadius: 6, color: Color(0x6600D1FF), offset: Offset(0, 1)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        const Spacer(),

        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
          child: Row(
            children: List.generate(options.length.clamp(0, 3), (i) {
              final opt = options[i];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: i == 0 ? 4 : 8,
                    right: i == (options.length.clamp(0, 3) - 1) ? 4 : 8,
                  ),
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: disabled ? null : () => game.onAnswerSelected(opt),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1E2A),
                        disabledBackgroundColor: const Color(0xFF121520),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.white.withOpacity(0.08)),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        "$opt",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
