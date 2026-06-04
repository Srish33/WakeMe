import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../widgets/mood_selector.dart';
import 'journal_history_screen.dart';
import '../../core/theme/app_theme.dart';

class MoodBoardScreen extends StatefulWidget {
  const MoodBoardScreen({super.key});

  @override
  State<MoodBoardScreen> createState() => _MoodBoardScreenState();
}

class _MoodBoardScreenState extends State<MoodBoardScreen> {
  String? _selectedMood;
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood first')),
      );
      return;
    }

    context.read<MoodProvider>().addEntry(
      mood: _selectedMood!,
      note: _noteController.text,
      title: _titleController.text.isNotEmpty ? _titleController.text : null,
    );

    // Clear fields
    setState(() {
      _selectedMood = null;
    });
    _noteController.clear();
    _titleController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Journal entry saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppTheme.primaryTextColor : AppTheme.lightPrimaryTextColor;
    final secondaryTextColor = isDark ? AppTheme.secondaryTextColor : AppTheme.lightSecondaryTextColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MOOD BOARD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const JournalHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How are you feeling?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 16),
            MoodSelector(
              selectedMood: _selectedMood,
              onMoodSelected: (mood) {
                setState(() {
                  _selectedMood = mood;
                });
              },
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _titleController,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
              decoration: InputDecoration(
                hintText: 'Title (Optional)',
                hintStyle: TextStyle(color: secondaryTextColor),
                border: InputBorder.none,
              ),
            ),
            Divider(color: secondaryTextColor, thickness: 0.5),
            TextField(
              controller: _noteController,
              maxLines: null,
              style: TextStyle(color: primaryTextColor),
              decoration: InputDecoration(
                hintText: 'Journal Entry...',
                hintStyle: TextStyle(color: secondaryTextColor),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveEntry,
        label: const Text('Save Entry'),
        icon: const Icon(Icons.save),
      ),
    );
  }
}