import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class AccessibleZoom extends StatefulWidget {
  const AccessibleZoom({
    super.key,
    required this.child,
    this.persistKey = 'math_access_zoom',
    this.maxScale = 3.0,
    this.textScaleBoost = 1.35,
    this.showButton = true,
    this.panEnabled = true,
  });

  final Widget child;
  final String persistKey;
  final double maxScale;
  final double textScaleBoost;
  final bool showButton;
  final bool panEnabled;

  @override
  State<AccessibleZoom> createState() => _AccessibleZoomState();
}

class _AccessibleZoomState extends State<AccessibleZoom> {
  bool _enabled = false;
  final _transform = TransformationController();
  late final AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _load();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    setState(() => _enabled = sp.getBool(widget.persistKey) ?? false);
  }

  Future<void> _stopSounds() async {
    try { await _player.stop(); } catch (_) {}
  }

  Future<void> _playToggleSound(bool enabled) async {
    final path = enabled
        ? 'audio/planet3/zoom_acik.mp3'
        : 'audio/planet3/zoom_off.mp3';
    try {
      await _player.stop();
      await _player.play(AssetSource(path));
    } catch (e) {
      debugPrint('Toggle sound error: $e');
    }
  }

  Future<void> _toggle() async {
    final sp = await SharedPreferences.getInstance();
    setState(() => _enabled = !_enabled);
    await sp.setBool(widget.persistKey, _enabled);

    HapticFeedback.selectionClick();
    await _playToggleSound(_enabled);

    if (!_enabled) _transform.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final scaled = MediaQuery(
      data: media.copyWith(
        textScaleFactor: _enabled
            ? (media.textScaleFactor * widget.textScaleBoost).clamp(1.0, 1.8)
            : media.textScaleFactor,
      ),
      child: widget.child,
    );

    Widget content = _enabled
        ? InteractiveViewer(
      transformationController: _transform,
      minScale: 1.0,
      maxScale: widget.maxScale,
      panEnabled: widget.panEnabled,
      boundaryMargin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      child: SizedBox.expand(child: scaled),
    )
        : scaled;

    if (widget.showButton) {
      content = Stack(
        children: [
          Positioned.fill(child: content),
          Positioned(
            top: 20,
            right: 20,
            child: Semantics(
              label: 'Yakınlaştırma',
              hint: _enabled ? 'Kapatmak için dokun' : 'Açmak için dokun',
              toggled: _enabled,
              button: true,
              child: _ZoomIconToggle(
                enabled: _enabled,
                onTap: _toggle,
              ),
            ),
          ),
        ],
      );
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _stopSounds(),
      child: content,
    );
  }
}

class _ZoomIconToggle extends StatelessWidget {
  const _ZoomIconToggle({
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shortest = MediaQuery.of(context).size.shortestSide;
    final bool isTablet = shortest >= 600;
    final double size = isTablet ? 72 : 64;
    final double iconSize = isTablet ? 44 : 40;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF8C7BFA),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.zoom_in, size: iconSize, color: Colors.white),
              if (!enabled)
                Transform.rotate(
                  angle: 0.78539816339, // ~45°
                  child: Container(
                    width: size * 0.65,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
