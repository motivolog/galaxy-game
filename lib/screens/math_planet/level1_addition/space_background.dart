import 'dart:math';
import 'package:flutter/material.dart';

class SpaceBackground extends StatelessWidget {
  const SpaceBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        _MainGradient(),
        _NebulaTopLeft(),
        _NebulaBottomRight(),
        _StarField(count: 40, seed: 7, opacity: 0.25),
      ],
    );
  }
}

class _MainGradient extends StatelessWidget {
  const _MainGradient();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF0B1533), Color(0xFF071427)],
        ),
      ),
    );
  }
}

class _NebulaTopLeft extends StatelessWidget {
  const _NebulaTopLeft();
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.8, -0.9),
            radius: 0.9,
            colors: [const Color(0xFF6D83F2).withOpacity(0.22), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _NebulaBottomRight extends StatelessWidget {
  const _NebulaBottomRight();
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.9, 0.8),
            radius: 1.0,
            colors: [const Color(0xFFFA72C6).withOpacity(0.18), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _StarField extends StatelessWidget {
  const _StarField({required this.count, required this.seed, this.opacity = 0.3});
  final int count;
  final int seed;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final rnd = Random(seed);
    return LayoutBuilder(
      builder: (_, c) {
        final stars = List.generate(count, (_) {
          final dx = rnd.nextDouble();
          final dy = rnd.nextDouble();
          final size = 1.5 + rnd.nextDouble() * 1.5;
          return Positioned(
            left: c.maxWidth * dx,
            top: c.maxHeight * dy,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          );
        });
        return Stack(children: stars);
      },
    );
  }
}
