import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/alarm_model.dart';
import '../services/alarm_service.dart';
import 'routine_reminder_screen.dart';
import 'mood_entry_screen.dart';

class ChallengeSuccessScreen extends StatefulWidget {
  final AlarmModel alarm;

  const ChallengeSuccessScreen({super.key, required this.alarm});

  @override
  State<ChallengeSuccessScreen> createState() => _ChallengeSuccessScreenState();
}

class _ChallengeSuccessScreenState extends State<ChallengeSuccessScreen> {
  Timer? _safetyTimer;

  @override
  void initState() {
    super.initState();
    _startSafetyTimer();
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    super.dispose();
  }

  void _startSafetyTimer() {
    // If no response within 5 minutes, re-trigger the alarm
    _safetyTimer = Timer(const Duration(minutes: 5), () {
      AlarmService.triggerSafetyAlarm(widget.alarm);
    });
  }

  void _cancelSafetyTimer() {
    _safetyTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12121A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_rounded,
                color: Color(0xFF8B5CF6),
                size: 80,
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 32),
              const Text(
                'CONGRATULATIONS!',
                style: TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 16),
              const Text(
                'You have proved that you woke up',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    _cancelSafetyTimer();
                    AlarmService.stopSessionAlarms(widget.alarm.id.hashCode);
                    if (widget.alarm.routineTasks.isEmpty) {
                      // Skip to mood entry if no tasks are set
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MoodEntryScreen(
                            isMorningFlow: true,
                            alarm: widget.alarm,
                          ),
                        ),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoutineReminderScreen(alarm: widget.alarm),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'YAYYY',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
