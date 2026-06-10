import 'package:flutter/material.dart';

// An interactive row of emojis that animate their size and shadow based on selection state.
class MoodSelector extends StatelessWidget {
  final String? selectedMood;
  final Function(String) onMoodSelected;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  // Current mood options available for selection
  final List<String> moods = const ['😴', '😐', '🙂', '😊', '🤩'];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: moods.map((mood) {
        final isSelected = selectedMood == mood;
        return GestureDetector(
          onTap: () => onMoodSelected(mood),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack, // Provide tactile "pop" feedback
            padding: EdgeInsets.all(isSelected ? 16 : 8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? primaryColor.withValues(alpha: 0.2) 
                  : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected 
                    ? primaryColor 
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected ? [
                // Glowing halo effect when selected
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 15, 
                  spreadRadius: 1
                )
              ] : [],
            ),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(fontSize: isSelected ? 36 : 24),
              child: Text(mood),
            ),
          ),
        );
      }).toList(),
    );
  }
}
