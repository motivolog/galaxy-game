import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'level5_meteor_quiz.dart';
import 'answers_overlay.dart';

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
      onFinished: () => setState(() {}),
      onUiRefresh: () => setState(() {}),
    );
  }

  @override
  void dispose() {
    game.pauseEngine();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GameWidget(game: game),
            AnswersOverlay(game: game),
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
                        onPressed: () => Navigator.pop(context),
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
