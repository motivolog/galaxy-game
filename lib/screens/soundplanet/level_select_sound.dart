import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'level1.dart';
import 'level2.dart';
import 'level3.dart';
import 'package:lottie/lottie.dart';
import '../../analytics_helper.dart'; // ✅ Analytics

class LevelSelectSoundScreen extends StatefulWidget {
  final AudioPlayer incomingPlayer;

  const LevelSelectSoundScreen({super.key, required this.incomingPlayer});

  @override
  State<LevelSelectSoundScreen> createState() =>
      _LevelSelectSoundScreenState();
}

class _LevelSelectSoundScreenState extends State<LevelSelectSoundScreen> {
  @override
  void initState() {
    super.initState();
    _playIntro();
  }

  Future<void> _playIntro() async {
    await widget.incomingPlayer.play(
      AssetSource('audio/hosgeldin_ses_gezegeni.mp3'),
    );
  }

  @override
  void dispose() {
    widget.incomingPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isTablet = shortestSide >= 600;

    final double buttonSize = isTablet ? shortestSide * 0.60 : shortestSide * 0.80;
    final double spacing = isTablet ? 48 : 60;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/gif/bgg.gif',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 20,
              left: 10,
              child: GestureDetector(
                onTap: () async {
                  // ✅ Analytics: geri butonu
                  ALog.tap('back', place: 'level_select_sound');

                  await widget.incomingPlayer.stop();
                  if (!mounted) return;
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 16),
                    _buildLevelButton(
                      label: 'Seviye 1: Hayvan Sesleri',
                      imagePath: 'assets/images/planet_animal.png',
                      onTap: () async {
                        // ✅ Analytics: kategori seçimi
                        ALog.tap('sound_animals', place: 'level_select_sound');
                        await ALog.e('sound_category_enter', params: {'category': 'animals'});
                        ALog.startTimer('sound:animals');

                        await widget.incomingPlayer.stop();
                        final player = AudioPlayer();
                        await player.play(AssetSource('audio/animal_yonlendirme.mp3'));
                        await player.onPlayerComplete.first;

                        if (!mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Level1()),
                        );
                      },
                      size: buttonSize,
                    ),
                    SizedBox(width: spacing),
                    _buildLevelButton(
                      label: 'Seviye 2: Taşıt Sesleri',
                      imagePath: 'assets/images/vehicleplanet.png',
                      onTap: () async {
                        // ✅ Analytics: kategori seçimi
                        ALog.tap('sound_vehicles', place: 'level_select_sound');
                        await ALog.e('sound_category_enter', params: {'category': 'vehicles'});
                        ALog.startTimer('sound:vehicles');

                        await widget.incomingPlayer.stop();
                        final player = AudioPlayer();
                        await player.play(AssetSource('audio/vehicle_yonlendirme.mp3'));
                        await player.onPlayerComplete.first;

                        if (!mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Level2()),
                        );
                      },
                      size: buttonSize,
                    ),
                    SizedBox(width: spacing),
                    _buildLevelButton(
                      label: 'Seviye 3: Müzik Aletleri',
                      imagePath: 'assets/images/planetiki.png',
                      onTap: () async {
                        // ✅ Analytics: kategori seçimi
                        ALog.tap('sound_instruments', place: 'level_select_sound');
                        await ALog.e('sound_category_enter', params: {'category': 'instruments'});
                        ALog.startTimer('sound:instruments');

                        await widget.incomingPlayer.stop();
                        final player = AudioPlayer();
                        await player.play(AssetSource('audio/intrument_yonlendirme.mp3'));
                        await player.onPlayerComplete.first;

                        if (!mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Level3()),
                        );
                      },
                      size: buttonSize,
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelButton({
    required String label,
    required String imagePath,
    required VoidCallback onTap,
    required double size,
  }) {
    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
