import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/alarm_model.dart';
import '../models/routine_task_model.dart';
import '../providers/analytics_provider.dart';
import '../services/alarm_service.dart';
import 'mood_entry_screen.dart';
import 'routine_timer_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Final check-off screen for the morning routine flow. 
class RoutineCompletionScreen extends StatefulWidget {
  final AlarmModel alarm;
  final bool isExtension; 
  final DateTime? routineStartTime;
  final int additionalTimeRequested;

  const RoutineCompletionScreen({
    super.key, 
    required this.alarm, 
    this.isExtension = false,
    this.routineStartTime,
    this.additionalTimeRequested = 0,
  });

  @override
  State<RoutineCompletionScreen> createState() => _RoutineCompletionScreenState();
}

class _RoutineCompletionScreenState extends State<RoutineCompletionScreen> {
  Timer? _safetyTimer;
  late AudioPlayer _audioPlayer;
  bool _isSoundPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _startSafetyTimer();
    // Delay playback slightly to ensure AudioPlayer is ready and UI is rendered
    Future.delayed(const Duration(milliseconds: 500), _playReminderSound);
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    _stopSound();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startSafetyTimer() {
    _safetyTimer = Timer(const Duration(minutes: 5), () {
      AlarmService.triggerSafetyAlarm(widget.alarm, isRoutineCompletion: true);
    });
  }

  void _cancelSafetyTimer() {
    _safetyTimer?.cancel();
  }

  Future<void> _playReminderSound() async {
    if (!mounted) return;
    try {
      final soundPath = widget.alarm.routineReminderSoundPath;
      Source source;
      
      if (soundPath == 'default' || soundPath.isEmpty) {
        source = AssetSource('sounds/Tropical.mp3');
      } else if (soundPath.startsWith('assets/')) {
        source = AssetSource(soundPath.replaceFirst('assets/', ''));
      } else {
        source = DeviceFileSource(soundPath);
      }
      
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(source);
      setState(() => _isSoundPlaying = true);
    } catch (e) {
      debugPrint('Error playing routine reminder sound: $e');
    }
  }

  void _stopSound() {
    if (_isSoundPlaying) {
      _audioPlayer.stop();
      _isSoundPlaying = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF12121A), const Color(0xFF1E1E2A)]
                : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 60),
                const Icon(Icons.celebration_rounded, size: 80, color: Color(0xFF8B5CF6))
                    .animate().scale(curve: Curves.easeOutBack),
                const SizedBox(height: 24),
                Text(
                  'Routine Done?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 32),
                
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TASKS:',
                          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        ...widget.alarm.routineTasks.map((task) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.check_rounded, color: Color(0xFF22D3EE), size: 20),
                              const SizedBox(width: 12),
                              Text(task.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        )),
                        if (widget.alarm.routineTasks.isEmpty)
                          const Text('Complete your morning activities'),
                        const Spacer(),
                        const Text(
                          'Completed these tasks?',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: () {
                      _cancelSafetyTimer();
                      _stopSound();
                      AlarmService.stopSessionAlarms(widget.alarm.id.hashCode);
                      if (widget.routineStartTime != null) {
                        context.read<AnalyticsProvider>().recordRoutineSession(
                          startTime: widget.routineStartTime!,
                          endTime: DateTime.now(),
                          additionalTimeRequested: widget.additionalTimeRequested,
                        );
                      }

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MoodEntryScreen(
                            isMorningFlow: true,
                            alarm: widget.alarm,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('DONE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                ),
                
                if (!widget.isExtension) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: OutlinedButton(
                      onPressed: () {
                        _cancelSafetyTimer();
                        _stopSound();
                        _showExtensionOptions(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('NEED MORE TIME', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                  ),
                ],
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showExtensionOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Extend routine by how much?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [5, 10, 15, 20, 30].map((mins) => _TimeOptionChip(
                label: '+$mins min',
                onTap: () {
                   Navigator.pop(context);
                   _startExtension(mins);
                },
              )).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _startExtension(int mins) {
    final extendedAlarm = AlarmModel(
      id: 'temp',
      hour: 0,
      minute: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      routineTasks: [RoutineTask(id: 'ext', name: 'Extension', durationMinutes: mins)],
    );
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RoutineTimerScreen(
          alarm: extendedAlarm,
          additionalTimeRequested: mins,
        )
      ),
    );
  }
}

class _TimeOptionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TimeOptionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
