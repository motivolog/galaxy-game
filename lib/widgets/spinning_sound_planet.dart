import 'package:flutter/material.dart';

class SpinningSoundPlanet extends StatefulWidget {
  const SpinningSoundPlanet({super.key});

  @override
  State<SpinningSoundPlanet> createState() => _SpinningSoundPlanetState();
}

class _SpinningSoundPlanetState extends State<SpinningSoundPlanet> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Image.asset(
        'assets/images/void_planet.png',
        width: 230,
        height: 230,
      ),
    );
  }
}
