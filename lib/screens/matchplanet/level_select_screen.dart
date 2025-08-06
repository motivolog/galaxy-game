import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'match_level1.dart';
import 'match_level2.dart';
import 'match_level3.dart';
import 'match_level4.dart';

class LevelSelectScreen extends StatefulWidget {
  final AudioPlayer homePlayer;
  const LevelSelectScreen({super.key, required this.homePlayer});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  List<bool> _completed = [false, false, false,false];
  List<bool> _unlocked = [true, false, false, false];
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _completed = List.generate(4, (i) => prefs.getBool('completed_$i') ?? false);
      _unlocked[0] = true;
      for (int i = 0; i < _completed.length; i++) {
        if (_completed[i] && i + 1 < _unlocked.length) {
          _unlocked[i + 1] = true;
        }
      }
    });
  }

  Future<void> _saveProgress(int i) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('completed_$i', true);
  }

  Future<void> _openLevel(int i) async {
    if (!_unlocked[i]) return;

    await widget.homePlayer.stop();

    bool? finished;

    switch (i) {
      case 0:
        finished = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const MatchLevel1()),
        );
        break;
      case 1:
        finished = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const MatchLevel2()),
        );
        break;
      case 2:
        finished = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const MatchLevel3()),
        );
        break;
      case 3:
        finished = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const MatchLevel4()),
        );
        break;
    }

    if (finished == true) {
      await _saveProgress(i);
      setState(() {
        _completed[i] = true;
        if (i + 1 < _unlocked.length) _unlocked[i + 1] = true;
      });
      await _player.play(AssetSource('audio/harikasin.mp3'));
    }
  }

  @override
  void dispose() {
    _player.dispose();
    widget.homePlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/levelsec_back.png',
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [

                Positioned(
                  top: 20,
                  left: 10,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Lottie.asset(
                      'assets/animations/back_arrow.json',
                      width: 70,
                      height: 70,
                      repeat: true,
                    ),
                  ),
                ),


                Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: List.generate(_unlocked.length, _buildBox),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBox(int i) {
    final locked = !_unlocked[i];
    final done = _completed[i];

    final List<String> planetImages = [
      'assets/images/planet_yellow.png',
      'assets/images/planet_white.png',
      'assets/images/planet_turquoise.png',
      'assets/images/planet_pink.png',
    ];

    return GestureDetector(
      onTap: () => _openLevel(i),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 250,
              height: 250,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: ColorFiltered(
                  colorFilter: locked
                      ? const ColorFilter.mode(Colors.black54, BlendMode.darken)
                      : const ColorFilter.mode(
                      Colors.transparent, BlendMode.multiply),
                  child: Image.asset(
                    planetImages[i],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            if (done)
              const Positioned(
                top: 12,
                right: 12,
                child: Icon(Icons.star, color: Colors.amber, size: 32),
              ),
            if (locked)
              const Positioned(
                top: 12,
                left: 12,
                child: Icon(Icons.lock, color: Colors.white70, size: 28),
              ),
          ],
        ),
      ),
    );
  }
}
