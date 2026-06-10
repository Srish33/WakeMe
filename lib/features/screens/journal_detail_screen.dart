import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/mood_entry_model.dart';
import '../providers/mood_provider.dart';
import '../widgets/mood_selector.dart';
import '../widgets/audio_playback_component.dart';
import '../widgets/voice_recorder_component.dart';
import 'package:intl/intl.dart';

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
  late List<String> _tempAudioPaths;
  late List<int> _tempAudioDurationsMs;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _noteController = TextEditingController(text: widget.entry.note);
    _selectedMood = widget.entry.mood;
    _tempAudioPaths = List.from(widget.entry.audioPaths);
    _tempAudioDurationsMs = List.from(widget.entry.audioDurationsMs);
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
    widget.entry.audioPaths = _tempAudioPaths;
    widget.entry.audioDurationsMs = _tempAudioDurationsMs;

    context.read<MoodProvider>().updateEntry(widget.entry);
    Navigator.pop(context);
  }

  void _deleteEntry() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Delete Entry', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this journal entry?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              context.read<MoodProvider>().deleteEntry(widget.entry.id);
              Navigator.pop(context); // Pop dialog
              Navigator.pop(context); // Pop screen
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            onPressed: _deleteEntry,
          ),
          TextButton(
            onPressed: _saveChanges,
            child: Text(
              'Save',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(widget.entry.createdAt),
                    style: TextStyle(color: secondaryTextColor, fontSize: 13, fontWeight: FontWeight.w500),
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
                  const SizedBox(height: 24),
                  TextField(
                    controller: _titleController,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: TextStyle(color: primaryTextColor.withValues(alpha: 0.2)),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      fillColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: null,
                    minLines: 10, // Extended writing area
                    style: TextStyle(color: primaryTextColor.withValues(alpha: 0.8), fontSize: 18, height: 1.5),
                    decoration: InputDecoration(
                      hintText: 'Start writing...',
                      hintStyle: TextStyle(color: primaryTextColor.withValues(alpha: 0.2)),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      fillColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Audio player list: Displays all recordings saved with this entry
                  ..._tempAudioPaths.asMap().entries.map((entry) {
                    int idx = entry.key;
                    String path = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AudioPlaybackComponent(
                        audioPath: path,
                        onDelete: () {
                          setState(() {
                            _tempAudioPaths.removeAt(idx);
                            _tempAudioDurationsMs.removeAt(idx);
                          });
                        },
                      ).animate().fadeIn(),
                    );
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          // Persistent voice recording panel at the bottom
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20),
              ],
            ),
            child: VoiceRecorderComponent(
              onRecordingComplete: (path, duration) {
                setState(() {
                  _tempAudioPaths.add(path);
                  _tempAudioDurationsMs.add(duration.inMilliseconds);
                });
              },
            ),
          ).animate().slideY(begin: 1, curve: Curves.easeOutBack),
        ],
      ),
    );
  }
}
