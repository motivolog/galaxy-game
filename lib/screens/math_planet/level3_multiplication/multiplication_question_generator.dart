import 'dart:math' as math;

enum Difficulty { easy, medium, hard }
enum QuizState { presenting, resolving, finished }

class Question {
  final int a;
  final int b;
  final String text;
  final int answer;
  final List<int> options;

  Question({
    required this.a,
    required this.b,
    required this.text,
    required this.answer,
    required this.options,
  });
}

class MultiplicationQuestionGenerator {
  static final _rng = math.Random();

  static (int min, int max) _range(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return (1, 5);
      case Difficulty.medium:
        return (5, 12);
      case Difficulty.hard:
        return (10, 50);
    }
  }

  static Question next(Difficulty difficulty) {
    final (min, max) = _range(difficulty);
    final a = min + _rng.nextInt(max - min + 1);
    final b = min + _rng.nextInt(max - min + 1);
    final ans = a * b;

    final opts = <int>{ans};
    while (opts.length < 3) {
      final delta = 1 + _rng.nextInt(6);
      final sign = _rng.nextBool() ? 1 : -1;
      final cand = math.max(0, ans + sign * delta * (1 + _rng.nextInt(2)));
      if (cand != ans) opts.add(cand);
    }
    final list = opts.toList()..shuffle(_rng);

    return Question(
      a: a,
      b: b,
      text: "$a × $b = ?",
      answer: ans,
      options: list,
    );
  }
}
