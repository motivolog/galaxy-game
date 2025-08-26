import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'space_background.dart';
import 'subtraction_question.dart';
import 'operation_panel.dart';
import 'monster_choice.dart';
import 'package:flutter_projects/screens/math_planet/tts_manager.dart';
import 'package:flutter_projects/screens/math_planet/speech_text.dart';

class SubtractionLevelPage extends StatefulWidget {
  const SubtractionLevelPage({
    super.key,
    required this.maxA,
    required this.maxB,
    this.targetCorrect = 6,
  });

  final int maxA;
  final int maxB;
  final int targetCorrect;

  @override
  State<SubtractionLevelPage> createState() => _SubtractionLevelPageState();
}

class _SubtractionLevelPageState extends State<SubtractionLevelPage>
    with TickerProviderStateMixin {
  final Random _random = Random();
  late SubtractionQuestion question;
  int correct = 0;
  bool lockingUi = false;

  bool pulseHint = false;
  int? shakeIndex;
  int? popIndex;

  AnimationController? _qmPulseCtrl;
  AnimationController? _rewardCtrl;

  void _ensureControllers() {
    _qmPulseCtrl ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _rewardCtrl ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
  }

  @override
  void initState() {
    super.initState();
    question = SubtractionQuestion.generate(_random, widget.maxA, widget.maxB);
    _ensureControllers();
    Future.microtask(_speakCurrentQuestion);
  }

  @override
  void dispose() {
    TTSManager.instance.stop();
    _qmPulseCtrl?.dispose();
    _rewardCtrl?.dispose();
    super.dispose();
  }

  Future<void> _onPickAt(int index) async {
    if (lockingUi) return;
    final value = question.options[index];
    final isRight = value == question.answer;
    await TTSManager.instance.stop();

    if (isRight) {
      setState(() {
        lockingUi = true;
        popIndex = index;
        correct++;
      });
      final ansText = mathAnswerToSpeech(a: question.a, op: '-', b: question.b);
      await TTSManager.instance.speakNow(ansText);
      _rewardCtrl!.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 320));
      if (!mounted) return;
      if (correct >= widget.targetCorrect) {
        await _completeLevel();
        return;
      }
      setState(() {
        question =
            SubtractionQuestion.generate(_random, widget.maxA, widget.maxB);
        lockingUi = false;
        popIndex = null;
      });
      _speakCurrentQuestion();
    } else {
      HapticFeedback.lightImpact();
      setState(() {
        pulseHint = true;
        shakeIndex = index;
      });
      await Future.delayed(const Duration(milliseconds: 260));
      if (!mounted) return;
      setState(() {
        pulseHint = false;
        shakeIndex = null;
      });

      final size = MediaQuery.of(context).size;
      final isTablet = size.shortestSide >= 600;
      final panelH = isTablet ? 180.0 : 150.0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bir daha dene'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: panelH + 16, left: 16, right: 16),
        ),
      );
      _speakCurrentQuestion();
    }
  }

  Future<void> _completeLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('math_level2_done', true);

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        title: Text('Tebrikler!'),
        content: Text('Çıkarma seviyesini tamamladın.'),
      ),
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }
  void _speakCurrentQuestion() {
    final speech = mathQuestionToSpeech(a: question.a, op: '-', b: question.b);
    final qid = '${question.a}-${question.b}';
    TTSManager.instance.speakOnce(speech, id: qid);
  }

  @override
  Widget build(BuildContext context) {
    _ensureControllers();
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    final double panelH = isTablet ? 180 : 150;
    final double gap = isTablet ? 16 : 12;
    final double bottomPad = 18;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const SpaceBackground(),

            // üst bar
            Positioned(
              top: 8, left: 8, right: 8,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: correct / widget.targetCorrect,
                          minHeight: isTablet ? 14 : 10,
                          backgroundColor: Colors.white10,
                          valueColor:
                          const AlwaysStoppedAnimation(Color(0xFF66E0FF)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Doğru: $correct / ${widget.targetCorrect}',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: isTablet ? 18 : 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Align(
              alignment: const Alignment(0, -0.45),
              child: OperationPanel(
                a: question.a,
                b: question.b,
                qmPulse: CurvedAnimation(
                    parent: _qmPulseCtrl!, curve: Curves.easeInOut),
                reward: _rewardCtrl!,
                isTablet: isTablet,
                pulseHint: pulseHint,
              ),
            ),

            Positioned(
              left: 12, right: 12, bottom: bottomPad,
              child: SizedBox(
                height: panelH,
                child: Row(
                  children: [
                    for (int i = 0; i < question.options.length; i++) ...[
                      Expanded(
                        child: MonsterChoice(
                          label: '${question.options[i]}',
                          palette: _paletteFor(i),
                          shaking: shakeIndex == i,
                          popping: popIndex == i,
                          glowing: popIndex == i,
                          phase: i * 0.9,
                          onTap: lockingUi ? null : () => _onPickAt(i),
                          fontSize: isTablet ? 22.0 : 18.0,
                          height: panelH,
                        ),
                      ),
                      if (i != question.options.length - 1)
                        SizedBox(width: gap),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _paletteFor(int i) {
    switch (i % 3) {
      case 0:
        return const [Color(0xFF6FD36B), Color(0xFF2A9D4A)];
      case 1:
        return const [Color(0xFFB57BE3), Color(0xFF6C3FB4)];
      default:
        return const [Color(0xFF5CE1E6), Color(0xFF2A9DA6)];
    }
  }
}
