import 'dart:math';
import 'package:flutter/material.dart';

class TypingChallenge extends StatefulWidget {
  final int difficulty;
  final VoidCallback onSuccess;
  final VoidCallback onFail;

  const TypingChallenge({
    super.key,
    required this.difficulty,
    required this.onSuccess,
    required this.onFail,
  });

  @override
  State<TypingChallenge> createState() => _TypingChallengeState();
}

class _TypingChallengeState extends State<TypingChallenge> {
  final Map<int, List<String>> _phrases = {
    1: ["Good morning", "Time to wake up", "Rise and shine", "Hello world"],
    2: [
      "Today will be a productive and focused day",
      "I am ready to start my morning routine",
      "Consistency is the key to achieving my goals",
      "Every new day is a fresh start for me"
    ],
    3: [
      "I am awake, alert, and ready to complete my morning routine successfully",
      "I will maintain a positive attitude and focus on my personal growth today",
      "Discipline is the bridge between goals and accomplishment in my daily life",
      "Success is not final, failure is not fatal, it is the courage to continue that counts"
    ],
  };

  late String _targetPhrase;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final list = _phrases[widget.difficulty] ?? _phrases[1]!;
    _targetPhrase = list[Random().nextInt(list.length)];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _checkTyping(String value) {
    if (value.trim().toLowerCase() == _targetPhrase.toLowerCase()) {
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'TYPING CHALLENGE',
          style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        Text(
          'Type the phrase below exactly (Level ${widget.difficulty})',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            _targetPhrase,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.done,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'Start typing...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
            ),
          ),
          onChanged: _checkTyping,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => _checkTyping(_controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
        ),
      ],
    );
  }
}
