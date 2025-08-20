import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AlienLottie extends StatefulWidget {
  const AlienLottie({
    super.key,
    required this.progressX,
    this.shakeTrigger = 0,
  });

  final double progressX;
  final int shakeTrigger;

  @override
  State<AlienLottie> createState() => _AlienLottieState();
}

class _AlienLottieState extends State<AlienLottie>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _t; // 0..1

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _t = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void didUpdateWidget(covariant AlienLottie oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shakeTrigger != oldWidget.shakeTrigger) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = _isTablet(context);
    final double spriteSize = isTablet ? 290 : 140;
    final double bottom     = isTablet ? 90  : 55;
    final double start      = size.width * (isTablet ? .04 : .05);
    final double end        = size.width * .80;

    final progress = widget.progressX.clamp(0.0, 1.0);
    final xBase = start + (end - start) * progress;

    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) {
        final amp = (spriteSize * 0.07) * (1 - _t.value);
        final dx  = math.sin(_t.value * math.pi * 8) * amp;
        final rot = math.sin(_t.value * math.pi * 8) * (1 - _t.value) * 0.03;

        return Positioned(
          left: xBase + dx,
          bottom: bottom,
          child: Transform.rotate(
            angle: rot,
            child: SizedBox(
              width: spriteSize,
              height: spriteSize,
              child: const _AlienSprite(),
            ),
          ),
        );
      },
    );
  }
}

class _AlienSprite extends StatelessWidget {
  const _AlienSprite();

  @override
  Widget build(BuildContext context) {
    return Lottie.asset('assets/animations/division_monster.json');
  }
}

class DoorView extends StatelessWidget {
  const DoorView({
    super.key,
    required this.label,
    required this.onTap,
    required this.imageAsset,
    this.disabled = false,
    this.width = 120,
    this.height = 180,
  });

  final String label;
  final VoidCallback onTap;
  final bool disabled;
  final double width;
  final double height;

  final String imageAsset;

  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = _isTablet(context);
    final double scale = isTablet ? 1.0 : 1.0;

    final double effWidth  = width  * scale;
    final double effHeight = height * scale;

    final Radius r = Radius.circular(18 * scale);
    final BorderRadius radius = BorderRadius.all(r);
    final double fontSize = (effHeight * 0.28)
        .clamp(18.0, isTablet ? 56.0 : 40.0)
        .toDouble();

    Widget body = ClipRRect(
      borderRadius: radius,
      child: Stack(
        children: [
          Image.asset(
            imageAsset,
            width: effWidth,
            height: effHeight,
            fit: BoxFit.cover,
          ),
          Container(
            width: effWidth,
            height: effHeight,
            color: Colors.black.withOpacity(disabled ? 0.20 : 0.08),
          ),
        ],
      ),
    );

    return Opacity(
      opacity: disabled ? 0.7 : 1,
      child: SizedBox(
        width: effWidth,
        height: effHeight,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: disabled ? null : onTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                body,
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: const [
                      Shadow(blurRadius: 6, color: Colors.black87, offset: Offset(0, 0)),
                      Shadow(blurRadius: 6, color: Colors.black87, offset: Offset(1, 1)),
                      Shadow(blurRadius: 6, color: Colors.black87, offset: Offset(-1, 1)),
                      Shadow(blurRadius: 6, color: Colors.black87, offset: Offset(1, -1)),
                      Shadow(blurRadius: 6, color: Colors.black87, offset: Offset(-1, -1)),
                    ],
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
