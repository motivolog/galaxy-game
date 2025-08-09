import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

enum QuizState { presenting, resolving, finished }

class Question {
  final String text;
  final int answer;
  final List<int> options;
  Question(this.text, this.answer, this.options);
}

class Level1MeteorQuizGame extends FlameGame {
  Level1MeteorQuizGame({required this.onFinished, required this.onUiRefresh});

  final VoidCallback onFinished;
  final VoidCallback onUiRefresh;


  QuizState state = QuizState.presenting;
  final int totalQuestions = 10;
  int currentIndex = 0;
  int correctCount = 0;


  final double baseMeteorSpeed = 120;
  final double boostMultiplier = 2.0;


  Meteor? activeMeteor;
  late List<Question> questions;
  late AnimatedAstronaut astronaut;

  Question? get currentQuestion =>
      (currentIndex < questions.length) ? questions[currentIndex] : null;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(_Starfield(size)..priority = -10);

    astronaut = AnimatedAstronaut()
      ..position = Vector2(80, size.y * 0.65)
      ..priority = 5
      ..anchor = Anchor.center;
    add(astronaut);


    questions = _generateQuestions(totalQuestions);

    _spawnNextMeteor();
  }

  void onAnswerSelected(int val) {
    if (state != QuizState.presenting || currentQuestion == null) return;

    final isCorrect = (val == currentQuestion!.answer);
    state = QuizState.resolving;

    if (isCorrect) {
      correctCount++;
      astronaut.cheer();
      activeMeteor?.explodeThenRemove(onDone: () {
        currentIndex++;
        _spawnNextMeteor();
      });
    } else {

      activeMeteor?.speedBoost(multiplier: boostMultiplier, duration: 0.6);
      Future.delayed(const Duration(milliseconds: 650), () {
        state = QuizState.presenting;
        onUiRefresh();
      });
    }
    onUiRefresh();
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

      final opIndex = math.min(i ~/ 3, 3);
      late int a, b, answer;
      late String text;

      switch (opIndex) {
        case 0:
          a = rnd.nextInt(21);
          b = rnd.nextInt(21);
          answer = a + b;
          text = "$a + $b = ?";
          break;
        case 1:
          a = rnd.nextInt(21);
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
    final set = {answer};
    while (set.length < 3) {
      final delta = 1 + rnd.nextInt(6);
      set.add(rnd.nextBool() ? answer + delta : (answer - delta).clamp(0, 100));
    }
    final list = set.toList()..shuffle(rnd);
    return list;
  }
}

class AnimatedAstronaut extends PositionComponent {
  double _t = 0;
  double _cheerTimer = 0;
  final double _bodyW = 70;
  final double _bodyH = 64;

  @override
  Future<void> onLoad() async {
    size = Vector2(_bodyW, _bodyH);
    anchor = Anchor.center;
  }

  void cheer() {
    _cheerTimer = 0.35; // ~350ms
  }

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    if (_cheerTimer > 0) _cheerTimer -= dt;


    final baseY = y;
    final bob = math.sin(_t * 2.0) * 2.5; // ±2.5px
    position.y = baseY + bob;


    angle = math.sin(_t * 1.6) * 0.02; // ± ~1.1°
    if (_cheerTimer > 0) {

      final k = (_cheerTimer / 0.35); // 1..0
      scale = Vector2.all(1.0 + 0.08 * k);
      angle += 0.08 * (1 - k);
    } else {
      scale = Vector2.all(1.0);
    }
  }

  @override
  void render(Canvas canvas) {
    // Gövde
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(-_bodyW/2, -_bodyH/2, _bodyW, _bodyH),
      const Radius.circular(18),
    );
    canvas.drawRRect(bodyRect, Paint()..color = const Color(0xFF8EC5FF));


    final visor = RRect.fromRectAndRadius(
      Rect.fromLTWH(-24, -16, 48, 28), const Radius.circular(12),
    );
    canvas.drawRRect(visor, Paint()..color = const Color(0xFF1B2A4A));


    final limbPaint = Paint()..color = const Color(0xFF6EA9E8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(-_bodyW/2-6, -8, 12, 22), const Radius.circular(6)),
      limbPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(_bodyW/2-6, -8, 12, 22), const Radius.circular(6)),
      limbPaint,
    );


    final pack = RRect.fromRectAndRadius(
      Rect.fromLTWH(-_bodyW/2-10, -10, 16, 28), const Radius.circular(6),
    );
    canvas.drawRRect(pack, Paint()..color = const Color(0xFF445D7A));

    final flameLen = 10 + 6 * (0.5 + 0.5 * math.sin(_t * 20));
    final flamePath = Path()
      ..moveTo(-_bodyW/2 - 10 + 8, 12)
      ..lineTo(-_bodyW/2 - 10 + 8 - flameLen, 12 + 4)
      ..lineTo(-_bodyW/2 - 10 + 8, 12 + 8)
      ..close();
    canvas.drawPath(flamePath, Paint()..color = const Color(0xFFFFA726));

    canvas.drawPath(flamePath.shift(const Offset(-2, 0)), Paint()..color = const Color(0xFFFFECB3).withOpacity(0.7));

    if (((_t * 3) % 2.0) < 0.12) {
      final starPaint = Paint()..color = Colors.white.withOpacity(0.9);
      _drawStar(canvas, const Offset(20, -26), 4, starPaint);
    }
  }

  void _drawStar(Canvas canvas, Offset c, double r, Paint p) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final rr = (i % 2 == 0) ? r : r * 0.45;
      final x = c.dx + rr * math.cos(a);
      final y = c.dy + rr * math.sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, p);
  }
}

class Meteor extends PositionComponent {
  Meteor({required this.label, required this.baseSpeed});

  final String label;
  final double baseSpeed;

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
      if (_boostTimer <= 0) {
        currentSpeed = baseSpeed;
      }
    }

    if (position.x < -200) {
      removeFromParent();
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

// basit yıldız arkaplan
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
