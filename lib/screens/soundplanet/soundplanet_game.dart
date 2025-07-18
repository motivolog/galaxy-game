import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'sound_level1.dart';

class SoundPlanetGame extends StatefulWidget {
  const SoundPlanetGame({super.key});
  @override
  State<SoundPlanetGame> createState() => _SoundPlanetGameState();
}

// ⚠️ MUTLAKA TickerProviderStateMixin
class _SoundPlanetGameState extends State<SoundPlanetGame>
    with TickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounce;

  late final AnimationController _noteCtrl;

  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )
      ..repeat(reverse: true);

    _bounce = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );

    // ▼ Bu satırlar varsa _noteCtrl NULL olamaz
    _noteCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )
      ..repeat();
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _noteCtrl.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _openLevel() async {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SoundLevel1()),
    );
  }

  Widget _animatedNote({
    required String asset,
    required Alignment align,
    required double size,
    required double phase,
  }) {
    return Align(
      alignment: align,
      child: AnimatedBuilder(
        animation: _noteCtrl,
        builder: (_, child) {
          final t = (_noteCtrl.value + phase) % 1.0;
          final angle = 0.25 * math.sin(2 * math.pi * t);
          return Transform.rotate(angle: angle, child: child);
        },
        child: Image.asset(asset, width: size),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const noteSize = 80.0;
    return Scaffold(
      backgroundColor: Colors.blueGrey[200],
      body: GestureDetector(
        onTap: _openLevel,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _bounce,
              builder: (_, child) =>
                  Transform.translate(
                      offset: Offset(0, _bounce.value), child: child),
              child: Image.asset(
                'assets/images/maskot.png',
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.65,
              ),
            ),
            _animatedNote(
              asset: 'assets/images/nota1.png',
              align: const Alignment(-0.75, -0.45),
              size: noteSize,
              phase: 0.0,
            ),
            _animatedNote(
              asset: 'assets/images/nota2.png',
              align: const Alignment(0.40, -0.65),
              size: noteSize,
              phase: 0.25,
            ),
            _animatedNote(
              asset: 'assets/images/nota3.png',
              align: const Alignment(0.90, -0.40),
              size: noteSize,
              phase: 0.5,
            ),
            _animatedNote(
              asset: 'assets/images/nota1.png',
              align: const Alignment(0.80, 0.25),
              size: noteSize,
              phase: 0.75,
            ),
            _animatedNote(
              asset: 'assets/images/nota2.png',
              align: const Alignment(-0.45, 0.50),
              size: noteSize,
              phase: 0.4,
            ),
            _animatedNote(
              asset: 'assets/images/nota3.png',
              align: const Alignment(0.50, 0.60),
              size: noteSize * 0.8,
              phase: 0.9,
            ),
            _animatedNote(
              asset: 'assets/images/nota1.png',
              align: const Alignment(-0.50, 0.80),
              size: noteSize * 0.8,
              phase: 0.6,
            ),
          ],
        ),
      ),
    );
  }
}