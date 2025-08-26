import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'multiplication_question_generator.dart';
import 'cosmic_pirates_game.dart';
import 'answers_overlay.dart';
import 'package:flutter_projects/screens/math_planet/tts_manager.dart';
import 'package:flutter_projects/screens/math_planet/speech_text.dart';

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
  PiratesMultiplyGame? _game;
  double? _lastWorldScale;

  static const String playerLottiePath = 'assets/animations/astronaut_plnt3.json';

  PiratesMultiplyGame _buildGame(double worldScale) {
    return PiratesMultiplyGame(
      targetCorrect: widget.targetCorrect,
      difficulty: widget.difficulty,
      onUiRefresh: () => setState(() {}),
      onFinished: _showFinishDialog,
      worldScale: worldScale,
      onNewQuestion: (int a, int b) {
        final s = mathQuestionToSpeech(a: a, op: '×', b: b);
        final id = '$a×$b';
        TTSManager.instance.speak(s, id: id);
      },
      onCorrectAnswer: (int a, int b) async {
        final ans = mathAnswerToSpeech(a: a, op: '×', b: b);
        await TTSManager.instance.speakNow(ans);
      },
    );
  }

  void _ensureGame(double worldScale) {
    if (_game == null || _lastWorldScale != worldScale) {
      _game = _buildGame(worldScale);
      _lastWorldScale = worldScale;
    }
  }

  Future<void> _showFinishDialog() async {
    await TTSManager.instance.stop();
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0E1224),
        title: const Text('Bravo!', style: TextStyle(color: Colors.white)),
        content: Text(
          'Seviyeyi tamamladın: ${_game!.correctCount}/${_game!.targetCorrect}',
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
  void dispose() {
    TTSManager.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortest = size.shortestSide;
    final bool isTablet = shortest >= 600;
    final double worldScale = isTablet
        ? 1.70
        : (shortest < 360
        ? 1.10
        : (shortest < 390
        ? 1.18
        : (shortest < 430 ? 1.24 : 1.28)));
    _ensureGame(worldScale);

    final double lottieSize = isTablet
        ? (shortest * 0.38).clamp(96.0, 220.0)
        : (shortest * 0.30).clamp(64.0, 150.0);

    final double laneY = size.height * (isTablet ? 0.56 : 0.58);

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
                game: _game!,
                overlayBuilderMap: {
                  'hud': (ctx, _) => AnswersOverlay(game: _game!, uiScale: worldScale),
                },
                initialActiveOverlays: const ['hud'],
              ),
              Positioned(
                left: 24 * worldScale,
                top: laneY - (lottieSize * 0.55),
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
