import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'multiplication_question_generator.dart';
import 'cosmic_pirates_game.dart';
import 'answers_overlay.dart';

class MultiplicationLevelPage extends StatefulWidget {
  const MultiplicationLevelPage({
    super.key,
    this.targetCorrect = 8,
    this.difficulty = Difficulty.medium,
  });

  final int targetCorrect;
  final Difficulty difficulty;

  @override
  State<MultiplicationLevelPage> createState() => _MultiplicationLevelPageState();
}

class _MultiplicationLevelPageState extends State<MultiplicationLevelPage> {
  late final PiratesMultiplyGame game;

  static const String playerLottiePath = 'assets/animations/astronaut_plnt3.json';

  @override
  void initState() {
    super.initState();
    game = PiratesMultiplyGame(
      targetCorrect: widget.targetCorrect,
      difficulty: widget.difficulty,
      onUiRefresh: () => setState(() {}),
      onFinished: _showFinishDialog,
    );
  }
  void _showFinishDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0E1224),
        title: const Text('Bravo!', style: TextStyle(color: Colors.white)),
        content: Text(
          'Seviyeyi tamamladın: ${game.correctCount}/${game.targetCorrect}',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Seviye Sayfası', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final laneY = screen.height * 0.58;

    final lottieSize = (screen.shortestSide * 0.3).clamp(64.0, 140.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/planet3/math_back.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [

              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0x880B0F1D), Color(0x660B0F1D)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ),

              GameWidget(
                game: game,
                overlayBuilderMap: {
                  'hud': (ctx, _) => AnswersOverlay(game: game),
                },
                initialActiveOverlays: const ['hud'],
              ),

              Positioned(
                left: 24,
                top: laneY - (lottieSize * 0.5),
                width: lottieSize,
                height: lottieSize,
                child: IgnorePointer(
                  child: Lottie.asset(
                    playerLottiePath,
                    repeat: true,
                    animate: true,
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
