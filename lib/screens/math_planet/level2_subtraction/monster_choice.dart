import 'dart:math';
import 'package:flutter/material.dart';

const String kAlienAsset = 'assets/images/secenek_alien.png';

class MonsterChoice extends StatefulWidget {
  const MonsterChoice({
    super.key,
    required this.label,
    required this.palette,
    required this.shaking,
    required this.popping,
    required this.onTap,
    required this.fontSize,
    required this.height,
    required this.phase,
    this.glowing = false,
  });

  final String label;
  final List<Color> palette;
  final bool shaking;
  final bool popping;
  final bool glowing;
  final VoidCallback? onTap;
  final double fontSize;
  final double height;
  final double phase;

  @override
  State<MonsterChoice> createState() => _MonsterChoiceState();
}

class _MonsterChoiceState extends State<MonsterChoice>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idle;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(kAlienAsset), context);
  }

  @override
  void dispose() {
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height;

    final double targetScale   = widget.popping ? 0.78 : 1.0;
    final double targetOpacity = widget.popping ? 0.0  : 1.0;
    final double shakeTurns    = widget.shaking ? 0.015 : 0.0;

    return AnimatedOpacity(
      opacity: targetOpacity,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: AnimatedRotation(
        turns: shakeTurns,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: AnimatedScale(
          scale: targetScale,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;

              return AnimatedBuilder(
                animation: _idle,
                builder: (_, __) {
                  final t = _idle.value * 2 * pi + widget.phase;
                  final double idleAngle = sin(t) * 0.035; // ~2°
                  final double idleDy    = cos(t) * 2.0;

                  return GestureDetector(
                    onTap: widget.onTap,
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          bottom: h * 0.02,
                          child: Container(
                            width: w * 0.55,
                            height: h * 0.10,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.28),
                              borderRadius: BorderRadius.circular(h),
                              boxShadow: const [BoxShadow(blurRadius: 16, color: Colors.black38)],
                            ),
                          ),
                        ),

                        Align(
                          alignment: const Alignment(0, 0.22),
                          child: AnimatedOpacity(
                            opacity: widget.glowing ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            child: Container(
                              width: w * 0.62,
                              height: h * 0.62,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  center: Alignment(0, 0),
                                  radius: 0.9,
                                  colors: [Color(0x55FFFFFF), Color(0x11FFFFFF), Colors.transparent],
                                  stops: [0.0, 0.55, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(0, idleDy),
                          child: Transform.rotate(
                            angle: idleAngle,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned.fill(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: w * 0.06,
                                      vertical: h * 0.04,
                                    ),
                                    child: RepaintBoundary(
                                      child: Image.asset(
                                        kAlienAsset,
                                        fit: BoxFit.contain,
                                        filterQuality: FilterQuality.high,
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: const Alignment(0, 0.45),
                                  child: LayoutBuilder(
                                    builder: (context, c2) {
                                      final double numFs =
                                      (h * 0.22).clamp(18.0, 44.0).toDouble();
                                      return FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Stack(
                                          children: [
                                            Text(
                                              widget.label,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: numFs,
                                                fontWeight: FontWeight.w900,
                                                foreground: Paint()
                                                  ..style = PaintingStyle.stroke
                                                  ..strokeWidth = max(1.6, numFs * 0.09)
                                                  ..color = Colors.white.withOpacity(0.90),
                                              ),
                                            ),
                                            Text(
                                              widget.label,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: numFs,
                                                fontWeight: FontWeight.w900,
                                                color: const Color(0xFF10233F),
                                                letterSpacing: 0.2,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black.withOpacity(0.35),
                                                    blurRadius: numFs * 0.15,
                                                    offset: Offset(0, numFs * 0.05),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
