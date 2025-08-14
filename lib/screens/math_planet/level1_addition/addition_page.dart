import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'object_panel.dart';
import 'space_background.dart';

class AdditionLevelPage extends StatefulWidget {
  const AdditionLevelPage({
    super.key,
    this.maxA = 100,
    this.maxB = 100,
    this.targetCorrect = 6,
    required this.objectAssets,
    this.objectSize = 56,
    this.distinctSides = true,
    this.changeAssetsEveryQuestion = true,
    this.visualizeUpTo = 10,
  });

  final int maxA;
  final int maxB;
  final int targetCorrect;
  final List<String> objectAssets;
  final double objectSize;
  final bool distinctSides;
  final bool changeAssetsEveryQuestion;
  final int visualizeUpTo;
  @override
  State<AdditionLevelPage> createState() => _AdditionLevelPageState();
}

class _AdditionLevelPageState extends State<AdditionLevelPage> {
  final _rnd = Random();
  late _AdditionQuestion q;
  int correct = 0;
  bool lockingUi = false;
  bool pulseHint = false;

  late String _leftAsset;
  late String _rightAsset;

  static const int _visualizeUpTo = 10;
  bool get _showObjects =>
      q.a <= widget.visualizeUpTo && q.b <= widget.visualizeUpTo;


  @override
  void initState() {
    super.initState();
    q = _AdditionQuestion.generate(_rnd, widget.maxA, widget.maxB);
    _pickAssets();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final p in widget.objectAssets) {
      precacheImage(AssetImage(p), context);
    }
  }

  void _pickAssets() {
    if (widget.objectAssets.isEmpty) {
      _leftAsset = _rightAsset = '';
      return;
    }
    _leftAsset = widget.objectAssets[_rnd.nextInt(widget.objectAssets.length)];
    if (widget.distinctSides && widget.objectAssets.length > 1) {
      String candidate;
      do {
        candidate = widget.objectAssets[_rnd.nextInt(widget.objectAssets.length)];
      } while (candidate == _leftAsset);
      _rightAsset = candidate;
    } else {
      _rightAsset = widget.objectAssets[_rnd.nextInt(widget.objectAssets.length)];
    }
  }

  Future<void> _onPick(int value) async {
    if (lockingUi) return;
    final isRight = value == q.answer;

    if (isRight) {
      setState(() { lockingUi = true; correct++; });
      await Future.delayed(const Duration(milliseconds: 500));

      if (correct >= widget.targetCorrect) {
        await _completeLevel();
        return;
      }

      setState(() {
        q = _AdditionQuestion.generate(_rnd, widget.maxA, widget.maxB);
        if (widget.changeAssetsEveryQuestion) _pickAssets();
        lockingUi = false;
      });
    } else {
      setState(() => pulseHint = true);
      await Future.delayed(const Duration(milliseconds: 350));
      if (mounted) setState(() => pulseHint = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Bir daha dene ')));
      }
    }
  }

  Future<void> _completeLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('math_level1_done', true);

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        title: Text('Tebrikler!'),
        content: Text('Toplama seviyesini tamamladın.'),
      ),
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortest = size.shortestSide;
    final isTablet = shortest >= 600;
    final titleFs = isTablet ? 44.0 : (size.width < 600 ? 32.0 : 36.0);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const SpaceBackground(),

            // Üst bar
            Positioned(
              top: 8, left: 8, right: 8,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: correct / widget.targetCorrect,
                          minHeight: isTablet ? 14 : 10,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Doğru: $correct / ${widget.targetCorrect}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: isTablet ? 18 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Align(
              alignment: Alignment.center,
              child: Container(
                width: size.width * (isTablet ? 0.8 : 0.88),
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E2148).withOpacity(0.55),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: titleFs,
                              fontWeight: FontWeight.w800,
                            ),
                            children: [
                              TextSpan(text: '${q.a}', style: const TextStyle(color: Color(0xFF9AE6FF))),
                              const TextSpan(text: '  +  ', style: TextStyle(color: Colors.white)),
                              TextSpan(text: '${q.b}', style: const TextStyle(color: Color(0xFFFF84B8))),
                              const TextSpan(text: '  =  ?', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (_showObjects) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ObjectPanel(
                              count: q.a,
                              asset: _leftAsset,
                              maxTargetSize: isTablet ? widget.objectSize * 1.2 : widget.objectSize,
                              semantic: 'Birinci sayı ${q.a}',
                              pulse: pulseHint,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ObjectPanel(
                              count: q.b,
                              asset: _rightAsset,
                              maxTargetSize: isTablet ? widget.objectSize * 1.2 : widget.objectSize,
                              semantic: 'İkinci sayı ${q.b}',
                              pulse: pulseHint,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ] else ...[
                      const SizedBox(height: 4),
                    ],
                  ],
                ),
              ),
            ),

            Positioned(
              right: 12, top: 0, bottom: 0,
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (_, cons) {
                    final colH = cons.maxHeight;
                    final btnH = isTablet ? 88.0 : (colH < 260 ? 56.0 : 70.0);
                    final btnW = isTablet ? 130.0 : (colH < 260 ? 96.0 : 110.0);
                    final spacing = isTablet ? 16.0 : (colH < 260 ? 8.0 : 14.0);
                    final fs = isTablet ? 28.0 : (colH < 260 ? 20.0 : 24.0);

                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int idx = 0; idx < q.options.length; idx++) ...[
                            SizedBox(
                              width: btnW,
                              height: btnH,
                              child: ElevatedButton(
                                onPressed: lockingUi ? null : () => _onPick(q.options[idx]),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text('${q.options[idx]}', style: TextStyle(fontSize: fs)),
                              ),
                            ),
                            if (idx != q.options.length - 1) SizedBox(height: spacing),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdditionQuestion {
  final int a, b, answer;
  final List<int> options;
  _AdditionQuestion(this.a, this.b, this.answer, this.options);

  static _AdditionQuestion generate(Random rnd, int maxA, int maxB) {
    final a = rnd.nextInt(maxA + 1);
    final b = rnd.nextInt(maxB + 1);
    final ans = a + b;

    final span = max(3, (ans * 0.15).round());
    int jitter() => rnd.nextInt(span * 2 + 1) - span;

    final set = <int>{ans};
    while (set.length < 3) {
      final d = ans + jitter();
      if (d >= 0) set.add(d);
    }

    final opts = set.toList()..shuffle(rnd);
    return _AdditionQuestion(a, b, ans, opts);
  }
}
