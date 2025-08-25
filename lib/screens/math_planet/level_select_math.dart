import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'level1_addition/addition_difficulty.dart';
import 'level2_subtraction/subtraction_difficulty.dart';
import 'level3_multiplication/multiplication_difficulty.dart';
import 'level4_division/division_difficulty.dart';
import 'level5_quiz/level5_meteor_quiz_page.dart';

class LevelSelectMathScreen extends StatefulWidget {
  const LevelSelectMathScreen({super.key});

  @override
  State<LevelSelectMathScreen> createState() => _LevelSelectMathScreenState();
}

class _LevelSelectMathScreenState extends State<LevelSelectMathScreen> {
  late final AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playTapSound(String? assetPath) async {
    if (assetPath == null) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } catch (_) {
    }
  }

  void _go(Widget page, {String? soundAsset}) async {
    HapticFeedback.selectionClick();
    await _playTapSound(soundAsset);
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortest = size.shortestSide;
    final double btnWidth  = (size.width * 0.18).clamp(120, 200).toDouble();
    final double btnHeight = (shortest / 7.9).clamp(59, 84).toDouble();
    final double gapH = 28, gapW = 20;
    final double symbolSize = (shortest / 12).clamp(50, 52).toDouble();

    Widget btn({
      required String symbol,
      required String semantics,
      required VoidCallback onTap,
    }) {
      return _CubeButton(
        width: btnWidth,
        height: btnHeight,
        symbol: symbol,
        symbolSize: symbolSize,
        onTap: onTap,
        semanticsLabel: semantics,
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/planet3/mathlevel_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              filterQuality: FilterQuality.high,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 28, top: 24, bottom: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      btn(
                        symbol: '+',
                        semantics: 'Toplama',
                        onTap: () => _go(
                          const AdditionDifficultyPage(),
                          soundAsset: 'audio/planet3/plus.mp3',
                        ),
                      ),
                      SizedBox(width: gapW),
                      btn(
                        symbol: '−',
                        semantics: 'Çıkarma',
                        onTap: () => _go(
                          const SubtractionDifficultyPage(),
                          soundAsset: 'audio/planet3/minus.mp3',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: gapH),
                  Row(
                    children: [
                      btn(
                        symbol: '×',
                        semantics: 'Çarpma',
                        onTap: () => _go(
                          const MultiplicationDifficultyPage(),
                          soundAsset: 'audio/planet3/multiplication.mp3',
                        ),
                      ),
                      SizedBox(width: gapW),
                      btn(
                        symbol: '÷',
                        semantics: 'Bölme',
                        onTap: () => _go(
                          const DivisionDifficultyPage(),
                          soundAsset: 'audio/planet3/divide.mp3',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: gapH),
                  btn(
                    symbol: '?',
                    semantics: 'Quiz',
                    onTap: () => _go(
                      const Level5MeteorQuizPage(),
                      soundAsset: 'audio/planet3/quiz.mp3',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _CubeButton extends StatefulWidget {
  const _CubeButton({
    required this.width,
    required this.height,
    required this.symbol,
    required this.symbolSize,
    required this.onTap,
    required this.semanticsLabel,
  });

  final double width;
  final double height;
  final String symbol;
  final double symbolSize;
  final VoidCallback onTap;
  final String semanticsLabel;

  @override
  State<_CubeButton> createState() => _CubeButtonState();
}

class _CubeButtonState extends State<_CubeButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const topColor = Color(0xFFA999FF);
    const midColor = Color(0xFF8C7BFA);
    const botColor = Color(0xFF5E50D9);

    return Semantics(
      button: true,
      label: widget.semanticsLabel,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          width: widget.width,
          height: widget.height,
          transform: Matrix4.identity()
            ..translate(0.0, _pressed ? 2.0 : 0.0)
            ..scale(_pressed ? 0.98 : 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [topColor, midColor, botColor],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 10),
              ),
              const BoxShadow(
                color: Color(0x40FFFFFF),
                blurRadius: 8,
                spreadRadius: -2,
                offset: Offset(-3, -3),
              ),
            ],
          ),
          foregroundDecoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.centerRight,
              colors: [Color(0x22FFFFFF), Color(0x00000000)],
            ),
          ),
          child: Center(
            child: Text(
              widget.symbol,
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.symbolSize,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
