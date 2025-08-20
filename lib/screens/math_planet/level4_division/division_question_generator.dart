import 'dart:math';

class DivisionQuestion {
  final int a;
  final int b;
  final int answer;
  final List<int> options;

  DivisionQuestion(this.a, this.b, this.answer, this.options);

  String get text => "$a ÷ $b = ?";
}

class _Profile {
  const _Profile({
    required this.minDividend,
    required this.maxDividend,
    required this.minDivisor,
    required this.maxDivisor,
    required this.minQuotient,
    required this.maxQuotient,
    this.optionCount = 3,
    this.deltaMax = 2,
  });

  final int minDividend, maxDividend;
  final int minDivisor, maxDivisor;
  final int minQuotient, maxQuotient;
  final int optionCount;
  final int deltaMax;
}

class DivisionQuestionGenerator {
  final Random _rng = Random();

  static const _easy = _Profile(
    minDividend: 1,   maxDividend: 30,   // a ∈ [1,30]
    minDivisor:  2,   maxDivisor: 10,    // b ∈ [2,10]
    minQuotient: 2,   maxQuotient: 12,   // ans ≥ 2
    optionCount: 3,   deltaMax: 2,
  );

  static const _medium = _Profile(
    minDividend: 20,  maxDividend: 60,   // a ∈ [20,60]
    minDivisor:  2,   maxDivisor: 12,    // b ∈ [2,12]
    minQuotient: 2,   maxQuotient: 15,   // ans ≥ 2
    optionCount: 3,   deltaMax: 3,
  );

  static const _hard = _Profile(
    minDividend: 45,  maxDividend: 100,  // a ∈ [45,100]
    minDivisor:  2,   maxDivisor: 15,    // b ∈ [2,15]
    minQuotient: 2,   maxQuotient: 20,   // ans ≥ 2
    optionCount: 3,   deltaMax: 4,
  );

  _Profile _pickProfile(String difficulty) {
    switch (difficulty) {
      case 'easy':   return _easy;
      case 'medium': return _medium;
      default:       return _hard;
    }
  }

  DivisionQuestion next({required String difficulty}) {
    final p = _pickProfile(difficulty);

    int a = 0, b = 0, ans = 0;

    for (int tries = 0; tries < 200; tries++) {
      b = _randIn(p.minDivisor, p.maxDivisor);

      final minAnsForB = _clampMax(
        _max2(p.minQuotient, _ceilDiv(p.minDividend, b)),
        p.maxQuotient,
      );
      final maxAnsForB = _min2(
        p.maxQuotient,
        _floorDiv(p.maxDividend, b),
      );

      if (minAnsForB > maxAnsForB) {
        continue;
      }

      ans = _randIn(minAnsForB, maxAnsForB);
      a = ans * b;

      if (a >= p.minDividend && a <= p.maxDividend) {
        break;
      }
    }

    final options = _buildOptions(correct: ans, count: p.optionCount, deltaMax: p.deltaMax)
      ..shuffle(_rng);

    return DivisionQuestion(a, b, ans, options);
  }


  int _randIn(int lo, int hi) => lo + _rng.nextInt(hi - lo + 1);

  int _ceilDiv(int x, int y) => (x + y - 1) ~/ y;
  int _floorDiv(int x, int y) => x ~/ y;

  int _min2(int a, int b) => a < b ? a : b;
  int _max2(int a, int b) => a > b ? a : b;

  int _clampMax(int v, int maxV) => v > maxV ? maxV : v;

  List<int> _buildOptions({required int correct, required int count, required int deltaMax}) {
    final set = <int>{correct};

    while (set.length < count) {
      final delta = 1 + _rng.nextInt(deltaMax);
      final sign  = _rng.nextBool() ? 1 : -1;
      final cand  = correct + sign * delta;
      if (cand > 0) set.add(cand);
    }

    for (int k = 1; set.length < count; k++) {
      final cand = correct + k;
      if (cand > 0) set.add(cand);
    }

    return set.toList();
  }
}
