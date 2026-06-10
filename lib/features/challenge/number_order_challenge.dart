import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NumberOrderChallenge extends StatefulWidget {
  final int difficulty;
  final VoidCallback onSuccess;
  final VoidCallback onFail;

  const NumberOrderChallenge({
    super.key,
    required this.difficulty,
    required this.onSuccess,
    required this.onFail,
  });

  @override
  State<NumberOrderChallenge> createState() => _NumberOrderChallengeState();
}

class _NumberOrderChallengeState extends State<NumberOrderChallenge> {
  late List<int> _numbers;
  int _nextTarget = 1;
  late int _maxNumber;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    _nextTarget = 1;
    if (widget.difficulty == 1) {
      _maxNumber = 10;
    } else if (widget.difficulty == 2) {
      _maxNumber = 20;
    } else {
      _maxNumber = 50;
    }
    _numbers = List.generate(_maxNumber, (i) => i + 1)..shuffle();
  }

  void _onTap(int number) {
    if (number == _nextTarget) {
      setState(() {
        _nextTarget++;
      });
      if (_nextTarget > _maxNumber) {
        widget.onSuccess();
      }
    } else {
      widget.onFail();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'NUMBER ORDER',
          style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        Text(
          'Tap numbers 1 to $_maxNumber in order',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _numbers.length,
            itemBuilder: (context, index) {
              final num = _numbers[index];
              final isTapped = num < _nextTarget;
              return GestureDetector(
                onTap: isTapped ? null : () => _onTap(num),
                child: AnimatedContainer(
                  duration: 200.ms,
                  decoration: BoxDecoration(
                    color: isTapped 
                        ? Colors.white.withValues(alpha: 0.05) 
                        : const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isTapped ? Colors.white10 : const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$num',
                      style: TextStyle(
                        color: isTapped ? Colors.white24 : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
