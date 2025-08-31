import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'division_page.dart';
import 'package:flutter_projects/analytics_helper.dart'; //  Analytics
import 'package:flutter_projects/widgets/accessible_zoom.dart';

class DivisionDifficultyPage extends StatefulWidget {
  const DivisionDifficultyPage({super.key});

  @override
  State<DivisionDifficultyPage> createState() => _DivisionDifficultyPageState();
}

class _DivisionDifficultyPageState extends State<DivisionDifficultyPage> {
  late final AudioPlayer _player;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

    // Analytics: ekran + süre ölçümü
    ALog.screen('math_div_difficulty', clazz: 'DivisionDifficultyPage');
    ALog.startTimer('screen:math_div_difficulty');

    _playScreenIntro();
  }

  @override
  void dispose() {
    // Analytics: ekranda geçirilen süreyi bitir (catch-all)
    ALog.endTimer('screen:math_div_difficulty', extra: {'result': 'exit'});

    _player.dispose();
    super.dispose();
  }

  Future<void> _playScreenIntro() async {
    try {
      await _player.stop();
      final completed = _player.onPlayerComplete.first;
      await _player.play(AssetSource('audio/planet3/zorluksec.mp3'));
      await completed.timeout(const Duration(seconds: 6));
    } catch (_) {}
  }

  Future<void> _playCueAndWait(String cue) async {
    final path = switch (cue) {
      'easy' => 'audio/planet3/easy.mp3',
      'medium' => 'audio/planet3/medium.mp3',
      'hard' => 'audio/planet3/hard.mp3',
      _ => null,
    };
    if (path == null) return;

    try {
      await _player.stop();
      final completed = _player.onPlayerComplete.first;
      await _player.play(AssetSource(path));
      await completed.timeout(const Duration(seconds: 4));
    } catch (_) {}
  }

  // Navigasyon öncesi ekran süresini kapat, dönüşte yeniden başlat
  Future<void> _start(
      BuildContext context, {
        required String difficulty,
      }) async {
    // difficulty seçimi olayı
    await ALog.e('math_difficulty_select', params: {'mode': 'div', 'difficulty': difficulty});

    // nav öncesi ekran süresini kapat
    ALog.endTimer('screen:math_div_difficulty', extra: {'result': 'nav_$difficulty'});

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DivisionPage(difficulty: difficulty)),
    );

    // geri dönünce yeniden başlat
    if (mounted) ALog.startTimer('screen:math_div_difficulty');
  }

  Future<void> _sayThenGo(String cue, Future<void> Function() go) async {
    if (_busy) return;
    setState(() => _busy = true);
    await _playCueAndWait(cue);
    if (!mounted) return;
    setState(() => _busy = false);
    await go();
  }

  Widget _buildBackButton(BuildContext context, double scale) {
    final double size = (44.0 * scale).clamp(44.0, 64.0);
    final double iconSize = (24.0 * scale).clamp(24.0, 36.0);

    return Semantics(
      label: 'Geri',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size),
          onTap: () async {
            ALog.tap('back', place: 'div_difficulty'); //  Analytics: geri
            // ekran süresi: geri
            ALog.endTimer('screen:math_div_difficulty', extra: {'result': 'back'});
            await _player.stop();
            await SystemSound.play(SystemSoundType.click);
            if (!mounted) return;
            Navigator.pop(context);
          },
          child: Ink(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              border: Border.all(color: Colors.white70, width: 2),
            ),
            child: Center(
              child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: iconSize),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final shortest = media.size.shortestSide;
    final isTablet = shortest >= 600;
    final scale = isTablet ? 1.8 : 1.0;
    final titleSize = (22.0 * scale).clamp(22.0, 48.0);
    final buttonHeight = (56.0 * scale).clamp(56.0, 100.0);
    final buttonTextSize = (16.0 * scale).clamp(16.0, 34.0);
    final verticalGapLarge = (24.0 * scale).clamp(24.0, 54.0);
    final verticalGap = (12.0 * scale).clamp(12.0, 34.0);
    final radius = Radius.circular((22.0 * scale).clamp(22.0, 44.0));
    final maxContentWidth = isTablet ? 800.0 : 420.0;
    final horizontalPadding = EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20);

    final ButtonStyle ghostBtnStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.white.withOpacity(0.15),
      foregroundColor: Colors.white,
      side: const BorderSide(color: Colors.white70, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(radius)),
      padding: EdgeInsets.zero,
      elevation: 0,
    );

    Widget buildBtn(String label, Future<void> Function() onTap) {
      return SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: ElevatedButton(
          style: ghostBtnStyle,
          onPressed: _busy ? null : () async {
            await _player.stop();
            await onTap();
          },
          child: Text(label, style: TextStyle(fontSize: buttonTextSize, fontWeight: FontWeight.w600)),
        ),
      );
    }

    return Scaffold(
      body: AccessibleZoom(
        persistKey: 'math_access_zoom',
        showButton: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/planet3/bg_add.png', fit: BoxFit.cover),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 20 : 12),
                  child: _buildBackButton(context, scale),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: horizontalPadding,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Bölme - Zorluk Seviyesi",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                            shadows: const [Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black54)],
                          ),
                        ),
                        SizedBox(height: verticalGapLarge),

                        buildBtn("Kolay", () async {
                          ALog.tap('div_select_easy', place: 'div_difficulty');
                          await _sayThenGo('easy', () {
                            return _start(context, difficulty: 'easy');
                          });
                        }),

                        SizedBox(height: verticalGap),

                        buildBtn("Orta", () async {
                          ALog.tap('div_select_medium', place: 'div_difficulty');
                          await _sayThenGo('medium', () {
                            return _start(context, difficulty: 'medium');
                          });
                        }),

                        SizedBox(height: verticalGap),

                        buildBtn("Zor", () async {
                          ALog.tap('div_select_hard', place: 'div_difficulty');
                          await _sayThenGo('hard', () {
                            return _start(context, difficulty: 'hard');
                          });
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
