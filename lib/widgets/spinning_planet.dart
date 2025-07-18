import 'dart:math' as math;
import 'package:flutter/material.dart';

class SpinningPlanet extends StatefulWidget {
  const SpinningPlanet({super.key});

  @override
  State<SpinningPlanet> createState() => _SpinningPlanetState();
}

class _SpinningPlanetState extends State<SpinningPlanet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final bounce = math.sin(_controller.value * 2 * math.pi * 4) * 20;
        return Transform.translate(
          offset: Offset(0, bounce),
          child: Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: child,
          ),
        );
      },
      child: Image.asset(
        'assets/images/gezegen_kartlar.png',
        width: 250,
        height: 250,
        semanticLabel: 'Eşleştirme gezegeni',
      ),
    );
  }
}
