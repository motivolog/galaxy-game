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
import 'package:flutter_projects/analytics_helper.dart'; // Analytics

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

  //  analytics state
  final Stopwatch _levelSW = Stopwatch();
  bool _finished = false;
  bool _exitLogged = false;
  int _correct = 0;
  int _wrong = 0;

  @override
  void initState() {
    super.initState();
    _fx.setReleaseMode(ReleaseMode.stop);

    //  screen + mode enter + süre
    ALog.screen('math_mul');
    ALog.e('math_mode_enter', params: {
      'mode': 'mul',
      'difficulty': widget.difficulty.name,
      'target': widget.targetCorrect,
    });
    ALog.startTimer('math:mul');
    _levelSW.start();
  }

  @override
  void dispose() {
    if (!_finished && !_exitLogged) {
      final progressPct = ((_correct / widget.targetCorrect) * 100).round();
      ALog.e('math_exit', params: {
        'mode': 'mul',
        'progress_pct': progressPct,
        'reason': 'dispose',
      });
      ALog.endTimer('math:mul', extra: {'mode': 'mul'});
    }
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
      scaleSpeedWithWorld: true,
      onNewQuestion: (int a, int b) {
        final s = mathQuestionToSpeech(a: a, op: '×', b: b);
        final id = '$a×$b';
        TTSManager.instance.speakOnce(s, id: id);

        ALog.e('math_question', params: {
          'mode': 'mul',
          'a': a,
          'b': b,
          'op': '*',
        });
      },
      onCorrectAnswer: (int a, int b) async {
        _correct++;
        ALog.e('math_answer', params: {
          'mode': 'mul',
          'a': a,
          'b': b,
          'op': '*',
          'correct': 1,
        });

        final ans = mathAnswerToSpeech(a: a, op: '×', b: b);
        await TTSManager.instance.speakNow(ans);
      },
      onWrongAnswer: () async {
        _wrong++;
        ALog.e('math_answer', params: {
          'mode': 'mul',
          'op': '*',
          'correct': 0,
        });

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

    final timeMs = _levelSW.elapsedMilliseconds;
    _levelSW.stop();
    ALog.e('math_level_complete', params: {
      'mode': 'mul',
      'time_ms': timeMs,
      'q_total': widget.targetCorrect,
      'q_correct': _correct,
      'q_wrong': _wrong,
      'difficulty': widget.difficulty.name,
    });
    ALog.endTimer('math:mul', extra: {'mode': 'mul'});
    _finished = true;

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

    final double hudScale = isTablet ? 1.18 : worldScale.clamp(1.0, 1.22);

    final double lottieSize = isTablet
        ? (shortest * 0.38).clamp(96.0, 220.0)
        : (shortest * 0.30).clamp(64.0, 150.0);
    final double laneY = size.height * (isTablet ? 0.58 : 0.58);

    return WillPopScope(
      onWillPop: () async {
        final progressPct = ((_correct / widget.targetCorrect) * 100).round();
        ALog.tap('back', place: 'math_mul');
        ALog.e('math_exit', params: {
          'mode': 'mul',
          'progress_pct': progressPct,
          'reason': 'back',
        });
        ALog.endTimer('math:mul', extra: {'mode': 'mul'});
        _exitLogged = true;
        return true;
      },
      child: Scaffold(
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

                //  Flame oyun sahnesi
                Positioned.fill(
                  child: GameWidget(
                    game: _game!,
                    overlayBuilderMap: {
                      'hud': (ctx, _) => const SizedBox.shrink(),
                      'gameover': (ctx, _) {
                        final bool t = MediaQuery.of(ctx).size.shortestSide >= 600;
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: Container(color: Colors.black.withOpacity(0.55)),
                            ),
                            Center(
                              child: Container(
                                width: (t ? 420.0 : 320.0),
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
                                              ALog.tap('mul_retry', place: 'mul_gameover');
                                              await TTSManager.instance.stop();
                                              try { await _fx.stop(); } catch (_) {}

                                              _levelSW
                                                ..reset()
                                                ..start();
                                              await ALog.endTimer('math:mul', extra: {'mode': 'mul'});
                                              ALog.startTimer('math:mul');

                                              _correct = 0;
                                              _wrong = 0;

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
                                              final progressPct =
                                              ((_correct / widget.targetCorrect) * 100).round();
                                              ALog.tap('mul_quit', place: 'mul_gameover');
                                              ALog.e('math_exit', params: {
                                                'mode': 'mul',
                                                'progress_pct': progressPct,
                                                'reason': 'gameover_quit',
                                              });
                                              ALog.endTimer('math:mul', extra: {'mode': 'mul'});
                                              _exitLogged = true;

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
                ),

                Positioned(
                  left: 24 * worldScale,
                  top: laneY - (lottieSize * 0.55),
                  width: lottieSize,
                  height: lottieSize,
                  child: const IgnorePointer(
                    ignoring: true,
                    child: _PlayerLottie(),
                  ),
                ),
                Positioned.fill(
                  child: AnswersOverlay(
                    game: _game!,
                    uiScale: hudScale,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class _PlayerLottie extends StatelessWidget {
  const _PlayerLottie();

  static const String _path = 'assets/animations/astronaut_plnt3.json';

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      _path,
      repeat: true,
      animate: true,
    );
  }
}
