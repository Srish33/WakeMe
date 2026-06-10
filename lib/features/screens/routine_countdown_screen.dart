import 'dart:async';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import '../models/alarm_model.dart';
import 'routine_completion_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RoutineCountdownScreen extends StatefulWidget {
  final AlarmModel alarm;
  final int? extraMinutes;
  final DateTime startTime;

  const RoutineCountdownScreen({
    super.key, 
    required this.alarm, 
    this.extraMinutes,
    required this.startTime,
  });

  @override
  State<RoutineCountdownScreen> createState() => _RoutineCountdownScreenState();
}

class _RoutineCountdownScreenState extends State<RoutineCountdownScreen> {
  late int _secondsRemaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    int totalMinutes = widget.alarm.routineTasks.fold(0, (sum, task) => sum + task.durationMinutes);
    if (widget.extraMinutes != null) {
      totalMinutes = widget.extraMinutes!;
    }
    // Handle case where totalMinutes is 0
    if (totalMinutes == 0) totalMinutes = 1; 

    _secondsRemaining = totalMinutes * 60;
    _startTimer();
    _scheduleCompletionAlarm();
  }

  Future<void> _scheduleCompletionAlarm() async {
    final completionSettings = AlarmSettings(
      id: widget.alarm.id.hashCode + 2,
      dateTime: DateTime.now().add(Duration(seconds: _secondsRemaining)),
      assetAudioPath: widget.alarm.routineReminderSoundPath == 'default' 
          ? 'assets/sounds/alarm.mp3' 
          : widget.alarm.routineReminderSoundPath,
      loopAudio: true,
      vibrate: true,
      volumeSettings: const VolumeSettings.fixed(volume: 0.5),
      notificationSettings: NotificationSettings(
        title: 'Routine Completed',
        body: 'Check your tasks!',
        stopButton: 'Open',
      ),
      androidFullScreenIntent: true,
    );
    await Alarm.set(alarmSettings: completionSettings);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        _timer?.cancel();
        _onFinished();
      }
    });
  }

  void _onFinished() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RoutineCompletionScreen(
            alarm: widget.alarm,
            // If extraMinutes is not null, it means we are in an extension phase
            isExtension: widget.extraMinutes != null,
            routineStartTime: widget.startTime,
            // If we are in an extension, the "additional time" is the extraMinutes provided
            additionalTimeRequested: widget.extraMinutes ?? 0,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12121A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text(
              'Morning Routine',
              style: TextStyle(color: Colors.white.withOpacity(0.5), letterSpacing: 4, fontWeight: FontWeight.bold),
            ).animate().fadeIn(),
            const Spacer(),
            Text(
              _formatTime(_secondsRemaining),
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'monospace',
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1.seconds),
            const Spacer(),
            if (widget.alarm.routineTasks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    ...widget.alarm.routineTasks.map((task) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.check_circle_outline, color: Color(0xFF8B5CF6)),
                        title: Text(task.name, style: const TextStyle(color: Colors.white)),
                        trailing: Text('${task.durationMinutes} min', style: const TextStyle(color: Colors.white54)),
                      ),
                    )),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
