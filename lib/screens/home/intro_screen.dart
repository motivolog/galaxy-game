import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import '../home/home_screen.dart';
import '../../analytics_helper.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  final String colorfulText = "Galaksimde";
  final List<Color> letterColors = const [
    Color(0xFFF47C3C), Color(0xFF76C2AF), Color(0xFFFBC02D),
    Color(0xFFAED581), Color(0xFFE57373), Color(0xFF4FC3F7),
    Color(0xFFBA68C8), Color(0xFF81D4FA), Color(0xFFFFB74D),
    Color(0xFF9575CD),
  ];
  final List<bool> _visible = [];
  late final List<AnimationController> _controllers = [];
  late final List<Animation<double>> _animations = [];

  bool showRocket = false;
  bool hideText = false;

  static const String kIntroMusicUrl =
      'https://zelihausta.github.io/game-assets-sound/game_intro.mp3';

  late final AudioPlayer _musicPlayer = AudioPlayer();
  Uint8List? _introBytes;
  bool _ended = false;
  void _endIntroTimer({String? next}) {
    if (_ended) return;
    _ended = true;
    ALog.endTimer('screen:intro', extra: {if (next != null) 'next': next});
  }

  @override
  void initState() {
    super.initState();

    // ANALYTICS
    ALog.screen('intro');
    ALog.startTimer('screen:intro');
    _preloadIntroAudio().then((_) => _playIntroMusic());
    for (int i = 0; i < colorfulText.length + 1; i++) {
      _visible.add(false);

      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );

      final animation = Tween<double>(begin: 0, end: -10).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );

      _controllers.add(controller);
      _animations.add(animation);

      Future.delayed(Duration(milliseconds: i * 150), () {
        if (!mounted) return;
        setState(() => _visible[i] = true);
        controller.repeat(reverse: true);

        if (i == colorfulText.length) {
          Future.delayed(const Duration(seconds: 4), () {
            if (!mounted) return;
            setState(() => hideText = true);

            Future.delayed(const Duration(milliseconds: 200), () {
              if (!mounted) return;
              setState(() => showRocket = true);
            });
          });
        }
      });
    }
  }
  Future<void> _preloadIntroAudio() async {
    try {
      final resp = await http.get(Uri.parse(kIntroMusicUrl));
      if (resp.statusCode == 200) {
        _introBytes = resp.bodyBytes;
      } else {
        _introBytes = null;
      }
    } catch (_) {
      _introBytes = null;
    }
  }

  Future<void> _playIntroMusic() async {
    try {
      await _musicPlayer.setVolume(0.0);
      if (_introBytes != null) {
        await _musicPlayer.play(BytesSource(_introBytes!));
      } else {
        await _musicPlayer.play(UrlSource(kIntroMusicUrl));
      }
      const target = 0.7;
      const steps = 6;
      for (int i = 1; i <= steps; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
        await _musicPlayer.setVolume(target * (i / steps));
      }
    } catch (_) {
    }
  }

  Future<void> _stopIntroMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (_) {}
  }
  @override
  void dispose() {
    // ANALYTICS
    _endIntroTimer();
    _stopIntroMusic();
    _musicPlayer.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final rocketSize = screenWidth * 0.4;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: showRocket
            ? Lottie.asset(
          'assets/animations/rocket_launch.json',
          width: rocketSize,
          height: rocketSize,
          fit: BoxFit.contain,
          onLoaded: (composition) {
            debugPrint(
              'Rocket duration: ${composition.duration.inMilliseconds} ms',
            );
            Future.delayed(composition.duration, () async {
              if (!mounted) return;
              await _stopIntroMusic();
              ALog.tap('intro_to_home', place: 'rocket_auto');
              _endIntroTimer(next: 'home');
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            });
          },
        )
            : !hideText
            ? Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: List.generate(colorfulText.length + 1, (index) {
            if (!_visible[index]) return const SizedBox(width: 24);
            final animation = _animations[index];

            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, animation.value),
                child: child,
              ),
              child: index < colorfulText.length
                  ? Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  colorfulText[index],
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: letterColors[
                    index % letterColors.length],
                  ),
                ),
              )
                  : Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3E5FC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "öğreniyorum",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            );
          }),
        )
            : const SizedBox(),
      ),
    );
  }
}
