import 'package:flame/game.dart';
import 'division_question_generator.dart';
import 'package:flutter/material.dart';

enum QuizState { presenting, resolving, escaping, finished }

class DivisionGame extends FlameGame {
  DivisionGame({
    required this.difficulty,
    required this.onUiRefresh,
    required this.onFinished,
  }) : totalQuestions = switch (difficulty) {
    'easy'   => 10,
    'medium' => 12,
    _        => 16,
  };

  final String difficulty;
  final VoidCallback onUiRefresh;
  final VoidCallback onFinished;
  final int totalQuestions;
  final gen = DivisionQuestionGenerator();

  int currentIndex = 0;
  int correctCount = 0;
  QuizState state = QuizState.presenting;
  double progress = 0.0;
  DivisionQuestion? current;
  int? lastSelectedIndex;
  int monsterShakeTick = 0;

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _nextQuestion();
  }

  void _nextQuestion() {
    lastSelectedIndex = null;
    current = gen.next(difficulty: difficulty);
    state = QuizState.presenting;
    onUiRefresh();
  }
  void onAnswerSelected(int value) => onAnswerSelectedAt(value, -1);
  void onAnswerSelectedAt(int value, int index) {
    if (state != QuizState.presenting || current == null) return;
    state = QuizState.resolving;
    lastSelectedIndex = index;
    onUiRefresh();

    final isCorrect = value == current!.answer;

    if (isCorrect) {
      correctCount++;
      progress = (correctCount / totalQuestions).clamp(0.0, 1.0);
      if (correctCount >= totalQuestions) {
        state = QuizState.escaping;
        onUiRefresh();

        Future.delayed(const Duration(milliseconds: 1200), () {
          state = QuizState.finished;
          onUiRefresh();
          onFinished();
        });
        return;
      }
      Future.delayed(const Duration(milliseconds: 400), () {
        currentIndex++;
        _nextQuestion();
      });

    } else {
      monsterShakeTick++;
      onUiRefresh();
      Future.delayed(const Duration(milliseconds: 400), () {
        state = QuizState.presenting;
        lastSelectedIndex = null;
        onUiRefresh();
      });
    }
  }
}
