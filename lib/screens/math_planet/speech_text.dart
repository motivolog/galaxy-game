String mathQuestionToSpeech({
  required int a,
  required String op,
  required int b,
}) {
  final normalized = _normalizeOp(op);
  final opWord = switch (normalized) {
    '+' => 'artı',
    '-' => 'eksi',
    '×' => 'çarpı',
    '÷' => 'bölü',
    _   => 'artı',
  };
  return '$a $opWord $b';
}

String mathAnswerToSpeech({
  required int a,
  required String op,
  required int b,
}) {
  final result = _calcStr(a, op, b);
  return ' $result';
}

String _normalizeOp(String op) {
  if (op == '*') return '×';
  if (op == '/') return '÷';
  return op;
}
String _calcStr(int a, String op, int b) {
  final n = _normalizeOp(op);
  switch (n) {
    case '+':
      return (a + b).toString();
    case '-':
      return (a - b).toString();
    case '×':
      return (a * b).toString();
    case '÷':
      if (b == 0) return 'sıfıra bölme tanımsız';
      final div = a / b;
      if (div == div.roundToDouble()) {
        return div.toInt().toString();
      } else {
        return div.toStringAsFixed(2);
      }
    default:
      return (a + b).toString();
  }
}
