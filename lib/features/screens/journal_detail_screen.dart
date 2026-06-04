import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mood_entry_model.dart';
import '../providers/mood_provider.dart';
import '../widgets/mood_selector.dart';
import '../../core/theme/app_theme.dart';

class JournalDetailScreen extends StatefulWidget {
  final MoodEntryModel entry;

  const JournalDetailScreen({super.key, required this.entry});

  @override
  State<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late String _selectedMood;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _noteController = TextEditingController(text: widget.entry.note);
    _selectedMood = widget.entry.mood;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    widget.entry.title = _titleController.text;
    widget.entry.note = _noteController.text;
    widget.entry.mood = _selectedMood;

    context.read<MoodProvider>().updateEntry(widget.entry);
    Navigator.pop(context);
  }

  void _deleteEntry() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this journal entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
                'Cancel',
                style: TextStyle(
                    color: isDark ? AppTheme.secondaryTextColor : AppTheme.lightSecondaryTextColor
                )
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<MoodProvider>().deleteEntry(widget.entry.id);
              Navigator.pop(context); // Pop dialog
              Navigator.pop(context); // Pop screen
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _deleteEntry,
          ),
          TextButton(
            onPressed: _saveChanges,
            child: const Text(
              'Done',
              style: TextStyle(
                color: AppTheme.primaryPurple,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(color: secondaryTextColor),
                border: InputBorder.none,
              ),
            ),
            Divider(color: secondaryTextColor, thickness: 0.5),
            TextField(
              controller: _noteController,
              maxLines: null,
              style: TextStyle(color: primaryTextColor, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Write your thoughts...',
                hintStyle: TextStyle(color: secondaryTextColor),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
