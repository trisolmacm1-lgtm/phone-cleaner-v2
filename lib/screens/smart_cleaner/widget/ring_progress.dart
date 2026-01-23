import 'dart:math';

import 'package:flutter/material.dart';
import 'package:phone_cleaner_2/screens/smart_cleaner/widget/segment.dart';

class RingProgressPainter extends CustomPainter {
  final List<SegmentData> segments;
  final double totalValue;
  final double strokeWidth;

  RingProgressPainter({
    required this.segments,
    required this.totalValue,
    this.strokeWidth = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Draw the overall white/light background ring
    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt; // Use 'butt' for a continuous look

    canvas.drawCircle(center, radius, backgroundPaint);

    // 2. Draw the segmented progress arcs
    double startAngle = -90.0; // Start from the top (-90 degrees)

    for (var segment in segments) {
      // Calculate sweep angle (in radians)
      final sweepFraction = segment.value / totalValue;
      final sweepAngleRadians = sweepFraction * 360.0; // 360 degrees in radians

      final progressPaint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round; // Use 'round' for the glowing/pill look

      // The use of SweepGradient helps achieve the subtle color fade/glow effect
      if (sweepAngleRadians.isFinite && sweepAngleRadians > 0) {
        final startRad = (startAngle - 90) * (pi / 180);

        final endRad = startRad + sweepAngleRadians;

        if (startRad.isFinite && endRad.isFinite && endRad > startRad) {
          progressPaint.shader = SweepGradient(
            startAngle: startRad,
            endAngle: endRad,
            colors: [
              segment.color.withOpacity(0.8),
              segment.color,
              segment.color.withOpacity(0.8),
            ],
            tileMode: TileMode.clamp,
          ).createShader(rect);
        }
      }

      canvas.drawArc(
        rect,
        (startAngle) * (3.14159 / 180), // Convert start angle to radians
        sweepAngleRadians * (3.14159 / 180), // Convert sweep angle to radians
        false, // 'useCenter' is false for an arc (not a pie wedge)
        progressPaint,
      );

      // Update the start angle for the next segment
      startAngle += sweepAngleRadians;
    }
  }

  @override
  bool shouldRepaint(covariant RingProgressPainter oldDelegate) {
    // Repaint only if the data has changed
    return oldDelegate.segments != segments ||
        oldDelegate.totalValue != totalValue;
  }
}
