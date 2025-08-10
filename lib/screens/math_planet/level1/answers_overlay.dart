import 'package:flutter/material.dart';
import 'level1_meteor_quiz.dart';

class AnswersOverlay extends StatelessWidget {
  const AnswersOverlay({super.key, required this.game});
  final Level1MeteorQuizGame game;

  @override
  Widget build(BuildContext context) {
    final q = game.currentQuestion;
    final disabled = game.state != QuizState.presenting || q == null;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final bool isTablet = screenWidth > 600;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: (q?.options ?? [])
              .map(
                (opt) => ElevatedButton(
              onPressed: disabled ? null : () => game.onAnswerSelected(opt),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(
                  isTablet ? screenWidth * 0.25 : screenWidth * 0.3,
                  isTablet ? screenHeight * 0.1 : screenHeight * 0.08,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                  vertical: isTablet ? 20 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                opt.toString(),
                style:  TextStyle(
                  fontSize: isTablet ? 20 : 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}
