import 'dart:ui'; // <--- This is the missing piece for PathMetric

import 'package:flutter/material.dart';
import 'package:phone_cleaner_2/main.dart';

class SquareProgressIndicator extends StatefulWidget {
  final double targetValue;
  final double size;
  final double strokeWidth;
  final double cornerRadius;
  final double scallopDepth; // New parameter for inward curve depth

  const SquareProgressIndicator({
    super.key,
    required this.targetValue,
    this.size = 150.0,
    this.strokeWidth = 12.0,
    this.cornerRadius = 30.0,
    this.scallopDepth = 15.0,
  });

  @override
  State<SquareProgressIndicator> createState() =>
      _SquareProgressIndicatorState();
}

class _SquareProgressIndicatorState extends State<SquareProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.targetValue,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  // ... (didUpdateWidget and dispose methods remain the same) ...

  @override
  void didUpdateWidget(covariant SquareProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetValue != widget.targetValue) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.targetValue,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: ScallopedProgressPainter(
              // Changed painter name
              progress: _animation.value,
              strokeWidth: widget.strokeWidth,
              cornerRadius: widget.cornerRadius,
              scallopDepth: widget.scallopDepth, // Passed to painter
            ),
            child: Center(
              child: Text(
                '${(widget.targetValue * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Gilroy',
                  fontSize: widget.size * 0.28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- 2. The CustomPainter for Drawing the Scalloped Shape ---

// --- 2. The CustomPainter for Drawing the Scalloped Shape (MODIFIED) ---

class ScallopedProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final double cornerRadius;
  final double scallopDepth;

  ScallopedProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.cornerRadius,
    required this.scallopDepth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double halfStroke = strokeWidth / 2;

    // Path for the background track and inner fill
    final Path trackPath = _createScallopedPath(
      size,
      cornerRadius,
      scallopDepth,
      halfStroke, // Inset by half the stroke for drawing the path center
    );

    // --- 1. Draw the Inner Scalloped Background (Gradient Fill - Gold) ---
    // (This part remains the same)
    final Path innerPath = _createScallopedPath(
      size,
      cornerRadius,
      scallopDepth,
      halfStroke * 2,
    );

    final Paint innerFillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(innerPath, innerFillPaint);

    // --- 2. Draw the Background Track (Faded White) ---
    // (This part remains the same)
    final Paint trackPaint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(trackPath, trackPaint);

    // --- 3. Draw the Gradient Progress Arc (MODIFIED) ---
    if (progress > 0) {
      final PathMetric pathMetric = trackPath.computeMetrics().first;
      final double totalLength = pathMetric.length;
      final double progressLength = totalLength * progress;

      // Extract the path segment for the current progress
      final Path progressPath = pathMetric.extractPath(0, progressLength);

      // Determine the bounds of the current progress path for the gradient shader
      // We use the entire widget bounds, but the path itself defines the gradient shape.
      final Rect rect = Offset.zero & size;

      final Paint progressPaint = Paint()
        // *** START OF GRADIENT IMPLEMENTATION ***
        ..shader = LinearGradient(
          // Define the colors for the gradient
          colors: [
            Theme.of(rootNavigatorKey.currentContext!).primaryColor,
            // Color(0xFFDBBC72), // Darker color for the end
            Color(0xFFFFFFFF), // Light color for the start
          ],
          // The gradient should extend along the entire path length
          // We define the starting point (0.0) and ending point (progressLength / totalLength)
          stops: [0.0, .5],

          // Define the coordinate system for the gradient.
          // We use the overall bounding box of the widget.
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect)
        // *** END OF GRADIENT IMPLEMENTATION ***
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(progressPath, progressPaint);
    }
  }

  // Helper function _createScallopedPath remains the same
  Path _createScallopedPath(
    Size size,
    double radius,
    double depth,
    double inset,
  ) {
    // ... (Code for creating the path remains the same as previous response) ...
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    // A. Start at the top-right straight edge
    path.moveTo(w - inset - radius, inset);

    // B. Top edge (Right to Left)
    path.lineTo(inset + radius, inset);

    // C. Top-Left Scallop Corner (Inward Curve)
    path.cubicTo(
      inset + depth,
      inset,
      inset,
      inset + depth,
      inset,
      inset + radius,
    );

    // D. Left edge (Top to Bottom)
    path.lineTo(inset, h - inset - radius);

    // E. Bottom-Left Scallop Corner
    path.cubicTo(
      inset,
      h - inset - depth,
      inset + depth,
      h - inset,
      inset + radius,
      h - inset,
    );

    // F. Bottom edge (Left to Right)
    path.lineTo(w - inset - radius, h - inset);

    // G. Bottom-Right Scallop Corner
    path.cubicTo(
      w - inset - depth,
      h - inset,
      w - inset,
      h - inset - depth,
      w - inset,
      h - inset - radius,
    );

    // H. Right edge (Bottom to Top)
    path.lineTo(w - inset, inset + radius);

    // I. Top-Right Scallop Corner (to close the path)
    path.cubicTo(
      w - inset,
      inset + depth,
      w - inset - depth,
      inset,
      w - inset - radius,
      inset,
    );

    return path;
  }

  @override
  bool shouldRepaint(covariant ScallopedProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.cornerRadius != cornerRadius ||
        oldDelegate.scallopDepth != scallopDepth;
  }
}
