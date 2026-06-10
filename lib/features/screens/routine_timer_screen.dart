import 'package:flutter/material.dart';
import 'dart:async';
import '../models/alarm_model.dart';
import '../services/alarm_service.dart';
import 'routine_completion_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

// The active countdown screen that runs while the user performs their morning tasks.
class RoutineTimerScreen extends StatefulWidget {
  final AlarmModel alarm;
  final int additionalTimeRequested;

  const RoutineTimerScreen({super.key, required this.alarm, this.additionalTimeRequested = 0});

  @override
  State<RoutineTimerScreen> createState() => _RoutineTimerScreenState();
}

class _RoutineTimerScreenState extends State<RoutineTimerScreen> {
  late Timer _timer;
  Timer? _inactivityTimer;
  late int _remainingSeconds;
  late int _totalSeconds;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    // Calculate total time from the sum of durations of all selected tasks
    final totalMins = widget.alarm.routineTasks.fold<int>(0, (sum, task) => sum + task.durationMinutes);
    _totalSeconds = totalMins > 0 ? totalMins * 60 : 30 * 60; // Default to 30 mins if task list is empty
    _remainingSeconds = _totalSeconds;
    _startTimer();
    _startInactivityTimer();
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(minutes: 5), () {
      AlarmService.triggerSafetyAlarm(widget.alarm);
    });
  }

  void _cancelSafetyAlarm() {
    AlarmService.stopAlarm(widget.alarm.id.hashCode + 2);
  }

  // Ticks every second to update the visual countdown
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
      } else {
        _timer.cancel();
        _onTimerComplete();
      }
    });
  }

  // Automatically transition to the completion check-off screen when time expires
  void _onTimerComplete() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RoutineCompletionScreen(
            alarm: widget.alarm,
            routineStartTime: _startTime,
            additionalTimeRequested: widget.additionalTimeRequested,
          )
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel(); // Stop the timer if the widget is destroyed
    _inactivityTimer?.cancel();
    super.dispose();
  }

  // Converts seconds into a user-friendly MM:SS string
  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = 1 - (_remainingSeconds / _totalSeconds);

    return Scaffold(
      body: GestureDetector(
        onTap: _startInactivityTimer, // Reset inactivity timer on tap
        child: Container(
          decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF12121A), const Color(0xFF1E1E2A)]
                : [const Color(0xFFF8F9FD), const Color(0xFFF1F5F9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'MORNING ROUTINE',
                style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.bold, color: Colors.grey),
              ).animate().fadeIn(),
              
              const Spacer(),
              
              // Visual representation of time remaining with a technical circular ring
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                    ),
                  ),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
              
              const Spacer(),
              
              // List of tasks the user should be performing currently
              if (widget.alarm.routineTasks.isNotEmpty)
                Container(
                  height: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ListView.builder(
                    itemCount: widget.alarm.routineTasks.length,
                    itemBuilder: (context, index) {
                      final task = widget.alarm.routineTasks[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: Color(0xFF22D3EE), size: 20),
                            const SizedBox(width: 12),
                            Text(task.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Text('${task.durationMinutes} min', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: TextButton(
                  onPressed: () {
                    _cancelSafetyAlarm();
                    _onTimerComplete();
                  },
                  child: const Text('I\'M DONE EARLY', style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
