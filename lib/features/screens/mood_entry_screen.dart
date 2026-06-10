import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/alarm_model.dart';
import '../providers/mood_provider.dart';
import '../services/alarm_service.dart';
import '../widgets/mood_selector.dart';
import '../widgets/voice_recorder_component.dart';
import '../widgets/audio_playback_component.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Unified capture surface for morning mood logs and hybrid text/voice journaling.
class MoodEntryScreen extends StatefulWidget {
  final DateTime? initialDate;
  final bool isMorningFlow; // Tracks if this screen is part of the post-alarm sequence
  final AlarmModel? alarm;

  const MoodEntryScreen({
    super.key, 
    this.initialDate, 
    this.isMorningFlow = false,
    this.alarm,
  });

  @override
  State<MoodEntryScreen> createState() => _MoodEntryScreenState();
}

class _MoodEntryScreenState extends State<MoodEntryScreen> {
  String? selectedMood;
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final List<String> _recordedAudioPaths = [];
  final List<int> _recordedAudioDurationsMs = [];
  late DateTime _selectedDateTime;
  Timer? _safetyTimer;

  @override
  void initState() {
    super.initState();
    // Default to the provided date (from calendar) or current timestamp
    _selectedDateTime = widget.initialDate ?? DateTime.now();

    if (widget.isMorningFlow && widget.alarm != null) {
      _startSafetyTimer();
    }
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    super.dispose();
  }

  void _startSafetyTimer() {
    // If no response within 5 minutes, re-trigger the alarm
    _safetyTimer = Timer(const Duration(minutes: 5), () {
      if (widget.alarm != null) {
        AlarmService.triggerSafetyAlarm(widget.alarm!);
      }
    });
  }

  void _cancelSafetyTimer() {
    _safetyTimer?.cancel();
  }

  // Opens a tiered selector for retroactively logging entries
  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  // Handles closing the screen or exiting the app based on the entry context
  void _handleClose() {
    _cancelSafetyTimer();
    if (widget.alarm != null) {
      AlarmService.stopSessionAlarms(widget.alarm!.id.hashCode);
    }

    if (widget.isMorningFlow) {
      // If in the post-alarm flow, we want to close the entire application.
      // SystemNavigator.pop() is the standard way to background/close the app on Android.
      // We use a fallback to exit(0) for a more definitive close if needed, although pop is preferred.
      SystemNavigator.pop(animated: true).catchError((e) {
        exit(0);
      });
    } else {
      // If manually opened from the mood board, just pop back to the dashboard
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Prevent manual back-button navigation during the morning flow 
      // without triggering the application close logic.
      canPop: !widget.isMorningFlow,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.isMorningFlow) {
          _handleClose();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: _handleClose,
          ),
          actions: [
            // Persist the entry only if a mood has been selected
            if (selectedMood != null)
              TextButton(
                onPressed: () {
                  _cancelSafetyTimer();
                  if (widget.alarm != null) {
                    AlarmService.stopSessionAlarms(widget.alarm!.id.hashCode);
                  }
                  final moodProvider = Provider.of<MoodProvider>(context, listen: false);
                  moodProvider.addEntry(
                    mood: selectedMood!,
                    note: _noteController.text,
                    title: _titleController.text.isNotEmpty ? _titleController.text : null,
                    audioPaths: _recordedAudioPaths,
                    audioDurationsMs: _recordedAudioDurationsMs,
                    date: _selectedDateTime,
                  );
                  _handleClose();
                },
                child: const Text(
                  'SAVE',
                  style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Entry Metadata: Editable timestamp
                      GestureDetector(
                        onTap: _pickDateTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.white54),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('MMM d, yyyy • hh:mm a').format(_selectedDateTime),
                                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.white38),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(),
                      const SizedBox(height: 32),
                      Text(
                        'How are you feeling?',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn().slideX(begin: -0.1),
                      const SizedBox(height: 24),
                      
                      // Animated emoji selection
                      MoodSelector(
                        selectedMood: selectedMood,
                        onMoodSelected: (mood) {
                          setState(() {
                            selectedMood = mood;
                          });
                        },
                      ).animate().fadeIn(delay: 200.ms).scale(),
                      
                      const SizedBox(height: 40),
                      
                      // Conditional reveal: Journal fields appear once mood is logged
                      if (selectedMood != null) ...[
                        TextField(
                          controller: _titleController,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            hintText: 'Entry Title',
                            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ).animate().fadeIn(),
                        const Divider(color: Colors.white10, height: 32),
                        TextField(
                          controller: _noteController,
                          maxLines: null,
                          minLines: 8, // Extended writing area
                          style: const TextStyle(color: Colors.white, fontSize: 17, height: 1.5),
                          decoration: InputDecoration(
                            hintText: 'Start writing your thoughts...',
                            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ).animate().fadeIn(),
                        
                        const SizedBox(height: 32),
        
                        // Audio player list: Displays all recordings added during this session
                        ..._recordedAudioPaths.asMap().entries.map((entry) {
                          int idx = entry.key;
                          String path = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AudioPlaybackComponent(
                              audioPath: path,
                              onDelete: () {
                                setState(() {
                                  _recordedAudioPaths.removeAt(idx);
                                  _recordedAudioDurationsMs.removeAt(idx);
                                });
                              },
                            ).animate().fadeIn(),
                          );
                        }),
                          
                        const SizedBox(height: 40),
                      ],
                    ],
                  ),
                ),
              ),
              // Persistent voice recording panel at the bottom
              if (selectedMood != null)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20),
                    ],
                  ),
                  child: VoiceRecorderComponent(
                    onRecordingComplete: (path, duration) {
                      setState(() {
                        _recordedAudioPaths.add(path);
                        _recordedAudioDurationsMs.add(duration.inMilliseconds);
                      });
                    },
                  ),
                ).animate().slideY(begin: 1, curve: Curves.easeOutBack),
            ],
          ),
        ),
      ),
    );
  }
}
