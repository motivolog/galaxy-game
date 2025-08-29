import 'package:flutter/material.dart';
import 'level5_meteor_quiz.dart';
import 'package:flutter_projects/analytics_helper.dart';

class AnswersOverlay extends StatelessWidget {
  const AnswersOverlay({super.key, required this.game});
  final Level5MeteorQuizGame game;

  @override
  Widget build(BuildContext context) {
    final q = game.currentQuestion;
    final bool disabled = game.state != QuizState.presenting || q == null;

    if (q == null) {
      return const SizedBox.shrink();
    }

    final shortest = MediaQuery.of(context).size.shortestSide;
    final bool isTablet = shortest >= 600;

    final Size buttonSize = isTablet ? const Size(180, 80) : const Size(120, 56);
    final double fontSize = isTablet ? 26.0 : 20.0;
    final double spacing = isTablet ? 14.0 : 12.0;
    final double bottomPad = isTablet ? 28.0 : 24.0;
    final double sidePad = isTablet ? 18.0 : 16.0;

    final options = q.options;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        minimum: EdgeInsets.only(bottom: bottomPad, left: sidePad, right: sidePad),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isTablet ? 14 : 10,
              horizontal: isTablet ? 12 : 8,
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: spacing,
              runSpacing: spacing,
              children: List.generate(options.length, (i) {
                final opt = options[i];
                return Semantics(
                  label: 'Cevap $opt',
                  button: true,
                  enabled: !disabled,
                  child: ElevatedButton(
                    onPressed: disabled
                        ? null
                        : () async {
                      // Analytics: kullanıcı seçenek tıkladı
                      await ALog.e('math5_choice_tap', params: {
                        'value': opt,
                        'idx': game.currentIndex,
                      });
                      game.onAnswerSelected(opt);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: buttonSize,
                      backgroundColor: Colors.greenAccent.shade100,
                      disabledBackgroundColor: Colors.greenAccent.shade100.withOpacity(0.45),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: Colors.black.withOpacity(0.10)),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      opt.toString(),
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
