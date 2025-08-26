import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'multiplication_question_generator.dart';

class Monster extends SpriteComponent {
  Monster({
    required Vector2 start,
    required this.speed,
    required Sprite sprite,
    required double worldScale,
  }) : super(
    sprite: sprite,
    position: start,
    size: Vector2(80, 80) * worldScale,
    anchor: Anchor.center,
  );
  final double speed;

  @override
  void update(double dt) {
    super.update(dt);
    x -= speed * dt;
  }

  bool get isOutOfScreen => x + width < -16;
}

class PiratesMultiplyGame extends FlameGame {
  PiratesMultiplyGame({
    required this.targetCorrect,
    required this.difficulty,
    required this.onUiRefresh,
    required this.onFinished,
    this.onNewQuestion,
    this.onCorrectAnswer,
    double? worldScale,
    this.scaleSpeedWithWorld = false,
  }) : worldScaleOverride = worldScale;

  final int targetCorrect;
  final Difficulty difficulty;
  final VoidCallback onUiRefresh;
  final VoidCallback onFinished;
  final void Function(int a, int b)? onNewQuestion;
  final void Function(int a, int b)? onCorrectAnswer;
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

    final laneY = size.y * 0.58;

    playerAnchor = RectangleComponent(
      position: Vector2(24 * worldScale, laneY - 28 * worldScale),
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
      if (lives <= 0) {
        state = QuizState.finished;
        onUiRefresh();
        onFinished();
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
      final m = RegExp(r'^(\d+)\s*[×x\*]\s*(\d+)\s*=').firstMatch(q.text);
      if (m != null) {
        final a = int.parse(m.group(1)!);
        final b = int.parse(m.group(2)!);
        onNewQuestion?.call(a, b);
      }
    }
  }

  void _spawnMonster() {
    monster?.removeFromParent();

    final laneY = size.y * 0.58;
    final sprite = monsterSprites[math.Random().nextInt(monsterSprites.length)];

    monster = Monster(
      start: Vector2(size.x + 80 * worldScale, laneY - 6 * worldScale),
      speed: monsterSpeed,
      sprite: sprite,
      worldScale: worldScale,
    );
    add(monster!);
  }

  void onAnswerSelected(int value) {
    if (state != QuizState.presenting || currentQuestion == null) return;
    if (value == currentQuestion!.answer) {
      state = QuizState.resolving;
      correctCount++;
      final txt = currentQuestion!.text;
      final m = RegExp(r'^(\d+)\s*[×x\*]\s*(\d+)\s*=').firstMatch(txt);
      if (m != null) {
        final a = int.parse(m.group(1)!);
        final b = int.parse(m.group(2)!);
        onCorrectAnswer?.call(a, b);
      }

      _beamThenNext();
    } else {
      lives = (lives - 1).clamp(0, 3);

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

      if (lives <= 0) {
        state = QuizState.finished;
        onUiRefresh();
        onFinished();
        return;
      }
      state = QuizState.presenting;
      onUiRefresh();
    }
  }
  void _beamThenNext() {
    final to = monster?.center;
    final from = playerAnchor.center;
    if (to != null) {
      final dx = to.x - from.x;
      final dy = to.y - from.y;
      final len = math.sqrt(dx * dx + dy * dy);

      final double beamThickness = 2 * worldScale;
      final beam = RectangleComponent(
        position: from,
        size: Vector2(beamThickness, beamThickness),
        paint: Paint()..color = const Color(0xFF80DEEA),
        anchor: Anchor.centerLeft,
      )..angle = math.atan2(dy, dx);
      add(beam);

      beam.add(SequenceEffect([
        SizeEffect.to(Vector2(len, beamThickness),
            EffectController(duration: 0.12, curve: Curves.easeOut)),
        OpacityEffect.to(0, EffectController(duration: 0.12)),
        RemoveEffect(),
      ]));
    }

    monster?.removeFromParent();
    monster = null;

    if (correctCount >= targetCorrect) {
      state = QuizState.finished;
      onUiRefresh();
      onFinished();
    } else {
      _nextQuestion();
    }
  }
}
