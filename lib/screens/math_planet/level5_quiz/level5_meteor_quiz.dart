import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame_lottie/flame_lottie.dart';
import 'package:lottie/lottie.dart';


enum QuizState { presenting, resolving, finished }
class Question {
  final String text;
  final int answer;
  final List<int> options;
  Question(this.text, this.answer, this.options);
}

class Level5MeteorQuizGame extends FlameGame {
  Level5MeteorQuizGame({required this.onFinished, required this.onUiRefresh});

  final VoidCallback onFinished;
  final VoidCallback onUiRefresh;


  QuizState state = QuizState.presenting;
  final int totalQuestions = 10;
  int currentIndex = 0;
  int correctCount = 0;

  final double baseMeteorSpeed = 80;
  final double boostMultiplier = 2.0;

  Meteor? activeMeteor;
  List<Question> questions = const [];

  LottieComponent? astronaut;

  double? _idleTopY;
  double? _idleBottomY;
  MoveToEffect? _idleMoveEffect;
  final double _astronautX = 80;
  bool _isAttacking = false;
  bool _isSpawning = false;

  Question? get currentQuestion =>
      (questions.isNotEmpty && currentIndex < questions.length)
          ? questions[currentIndex]
          : null;

  @override
  Future<void> onLoad() async {
    await super.onLoad();


    add(_Starfield(size)..priority = -10);

    final lottie = await loadLottie(
      Lottie.asset('assets/animations/astronot_math.json'),
    );
    final a = LottieComponent(
      lottie,
      size: Vector2(160, 160),
      position: Vector2(_astronautX, size.y * 0.65),
      repeating: true,
    )
      ..priority = 5
      ..anchor = Anchor.center;
    astronaut = a;
    add(a);

    _idleTopY = size.y * 0.25;
    _idleBottomY = size.y * 0.75;
    a.position = Vector2(_astronautX, _idleBottomY!);
    _startIdleFloat();

    questions = _generateQuestions(totalQuestions);
    onUiRefresh();

    _spawnNextMeteor();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _idleTopY = this.size.y * 0.25;
    _idleBottomY = this.size.y * 0.75;

    final a = astronaut;
    if (a != null && a.isMounted) {
      final clampedY =
      a.y.clamp(_idleTopY ?? a.y, _idleBottomY ?? a.y).toDouble();
      a.position = Vector2(_astronautX, clampedY);
    }
  }
  void _startIdleFloat() {
    _stopIdleFloat();
    if (astronaut == null || _idleTopY == null) return;

    _idleMoveEffect = MoveToEffect(
      Vector2(_astronautX, _idleTopY!),
      EffectController(
        duration: 2.4,
        curve: Curves.easeInOut,
        alternate: true,
        infinite: true,
      ),
    );
    astronaut!.add(_idleMoveEffect!);

    astronaut!.add(
      RotateEffect.by(
        0.03,
        EffectController(
          duration: 1.6,
          curve: Curves.easeInOut,
          alternate: true,
          infinite: true,
        ),
      ),
    );
  }

  void _stopIdleFloat() {
    _idleMoveEffect?.removeFromParent();
    _idleMoveEffect = null;
    astronaut?.children.whereType<Effect>().toList().forEach(
          (e) => e.removeFromParent(),
    );
  }

  Future<void> _attackMeteorAndExplode() async {
    final a = astronaut;
    final m = activeMeteor;
    if (a == null || m == null || _isAttacking) return;
    _isAttacking = true;

    _stopIdleFloat();

    final moveToMeteorY = MoveToEffect(
      Vector2(a.x, m.y),
      EffectController(duration: 0.35, curve: Curves.easeInOut),
    );
    a.add(moveToMeteorY);
    await moveToMeteorY.completed;

    // 2) hafif pulse
    final hitPulse = SequenceEffect([
      ScaleEffect.to(
        Vector2.all(1.08),
        EffectController(duration: 0.12, curve: Curves.easeOut),
      ),
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: 0.10, curve: Curves.easeIn),
      ),
    ]);
    a.add(hitPulse);

    _shootStarWarsLaser(
      a.position.clone() + Vector2(40, 0),
      m.position.clone(),
      color: Colors.green,
      travelDuration: 0.22,       // hız: 0.10 hızlı, 0.30 daha yavaş
    );

    m.explodeThenRemove(onDone: () {});

    final moveBackToIdleY = MoveToEffect(
      Vector2(a.x, size.y * 0.65),
      EffectController(duration: 0.35, curve: Curves.easeInOut),
    );
    a.add(moveBackToIdleY);
    await moveBackToIdleY.completed;

    _startIdleFloat();
    _isAttacking = false;
  }

  Future<void> _shootStarWarsLaser(
      Vector2 from,
      Vector2 to, {
        Color color = Colors.green,
        double travelDuration = 0.18,
      }) async {
    final dir = to - from;
    final angle = math.atan2(dir.y, dir.x);
    final length = dir.length;

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(0.95),
          color.withOpacity(0.55),
          color.withOpacity(0.95),
        ],
      ).createShader(Rect.fromLTWH(0, 0, length, 4))
      ..blendMode = BlendMode.plus;

    final laser = RectangleComponent(
      size: Vector2(0, 4),
      position: from,
      anchor: Anchor.centerLeft,
      angle: angle,
      paint: paint,
    )..priority = 50;
    add(laser);

    final glow = CircleComponent(
      radius: 12,
      position: from,
      anchor: Anchor.center,
      paint: Paint()
        ..shader = RadialGradient(
          colors: [
            color.withOpacity(0.9),
            Colors.white.withOpacity(0.6),
            Colors.transparent,
          ],
        ).createShader(const Rect.fromLTWH(-12, -12, 24, 24)),
    )..priority = 51;
    add(glow);

    laser.add(SizeEffect.to(
      Vector2(length, 4),
      EffectController(duration: travelDuration, curve: Curves.linear),
    ));
    glow.add(MoveToEffect(
      to,
      EffectController(duration: travelDuration, curve: Curves.linear),
    ));

    await Future.delayed(Duration(milliseconds: (travelDuration * 1000).round()));

    laser.add(OpacityEffect.to(
      0,
      EffectController(duration: 0.12, curve: Curves.easeOut),
      onComplete: () => laser.removeFromParent(),
    ));
    glow.add(OpacityEffect.to(
      0,
      EffectController(duration: 0.12, curve: Curves.easeOut),
      onComplete: () => glow.removeFromParent(),
    ));
  }
  Future<void> onAnswerSelected(int val) async {
    if (state != QuizState.presenting || currentQuestion == null) return;

    final isCorrect = (val == currentQuestion!.answer);
    state = QuizState.resolving;

    if (isCorrect) {
      correctCount++;
      await _attackMeteorAndExplode();
      currentIndex++;
      _spawnNextMeteor();
    } else {
      activeMeteor?.speedBoost(multiplier: boostMultiplier, duration: 0.6);
      Future.delayed(const Duration(milliseconds: 650), () {
        state = QuizState.presenting;
        onUiRefresh();
      });
    }
    onUiRefresh();
  }

  void _respawnSameQuestion() {
    if (_isSpawning || state == QuizState.finished) return;
    _isSpawning = true;

    activeMeteor?.removeFromParent();
    activeMeteor = null;

    Future.microtask(() {
      _spawnNextMeteor();
      _isSpawning = false;
    });
  }

  void _spawnNextMeteor() {
    if (currentIndex >= totalQuestions) {
      state = QuizState.finished;
      onFinished();
      return;
    }

    final q = questions[currentIndex];
    final y = size.y * (0.35 + math.Random().nextDouble() * 0.4);

    activeMeteor?.removeFromParent();
    activeMeteor = Meteor(
      label: q.text,
      baseSpeed: baseMeteorSpeed,
      onMissed: () {
        if (state != QuizState.finished) {
          state = QuizState.presenting;
          _respawnSameQuestion();
        }
      },
    )
      ..position = Vector2(size.x + 80, y)
      ..anchor = Anchor.center;

    add(activeMeteor!);
    state = QuizState.presenting;
    onUiRefresh();
  }

  List<Question> _generateQuestions(int n) {
    final rnd = math.Random();
    final List<Question> list = [];
    for (int i = 0; i < n; i++) {
      final opIndex = math.min(i ~/ 1, 3);
      late int a, b, answer;
      late String text;

      switch (opIndex) {
        case 0:
          a = rnd.nextInt(21);
          b = rnd.nextInt(41);
          answer = a + b;
          text = "$a + $b = ?";
          break;
        case 1:
          a = rnd.nextInt(31);
          b = rnd.nextInt(a + 1);
          answer = a - b;
          text = "$a − $b = ?";
          break;
        case 2:
          a = 2 + rnd.nextInt(10);
          b = 2 + rnd.nextInt(9);
          answer = a * b;
          text = "$a × $b = ?";
          break;
        default:
          b = 2 + rnd.nextInt(9);
          answer = 2 + rnd.nextInt(10);
          a = b * answer;
          text = "$a ÷ $b = ?";
          break;
      }

      final options = _buildOptions(answer, rnd);
      list.add(Question(text, answer, options));
    }
    return list;
  }

  List<int> _buildOptions(int answer, math.Random rnd) {
    final set = <int>{answer};
    while (set.length < 3) {
      final delta = 1 + rnd.nextInt(6);
      final candidate = rnd.nextBool() ? (answer + delta) : (answer - delta);
      set.add(candidate.clamp(0, 100));
    }
    final list = set.toList()..shuffle(rnd);
    return list;
  }
}

class Meteor extends PositionComponent {
  Meteor({
    required this.label,
    required this.baseSpeed,
    required this.onMissed,
  });

  final String label;
  final double baseSpeed;
  final VoidCallback onMissed;

  double currentSpeed = 0;
  double _boostTimer = 0;

  @override
  Future<void> onLoad() async {
    size = Vector2(120, 64);
    currentSpeed = baseSpeed;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= currentSpeed * dt;

    if (_boostTimer > 0) {
      _boostTimer -= dt;
      if (_boostTimer <= 0) currentSpeed = baseSpeed;
    }

    if (position.x < -200) {
      removeFromParent();
      onMissed();
    }
  }

  @override
  void render(Canvas canvas) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(18),
    );
    canvas.drawRRect(r, Paint()..color = const Color(0xFFFFAB91));

    final tp = TextPaint(
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
    tp.render(canvas, label, Vector2(10, size.y / 2 - 12));
  }

  void speedBoost({required double multiplier, required double duration}) {
    currentSpeed = baseSpeed * multiplier;
    _boostTimer = duration;
  }

  void explodeThenRemove({required VoidCallback onDone}) {
    removeFromParent();
    onDone();
  }
}


class _Starfield extends Component {
  _Starfield(this.screenSize);
  final Vector2 screenSize;
  final math.Random rnd = math.Random();
  late final List<Vector2> stars;

  @override
  Future<void> onLoad() async {
    stars = List.generate(80, (_) {
      return Vector2(
        rnd.nextDouble() * screenSize.x,
        rnd.nextDouble() * screenSize.y,
      );
    });
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, screenSize.x, screenSize.y),
      Paint()..color = const Color(0xFF0B1020),
    );
    final p = Paint()..color = const Color(0xFFBBDEFB);
    for (final s in stars) {
      canvas.drawCircle(Offset(s.x, s.y), 1.6, p);
    }
  }
}
