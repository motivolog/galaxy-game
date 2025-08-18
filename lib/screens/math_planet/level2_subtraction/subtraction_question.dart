import 'dart:math';

class SubtractionQuestion {
  final int a, b, answer;
  final List<int> options;
  SubtractionQuestion(this.a, this.b, this.answer, this.options);

  static SubtractionQuestion generate(Random rnd, int maxA, int maxB) {
    int a = rnd.nextInt(maxA + 1);
    int b = rnd.nextInt(maxB + 1);
    if (b > a) { final t = a; a = b; b = t; }
    final ans = a - b;

    final set = <int>{ans};
    final span = max(3, (ans.abs() * 0.15).round());
    int jitter() => rnd.nextInt(span * 2 + 1) - span;
    while (set.length < 3) {
      final d = ans + jitter();
      if (d >= 0) set.add(d);
    }
    final opts = set.toList()..shuffle(rnd);
    return SubtractionQuestion(a, b, ans, opts);
  }
}
