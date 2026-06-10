import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/alarm_model.dart';
import '../providers/alarm_provider.dart';
import '../challenge/memory_sequence_challenge.dart';
import '../challenge/match_pairs_challenge.dart';
import '../challenge/sequence_path_challenge.dart';
import '../challenge/pattern_memory_challenge.dart';
import '../challenge/number_order_challenge.dart';
import '../challenge/typing_challenge.dart';
import '../challenge/math_challenge.dart';
import '../challenge/step_counter_challenge.dart';
import '../challenge/barcode_scanner_challenge.dart';
import '../challenge/photo_match_challenge.dart';
import 'challenge_success_screen.dart';
import '../providers/analytics_provider.dart';

// The centralized controller for all wake-up challenges.
// Handles level progression (1-3) and ensures background audio continues until completion.
class ChallengeScreen extends StatefulWidget {
  final AlarmModel alarm;
  final DateTime scheduledTime;
  final int snoozeCount;
  final VoidCallback onFail;

  const ChallengeScreen({
    super.key,
    required this.alarm,
    required this.scheduledTime,
    required this.snoozeCount,
    required this.onFail,
  });

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  late Timer _challengeTimer;
  late int _secondsRemaining;
  int _currentSessionLevel = 1;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = _getInitialTimerDuration();
    _startChallengeTimer();
  }

  // Determines if the selected challenge should only run once (Step Counter, Scanner, Camera)
  bool get _isSingleLevelChallenge {
    final type = widget.alarm.challengeType;
    return type == ChallengeType.stepCounter || 
           type == ChallengeType.barcodeScanner || 
           type == ChallengeType.photoMatch;
  }

  int _getInitialTimerDuration() {
    // Single level sensor challenges usually require more movement/travel time
    if (_isSingleLevelChallenge) return 180;
    
    // Number Order Level 3 gets extra time
    if (widget.alarm.challengeType == ChallengeType.numberOrder && _currentSessionLevel == 3) {
      return 180; 
    }
    if (widget.alarm.challengeType == ChallengeType.numberOrder) {
      return 120;
    }
    return 90;
  }

  @override
  void dispose() {
    _challengeTimer.cancel();
    super.dispose();
  }

  void _startChallengeTimer() {
    _challengeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) setState(() => _secondsRemaining--);
      } else {
        // Safety timer expired - force restart flow
        widget.onFail();
      }
    });
  }

  void _handleSuccess() {
    final provider = context.read<AlarmProvider>();
    
    // If it's a multi-level challenge, progress from 1 -> 2 -> 3
    if (!_isSingleLevelChallenge && _currentSessionLevel < 3) {
      setState(() {
        _currentSessionLevel++;
        _secondsRemaining = _getInitialTimerDuration(); 
      });
      provider.updateChallengeLevel(widget.alarm.challengeType, true);
    } else {
      // Final completion reached
      _challengeTimer.cancel();
      provider.updateChallengeLevel(widget.alarm.challengeType, true);

      // If the alarm is set for "Once" (no repeat days), disable it
      if (widget.alarm.repeatDays.isEmpty) {
        widget.alarm.isEnabled = false;
        provider.updateAlarm(widget.alarm);
      }

      // Persist the final wake-up metrics to analytics database
      context.read<AnalyticsProvider>().recordAlarmSession(
        alarmTime: widget.scheduledTime,
        actualWakeUpTime: DateTime.now(),
        snoozeCount: widget.snoozeCount,
      );

      // Transition to success celebration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChallengeSuccessScreen(alarm: widget.alarm)),
      );
    }
  }

  void _handleFailure() {
    final provider = context.read<AlarmProvider>();
    provider.updateChallengeLevel(widget.alarm.challengeType, false);
    
    if (_secondsRemaining > 0) {
      // Re-trigger current level on mistake if time remains
      setState(() {
        if (!_isSingleLevelChallenge) {
          _currentSessionLevel = provider.assistedMode ? 1 : provider.getChallengeLevel(widget.alarm.challengeType);
        }
      });
    } else {
      widget.onFail();
    }
  }

  Widget _getChallengeWidget() {
    final provider = context.read<AlarmProvider>();
    int difficulty = provider.assistedMode ? 1 : _currentSessionLevel;
    
    switch (widget.alarm.challengeType) {
      case ChallengeType.memorySequence:
        return MemorySequenceChallenge(difficulty: difficulty, onSuccess: _handleSuccess, onFail: _handleFailure);
      case ChallengeType.matchPairs:
        return MatchPairsChallenge(difficulty: difficulty, onSuccess: _handleSuccess, onFail: _handleFailure);
      case ChallengeType.sequencePath:
        return SequencePathChallenge(difficulty: difficulty, onSuccess: _handleSuccess, onFail: _handleFailure);
      case ChallengeType.patternMemory:
        return PatternMemoryChallenge(difficulty: difficulty, onSuccess: _handleSuccess, onFail: _handleFailure);
      case ChallengeType.numberOrder:
        return NumberOrderChallenge(difficulty: difficulty, onSuccess: _handleSuccess, onFail: _handleFailure);
      case ChallengeType.typing:
        return TypingChallenge(difficulty: difficulty, onSuccess: _handleSuccess, onFail: _handleFailure);
      case ChallengeType.math:
        return MathChallenge(difficulty: difficulty, onSuccess: _handleSuccess, onFail: _handleFailure);
      case ChallengeType.stepCounter:
        return StepCounterChallenge(stepGoal: widget.alarm.stepGoal, onSuccess: _handleSuccess, onFail: _handleFailure);
      case ChallengeType.barcodeScanner:
        return BarcodeScannerChallenge(targetBarcode: widget.alarm.barcodeData ?? '', onSuccess: _handleSuccess, onFail: _handleFailure);
      case ChallengeType.photoMatch:
        return PhotoMatchChallenge(referencePhotoPath: widget.alarm.referencePhotoPath ?? '', onSuccess: _handleSuccess, onFail: _handleFailure);
      default:
        return MemorySequenceChallenge(difficulty: difficulty, onSuccess: _handleSuccess, onFail: _handleFailure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlarmProvider>();
    
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF12121A),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.assistedMode 
                              ? 'ASSISTED MODE' 
                              : (_isSingleLevelChallenge ? 'SENSORY TASK' : 'LEVEL $_currentSessionLevel OF 3'),
                          style: TextStyle(
                            color: provider.assistedMode ? Colors.amber : Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: 10,
                          ),
                        ),
                        const Text(
                          'Prove you\'re awake',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 16, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            '$_secondsRemaining',
                            style: GoogleFonts.jetBrainsMono(
                              color: _secondsRemaining < 15 ? Colors.redAccent : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: KeyedSubtree(
                      key: ValueKey('$_currentSessionLevel-${widget.alarm.challengeType}-${_secondsRemaining == 0}'),
                      child: _getChallengeWidget(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
