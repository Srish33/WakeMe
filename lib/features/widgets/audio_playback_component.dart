import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

// Provides a themed interface for playing back recorded journal voice notes.
class AudioPlaybackComponent extends StatefulWidget {
  final String audioPath;
  final VoidCallback? onDelete;

  const AudioPlaybackComponent({super.key, required this.audioPath, this.onDelete});

  @override
  State<AudioPlaybackComponent> createState() => _AudioPlaybackComponentState();
}

class _AudioPlaybackComponentState extends State<AudioPlaybackComponent> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await _player.setSourceDeviceFile(widget.audioPath);
      
      // Some devices/files don't trigger duration changed until played or explicitly requested
      final d = await _player.getDuration();
      if (d != null && mounted) {
        setState(() => _duration = d);
      }

      _durationSubscription = _player.onDurationChanged.listen((d) {
        if (mounted) setState(() => _duration = d);
      });
      
      _positionSubscription = _player.onPositionChanged.listen((p) {
        if (mounted) setState(() => _position = p);
      });
      
      _playerCompleteSubscription = _player.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _position = Duration.zero;
          });
        }
      });
    } catch (e) {
      debugPrint('Audio player init error: $e');
    }
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  void _togglePlayback() async {
    try {
      if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.resume();
      }
      if (mounted) setState(() => _isPlaying = !_isPlaying);
    } catch (e) {
      debugPrint('Playback error: $e');
    }
  }

  String _formatTime(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final backgroundColor = primaryColor.withValues(alpha: 0.15);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _togglePlayback,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: CustomPaint(
                    painter: WaveformPainter(
                      progress: _duration.inMilliseconds > 0 
                          ? _position.inMilliseconds / _duration.inMilliseconds 
                          : 0.0,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
              if (widget.onDelete != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                  onPressed: widget.onDelete,
                ),
              ],
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 64, top: 4),
            child: Text(
              _isPlaying ? _formatTime(_position) : _formatTime(_duration),
              style: TextStyle(
                color: primaryColor.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double progress;
  final Color color;

  WaveformPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final int barCount = 40;
    final double barGap = 2.0;
    final double barWidth = (size.width - (barCount - 1) * barGap) / barCount;
    
    // Fixed heights for a consistent "waveform" look as in the image
    final List<double> heights = [
      0.2, 0.3, 0.2, 0.4, 0.6, 0.5, 0.3, 0.2, 0.4, 0.5,
      0.8, 0.7, 0.9, 0.6, 0.4, 0.3, 0.5, 0.7, 0.8, 0.6,
      0.4, 0.3, 0.5, 0.6, 0.4, 0.3, 0.2, 0.4, 0.5, 0.6,
      0.7, 0.5, 0.4, 0.3, 0.4, 0.2, 0.3, 0.4, 0.3, 0.2
    ];

    for (int i = 0; i < barCount; i++) {
      final double x = i * (barWidth + barGap);
      final double barHeight = size.height * heights[i % heights.length];
      final double y = (size.height - barHeight) / 2;

      // Color the bar based on progress
      final double barProgress = i / barCount;
      paint.color = barProgress <= progress ? color : color.withValues(alpha: 0.3);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
