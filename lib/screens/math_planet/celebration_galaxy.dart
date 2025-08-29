import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_projects/analytics_helper.dart';

Future<void> showCelebrationGalaxy(
    BuildContext context, {
      bool autoClose = false,
      Duration duration = const Duration(seconds: 4),
      bool closeOnBackgroundTap = false,
      bool closeOnAnimationTap = true,
    }) async {
  await Navigator.of(context).push(PageRouteBuilder(
    opaque: false,
    barrierColor: Colors.black.withOpacity(0.4),
    pageBuilder: (_, __, ___) {
      bool _closed = false;

      Future<void> _close(BuildContext ctx, {required String reason}) async {
        if (_closed) return;
        _closed = true;
        await ALog.e('celebration_close', params: {'reason': reason});
        await ALog.endTimer('overlay:celebration', metric: 'celebration_time_ms');
        if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop();
      }

      // analytics: gösterildi + süre sayacı
      ALog.e('celebration_open', params: {
        'autoClose': autoClose,
        'duration_ms': duration.inMilliseconds,
        'bg_tap_enabled': closeOnBackgroundTap,
        'anim_tap_enabled': closeOnAnimationTap,
      });
      ALog.startTimer('overlay:celebration');

      if (autoClose) {
        Future.delayed(duration, () {
          if (!_closed) _close(_, reason: 'auto');
        });
      }

      final size = MediaQuery.of(_).size;
      final shortest = size.shortestSide;
      final bool isTablet = shortest >= 600;
      final double targetWidth = (isTablet ? shortest * 0.80 : shortest * 0.80)
          .clamp(isTablet ? 360.0 : 300.0, isTablet ? 820.0 : 650.0);

      return WillPopScope(
        onWillPop: () async {
          if (!_closed) {
            await ALog.e('celebration_close', params: {'reason': 'system_back'});
            await ALog.endTimer('overlay:celebration', metric: 'celebration_time_ms');
          }
          return true; // sistem geri kapanmasına izin ver
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              IgnorePointer(child: GameWidget(game: _CelebrationGalaxyGame())),
              if (closeOnBackgroundTap)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _close(_, reason: 'background_tap'),
                  ),
                ),
              Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: closeOnAnimationTap
                      ? () => _close(_, reason: 'animation_tap')
                      : null,
                  child: SizedBox(
                    width: targetWidth,
                    child: Lottie.asset(
                      'assets/animations/game3celebrate.json',
                      repeat: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
    transitionsBuilder: (_, anim, __, child) =>
        FadeTransition(opacity: anim, child: child),
  ));
}

class _CelebrationGalaxyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    add(_GalaxyBackground()..priority = -2);
    add(_StarField(count: 130)..priority = -1);
  }
}

class _GalaxyBackground extends PositionComponent with HasGameRef {
  @override
  Future<void> onLoad() async => size = gameRef.size;

  @override
  void render(Canvas c) {
    final rect = size.toRect();
    final center = rect.center;
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(center.dx, center.dy),
        size.length / 2,
        const [Color(0xFF0B1023), Color(0xFF1B2B57), Color(0xFF0B1023)],
        const [0.0, 0.6, 1.0],
      );
    c.drawRect(rect, paint);
  }
}

class _StarField extends Component with HasGameRef {
  _StarField({this.count = 120});
  final int count;
  final math.Random _rnd = math.Random();

  @override
  Future<void> onLoad() async {
    for (var i = 0; i < count; i++) {
      final pos = Vector2(
        _rnd.nextDouble() * gameRef.size.x,
        _rnd.nextDouble() * gameRef.size.y,
      );

      final vel = Vector2(
        (_rnd.nextDouble() - 0.5) * 6,
        -(8 + _rnd.nextDouble() * 12),
      );

      final radius = 0.8 + _rnd.nextDouble() * 1.6;
      final twinkleHz = 0.6 + _rnd.nextDouble() * 1.0;
      final phase = _rnd.nextDouble() * math.pi * 2;

      add(_Star(
        position: pos,
        radius: radius,
        velocity: vel,
        twinkleHz: twinkleHz,
        phase: phase,
      ));
    }
  }
}

class _Star extends PositionComponent with HasGameRef {
  _Star({
    required Vector2 position,
    required this.radius,
    required this.velocity,
    required this.twinkleHz,
    required this.phase,
  }) {
    this.position = position;
    size = Vector2.all(radius * 2);
    anchor = Anchor.center;
  }
  final double radius;
  final Vector2 velocity;
  final double twinkleHz;
  final double phase;
  double _t = 0;
  final Paint _paint = Paint();

  @override
  void render(Canvas c) {
    final a = 0.4 +
        0.6 * (0.5 * (1 + math.sin(_t * twinkleHz * 2 * math.pi + phase)));
    _paint.color = Colors.white.withOpacity(a);
    c.drawCircle(Offset(radius, radius), radius, _paint);
  }

  @override
  void update(double dt) {
    _t += dt;
    position.add(velocity * dt);

    final w = gameRef.size.x;
    final h = gameRef.size.y;

    if (position.y < -radius) position.y = h + radius;
    if (position.y > h + radius) position.y = -radius;
    if (position.x < -radius) position.x = w + radius;
    if (position.x > w + radius) position.x = -radius;
  }
}
