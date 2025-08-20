import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'division_game.dart';
import 'ui.dart';
import 'components.dart';

class DivisionPage extends StatefulWidget {
  const DivisionPage({super.key, required this.difficulty});
  final String difficulty;

  @override
  State<DivisionPage> createState() => _DivisionPageState();
}

class _DivisionPageState extends State<DivisionPage> {
  late DivisionGame game;

  @override
  void initState() {
    super.initState();
    game = DivisionGame(
      difficulty: widget.difficulty,
      onUiRefresh: () => setState(() {}),
      onFinished: _onFinished,
    );
  }
  void _onFinished() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Tebrikler!'),
        content: const Text('Uzay canavarı kapıdan kaçtı 🚀'),
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
  Widget build(BuildContext context) {
    final qText = game.current?.text ?? '';

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
                      padding: const EdgeInsets.only(top: 8, right: 120),
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
              game: game,
              gap: 2.0,
            ),
          ],
        ),
      ),
    );
  }
}
