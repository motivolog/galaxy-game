import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'level5_meteor_quiz.dart';
import 'answers_overlay.dart';
import 'package:flutter_projects/screens/math_planet/tts_manager.dart';
import 'package:flutter_projects/screens/math_planet/speech_text.dart';
import 'package:flutter_projects/analytics_helper.dart';
import 'package:audioplayers/audioplayers.dart';

class Level5MeteorQuizPage extends StatefulWidget {
  const Level5MeteorQuizPage({super.key});

  @override
  State<Level5MeteorQuizPage> createState() => _Level5MeteorQuizPageState();
}

class _Level5MeteorQuizPageState extends State<Level5MeteorQuizPage> {
  late Level5MeteorQuizGame game;
  bool _ended = false;
  static const String kStarLottie = 'assets/animations/star_madal.json';
  @override
  void initState() {
    super.initState();

    // ANALYTICS: ekran + süre başlangıcı + level start
    ALog.screen('level5_meteor_quiz');
    ALog.startTimer('level5_meteor_quiz');
    ALog.levelStart('math', 5, difficulty: 'mixed');

    game = Level5MeteorQuizGame(
      onFinished: _onFinished,
      onUiRefresh: () => setState(() {}),
      onNewQuestion: (int a, String op, int b) {
        final speech = mathQuestionToSpeech(a: a, op: op, b: b);
        final id = '$a$op$b';
        TTSManager.instance.speak(speech, id: id);
        ALog.e('math5_new_question', params: {
          'a': a, 'op': op, 'b': b, 'idx': game.currentIndex,
        });
      },
      onCorrectAnswer: (int a, String op, int b) async {
        final ans = mathAnswerToSpeech(a: a, op: op, b: b);
        await TTSManager.instance.speakNow(ans);
        ALog.e('math5_answer_correct', params: {
          'a': a, 'op': op, 'b': b, 'idx': game.currentIndex,
        });
      },
    );
  }

  Future<void> _endTimerOnce() async {
    if (_ended) return;
    _ended = true;
    await ALog.endTimer('level5_meteor_quiz'); // 'screen_time_ms' event'i
  }

  Future<void> _onFinished() async {
    await TTSManager.instance.stop();

    // ANALYTICS: bitiş + özet
    ALog.levelComplete(
      'math',
      5,
      score: game.correctCount,
      mistakes: (game.totalQuestions - game.correctCount),
      durationMs: 0,
    );
    ALog.e('math5_finished', params: {
      'correct': game.correctCount,
      'total': game.totalQuestions,
    });

    await _endTimerOnce();
    try { game.pauseEngine(); } catch (_) {}
    if (!mounted) return;

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => const MedalFinishPage(
          lottiePath: kStarLottie,
        ),
        transitionsBuilder: (ctx, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  Future<void> _handleBack() async {
    await ALog.tap('math_l5_back', place: 'page_top_left');
    await TTSManager.instance.stop();
    await _endTimerOnce();
    try { game.pauseEngine(); } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    TTSManager.instance.stop();
    try { game.pauseEngine(); } catch (_) {}
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
                        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
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

            // geri
            Positioned(
              top: posInset, left: posInset,
              child: Semantics(
                label: 'Geri',
                button: true,
                child: IconButton(
                  tooltip: 'Geri',
                  icon: Icon(
                    Icons.arrow_back,
                    size: iconSize,
                    color: Colors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF81C784),
                    padding: EdgeInsets.all(buttonPadding),
                    shape: const CircleBorder(),
                  ),
                  onPressed: _handleBack,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class MedalFinishPage extends StatefulWidget {
  const MedalFinishPage({super.key, required this.lottiePath});
  final String lottiePath;

  @override
  State<MedalFinishPage> createState() => _MedalFinishPageState();
}

class _MedalFinishPageState extends State<MedalFinishPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;
  late final AudioPlayer _sfx;

  @override
  void initState() {
    super.initState();
    ALog.screen('medal_finish');

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _scale = Tween(begin: 0.94, end: 1.08)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_pulse);
    _sfx = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _sfx.play(AssetSource('audio/planet3/quizsucces.mp3'));
  }

  @override
  void dispose() {
    _pulse.dispose();
    _sfx.stop();
    _sfx.dispose();
    super.dispose();
  }
  Future<void> _exit() async {
    try { await _sfx.stop(); } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1D),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/planet3/quizbg.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _exit,
              child: LayoutBuilder(
                builder: (context, c) {
                  final bool isTablet = c.maxWidth >= 600;
                  final double widthFactor = isTablet ? 0.86 : 0.88;
                  final double targetW = c.maxWidth * widthFactor;
                  return Center(
                    child: Transform.translate(
                      offset: const Offset(0, -38),
                      child: ScaleTransition(
                        scale: _scale,
                        child: Lottie.asset(
                          widget.lottiePath,
                          width: targetW,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          repeat: true,
                          animate: true,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
