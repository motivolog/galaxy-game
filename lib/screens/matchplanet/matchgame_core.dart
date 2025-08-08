import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';

class MatchGameCore extends StatefulWidget {
  final List<Map<String, String>> cards;
  final int pairCount;
  final String backgroundImage;
  final int crossAxisCountPortrait;
  final int crossAxisCountLandscape;
  final String successSound;
  final String failSound;
  final String congratsSound;
  final bool centerGrid;
  final int flipBackDelayMs;
  final double? cardSize;
  final Function()? onExit;


  const MatchGameCore({
    super.key,
    required this.cards,
    required this.pairCount,
    required this.backgroundImage,
    required this.crossAxisCountPortrait,
    required this.crossAxisCountLandscape,
    required this.successSound,
    required this.failSound,
    required this.congratsSound,
    this.centerGrid = false,
    this.flipBackDelayMs = 400,
    this.cardSize,
    this.onExit,

  });

  @override
  State<MatchGameCore> createState() => _MatchGameCoreState();
}

class _MatchGameCoreState extends State<MatchGameCore>
    with TickerProviderStateMixin {
  final AudioPlayer _namePlayer = AudioPlayer();
  final AudioPlayer _fxPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();
  bool _isMuted = false;

  late final List<Map<String, String>> _cards;
  late final List<bool> _revealed;
  late final List<bool> _matched;
  final List<int> _selected = [];
  late final List<AnimationController> _slideCtrls;

  @override
  void initState() {
    super.initState();
    _cards = [...widget.cards, ...widget.cards]..shuffle(Random());
    _revealed = List.filled(_cards.length, false);
    _matched = List.filled(_cards.length, false);
    _slideCtrls = List.generate(
      _cards.length,
          (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _playBackgroundMusic();
  }

  void _playBackgroundMusic() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(0.1);
    await _bgmPlayer.setSource(
      UrlSource('https://zelihausta.github.io/game-assets-sound/bg.mp3'),
    );
    await _bgmPlayer.resume();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    if (_isMuted) {
      _bgmPlayer.pause();
    } else {
      _bgmPlayer.resume();
    }
  }

  @override
  void dispose() {
    for (var ctrl in _slideCtrls) {
      ctrl.dispose();
    }
    _namePlayer.dispose();
    _fxPlayer.dispose();
    _bgmPlayer.dispose();
    super.dispose();
  }

  Future<void> _playName(String asset) async {
    await _namePlayer.stop();
    await _namePlayer.play(AssetSource(asset));
    await _namePlayer.onPlayerComplete.first;
  }

  Future<void> _playFx(String asset, {bool wait = false}) async {
    await _fxPlayer.stop();
    await _fxPlayer.play(AssetSource(asset));
    if (wait) await _fxPlayer.onPlayerComplete.first;
  }

  Future<void> _onCardTap(int idx) async {
    if (_revealed[idx] || _matched[idx] || _selected.length == 2) return;

    setState(() => _revealed[idx] = true);
    _selected.add(idx);

    await _fxPlayer.stop();
    await _namePlayer.stop();

    await _playName(_cards[idx]['sound']!);

    if (_selected.length == 2) {
      final i1 = _selected[0], i2 = _selected[1];
      final match = _cards[i1]['image'] == _cards[i2]['image'];

      if (match) {
        _slideCtrls[i1].forward();
        _slideCtrls[i2].forward();
        setState(() {
          _matched[i1] = true;
          _matched[i2] = true;
        });
        _selected.clear();

        final allDone = _matched.every((m) => m);
        if (!allDone) {
          _playFx(widget.successSound);
        } else {
          await Future.delayed(const Duration(milliseconds: 500));
          _playFx(widget.congratsSound);
          await Future.delayed(const Duration(milliseconds: 800));

          if (!mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  widget.onExit?.call();
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
                child: Scaffold(
                  backgroundColor: Colors.black.withOpacity(0.8),
                  body: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isPortrait =
                            MediaQuery.of(context).orientation ==
                                Orientation.portrait;
                        final maxHeight = constraints.maxHeight;

                        final animationSize = isPortrait
                            ? maxHeight * 0.75
                            : maxHeight * 0.90;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/animations/celebrate_baykus.json',
                              width: animationSize,
                              height: animationSize,
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      } else {
        _playFx(widget.failSound);
        await Future.delayed(Duration(milliseconds: widget.flipBackDelayMs));
        setState(() {
          _revealed[i1] = false;
          _revealed[i2] = false;
        });
        _selected.clear();
      }
    }
  }

  Widget _flipCard({
    required bool showFront,
    required String imagePath,
    required Color backColor,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, anim) {
        final rot = Tween(begin: pi, end: 0.0).animate(anim);
        return AnimatedBuilder(
          animation: rot,
          child: child,
          builder: (context, child) {
            final under = rot.value > pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(rot.value),
              child: under
                  ? Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(pi),
                child: child,
              )
                  : child,
            );
          },
        );
      },
      layoutBuilder: (widgets, animations) =>
          Stack(children: [widgets!, ...animations]),
      child: showFront
          ? SizedBox.expand(
        key: const ValueKey('front'),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
      )
          : SizedBox.expand(
        key: const ValueKey('back'),
        child: Container(color: backColor),
      ),
    );
  }

  Widget _buildCard(BuildContext ctx, int idx, bool portrait) {
    final gone = _matched[idx];
    final slide = portrait ? const Offset(-3, 0) : const Offset(0, -3);

    return GestureDetector(
      onTap: () => _onCardTap(idx),
      child: AnimatedSlide(
        offset: gone ? slide : Offset.zero,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
        child: gone && _slideCtrls[idx].isCompleted
            ? const SizedBox.shrink()
            : ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _flipCard(
            showFront: _revealed[idx],
            imagePath: _cards[idx]['image']!,
            backColor: Colors.deepPurple.shade200.withOpacity(0.8),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const spacing = 15.0;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(widget.backgroundImage),
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),
          SafeArea(
            child: OrientationBuilder(
              builder: (context, ori) {
                final portrait = ori == Orientation.portrait;
                final cols = portrait
                    ? widget.crossAxisCountPortrait
                    : widget.crossAxisCountLandscape;
                final rows = (_cards.length / cols).ceil();

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final maxW = constraints.maxWidth;
                    final maxH = constraints.maxHeight;

                    final totalHSpacing = spacing * (cols - 1);
                    final totalVSpacing = spacing * (rows - 1);

                    final cellWidth = (maxW - totalHSpacing) / cols;
                    final cellHeight = (maxH - totalVSpacing) / rows;

                    final cellSize = min(cellWidth, cellHeight);
                    final effectiveSize = widget.cardSize ?? cellSize;


                    final gridW = effectiveSize * cols + totalHSpacing;
                    final gridH = effectiveSize * rows + totalVSpacing;


                    return Align(
                      alignment: widget.centerGrid ? Alignment.center : Alignment.centerLeft,
                      child: SizedBox(
                        width: gridW,
                        height: gridH,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: spacing,
                            mainAxisSpacing: spacing,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: _cards.length,
                          itemBuilder: (ctx, idx) =>
                              _buildCard(ctx, idx, portrait),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Positioned(
            top: 30,
            right: 16,
            child: GestureDetector(
              onTap: _toggleMute,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.1),
                radius: 22,
                child: Text(
                  _isMuted ? '🔇' : '🎶',
                  style: const TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
