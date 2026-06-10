import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class SequencePathChallenge extends StatefulWidget {
  final int difficulty;
  final VoidCallback onSuccess;
  final VoidCallback onFail;

  const SequencePathChallenge({
    super.key,
    required this.difficulty,
    required this.onSuccess,
    required this.onFail,
  });

  @override
  State<SequencePathChallenge> createState() => _SequencePathChallengeState();
}

class _SequencePathChallengeState extends State<SequencePathChallenge> {
  final GlobalKey _containerKey = GlobalKey();
  late List<int> _nodeValues;
  late List<Offset> _nodePositions;
  int _nextExpected = 1;
  bool _isDragging = false;
  late int _maxNumber;
  List<Offset> _dragPoints = [];

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    if (widget.difficulty == 1) _maxNumber = 5;
    else if (widget.difficulty == 2) _maxNumber = 9;
    else _maxNumber = 15;

    _nodeValues = List.generate(_maxNumber, (i) => i + 1);
    _generatePositions();
    _nextExpected = 1;
    _dragPoints = [];
  }

  void _generatePositions() {
    _nodePositions = [];
    final random = Random();
    
    // Grid approach to prevent overlaps
    // For 15 nodes, a 4x4 or 5x5 grid ensures space
    int cols = widget.difficulty == 3 ? 4 : 3;
    int rows = widget.difficulty == 3 ? 4 : 3;
    int totalCells = cols * rows;
    
    List<int> cells = List.generate(totalCells, (i) => i);
    cells.shuffle();

    for (int i = 0; i < _maxNumber; i++) {
      int cellIdx = cells[i];
      int row = cellIdx ~/ cols;
      int col = cellIdx % cols;
      
      // Randomize within the cell with a safe margin
      double x = (col + 0.2 + random.nextDouble() * 0.6) / cols;
      double y = (row + 0.2 + random.nextDouble() * 0.6) / rows;
      
      _nodePositions.add(Offset(x, y));
    }
  }

  void _onPanStart(DragStartDetails details) {
    _resetAttempt();
    setState(() {
      _isDragging = true;
      _dragPoints = [details.localPosition];
    });
    _checkCollision(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() {
      _dragPoints.add(details.localPosition);
    });
    _checkCollision(details.localPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_nextExpected <= _maxNumber) {
      _handleFail();
    }
    setState(() {
      _isDragging = false;
      _dragPoints = [];
    });
  }

  void _checkCollision(Offset localPosition) {
    final RenderBox? box = _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final size = box.size;
    final normalized = Offset(localPosition.dx / size.width, localPosition.dy / size.height);

    for (int i = 0; i < _nodePositions.length; i++) {
      final nodeVal = _nodeValues[i];
      final nodePos = _nodePositions[i];
      
      // Hit detection threshold
      if ((normalized - nodePos).distance < 0.08) {
        if (nodeVal == _nextExpected) {
          setState(() {
            _nextExpected++;
          });
          if (_nextExpected > _maxNumber) {
            _handleSuccess();
          }
        } else if (nodeVal > _nextExpected) {
          _handleFail();
        }
      }
    }
  }

  void _handleSuccess() {
    setState(() => _isDragging = false);
    widget.onSuccess();
  }

  void _handleFail() {
    _resetAttempt();
    widget.onFail();
  }

  void _resetAttempt() {
    setState(() {
      _nextExpected = 1;
      _dragPoints = [];
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String completedText = "";
    for (int i = 1; i < _nextExpected; i++) {
      completedText += "$i ✓  ";
    }

    return Column(
      children: [
        const Text(
          'CONNECT NUMBERS',
          style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Current Target: ', style: TextStyle(color: Colors.white70)),
                  Text('$_nextExpected', 
                    style: const TextStyle(color: Color(0xFF22D3EE), fontWeight: FontWeight.bold, fontSize: 20)),
                ],
              ),
              if (completedText.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(completedText, 
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.w600)),
              ]
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Container(
                  key: _containerKey,
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Stack(
                    children: [
                      if (_dragPoints.isNotEmpty)
                        CustomPaint(
                          size: Size.infinite,
                          painter: _PathTrailPainter(_dragPoints),
                        ),
                      
                      ...List.generate(_nodePositions.length, (index) {
                        final val = _nodeValues[index];
                        final pos = _nodePositions[index];
                        final isReached = val < _nextExpected;
                        final isTarget = val == _nextExpected;

                        return Positioned(
                          left: pos.dx * constraints.maxWidth - 22,
                          top: pos.dy * constraints.maxHeight - 22,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isReached 
                                  ? const Color(0xFF8B5CF6) 
                                  : (isTarget ? const Color(0xFF1E1E2A) : const Color(0xFF12121A)),
                              border: Border.all(
                                color: isTarget ? const Color(0xFF22D3EE) : (isReached ? Colors.white24 : Colors.white10),
                                width: isTarget ? 3 : 1,
                              ),
                              boxShadow: isTarget ? [
                                BoxShadow(color: const Color(0xFF22D3EE).withValues(alpha: 0.4), blurRadius: 15, spreadRadius: 2)
                              ] : [],
                            ),
                            child: Center(
                              child: Text(
                                '$val',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isReached || isTarget ? Colors.white : Colors.white24,
                                ),
                              ),
                            ),
                          ).animate(target: isTarget ? 1 : 0, onPlay: (c) => c.repeat(reverse: true))
                           .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 600.ms),
                        );
                      }),
                    ],
                  ),
                ),
              );
            }
          ),
        ),
      ],
    );
  }
}

class _PathTrailPainter extends CustomPainter {
  final List<Offset> points;
  _PathTrailPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final paint = Paint()
      ..color = const Color(0xFF22D3EE).withValues(alpha: 0.6)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
