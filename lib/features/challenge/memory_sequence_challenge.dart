import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class MemorySequenceChallenge extends StatefulWidget {
  final int difficulty;
  final VoidCallback onSuccess;
  final VoidCallback onFail;

  const MemorySequenceChallenge({
    super.key,
    required this.difficulty,
    required this.onSuccess,
    required this.onFail,
  });

  @override
  State<MemorySequenceChallenge> createState() => _MemorySequenceChallengeState();
}

class _MemorySequenceChallengeState extends State<MemorySequenceChallenge> {
  List<int> _sequence = [];
  List<int> _userSequence = [];
  bool _isShowingSequence = true;
  bool _canInput = false;

  final List<Color> _buttonColors = [
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFF22D3EE), // Cyan
    const Color(0xFFFACC15), // Yellow
    const Color(0xFFF43F5E), // Rose
  ];

  @override
  void initState() {
    super.initState();
    _startNewLevel();
  }

  void _startNewLevel() {
    setState(() {
      _isShowingSequence = true;
      _canInput = false;
      _userSequence = [];
      // Level 1: 3 colors, Level 2: 4 colors, Level 3: 5 colors
      int length = widget.difficulty + 2; 
      _sequence = List.generate(length, (_) => Random().nextInt(4));
    });

    // Uniform 3 seconds display as per refinement
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isShowingSequence = false;
          _canInput = true;
        });
      }
    });
  }

  void _handleInput(int index) {
    if (!_canInput) return;

    setState(() {
      _userSequence.add(index);
    });

    if (_userSequence.last != _sequence[_userSequence.length - 1]) {
      widget.onFail();
      return;
    }

    if (_userSequence.length == _sequence.length) {
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'MEMORY SEQUENCE',
          style: TextStyle(
            color: Color(0xFF8B5CF6),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        Text(
          'Repeat the Sequence (Level ${widget.difficulty})',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        Container(
          height: 80,
          alignment: Alignment.center,
          child: _isShowingSequence 
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _sequence.map((colorIndex) {
                  return Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _buttonColors[colorIndex],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: _buttonColors[colorIndex].withValues(alpha: 0.5), blurRadius: 10)
                      ],
                    ),
                  ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
                }).toList(),
              )
            : Text(
                'GO!',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ).animate().fadeIn(),
        ),
        const SizedBox(height: 40),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _handleInput(index),
              child: AnimatedContainer(
                duration: 200.ms,
                decoration: BoxDecoration(
                  color: _canInput ? _buttonColors[index] : _buttonColors[index].withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _canInput ? [
                    BoxShadow(color: _buttonColors[index].withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                  ] : [],
                ),
                child: Icon(
                  [Icons.grid_view_rounded, Icons.category_rounded, Icons.change_history_rounded, Icons.layers_rounded][index],
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 28,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
