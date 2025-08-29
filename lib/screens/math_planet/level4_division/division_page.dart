import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'division_game.dart';
import 'ui.dart';
import 'components.dart';
import 'package:flutter_projects/screens/math_planet/tts_manager.dart';
import 'package:flutter_projects/screens/math_planet/speech_text.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_projects/screens/math_planet/celebration_galaxy.dart';
import 'package:flutter_projects/analytics_helper.dart'; //  Analytics
import 'package:flutter_projects/widgets/accessible_zoom.dart';

class DivisionPage extends StatefulWidget {
  const DivisionPage({super.key, required this.difficulty});
  final String difficulty;

  @override
  State<DivisionPage> createState() => _DivisionPageState();
}

class _DivisionPageState extends State<DivisionPage> {
  late DivisionGame game;
  final AudioPlayer _fx = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  Future<void> _stopAllAudio() async {
    try { await TTSManager.instance.stop(); } catch (_) {}
    try { await _fx.stop(); } catch (_) {}
  }

  //  Analytics state
  late final Stopwatch _sw;
  int _misses = 0;
  bool _finished = false;
  late final int _levelIndex;

  bool get isTablet {
    final mq = MediaQuery.maybeOf(context);
    if (mq == null) return false;
    return mq.size.shortestSide >= 600;
  }

  int _mapLevel(String d) {
    switch (d) {
      case 'easy': return 1;
      case 'hard': return 3;
      case 'medium':
      default: return 2;
    }
  }

  @override
  void initState() {
    super.initState();
    _fx.setReleaseMode(ReleaseMode.stop);

    //  Analytics: ekran + level başlangıcı + süre
    _levelIndex = _mapLevel(widget.difficulty);
    ALog.screen('math_division_game');
    ALog.levelStart('math_division', _levelIndex, difficulty: widget.difficulty);
    ALog.startTimer('game:math_division:${widget.difficulty}');
    _sw = Stopwatch()..start();

    game = DivisionGame(
      difficulty: widget.difficulty,
      onUiRefresh: () => setState(() {}),
      onFinished: _onFinished,
      onNewQuestion: (int a, int b) async {
        await _stopAllAudio();
        final s = mathQuestionToSpeech(a: a, op: '÷', b: b);
        final id = '$a÷$b';
        TTSManager.instance.speakOnce(s, id: id);
      },
      onCorrectAnswer: (int a, int b) async {
        await _stopAllAudio();
        final ans = mathAnswerToSpeech(a: a, op: '÷', b: b);
        try {
          await TTSManager.instance.speakNow(ans).timeout(const Duration(seconds: 2));
        } catch (_) {}
      },
      onWrongAnswer: () async {
        _misses++;
        await _stopAllAudio();
        try { await _fx.play(AssetSource('audio/tekrar_dene.mp3')); } catch (_) {}
      },
    );
  }

  Future<void> _onFinished() async {
    _finished = true;

    // Analytics: level tamamlandı + süre bitti
    final dur = _sw.elapsedMilliseconds;
    ALog.levelComplete(
      'math_division',
      _levelIndex,
      score: game.correctCount,
      mistakes: _misses,
      durationMs: dur,
    );
    ALog.endTimer('game:math_division:${widget.difficulty}', extra: {
      'result': 'completed',
      'correct': game.correctCount,
      'misses': _misses,
    });

    await _stopAllAudio();

    if (!mounted) return;

    await showCelebrationGalaxy(
      context,
      duration: const Duration(seconds: 4),
    );

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    //  Kullanıcı çıkarsa süreyi kapat
    if (!_finished) {
      ALog.endTimer('game:math_division:${widget.difficulty}', extra: {
        'result': 'quit',
        'correct': game.correctCount,
        'misses': _misses,
      });
    }
    TTSManager.instance.stop();
    _fx.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qText = game.current?.text ?? '';
    final double rightPad = isTablet ? 160 : 120;
    final double backSize = isTablet ? 64 : 44;
    final double backIcon = isTablet ? 30 : 24;
    final double backPad = isTablet ? 16 : 12;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1D),
      body: AccessibleZoom(
        persistKey: 'math_access_zoom',
        showButton: false,
        panEnabled: false,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/planet3/dvsn_bg.png',
                  fit: BoxFit.cover,
                ),
              ),

              GameWidget(game: game),

              AlienLottie(
                progressX: game.progress,
                shakeTrigger: game.monsterShakeTick,
              ),

              Positioned.fill(
                child: IgnorePointer(
                  child: Align(
                    alignment: const Alignment(0, -0.78),
                    child: DivisionHud(
                      questionText: qText,
                      progress: game.progress,
                      stepLabel: '${game.correctCount} / ${game.totalQuestions}',
                      prominent: true,
                      capsule: true,
                      showProgress: false,
                    ),
                  ),
                ),
              ),

              Positioned.fill(
                child: IgnorePointer(
                  child: SafeArea(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.only(top: 8, right: rightPad),
                        child: TopRightMiniProgressBar(
                          progress: game.progress,
                          stepLabel: '${game.correctCount} / ${game.totalQuestions}',
                          width: 180,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              DoorsOverlay(game: game, gap: 2.0),


              Positioned(
                top: backPad, left: backPad,
                child: SafeArea(
                  child: Semantics(
                    label: 'Geri',
                    button: true,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          ALog.tap('back', place: 'math_division_game');
                          await _stopAllAudio();
                          if (mounted) Navigator.pop(context);
                        },
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: backSize, height: backSize,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC160A0),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: isTablet ? 10 : 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.arrow_back, color: Colors.white, size: backIcon),
                        ),
                      ),
                    ),
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
