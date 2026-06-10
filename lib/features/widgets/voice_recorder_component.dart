import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Captures audio input with a real-time reactive waveform.
class VoiceRecorderComponent extends StatefulWidget {
  final Function(String path, Duration duration) onRecordingComplete;

  const VoiceRecorderComponent({super.key, required this.onRecordingComplete});

  @override
  State<VoiceRecorderComponent> createState() => _VoiceRecorderComponentState();
}

class _VoiceRecorderComponentState extends State<VoiceRecorderComponent> {
  late AudioRecorder _recorder;
  bool _isRecording = false;
  bool _isPaused = false;
  Timer? _timer;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  int _recordDuration = 0; // Duration counter in 100ms units
  
  // Use a list of 40 bars for a cleaner look, matching the playback UI
  List<double> _amplitudes = List.generate(40, (index) => 0.1 + (math.Random().nextDouble() * 0.1));

  @override
  void initState() {
    super.initState();
    _recorder = AudioRecorder();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _amplitudeSubscription?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        final path = p.join(directory.path, fileName);

        const config = RecordConfig();
        await _recorder.start(config, path: path);

        setState(() {
          _isRecording = true;
          _isPaused = false;
          _recordDuration = 0;
          _amplitudes = List.generate(40, (index) => 0.1);
        });
        
        _startTimer();
        _startAmplitudeListener();
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  void _startAmplitudeListener() {
    _amplitudeSubscription?.cancel();
    // Listen for amplitude changes more frequently for smoother animation
    _amplitudeSubscription = _recorder.onAmplitudeChanged(const Duration(milliseconds: 50)).listen((amp) {
      if (mounted && _isRecording && !_isPaused) {
        setState(() {
          // Convert dB (-160 to 0) to a 0.05 - 1.0 visual factor.
          // We use -60 as a practical floor for speaking volume to make it more reactive.
          double normalized = (amp.current + 60) / 60;
          normalized = normalized.clamp(0.05, 1.0);
          
          _amplitudes.removeAt(0);
          _amplitudes.add(normalized);
        });
      }
    });
  }

  Future<void> _pauseRecording() async {
    await _recorder.pause();
    _timer?.cancel();
    setState(() {
      _isPaused = true;
    });
  }

  Future<void> _resumeRecording() async {
    await _recorder.resume();
    _startTimer();
    setState(() {
      _isPaused = false;
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _amplitudeSubscription?.cancel();
    final path = await _recorder.stop();
    final duration = _recordDuration;
    setState(() {
      _isRecording = false;
      _isPaused = false;
    });
    if (path != null) {
      widget.onRecordingComplete(path, Duration(milliseconds: duration * 100));
    }
  }

  Future<void> _cancelRecording() async {
    _timer?.cancel();
    _amplitudeSubscription?.cancel();
    await _recorder.stop(); 
    setState(() {
      _isRecording = false;
      _isPaused = false;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _recordDuration++; 
        });
      }
    });
  }

  String _formatDuration(int deciseconds) {
    int seconds = deciseconds ~/ 10;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    if (!_isRecording) {
      return SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton.icon(
          onPressed: _startRecording,
          icon: const Icon(Icons.mic_rounded, color: Colors.white),
          label: const Text(
            'RECORD VOICE NOTE',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            elevation: 0,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isPaused ? 'Recording Paused' : 'Audio Recording...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  if (!_isPaused)
                    const Icon(Icons.fiber_manual_record, color: Colors.redAccent, size: 12),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(_recordDuration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // High-visibility Waveform
          SizedBox(
            height: 60,
            width: double.infinity,
            child: CustomPaint(
              painter: RecordingWaveformPainter(
                isPaused: _isPaused,
                waveColor: primaryColor,
                activeLineColor: Colors.transparent,
                amplitudes: _amplitudes,
                progress: (_recordDuration / 300) % 1.0,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                icon: Icons.delete_rounded,
                onPressed: _cancelRecording,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
              ),
              const SizedBox(width: 20),
              _buildControlButton(
                icon: _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                onPressed: _isPaused ? _resumeRecording : _pauseRecording,
                backgroundColor: Colors.redAccent,
                iconColor: Colors.white,
                isLarge: true,
              ),
              const SizedBox(width: 20),
              _buildControlButton(
                icon: Icons.stop_rounded,
                onPressed: _stopRecording,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    Color iconColor = Colors.white70,
    bool isLarge = false,
  }) {
    double size = isLarge ? 64 : 48;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: isLarge ? 32 : 24),
      ),
    );
  }
}

class RecordingWaveformPainter extends CustomPainter {
  final bool isPaused;
  final Color waveColor;
  final Color activeLineColor;
  final List<double> amplitudes;
  final double progress; 

  RecordingWaveformPainter({
    required this.isPaused,
    required this.waveColor,
    required this.activeLineColor,
    required this.amplitudes,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final int barCount = amplitudes.length;
    final double barGap = 3.0;
    final double barWidth = (size.width - (barCount - 1) * barGap) / barCount;
    
    // Draw the static waveform bars
    for (int i = 0; i < barCount; i++) {
      final double x = i * (barWidth + barGap);
      
      // Scale height based on amplitude
      double ampFactor = amplitudes[i];
      if (isPaused) ampFactor *= 0.3;
      
      // Ensure a minimum visible height
      final double barHeight = (size.height * ampFactor).clamp(6.0, size.height);
      final double y = (size.height - barHeight) / 2;

      // Color based on theme primary with good visibility
      paint.color = waveColor.withValues(alpha: isPaused ? 0.2 : 0.6);
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(2),
        ),
        paint,
      );
    }
    
    // Draw a subtle baseline
    paint.color = waveColor.withValues(alpha: 0.1);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);

    // Draw the moving "recording head" line (the red bar)
    final double activeX = size.width * progress;
    paint.color = activeLineColor;
    canvas.drawRect(Rect.fromLTWH(activeX, 0, 2.5, size.height), paint);
    
    // Add a glow to the recording head
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    paint.color = activeLineColor.withValues(alpha: 0.5);
    canvas.drawRect(Rect.fromLTWH(activeX - 1, 0, 4.5, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant RecordingWaveformPainter oldDelegate) {
    return true;
  }
}
