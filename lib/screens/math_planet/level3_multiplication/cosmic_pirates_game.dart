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
  }) : super(
    sprite: sprite,
    position: start,
    size: Vector2(80, 80),
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
  });

  final int targetCorrect;
  final Difficulty difficulty;
  final VoidCallback onUiRefresh;
  final VoidCallback onFinished;

  QuizState state = QuizState.presenting;
  int correctCount = 0;
  int lives = 3;

  Question? currentQuestion;

  late List<Sprite> monsterSprites;
  late RectangleComponent playerAnchor;
  Monster? monster;

  @override
  Color backgroundColor() => Colors.transparent;

  double get monsterSpeed {
    switch (difficulty) {
      case Difficulty.easy:
        return 55;
      case Difficulty.medium:
        return 75;
      case Difficulty.hard:
        return 80;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    monsterSprites = [
      await Sprite.load('planet3/enemy1.png'),
      await Sprite.load('planet3/enemy2.png'),
      await Sprite.load('planet3/enemy3.png'),
      await Sprite.load('planet3/enemy4.png'),
      await Sprite.load('planet3/enemy5.png'),
    ];

    final laneY = size.y * 0.58;
    playerAnchor = RectangleComponent(
      position: Vector2(24, laneY - 28),
      size: Vector2(56, 56),
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
  }

  void _spawnMonster() {
    monster?.removeFromParent();

    final laneY = size.y * 0.58;
    final sprite = monsterSprites[math.Random().nextInt(monsterSprites.length)];

    monster = Monster(
      start: Vector2(size.x + 80, laneY - 6),
      speed: monsterSpeed,
      sprite: sprite,
    );
    add(monster!);
  }

  void onAnswerSelected(int value) {
    if (state != QuizState.presenting || currentQuestion == null) return;

    if (value == currentQuestion!.answer) {
      state = QuizState.resolving;
      correctCount++;
      _beamThenNext();
    } else {
      lives = (lives - 1).clamp(0, 3);

      final x = playerAnchor.x;
      playerAnchor.add(
        SequenceEffect([
          MoveToEffect(Vector2(x + 6, playerAnchor.y),
              EffectController(duration: 0.05)),
          MoveToEffect(Vector2(x - 6, playerAnchor.y),
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

      final beam = RectangleComponent(
        position: from,
        size: Vector2(2, 2),
        paint: Paint()..color = const Color(0xFF80DEEA),
        anchor: Anchor.centerLeft,
      )..angle = math.atan2(dy, dx);
      add(beam);

      beam.add(SequenceEffect([
        SizeEffect.to(Vector2(len, 2),
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
