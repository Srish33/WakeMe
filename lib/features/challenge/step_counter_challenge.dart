import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

// Engineered Step Counter that ignores shaking and requires physical walking.
// Uses custom peak-detection on the accelerometer magnitude for anti-cheat.
class StepCounterChallenge extends StatefulWidget {
  final int stepGoal;
  final VoidCallback onSuccess;
  final VoidCallback onFail;

  const StepCounterChallenge({
    super.key,
    required this.stepGoal,
    required this.onSuccess,
    required this.onFail,
  });

  @override
  State<StepCounterChallenge> createState() => _StepCounterChallengeState();
}

class _StepCounterChallengeState extends State<StepCounterChallenge> {
StreamSubscription<UserAccelerometerEvent>? _sensorSubscription;

int _currentSteps = 0;
bool _isInitialized = false;

// Motion Detection State
bool _isShaking = false;
double _lastMagnitude = 0;
DateTime _lastStepTime = DateTime.now();

// Peak Detection Config
static const double _stepThreshold = 2.5; // Acceleration m/s^2 above gravity/rest
static const double _shakeThreshold = 14.0; // Violent motion rejection
static const Duration _minStepInterval = Duration(milliseconds: 350);

final List<double> _magnitudeHistory = [];
static const int _historySize = 10;

@override
void initState() {
super.initState();
_initChallenge();
}

Future<void> _initChallenge() async {
// Pedometer is not used here to avoid OS-level shake-counting.
// We use raw sensors for a "uncheatable" experience.
_startMotionDetection();
}

void _startMotionDetection() {
_sensorSubscription = userAccelerometerEventStream().listen((event) {
final double magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

_magnitudeHistory.add(magnitude);
if (_magnitudeHistory.length > _historySize) _magnitudeHistory.removeAt(0);

double avgMag = _magnitudeHistory.reduce((a, b) => a + b) / _magnitudeHistory.length;

setState(() {
_isInitialized = true;

// 1. Shake Detection: If current peak is too high, mark as shaking
if (magnitude > _shakeThreshold) {
_isShaking = true;
} else if (avgMag < 5.0) {
_isShaking = false;
}

// 2. Step Detection (Peak Algorithm)
// A step is counted when magnitude goes from below threshold to above,
// provided we aren't shaking and enough time has passed.
if (!_isShaking &&
_lastMagnitude <= _stepThreshold &&
magnitude > _stepThreshold &&
DateTime.now().difference(_lastStepTime) > _minStepInterval) {

_currentSteps++;
_lastStepTime = DateTime.now();

if (_currentSteps >= widget.stepGoal) {
_complete();
}
}

_lastMagnitude = magnitude;
});
});
}

void _complete() {
_sensorSubscription?.cancel();
widget.onSuccess();
}

@override
void dispose() {
_sensorSubscription?.cancel();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Text(
'STEP COUNTER',
style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold, letterSpacing: 2),
),
const SizedBox(height: 40),

if (!_isInitialized)
const CircularProgressIndicator(color: Color(0xFF8B5CF6))
else ...[
// Technical Progress Ring
Stack(
alignment: Alignment.center,
children: [
SizedBox(
width: 220,
height: 220,
child: CircularProgressIndicator(
value: _currentSteps / widget.stepGoal,
strokeWidth: 10,
backgroundColor: Colors.white.withValues(alpha: 0.03),
valueColor: AlwaysStoppedAnimation<Color>(
_isShaking ? Colors.redAccent : const Color(0xFF8B5CF6)
),
),
),
Column(
mainAxisSize: MainAxisSize.min,
children: [
Text(
'$_currentSteps',
style: const TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.bold),
),
Text(
'OF ${widget.stepGoal}',
style: const TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
),
],
),
],
),

const SizedBox(height: 48),

// Real-time Feedback Panel
AnimatedContainer(
duration: const Duration(milliseconds: 200),
padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
decoration: BoxDecoration(
color: _isShaking
? Colors.redAccent.withValues(alpha: 0.1)
: (_lastMagnitude > _stepThreshold ? Colors.greenAccent.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05)),
borderRadius: BorderRadius.circular(24),
border: Border.all(
color: _isShaking ? Colors.redAccent : (_lastMagnitude > _stepThreshold ? Colors.greenAccent : Colors.white10),
width: 2,
),
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
_isShaking ? Icons.warning_amber_rounded : Icons.directions_walk_rounded,
color: _isShaking ? Colors.redAccent : (_lastMagnitude > _stepThreshold ? Colors.greenAccent : Colors.white24),
),
const SizedBox(width: 16),
Text(
_isShaking ? 'SYSTEM LOCK: SHAKING' : 'WALK TO DISMISS',
style: TextStyle(
color: _isShaking ? Colors.redAccent : Colors.white,
fontWeight: FontWeight.bold,
letterSpacing: 1,
),
),
],
),
),

          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Please walk at a normal pace to clear this challenge.\nViolent shaking is ignored.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white24, fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ],
    );
  }
}
