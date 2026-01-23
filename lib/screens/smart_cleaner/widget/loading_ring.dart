// --- 1. Data Structure ---
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phone_cleaner_2/l10n/generated/app_localizations.dart';
import 'package:phone_cleaner_2/screens/smart_cleaner/widget/segment.dart';

// --- 2. Animated Progress and Glow Controller ---
class RingProgressAnimationDemo extends StatefulWidget {
  final List<SegmentData> segments;
  final double totalValue;

  const RingProgressAnimationDemo({
    super.key,
    required this.segments,
    required this.totalValue,
  });

  @override
  State<RingProgressAnimationDemo> createState() =>
      _RingProgressAnimationDemoState();
}

class _RingProgressAnimationDemoState extends State<RingProgressAnimationDemo>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();

    // 1. Progress Animation Setup
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _progressController.forward();

    // 2. Glow Animation Setup
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // Repeat the animation back and forth

    _glowAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _controller = AnimationController(
      // The vsync is required for the controller to work and ties it to the widget's lifecycle.
      vsync: this,
      // The duration determines how long the animation will take (e.g., 5 seconds).
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 1.0, end: 100.0).animate(_controller)
      // The listener is called every time the animation changes value.
      ..addListener(() {
        // Calling setState redraws the widget with the new value.
        setState(() {});
      }); // 3. Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _glowController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to both animations to rebuild
    final currentValue = _animation.value.round();
    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnimation, _glowAnimation]),
      builder: (context, child) {
        // Use the glow animation values to control the BoxShadow properties
        // final blurRadius = 15.0 * _glowAnimation.value;
        // final spreadRadius = 5.0 * _glowAnimation.value;

        return Container(
          // External Pulsating Glow Effect
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // boxShadow: [
            //   BoxShadow(
            //     color: Theme.of(
            //       context,
            //     ).primaryColor.withOpacity(0.5 * _glowAnimation.value),
            //     blurRadius: blurRadius,
            //     spreadRadius: spreadRadius,
            //   ),
            // ],
          ),
          // The actual Ring Progress Widget
          child: RingProgressWidgets(
            segments: widget.segments,
            totalValue: widget.totalValue,
            animationValue: _progressAnimation.value,
            centerText: currentValue.toString(),
            ringStrokeWidth: 25.0,
          ),
        );
      },
    );
  }
}

// --- 3. Stateless Wrapper and Layout ---
class RingProgressWidgets extends StatelessWidget {
  final List<SegmentData> segments;
  final double totalValue;
  final double animationValue;
  final String centerText;
  final double ringStrokeWidth;

  const RingProgressWidgets({
    super.key,
    required this.segments,
    required this.totalValue,
    required this.animationValue,
    this.centerText = '2.56GB',
    this.ringStrokeWidth = 25.0,
  });

  @override
  Widget build(BuildContext context) {
    const double innerCircleRadius = 90.0;
    final widgetDiameter = (innerCircleRadius * 2) + (ringStrokeWidth * 2);

    return Container(
      width: widgetDiameter,
      height: widgetDiameter,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. The Custom Painter for the Ring
          // CustomPaint(
          //   size: Size(widgetDiameter, widgetDiameter),
          //   painter: RingProgressPainter(
          //     segments: segments,
          //     totalValue: totalValue,
          //     strokeWidth: ringStrokeWidth,
          //     animationValue: animationValue,
          //   ),
          // ),

          // 2. The Central Content
          Container(
            // width: innerCircleRadius * 2,
            // height: innerCircleRadius * 2,
            // decoration: BoxDecoration(
            //   color: Colors.white, // Inner white circle
            //   shape: BoxShape.circle,
            //   // boxShadow: [
            //   //   BoxShadow(
            //   //     color: Colors.black,
            //   //     spreadRadius: 5,
            //   //     blurRadius: 15,
            //   //     offset: Offset(0, 0), // changes position of shadow
            //   //   ),
            //   // ],
            // ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.clean,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "$centerText%",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 4. Custom Painter for the Animated Arc and Gradient ---
class RingProgressPainter extends CustomPainter {
  final List<SegmentData> segments;
  final double totalValue;
  final double strokeWidth;
  final double animationValue;

  RingProgressPainter({
    required this.segments,
    required this.totalValue,
    required this.animationValue,
    this.strokeWidth = 15.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Draw the light background ring (Gray, fading out from the center to simulate the inner glow)
    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          Colors.white.withOpacity(0.0), // Transparent at the center
          Colors.white.withOpacity(0.1), // Faint white at the edge
        ],
      ).createShader(rect);

    canvas.drawCircle(center, radius, backgroundPaint);

    // 2. Draw the segmented progress arcs
    double startAngle = -90.0; // Start from the top (-90 degrees)

    for (var segment in segments) {
      final sweepFraction = segment.value / totalValue;
      final sweepAngleDegrees = sweepFraction * 360.0;

      // Apply the animation value for the growth effect
      final currentSweepAngleDegrees = sweepAngleDegrees * animationValue;
      final sweepAngleRadians = currentSweepAngleDegrees * (math.pi / 180);

      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round; // Gives the pill-shaped ends

      // 🔑 Create the SweepGradient for the glowing/pill look
      final startAngleForGradient = startAngle * (math.pi / 180);
      final endAngleForGradient =
          (startAngle + currentSweepAngleDegrees) * (math.pi / 180);

      // Only apply gradient if the segment is visible and not transparent
      if (segment.color != Colors.transparent && currentSweepAngleDegrees > 0) {
        final gradientColors = [
          segment.color.withOpacity(0.7),
          segment.color,
          segment.color.withOpacity(0.5),
          segment.color.withOpacity(0.7),
        ];

        progressPaint.shader = SweepGradient(
          center: Alignment.center,
          startAngle: startAngleForGradient,
          endAngle: endAngleForGradient,
          colors: gradientColors,
          stops: const [0.0, 0.4, 0.6, 1.0],
          tileMode: TileMode.clamp,
        ).createShader(rect);
      } else {
        progressPaint.color = segment.color;
      }

      canvas.drawArc(
        rect,
        startAngle * (math.pi / 180), // Start angle in radians
        sweepAngleRadians, // Draw the animated arc length
        false,
        progressPaint,
      );

      // Advance the start angle by the FULL segment value to position the next one correctly
      startAngle += sweepAngleDegrees;
    }
  }

  @override
  bool shouldRepaint(covariant RingProgressPainter oldDelegate) {
    // Only repaint if the data or the animation value has changed
    return oldDelegate.segments != segments ||
        oldDelegate.totalValue != totalValue ||
        oldDelegate.animationValue != animationValue;
  }
}
