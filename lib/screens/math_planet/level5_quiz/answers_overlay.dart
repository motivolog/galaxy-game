import 'package:flutter/material.dart';
import 'level5_meteor_quiz.dart';

class AnswersOverlay extends StatelessWidget {
  const AnswersOverlay({super.key, required this.game});
  final Level5MeteorQuizGame game;

  @override
  Widget build(BuildContext context) {
    final q = game.currentQuestion;
    final disabled = game.state != QuizState.presenting || q == null;

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
                minimumSize: const Size(120, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                opt.toString(),
                style: const TextStyle(
                  fontSize: 20,
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
