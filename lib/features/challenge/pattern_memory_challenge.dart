import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PatternMemoryChallenge extends StatefulWidget {
  final int difficulty;
  final VoidCallback onSuccess;
  final VoidCallback onFail;

  const PatternMemoryChallenge({
    super.key,
    required this.difficulty,
    required this.onSuccess,
    required this.onFail,
  });

  @override
  State<PatternMemoryChallenge> createState() => _PatternMemoryChallengeState();
}

class _PatternMemoryChallengeState extends State<PatternMemoryChallenge> {
  late int _gridSize;
  late int _highlightCount;
  late int _displaySeconds;
  late List<bool> _targetPattern;
  late List<bool> _userPattern;
  bool _isMemorizing = true;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    if (widget.difficulty == 1) {
      _gridSize = 3;
      _highlightCount = 4;
      _displaySeconds = 3;
    } else if (widget.difficulty == 2) {
      _gridSize = 4;
      _highlightCount = 6;
      _displaySeconds = 4;
    } else {
      _gridSize = 5;
      _highlightCount = 9;
      _displaySeconds = 5;
    }

    _targetPattern = List.generate(_gridSize * _gridSize, (_) => false);
    _userPattern = List.generate(_gridSize * _gridSize, (_) => false);
    
    int added = 0;
    while (added < _highlightCount) {
      int idx = Random().nextInt(_targetPattern.length);
      if (!_targetPattern[idx]) {
        _targetPattern[idx] = true;
        added++;
      }
    }

    _isMemorizing = true;
    Timer(Duration(seconds: _displaySeconds), () {
      if (mounted) {
        setState(() {
          _isMemorizing = false;
        });
      }
    });
  }

  void _onTap(int index) {
    if (_isMemorizing) return;
    setState(() {
      _userPattern[index] = !_userPattern[index];
    });
  }

  void _checkResult() {
    bool correct = true;
    for (int i = 0; i < _targetPattern.length; i++) {
      if (_targetPattern[i] != _userPattern[i]) {
        correct = false;
        break;
      }
    }

    if (correct) {
      widget.onSuccess();
    } else {
      widget.onFail();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'PATTERN MEMORY',
          style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        Text(
          _isMemorizing 
            ? 'Memorize the pattern (Level ${widget.difficulty})' 
            : 'Recreate the pattern (Level ${widget.difficulty})',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(4),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _gridSize,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _targetPattern.length,
            itemBuilder: (context, index) {
              bool showHighlight = _isMemorizing ? _targetPattern[index] : _userPattern[index];
              return GestureDetector(
                onTap: () => _onTap(index),
                child: AnimatedContainer(
                  duration: 200.ms,
                  decoration: BoxDecoration(
                    color: showHighlight 
                        ? const Color(0xFF8B5CF6) 
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: showHighlight ? const Color(0xFF8B5CF6) : Colors.white10,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (!_isMemorizing)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _checkResult,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ),
          ),
      ],
    );
  }
}
