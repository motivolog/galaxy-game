import 'dart:ui';
import 'package:flutter/material.dart';
import 'multiplication_question_generator.dart';
import 'cosmic_pirates_game.dart';
import 'package:flutter_projects/widgets/accessible_zoom.dart';

class AnswersOverlay extends StatelessWidget {
  const AnswersOverlay({
    super.key,
    required this.game,
    this.uiScale,
  });

  final PiratesMultiplyGame game;
  final double? uiScale;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final shortest = media.size.shortestSide;
    final bool isTablet = shortest >= 600;
    final double autoPhoneScale = () {
      if (shortest < 360) return 1.08;
      if (shortest < 390) return 1.16;
      if (shortest < 430) return 1.22;
      return 1.28;
    }();
    final double s = uiScale ?? (isTablet ? 1.70 : autoPhoneScale);

    final q = game.currentQuestion;
    final disabled = game.state != QuizState.presenting || q == null;
    final options = q?.options ?? const <int>[];
    final visibleOptions = options.take(3).toList();
    final double padH = 16 * s;
    final double radiusLg = 18 * s;
    final double qMaxH = isTablet ? 120.0 : 96.0;


    final Widget topBlock = Padding(
      padding: EdgeInsets.only(
        left: padH,
        right: padH,
        top: isTablet ? 2.0 : 0.0,
        bottom: isTablet ? 6.0 : 4.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFA726),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      iconSize: 24,
                      padding: const EdgeInsets.all(8),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Row(
                    children: List.generate(3, (i) {
                      final filled = i < game.lives;
                      return Padding(
                        padding: EdgeInsets.only(right: 6 * s),
                        child: Icon(
                          filled ? Icons.favorite : Icons.favorite_border,
                          color: filled ? Colors.pinkAccent : Colors.white54,
                          size: 22 * s,
                        ),
                      );
                    }),
                  ),
                ],
              ),
              Builder(
                builder: (context) {
                  final total = game.targetCorrect.clamp(1, 999);
                  final done = game.correctCount.clamp(0, total);
                  final ratio = done / total;

                  final screenW = media.size.width;
                  final double baseW = isTablet
                      ? (screenW > 1000 ? 320.0 : 260.0)
                      : (screenW > 380 ? 200.0 : 180.0);

                  final double barWidth = baseW *
                      (isTablet ? (0.95 + 0.1 * (s / 1.7)) : (0.95 + 0.08 * (s / 1.22)));
                  final double barHeight = isTablet ? 12.0 : 10.0;

                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 4 * s),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12 * s),
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
                            border: Border.all(color: const Color(0xFFFFA726), width: 2 * s),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Align(
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
                                  colors: [Color(0xFFFFA726), Color(0xFFFFD180)],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 6 * s),
                          child: Text(
                            "$done/$total",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12 * s,
                              fontWeight: FontWeight.w600,
                              shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(padH, 8, padH, 0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: qMaxH),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radiusLg),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 14 : 12,
                      horizontal: isTablet ? 24 : 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xB30B0F1D),
                      borderRadius: BorderRadius.circular(radiusLg),
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
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        q?.text ?? "",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 36 : 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          shadows: const [
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
        ],
      ),
    );
    final Widget bottomBlock = Padding(
      padding: EdgeInsets.fromLTRB(12 * s, 6 * s, 12 * s, 12 * s),
      child: AccessibleZoom(
        persistKey: 'mul_answers_zoom',
        showButton: false,
        panEnabled: false,
        textScaleBoost: isTablet ? 1.10 : 1.20,
        maxScale: isTablet ? 1.40 : 1.60,
        child: Row(
          children: List.generate(visibleOptions.length, (i) {
            final opt = visibleOptions[i];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? 4 * s : 8 * s,
                  right: i == (visibleOptions.length - 1) ? 4 * s : 8 * s,
                ),
                child: SizedBox(
                  height: (isTablet ? 55 : 45) * s,
                  child: ElevatedButton(
                    onPressed: disabled ? null : () => game.onAnswerSelected(opt),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1E2A),
                      disabledBackgroundColor: const Color(0xFF121520),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16 * s),
                        side: BorderSide(color: Colors.white.withOpacity(0.08), width: 1 * s),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      "$opt",
                      style: TextStyle(
                        fontSize: (isTablet ? 28 : 18) * s,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
    return Stack(
      children: [
        Align(alignment: Alignment.topCenter, child: topBlock),
        Align(alignment: Alignment.bottomCenter, child: bottomBlock),
      ],
    );
  }
}