import 'package:flame/game.dart';
import 'division_question_generator.dart';
import 'package:flutter/material.dart';

enum QuizState { presenting, resolving, escaping, finished }

class DivisionGame extends FlameGame {
  DivisionGame({
    required this.difficulty,
    required this.onUiRefresh,
    required this.onFinished,
    this.onNewQuestion,
    this.onCorrectAnswer,
  }) : totalQuestions = switch (difficulty) {
    'easy' => 10,
    'medium' => 12,
    _ => 16,
  };

  final String difficulty;
  final VoidCallback onUiRefresh;
  final VoidCallback onFinished;
  final void Function(int a, int b)? onNewQuestion;
  final void Function(int a, int b)? onCorrectAnswer;
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
    _notifyNewQuestion();
  }
  (int?, int?) _extractAB(DivisionQuestion? q) {
    if (q == null) return (null, null);
    int? a, b;
    try {
      final dynamic dq = q;
      if (dq.a is int && dq.b is int) {
        a = dq.a as int;
        b = dq.b as int;
      } else if (dq.left is int && dq.right is int) {
        a = dq.left as int;
        b = dq.right as int;
      } else if (dq.numerator is int && dq.denominator is int) {
        a = dq.numerator as int;
        b = dq.denominator as int;
      }
    } catch (_) {}
    if (a == null || b == null) {
      try {
        final dynamic dq = q;
        final String text =
        (dq.text is String) ? (dq.text as String) : dq.toString();
        final m = RegExp(r'(\d+)\s*[÷/]\s*(\d+)').firstMatch(text);
        if (m != null) {
          a = int.parse(m.group(1)!);
          b = int.parse(m.group(2)!);
        }
      } catch (_) {}
    }
    return (a, b);
  }

  void _notifyNewQuestion() {
    final (a, b) = _extractAB(current);
    if (a != null && b != null) {
      onNewQuestion?.call(a, b);
    }
  }

  void onAnswerSelected(int value) => onAnswerSelectedAt(value, -1);
  void onAnswerSelectedAt(int value, int index) {
    if (state != QuizState.presenting || current == null) return;
    state = QuizState.resolving;
    lastSelectedIndex = index;
    onUiRefresh();

    final isCorrect = value == current!.answer;
    if (isCorrect) {
      final (a, b) = _extractAB(current);
      if (a != null && b != null) {
        onCorrectAnswer?.call(a, b);
      }
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
