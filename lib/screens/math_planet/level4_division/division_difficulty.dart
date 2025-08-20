import 'package:flutter/material.dart';
import 'division_page.dart';

class DivisionDifficultyPage extends StatelessWidget {
  const DivisionDifficultyPage({super.key});

  Widget _btn(BuildContext ctx, String t, String diff) {
    return SizedBox(
      width: 280, height: 64,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            ctx,
            MaterialPageRoute(builder: (_) => DivisionPage(difficulty: diff)),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1F2B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Text(t, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1224),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(88),
        child: AppBar(
          backgroundColor: const Color(0xFF0E1224),
          elevation: 0,
          automaticallyImplyLeading: true,
          centerTitle: true,
          title: null,
          flexibleSpace: SafeArea(
            child: Align(
              alignment: const Alignment(0, 1.75),
              child: const Text(
                'Bölme - Zorluk Seviyesi',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _btn(context, 'Kolay ', 'easy'),
                const SizedBox(height: 16),
                _btn(context, 'Orta ', 'medium'),
                const SizedBox(height: 16),
                _btn(context, 'Zor ', 'hard'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
