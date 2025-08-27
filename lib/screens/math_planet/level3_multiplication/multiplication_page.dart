import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'multiplication_question_generator.dart';
import 'cosmic_pirates_game.dart';
import 'answers_overlay.dart';
import 'package:flutter_projects/screens/math_planet/tts_manager.dart';
import 'package:flutter_projects/screens/math_planet/speech_text.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_projects/screens/math_planet/celebration_galaxy.dart';

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
  final AudioPlayer _fx = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _fx.setReleaseMode(ReleaseMode.stop);
  }

  @override
  void dispose() {
    TTSManager.instance.stop();
    _fx.dispose();
    super.dispose();
  }

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
        TTSManager.instance.speakOnce(s, id: id);
      },
      onCorrectAnswer: (int a, int b) async {
        final ans = mathAnswerToSpeech(a: a, op: '×', b: b);
        await TTSManager.instance.speakNow(ans);
      },
      onWrongAnswer: () async {
        try { await TTSManager.instance.stop(); } catch (_) {}
        try { await _fx.stop(); } catch (_) {}
        try {
          await _fx.play(AssetSource('audio/tekrar_dene.mp3'));
        } catch (_) {}
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
    try { await _fx.stop(); } catch (_) {}
    if (!mounted) return;

    await showCelebrationGalaxy(
      context,
      duration: const Duration(seconds: 4),
    );

    if (!mounted) return;
    Navigator.of(context).pop(true);
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
            children: [Positioned.fill(
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
                overlayBuilderMap: {'hud': (ctx, _) => AnswersOverlay(game: _game!, uiScale: worldScale),
                  'gameover': (ctx, _) {
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: Container(color: Colors.black.withOpacity(0.55)),
                        ),
                        Center(
                          child: Container(
                            width: (isTablet ? 420.0 : 320.0),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0E1224),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Canlar bitti!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Doğru: ${_game!.correctCount}/${_game!.targetCorrect}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          await TTSManager.instance.stop();
                                          try { await _fx.stop(); } catch (_) {}
                                          _game!.restart();
                                          _game!.overlays.remove('gameover');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF2DD4BF),
                                          foregroundColor: Colors.black,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          'Yeniden Dene',
                                          style: TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          await TTSManager.instance.stop();
                                          try { await _fx.stop(); } catch (_) {}
                                          if (mounted) Navigator.of(context).pop(false);
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Colors.white24),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text('Seviye Ekranı'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
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
