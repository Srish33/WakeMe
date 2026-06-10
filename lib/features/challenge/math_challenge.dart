import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MathChallenge extends StatefulWidget {
  final int difficulty;
  final VoidCallback onSuccess;
  final VoidCallback onFail;

  const MathChallenge({
    super.key,
    required this.difficulty,
    required this.onSuccess,
    required this.onFail,
  });

  @override
  State<MathChallenge> createState() => _MathChallengeState();
}

class _MathChallengeState extends State<MathChallenge> {
  late String _question;
  late int _answer;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateProblem();
  }

  void _generateProblem() {
    final rand = Random();
    if (widget.difficulty == 1) {
      // Easy: Addition/Subtraction
      int a = rand.nextInt(20) + 1;
      int b = rand.nextInt(20) + 1;
      if (rand.nextBool()) {
        _question = '$a + $b';
        _answer = a + b;
      } else {
        if (a < b) {
          int temp = a;
          a = b;
          b = temp;
        }
        _question = '$a - $b';
        _answer = a - b;
      }
    } else if (widget.difficulty == 2) {
      // Medium: Multiplication/Division
      int a = rand.nextInt(12) + 2;
      int b = rand.nextInt(12) + 2;
      if (rand.nextBool()) {
        _question = '$a × $b';
        _answer = a * b;
      } else {
        int product = a * b;
        _question = '$product ÷ $a';
        _answer = b;
      }
    } else {
      // Hard: Multiple-operation expressions
      int a = rand.nextInt(10) + 2;
      int b = rand.nextInt(10) + 2;
      int c = rand.nextInt(10) + 2;
      _question = '($a × $b) + $c';
      _answer = (a * b) + c;
    }
  }

  void _checkAnswer() {
    if (int.tryParse(_controller.text) == _answer) {
      widget.onSuccess();
    } else {
      _controller.clear();
      widget.onFail();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'MATH CHALLENGE',
          style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        const SizedBox(height: 32),
        Text(
          _question,
          style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 24),
          decoration: InputDecoration(
            hintText: 'Answer',
            hintStyle: const TextStyle(color: Colors.white24),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF8B5CF6))),
          ),
          onSubmitted: (_) => _checkAnswer(),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _checkAnswer,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5CF6),
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
