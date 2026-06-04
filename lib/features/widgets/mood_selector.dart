import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class MoodSelector extends StatelessWidget {
  final String? selectedMood;
  final Function(String) onMoodSelected;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  final List<Map<String, String>> moods = const [
    {'emoji': '😢', 'label': 'Sad'},
    {'emoji': '😐', 'label': 'Neutral'},
    {'emoji': '🙂', 'label': 'Good'},
    {'emoji': '😊', 'label': 'Happy'},
    {'emoji': '🤩', 'label': 'Excited'},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: moods.map((mood) {
        final isSelected = selectedMood == mood['emoji'];
        return GestureDetector(
          onTap: () => onMoodSelected(mood['emoji']!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryPurple.withValues(alpha: 0.2) : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(
              mood['emoji']!,
              style: const TextStyle(fontSize: 32),
            ),
          ),
        );
      }).toList(),
    );
  }
}
