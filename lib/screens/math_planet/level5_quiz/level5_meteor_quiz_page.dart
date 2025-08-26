import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'level5_meteor_quiz.dart';
import 'answers_overlay.dart';
import 'package:flutter_projects/screens/math_planet/tts_manager.dart';
import 'package:flutter_projects/screens/math_planet/speech_text.dart';

class Level5MeteorQuizPage extends StatefulWidget {
  const Level5MeteorQuizPage({super.key});

  @override
  State<Level5MeteorQuizPage> createState() => _Level5MeteorQuizPageState();
}

class _Level5MeteorQuizPageState extends State<Level5MeteorQuizPage> {
  late Level5MeteorQuizGame game;

  @override
  void initState() {
    super.initState();
    game = Level5MeteorQuizGame(
      onFinished: _onFinished,
      onUiRefresh: () => setState(() {}),
      onNewQuestion: (int a, String op, int b) {
        final speech = mathQuestionToSpeech(a: a, op: op, b: b);
        final id = '$a$op$b';
        TTSManager.instance.speak(speech, id: id);
      },
      onCorrectAnswer: (int a, String op, int b) async {
        final ans = mathAnswerToSpeech(a: a, op: op, b: b);
        await TTSManager.instance.speakNow(ans);
      },
    );
  }

  Future<void> _onFinished() async {
    await TTSManager.instance.stop();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    TTSManager.instance.stop();
    game.pauseEngine();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.shortestSide >= 600;
    final double progress = game.totalQuestions == 0
        ? 0
        : (game.currentIndex.clamp(0, game.totalQuestions) /
        game.totalQuestions);
    final iconSize = isTablet ? 32.0 : 24.0;
    final buttonPadding = isTablet ? 18.0 : 12.0;
    final posInset = isTablet ? 20.0 : 14.0;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GameWidget(game: game),
            AnswersOverlay(game: game),
            Positioned(
              top: 16,
              right: 16,
              child: IgnorePointer(
                ignoring: true,
                child: SizedBox(
                  width: isTablet ? 220 : 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(isTablet ? 12 : 8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: isTablet ? 16 : 10,
                          backgroundColor: Colors.white.withOpacity(0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF81C784),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${game.currentIndex}/${game.totalQuestions}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isTablet ? 16 : 12,
                          fontWeight: FontWeight.w600,
                          shadows: const [
                            Shadow(offset: Offset(0, 1), blurRadius: 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: posInset,
              left: posInset,
              child: Semantics(
                label: 'Geri',
                button: true,
                child: IconButton(
                  tooltip: 'Geri',
                  icon: Icon(Icons.arrow_back,
                      size: iconSize, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF81C784),
                    padding: EdgeInsets.all(buttonPadding),
                    shape: const CircleBorder(),
                  ),
                  onPressed: () async {
                    await TTSManager.instance.stop();
                    if (mounted) Navigator.pop(context);
                  },
                ),
              ),
            ),
            if (game.state == QuizState.finished)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Tebrikler!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${game.correctCount}/${game.totalQuestions} doğru",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          await TTSManager.instance.stop();
                          if (mounted) Navigator.pop(context);
                        },
                        child: const Text("Level ekranına dön"),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
