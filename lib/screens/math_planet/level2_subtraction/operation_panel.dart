import 'dart:ui';
import 'package:flutter/material.dart';

class OperationPanel extends StatelessWidget {
  const OperationPanel({
    super.key,
    required this.a,
    required this.b,
    required this.qmPulse,
    required this.reward,
    required this.isTablet,
    required this.pulseHint,
  });

  final int a, b;
  final Animation<double> qmPulse;
  final AnimationController reward;
  final bool isTablet;
  final bool pulseHint;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double radius = 28;
    final double cardW = size.width * (isTablet ? 0.8 : 0.88);
    final double cardPad = isTablet ? 22 : 18;
    final double fsNum = isTablet ? 42 : (size.width < 600 ? 32 : 36);
    final double fsSym = fsNum * 0.9;

    return AnimatedScale(
      scale: pulseHint ? 1.04 : 1.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: cardW,
            padding: EdgeInsets.all(cardPad),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0D1C3D).withOpacity(0.60),
                  const Color(0xFF09142B).withOpacity(0.50),
                ],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF000000).withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: reward,
                    builder: (_, __) {
                      final double extra = reward.value * 0.15;
                      return Align(
                        alignment: Alignment(-1 + (DateTime.now().millisecond / 1000), 0),
                        child: Container(
                          width: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.00),
                                Colors.white.withOpacity(0.07 + extra),
                                Colors.white.withOpacity(0.00),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _NumCapsule('$a', fs: fsNum, color: const Color(0xFF78C9FF)),
                      SizedBox(width: fsNum * 0.5),
                      Text('−', style: TextStyle(color: Colors.white, fontSize: fsSym, fontWeight: FontWeight.w800)),
                      SizedBox(width: fsNum * 0.5),
                      _NumCapsule('$b', fs: fsNum, color: const Color(0xFFFF9AD0)),
                      SizedBox(width: fsNum * 0.6),
                      Text('=', style: TextStyle(color: Colors.white, fontSize: fsSym, fontWeight: FontWeight.w800)),
                      SizedBox(width: fsNum * 0.6),
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.94, end: 1.08).animate(qmPulse),
                        child: Text('?', style: TextStyle(color: const Color(0xFFFFF4BF), fontSize: fsNum, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: cardPad + 6,
                  child: AnimatedBuilder(
                    animation: reward,
                    builder: (_, __) {
                      final double t = Curves.easeOut.transform(reward.value);
                      return Opacity(
                        opacity: (1 - t).clamp(0, 1),
                        child: Transform.translate(
                          offset: Offset(0, -40 * t),
                          child: Transform.scale(
                            scale: 0.8 + 0.4 * (1 - t),
                            child: const Icon(Icons.star, color: Color(0xFFFFE071)),
                          ),
                        ),
                      );
                    },
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

class _NumCapsule extends StatelessWidget {
  const _NumCapsule(this.text, {required this.fs, required this.color});
  final String text;
  final double fs;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: fs * 0.36, vertical: fs * 0.18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.85), color.withOpacity(0.58)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fs,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 0.5,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 3)],
        ),
      ),
    );
  }
}
