import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'level1_addition/addition_difficulty.dart';
import 'level2_subtraction/subtraction_difficulty.dart';
import 'level3_multiplication/multiplication_difficulty.dart';
import 'level4_division/division_difficulty.dart';
import 'level5_quiz/level5_meteor_quiz_page.dart';
import 'package:flutter_projects/analytics_helper.dart'; // <-- ALog

class LevelSelectMathScreen extends StatefulWidget {
  const LevelSelectMathScreen({super.key, this.incomingPlayer});
  final AudioPlayer? incomingPlayer;

  @override
  State<LevelSelectMathScreen> createState() => _LevelSelectMathScreenState();
}

class _LevelSelectMathScreenState extends State<LevelSelectMathScreen> {
  late final AudioPlayer _player;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer()
      ..setReleaseMode(ReleaseMode.stop)
      ..setPlayerMode(PlayerMode.mediaPlayer);

    // Analytics: ekran + gezegen + süre sayacı
    ALog.screen('math_level_select', clazz: 'LevelSelectMathScreen');
    ALog.planetOpened('math');
    ALog.startTimer('screen:math_level_select');
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();

    // Analytics: ekranda kalma süresi
    ALog.endTimer('screen:math_level_select', metric: 'screen_time_ms');

    super.dispose();
  }

  Future<void> _playTapSoundAndWait(String? assetPath) async {
    if (assetPath == null) return;
    try {
      await widget.incomingPlayer?.stop();
      await _player.stop();
      await _player.play(AssetSource(assetPath));
      await _player.onPlayerComplete.first.timeout(const Duration(seconds: 2));
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  Future<void> _go(
      Widget page, {
        String? soundAsset,
        required String tapId, // <-- analytics id
      }) async {
    if (_navigating) return;
    _navigating = true;

    HapticFeedback.selectionClick();

    // Analytics: buton tıklama
    ALog.tap(tapId, place: 'math_level_select');

    await _playTapSoundAndWait(soundAsset);

    if (!mounted) {
      _navigating = false;
      return;
    }
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    _navigating = false;
  }

  Future<void> _onBack() async {
    HapticFeedback.selectionClick();
    // Analytics: geri
    ALog.tap('back_btn', place: 'math_level_select');

    try {
      await widget.incomingPlayer?.stop();
      await _player.stop();
    } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortest = size.shortestSide;
    final bool isTablet = shortest >= 600;
    final double btnWidth  = isTablet
        ? (size.width * 0.22).clamp(160, 240).toDouble()
        : (size.width * 0.18).clamp(120, 200).toDouble();
    final double btnHeight = isTablet
        ? (shortest / 6.8).clamp(70, 100).toDouble()
        : (shortest / 7.9).clamp(59, 84).toDouble();
    final double symbolSize = isTablet
        ? (shortest / 10).clamp(60, 75).toDouble()
        : (shortest / 12).clamp(50, 52).toDouble();
    final double gapH = isTablet ? 30 : 28;
    final double gapW = isTablet ? 22 : 20;
    final double topPad = isTablet
        ? (shortest / 5.5).clamp(80, 140).toDouble()
        : (shortest / 4.5).clamp(50, 90).toDouble();

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
              'assets/images/planet3/mathlevelback.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              filterQuality: FilterQuality.high,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, left: 12),
              child: GestureDetector(
                onTap: _onBack,
                child: Container(
                  width: isTablet ? 72 : 54,
                  height: isTablet ? 72 : 54,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8C7BFA),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: isTablet ? 40 : 32,
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 28, top: topPad, bottom: 26),
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
                          tapId: 'open_addition',
                        ),
                      ),
                      SizedBox(width: gapW),
                      btn(
                        symbol: '−',
                        semantics: 'Çıkarma',
                        onTap: () => _go(
                          const SubtractionDifficultyPage(),
                          soundAsset: 'audio/planet3/minus.mp3',
                          tapId: 'open_subtraction',
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
                          tapId: 'open_multiplication',
                        ),
                      ),
                      SizedBox(width: gapW),
                      btn(
                        symbol: '÷',
                        semantics: 'Bölme',
                        onTap: () => _go(
                          const DivisionDifficultyPage(),
                          soundAsset: 'audio/planet3/divide.mp3',
                          tapId: 'open_division',
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
                      tapId: 'open_quiz',
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
