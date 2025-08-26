import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'division_game.dart';
import 'ui.dart';
import 'components.dart';
import 'package:flutter_projects/screens/math_planet/tts_manager.dart';
import 'package:flutter_projects/screens/math_planet/speech_text.dart';

class DivisionPage extends StatefulWidget {
  const DivisionPage({super.key, required this.difficulty});
  final String difficulty;

  @override
  State<DivisionPage> createState() => _DivisionPageState();
}

class _DivisionPageState extends State<DivisionPage> {
  late DivisionGame game;

  bool get isTablet {
    final mq = MediaQuery.maybeOf(context);
    if (mq == null) return false;
    return mq.size.shortestSide >= 600;
  }
  @override
  void initState() {
    super.initState();
    game = DivisionGame(
      difficulty: widget.difficulty,
      onUiRefresh: () => setState(() {}),
      onFinished: _onFinished,
      onNewQuestion: (int a, int b) {
        final s = mathQuestionToSpeech(a: a, op: '÷', b: b);
        final id = '$a÷$b';
        TTSManager.instance.speak(s, id: id);
      },
      onCorrectAnswer: (int a, int b) async {
        final ans = mathAnswerToSpeech(a: a, op: '÷', b: b);
        await TTSManager.instance.speakNow(ans);
      },
    );
  }

  Future<void> _onFinished() async {
    await TTSManager.instance.stop();

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Tebrikler!'),
        content: const Text('Uzay canavarı kapıdan kaçtı '),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Future.microtask(() => Navigator.of(context).pop());
            },
            child: const Text('Tamam'),
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
    final qText = game.current?.text ?? '';

    final double rightPad = isTablet ? 160 : 120;
    final double backSize = isTablet ? 64 : 44;
    final double backIcon = isTablet ? 30 : 24;
    final double backPad = isTablet ? 16 : 12;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1D),
      body: SafeArea(
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
                    prominent: true, capsule: true, showProgress: false,
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
            DoorsOverlay(
              game: game, gap: 2.0,
            ),
            Positioned(
              top: backPad, left: backPad,
              child: SafeArea(
                child: Semantics(
                  label: 'Geri', button: true,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await TTSManager.instance.stop();
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
                        child: Icon(
                          Icons.arrow_back, color: Colors.white, size: backIcon,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
