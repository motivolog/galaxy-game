import 'dart:math' as math;
import 'dart:ui' as ui;
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
  Level5MeteorQuizGame({
    required this.onFinished,
    required this.onUiRefresh,
    this.onNewQuestion,
    this.onCorrectAnswer,
  });

  final VoidCallback onFinished;
  final VoidCallback onUiRefresh;
  final void Function(int a, String op, int b)? onNewQuestion;
  final void Function(int a, String op, int b)? onCorrectAnswer;

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
  bool get isTablet => math.min(size.x, size.y) >= 600;
  double get uiScale => isTablet ? 1.6 : 1.0;

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
      size: Vector2(160 * uiScale, 160 * uiScale),
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
      a.size = Vector2(160 * uiScale, 160 * uiScale);
    }
  }

  void _startIdleFloat() {
    _stopIdleFloat();
    if (astronaut == null || _idleTopY == null) return;
    _idleMoveEffect = MoveToEffect(
      Vector2(_astronautX, _idleTopY!),
      EffectController(
        duration: 2.4, curve: Curves.easeInOut, alternate: true, infinite: true,
      ),
    );
    astronaut!.add(_idleMoveEffect!);

    astronaut!.add(
      RotateEffect.by(
        0.03,
        EffectController(
          duration: 1.6, curve: Curves.easeInOut, alternate: true, infinite: true,
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
      travelDuration: 0.22,
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
        double travelDuration = 0.12,
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
      radius: 12, position: from, anchor: Anchor.center,
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

    await Future.delayed(
      Duration(milliseconds: (travelDuration * 1000).round()),
    );

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
      final triple = _parseAopB(currentQuestion!.text);
      if (triple != null) {
        final (a, op, b) = triple;
        onCorrectAnswer?.call(a, op, b);
      }
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
      uiScale: uiScale,
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
    _notifyNewQuestionFromText(q.text);

    onUiRefresh();
  }
  void _notifyNewQuestionFromText(String text) {
    final triple = _parseAopB(text);
    if (triple == null) return;
    final (a, op, b) = triple;
    onNewQuestion?.call(a, op, b);
  }
  (int, String, int)? _parseAopB(String text) {
    final m = RegExp(r'^\s*(\d+)\s*([+\-−×x\*/÷/])\s*(\d+)\s*=').firstMatch(text);
    if (m == null) return null;
    final a = int.parse(m.group(1)!);
    final rawOp = m.group(2)!;
    final b = int.parse(m.group(3)!);
    final op = switch (rawOp) {
      '+' => '+',
      '-' || '−' => '-',
      '×' || 'x' || 'X' || '*' => '×',
      '÷' || '/' => '÷',
      _ => '+',
    };
    return (a, op, b);
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
    required this.uiScale,
  });

  final String label;
  final double baseSpeed;
  final VoidCallback onMissed;
  final double uiScale;

  double currentSpeed = 0;
  double _boostTimer = 0;

  @override
  Future<void> onLoad() async {
    final w = 140.0 * uiScale;
    final h = 80.0 * uiScale;
    size = Vector2(w, h);
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
    final shadowRect = Rect.fromLTWH(4, 6, size.x - 8, size.y - 8);
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(shadowRect, Radius.circular(18 * uiScale)),
      shadowPaint,
    );
    final bgRect = Rect.fromLTWH(0, 0, size.x, size.y);
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFCDDC39),
          Color(0xFF8BC34A),
        ],
      ).createShader(bgRect);
    final rrect =
    RRect.fromRectAndRadius(bgRect, Radius.circular(18 * uiScale));
    canvas.drawRRect(rrect, bgPaint);

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF7A4A00).withOpacity(0.35),
    );

    final tp = TextPaint(
      style: TextStyle(
        color: Colors.black87,
        fontSize: 22 * uiScale,
        fontWeight: FontWeight.w700,
      ),
    );
    final textPainter = tp.toTextPainter(label)..layout();
    final dx = (size.x - textPainter.width) / 2;
    final dy = (size.y - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(dx, dy));
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
