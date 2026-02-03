import 'package:flutter/material.dart';

class SegmentedCircularPainter extends CustomPainter {
  final double totalStorage;
  final double imageStorage;
  final double videoStorage;
  final double contactStorage;

  SegmentedCircularPainter({
    required this.totalStorage,
    required this.imageStorage,
    required this.videoStorage,
    required this.contactStorage,
  });

  final double strokeWidth = 20;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    const double totalAngle = 2 * 3.14159;

    final double radius = (size.width / 2.8) - strokeWidth / 10;

    // ✅ Spacing from OUTER ring
    final double outerGap = 0;

    // ✅ Spacing from INNER ring
    final double innerGap = 9;

    // ✅ Outer full ring boundary
    final borderRect = Rect.fromCircle(center: center, radius: radius);

    // ✅ Segment ring radius sits between inner & outer gap
    final segmentRect = Rect.fromCircle(
      center: center,
      radius: radius - outerGap,
    );

    // ✅ Reduce segment thickness so inner space is visible
    final double segmentStroke = strokeWidth - innerGap;

    // ======================================================
    // ✅ Background Ring
    // ======================================================

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(borderRect, 0, totalAngle, false, bgPaint);

    // ======================================================
    // ✅ Outer Border Ring
    // ======================================================

    final outerRingPaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + strokeWidth / 2),
      0,
      totalAngle,
      false,
      outerRingPaint,
    );

    // ======================================================
    // ✅ Inner Border Ring
    // ======================================================

    final innerRingPaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      0,
      totalAngle,
      false,
      innerRingPaint,
    );

    // ======================================================
    // ✅ Segment Data
    // ======================================================

    final values = [imageStorage, videoStorage, contactStorage];

    final colors = [
      const Color(0xFF91ADF4),
      const Color(0xFF81DEEA),
      const Color(0xFF98EE99),
    ];

    double startAngle = -3.14159 / 2;
    const double gap = 0.35;

    // ======================================================
    // ✅ Draw Segments with BOTH Side Spacing
    // ======================================================

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / totalStorage) * totalAngle;

      final adjustedStart = startAngle + gap / 2;
      final adjustedSweep = sweepAngle - gap;

      // ✅ Outer Shadow
      final outerShadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = segmentStroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(center.dx, center.dy + 3),
          radius: radius - outerGap,
        ),
        adjustedStart,
        adjustedSweep,
        false,
        outerShadowPaint,
      );

      // ✅ Main Segment
      final segmentPaint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = segmentStroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        segmentRect,
        adjustedStart,
        adjustedSweep,
        false,
        segmentPaint,
      );

      // ✅ Inner Shadow
      final innerShadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = segmentStroke - 6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 5);

      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(center.dx, center.dy - 3),
          radius: radius - outerGap - 1,
        ),
        adjustedStart,
        adjustedSweep,
        false,
        innerShadowPaint,
      );

      // ✅ Highlight Bevel
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(center.dx, center.dy + 1),
          radius: radius - outerGap - 1,
        ),
        adjustedStart,
        adjustedSweep,
        false,
        highlightPaint,
      );

      startAngle += sweepAngle;
    }

    // ======================================================
    // ✅ Center Percentage
    // ======================================================

    final used = imageStorage + videoStorage + contactStorage;
    final percent = (used / totalStorage) * 100;

    _drawCenterText(canvas, center, percent);
  }

  void _drawCenterText(Canvas canvas, Offset center, double percent) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: "${percent.toStringAsFixed(0)}%",
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
