import 'dart:math';

import 'package:flutter/material.dart';

class DrawingBoard extends StatefulWidget {
  final Function(List<List<double>>)? onChange;
  final double size;

  const DrawingBoard({
    super.key,
    this.onChange,
    this.size = 280, // Default size for the drawing area
  });

  @override
  State<DrawingBoard> createState() => _DrawingBoardState();
}

class _DrawingBoardState extends State<DrawingBoard> {
  List<List<double>> pixelData = List.generate(
      28, (_) => List.filled(28, 0.0)
  );

  List<Offset> currentStroke = [];
  List<List<Offset>> strokes = [];

  void _resetDrawing() {
    setState(() {
      currentStroke = [];
      strokes = [];
      pixelData = List.generate(28, (_) => List.filled(28, 0.0));
    });
    if (widget.onChange != null) {
      widget.onChange!(pixelData);
    }
  }

  void _updatePixelData() {
    // Convert drawing to 28x28 pixel data
    final cellSize = widget.size / 28;

    // Reset pixel data
    pixelData = List.generate(28, (_) => List.filled(28, 0.0));

    // Process all strokes
    for (final stroke in [...strokes, if (currentStroke.isNotEmpty) currentStroke]) {
      for (int i = 0; i < stroke.length; i++) {
        // Get current point
        final point = stroke[i];

        // Convert to grid coordinates
        final col = (point.dx / cellSize).floor().clamp(0, 27);
        final row = (point.dy / cellSize).floor().clamp(0, 27);

        // Set pixel value
        pixelData[row][col] = 1.0;

        // Add some bloom to neighboring pixels
        for (int r = -1; r <= 1; r++) {
          for (int c = -1; c <= 1; c++) {
            final newRow = row + r;
            final newCol = col + c;
            if (newRow >= 0 && newRow < 28 && newCol >= 0 && newCol < 28) {
              if (r == 0 && c == 0) continue; // Skip center
              pixelData[newRow][newCol] =
                  (pixelData[newRow][newCol] + 0.7).clamp(0.0, 1.0);
            }
          }
        }

        // If we have consecutive points, interpolate between them
        if (i > 0) {
          final prev = stroke[i - 1];
          final dx = point.dx - prev.dx;
          final dy = point.dy - prev.dy;
          final distance = sqrt(dx * dx + dy * dy);

          // If points are far apart, interpolate
          if (distance > cellSize / 2) {
            final steps = (distance / (cellSize / 2)).ceil();
            for (int step = 1; step < steps; step++) {
              final t = step / steps;
              final interpX = prev.dx + dx * t;
              final interpY = prev.dy + dy * t;

              final interpCol = (interpX / cellSize).floor().clamp(0, 27);
              final interpRow = (interpY / cellSize).floor().clamp(0, 27);

              pixelData[interpRow][interpCol] = 1.0;

              // Bloom for interpolated points
              for (int r = -1; r <= 1; r++) {
                for (int c = -1; c <= 1; c++) {
                  final newRow = interpRow + r;
                  final newCol = interpCol + c;
                  if (newRow >= 0 && newRow < 28 && newCol >= 0 && newCol < 28) {
                    if (r == 0 && c == 0) continue;
                    pixelData[newRow][newCol] =
                        (pixelData[newRow][newCol] + 0.7).clamp(0.0, 1.0);
                  }
                }
              }
            }
          }
        }
      }
    }

    if (widget.onChange != null) {
      widget.onChange!(pixelData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 6.0),
          child: ElevatedButton(
            onPressed: _resetDrawing,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.clear),
                Text('Clear Canvas')
              ],
            ),
          ),
        ),
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: Colors.grey,
            border: Border.all(color: Colors.grey),
          ),
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                currentStroke = [details.localPosition];
              });
              _updatePixelData();
            },
            onPanUpdate: (details) {
              setState(() {
                currentStroke.add(details.localPosition);
              });
              _updatePixelData();
            },
            onPanEnd: (_) {
              setState(() {
                if (currentStroke.isNotEmpty) {
                  strokes.add(List.from(currentStroke));
                  currentStroke = [];
                }
              });
            },
            child: CustomPaint(
              painter: DrawingPainter(
                strokes: strokes,
                currentStroke: currentStroke,
                gridSize: 28,
                canvasSize: widget.size,
              ),
              size: Size(widget.size, widget.size),
            ),
          ),
        ),
      ],
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final int gridSize;
  final double canvasSize;

  DrawingPainter({
    required this.strokes,
    required this.currentStroke,
    required this.gridSize,
    required this.canvasSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = canvasSize / gridSize * 0.5 // Make stroke approximately half a cell
      ..strokeCap = StrokeCap.round;

    // Draw completed strokes
    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }

    // Draw current stroke
    for (int i = 0; i < currentStroke.length - 1; i++) {
      canvas.drawLine(currentStroke[i], currentStroke[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}