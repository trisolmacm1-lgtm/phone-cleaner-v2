import 'dart:math';
import 'package:flutter/material.dart';
import 'segment.dart';

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

    // ✅ Background Ring
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    // ✅ Strong Gap (Fixes Rounded Cap Overlap)
    final gapRadians = (strokeWidth * 2) / radius;

    double startAngle = -pi / 2;

    for (var segment in segments) {
      final sweepAngle = (segment.value / totalValue) * 2 * pi;

      // ✅ Skip very small segments
      if (sweepAngle <= gapRadians) {
        startAngle += sweepAngle;
        continue;
      }

      // ✅ Apply gap offset
      final adjustedStart = startAngle + gapRadians / 2;
      final adjustedSweep = sweepAngle - gapRadians;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = segment.color;

      canvas.drawArc(
        rect,
        adjustedStart,
        adjustedSweep,
        false,
        paint,
      );

      // ✅ Move to next arc position
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant RingProgressPainter oldDelegate) {
    return oldDelegate.segments != segments ||
        oldDelegate.totalValue != totalValue;
  }
}
