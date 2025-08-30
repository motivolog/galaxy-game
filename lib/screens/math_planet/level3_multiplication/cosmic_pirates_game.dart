import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'multiplication_question_generator.dart';
import 'package:flutter_projects/analytics_helper.dart'; //  Analytics

class Monster extends SpriteComponent {
  Monster({
    required Vector2 start,
    required this.speed,
    required Sprite sprite,
    required this.worldScale,
  }) : super(
    sprite: sprite,
    position: start,
    size: Vector2(80, 80) * worldScale,
    anchor: Anchor.center,
  );

  final double speed;
  final double worldScale;

  @override
  void update(double dt) {
    super.update(dt);
    x -= speed * dt;
  }

  bool get isOutOfScreen => x + width < -16 * worldScale;
}

class PiratesMultiplyGame extends FlameGame {
  PiratesMultiplyGame({
    required this.targetCorrect,
    required this.difficulty,
    required this.onUiRefresh,
    required this.onFinished,
    this.onNewQuestion,
    this.onCorrectAnswer,
    this.onWrongAnswer,
    double? worldScale,
    this.scaleSpeedWithWorld = false,
  }) : worldScaleOverride = worldScale;

  final int targetCorrect;
  final Difficulty difficulty;
  final VoidCallback onUiRefresh;
  final VoidCallback onFinished;
  final void Function(int a, int b)? onNewQuestion;
  final Future<void> Function(int a, int b)? onCorrectAnswer;
  final Future<void> Function()? onWrongAnswer;

  final double? worldScaleOverride;
  late double worldScale;
  final bool scaleSpeedWithWorld;

  QuizState state = QuizState.presenting;
  int correctCount = 0;
  int lives = 3;

  Question? currentQuestion;

  late List<Sprite> monsterSprites;
  late RectangleComponent playerAnchor;

  Monster? monster;

  @override
  Color backgroundColor() => Colors.transparent;

  double get _baseMonsterSpeed {
    switch (difficulty) {
      case Difficulty.easy:
        return 55;
      case Difficulty.medium:
        return 75;
      case Difficulty.hard:
        return 80;
    }
  }

  double get monsterSpeed =>
      scaleSpeedWithWorld ? _baseMonsterSpeed * worldScale : _baseMonsterSpeed;

  double _autoScale() {
    final shortest = math.min(size.x, size.y);
    final bool isTablet = shortest >= 600;
    if (isTablet) return 1.70;
    if (shortest < 360) return 1.10;
    if (shortest < 390) return 1.18;
    if (shortest < 430) return 1.24;
    return 1.28;
  }

  bool get _isTablet => math.min(size.x, size.y) >= 600;
  double get _laneY => size.y * (_isTablet ? 0.56 : 0.58);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    worldScale = worldScaleOverride ?? _autoScale();

    monsterSprites = [
      await Sprite.load('planet3/enemy1.png'),
      await Sprite.load('planet3/enemy2.png'),
      await Sprite.load('planet3/enemy3.png'),
      await Sprite.load('planet3/enemy4.png'),
      await Sprite.load('planet3/enemy5.png'),
    ];

    playerAnchor = RectangleComponent(
      position: Vector2(24 * worldScale, _laneY - 28 * worldScale),
      size: Vector2(56, 56) * worldScale,
      paint: Paint()..color = const Color(0x00000000),
      anchor: Anchor.topLeft,
    );
    add(playerAnchor);

    _nextQuestion();
  }

  @override
  void update(double dt) {
    super.update(dt);

    final m = monster;
    if (state == QuizState.presenting && m != null && m.isOutOfScreen) {
      lives = (lives - 1).clamp(0, 3);
      ALog.e('math_life_lost', params: {
        'mode': 'mul',
        'reason': 'missed',
        'lives_left': lives,
      });

      if (lives <= 0) {
        _triggerGameOver();
      } else {
        _spawnMonster();
        onUiRefresh();
      }
    }
  }

  void _nextQuestion() {
    currentQuestion = MultiplicationQuestionGenerator.next(difficulty);
    state = QuizState.presenting;
    _spawnMonster();
    onUiRefresh();

    final q = currentQuestion;
    if (q != null) {
      onNewQuestion?.call(q.a, q.b);
    }
  }

  void _spawnMonster() {
    monster?.removeFromParent();

    final sprite = monsterSprites[math.Random().nextInt(monsterSprites.length)];
    monster = Monster(
      start: Vector2(size.x + 80 * worldScale, _laneY - 6 * worldScale),
      speed: monsterSpeed,
      sprite: sprite,
      worldScale: worldScale,
    );
    add(monster!);
  }

  Future<void> onAnswerSelected(int value) async {
    if (state != QuizState.presenting || currentQuestion == null) return;

    state = QuizState.resolving;
    final q = currentQuestion!;
    final isCorrect = value == q.answer;

    if (isCorrect) {
      correctCount++;
      onUiRefresh();
      _fireBeamAndRemoveMonster();

      Future<void> speak = onCorrectAnswer?.call(q.a, q.b) ?? Future.value();
      bool timedOut = false;
      await Future.any([
        speak,
        Future.delayed(const Duration(milliseconds: 3000)).then((_) {
          timedOut = true;
        }),
      ]);
      if (timedOut) {
        ALog.e('tts_timeout', params: {'mode': 'mul', 'phase': 'correct'});
      }
      _proceedAfterCorrect();
      return;
    }
    final x = playerAnchor.x;
    final double shake = 6 * worldScale;
    playerAnchor.add(
      SequenceEffect([
        MoveToEffect(Vector2(x + shake, playerAnchor.y),
            EffectController(duration: 0.05)),
        MoveToEffect(Vector2(x - shake, playerAnchor.y),
            EffectController(duration: 0.05)),
        MoveToEffect(Vector2(x, playerAnchor.y),
            EffectController(duration: 0.05)),
      ]),
    );

    if (onWrongAnswer != null) {
      await onWrongAnswer!();
    }
    lives = (lives - 1).clamp(0, 3);
    ALog.e('math_life_lost', params: {
      'mode': 'mul',
      'reason': 'wrong',
      'lives_left': lives,
    });

    if (lives <= 0) {
      _triggerGameOver();
      return;
    }
    monster?.removeFromParent();
    monster = null;
    _spawnMonster();

    state = QuizState.presenting;
    onUiRefresh();
  }

  void _fireBeamAndRemoveMonster() {
    final to = monster?.center;
    final from = playerAnchor.center;
    if (to != null) {
      final dx = to.x - from.x;
      final dy = to.y - from.y;
      final len = math.sqrt(dx * dx + dy * dy);
      final double beamThickness = (_isTablet ? 3.0 : 2.0) * worldScale;

      final beam = RectangleComponent(
        position: from,
        size: Vector2(beamThickness, beamThickness),
        paint: Paint()..color = const Color(0xFF80DEEA),
        anchor: Anchor.centerLeft,
      )..angle = math.atan2(dy, dx);

      beam.priority = 1000;
      add(beam);

      beam.add(SequenceEffect([
        SizeEffect.to(
          Vector2(len, beamThickness),
          EffectController(duration: 0.12, curve: Curves.easeOut),
        ),
        OpacityEffect.to(0, EffectController(duration: 0.12)),
        RemoveEffect(),
      ]));
    }
    monster?.removeFromParent();
    monster = null;
  }

  void _proceedAfterCorrect() {
    if (correctCount >= targetCorrect) {
      state = QuizState.finished;
      onUiRefresh();
      onFinished();
    } else {
      _nextQuestion();
    }
  }

  void _triggerGameOver() {
    state = QuizState.finished;
    pauseEngine();
    overlays.add('gameover');
    onUiRefresh();

    // Game over olayı
    ALog.e('math_gameover', params: {
      'mode': 'mul',
      'correct': correctCount,
      'target': targetCorrect,
      'lives_left': lives,
    });
  }

  void restart() {
    correctCount = 0;
    lives = 3;
    state = QuizState.presenting;
    monster?.removeFromParent();
    monster = null;
    resumeEngine();
    _nextQuestion();
  }
}
