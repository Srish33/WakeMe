import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MatchPairsChallenge extends StatefulWidget {
  final int difficulty;
  final VoidCallback onSuccess;
  final VoidCallback onFail;

  const MatchPairsChallenge({
    super.key,
    required this.difficulty,
    required this.onSuccess,
    required this.onFail,
  });

  @override
  State<MatchPairsChallenge> createState() => _MatchPairsChallengeState();
}

class _MatchPairsChallengeState extends State<MatchPairsChallenge> {
  final List<IconData> _iconsPool = [
    Icons.wb_sunny_rounded, Icons.nightlight_round, Icons.cloud_rounded, 
    Icons.flash_on_rounded, Icons.water_drop_rounded, Icons.eco_rounded,
    Icons.star_rounded, Icons.pets_rounded, Icons.music_note_rounded, 
    Icons.favorite_rounded, Icons.explore_rounded, Icons.auto_awesome_rounded
  ];

  late List<IconData> _gridIcons;
  late List<bool> _flipped;
  late List<bool> _matched;
  int? _firstIndex;
  bool _wait = false;
  int _matchesFound = 0;
  late int _totalPairs;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    // Level 1: 4 pairs (8 cards), Level 2: 6 pairs (12 cards), Level 3: 8 pairs (16 cards)
    if (widget.difficulty == 1) {
      _totalPairs = 4;
    } else if (widget.difficulty == 2) {
      _totalPairs = 6;
    } else {
      _totalPairs = 8;
    }

    _gridIcons = [..._iconsPool.take(_totalPairs), ..._iconsPool.take(_totalPairs)];
    _gridIcons.shuffle();
    _flipped = List.generate(_totalPairs * 2, (_) => false);
    _matched = List.generate(_totalPairs * 2, (_) => false);
    _matchesFound = 0;
    _firstIndex = null;
    _wait = false;
  }

  void _handleTap(int index) {
    if (_wait || _flipped[index] || _matched[index]) return;

    setState(() {
      _flipped[index] = true;
    });

    if (_firstIndex == null) {
      _firstIndex = index;
    } else {
      if (_gridIcons[_firstIndex!] == _gridIcons[index]) {
        _matchesFound++;
        _matched[_firstIndex!] = true;
        _matched[index] = true;
        _firstIndex = null;
        if (_matchesFound == _totalPairs) {
          Future.delayed(500.ms, widget.onSuccess);
        }
      } else {
        _wait = true;
        Timer(800.ms, () {
          if (mounted) {
            setState(() {
              _flipped[_firstIndex!] = false;
              _flipped[index] = false;
              _firstIndex = null;
              _wait = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'MATCH PAIRS',
          style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        Text(
          'Find all $_totalPairs pairs (Level ${widget.difficulty})',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(4),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.difficulty == 3 ? 4 : 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _totalPairs * 2,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _handleTap(index),
                child: AnimatedContainer(
                  duration: 300.ms,
                  decoration: BoxDecoration(
                    color: _matched[index] 
                        ? Colors.greenAccent.withValues(alpha: 0.1) 
                        : (_flipped[index] ? const Color(0xFF1E1E2A) : const Color(0xFF8B5CF6)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _matched[index] 
                          ? Colors.greenAccent.withValues(alpha: 0.5)
                          : (_flipped[index] ? const Color(0xFF8B5CF6).withValues(alpha: 0.5) : Colors.white10),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: (_flipped[index] || _matched[index])
                        ? Icon(
                            _gridIcons[index], 
                            color: _matched[index] ? Colors.greenAccent : Colors.white, 
                            size: 28
                          ).animate().scale()
                        : const Icon(Icons.help_outline_rounded, color: Colors.white24, size: 24),
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
