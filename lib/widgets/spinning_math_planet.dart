import 'package:flutter/material.dart';

class SpinningMathPlanet extends StatefulWidget{
  const SpinningMathPlanet({super.key});

  @override
  State<SpinningMathPlanet> createState() => _SpinningMathPlanetState();
}

class _SpinningMathPlanetState extends State<SpinningMathPlanet> with SingleTickerProviderStateMixin{
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
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
        turns: _controller,
    child: Image.asset(
      'assets/images/planet3.png',
      width: 350,
        height: 350,
    ),
    );
  }
}