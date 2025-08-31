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
    this.onWrongAnswer,
  }) : totalQuestions = switch (difficulty) {
    'easy' => 10,
    'medium' => 12,
    _ => 16,
  };

  final String difficulty;
  final VoidCallback onUiRefresh;
  final VoidCallback onFinished;
  final void Function(int a, int b)? onNewQuestion;
  final Future<void> Function(int a, int b)? onCorrectAnswer;
  final Future<void> Function()? onWrongAnswer;

  final int totalQuestions;
  final gen = DivisionQuestionGenerator();

  int currentIndex = 0;
  int correctCount = 0;
  QuizState state = QuizState.presenting;
  double progress = 0.0;
  DivisionQuestion? current;
  int? lastSelectedIndex;
  int monsterShakeTick = 0;

  // ⛑küçük korumalar
  bool _finishNotified = false;
  int _answerSeq = 0;

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _nextQuestion();
  }
  void restart() {
    currentIndex = 0;
    correctCount = 0;
    progress = 0.0;
    state = QuizState.presenting;
    lastSelectedIndex = null;
    _finishNotified = false;
    monsterShakeTick = 0;
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
        final String text = (dq.text is String) ? (dq.text as String) : dq.toString();
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

  Future<void> onAnswerSelected(int value) => onAnswerSelectedAt(value, -1);

  Future<void> onAnswerSelectedAt(int value, int index) async {
    if (state != QuizState.presenting || current == null) return;
    final int mySeq = ++_answerSeq;

    state = QuizState.resolving;
    lastSelectedIndex = index;
    onUiRefresh();

    final isCorrect = value == current!.answer;

    if (isCorrect) {
      final (a, b) = _extractAB(current);
      if (a != null && b != null && onCorrectAnswer != null) {
        try {
          await onCorrectAnswer!(a, b);
        } catch (_) {}
      }

      correctCount++;
      progress = (correctCount / totalQuestions).clamp(0.0, 1.0);

      if (correctCount >= totalQuestions) {
        // kaçış animasyonu → bitiş
        state = QuizState.escaping;
        onUiRefresh();
        Future.delayed(const Duration(milliseconds: 1200), () {
          // aynı anda birden fazla tamamlanmayı engelle
          if (_finishNotified) return;
          _finishNotified = true;

          state = QuizState.finished;
          onUiRefresh();
          onFinished();
        });
        return;
      }

      currentIndex++;
      _nextQuestion();
    } else {
      if (onWrongAnswer != null) {
        try {
          await onWrongAnswer!();
        } catch (_) {}
      }

      monsterShakeTick++;
      onUiRefresh();

      await Future.delayed(const Duration(milliseconds: 400));

      // esnada başka cevaplandıysa (ör. overlay) geri alma
      if (mySeq != _answerSeq) return;

      state = QuizState.presenting;
      lastSelectedIndex = null;
      onUiRefresh();
    }
  }
}
