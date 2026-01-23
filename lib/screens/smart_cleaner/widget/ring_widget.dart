import 'package:flutter/material.dart';
import 'package:phone_cleaner_2/core/utils/colors.dart';
import 'package:phone_cleaner_2/screens/smart_cleaner/widget/ring_progress.dart';
import 'package:phone_cleaner_2/screens/smart_cleaner/widget/segment.dart';

class RingProgressWidget extends StatelessWidget {
  final List<SegmentData> segments;
  final double totalValue;
  final double innerCircleRadius;
  final String centerText;
  final double ringStrokeWidth;

  const RingProgressWidget({
    super.key,
    required this.segments,
    required this.totalValue,
    this.centerText = '2.56GB',
    this.innerCircleRadius = 100.0,
    this.ringStrokeWidth = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the total diameter of the widget
    final widgetDiameter = (innerCircleRadius * 2) + (ringStrokeWidth * 2);
    return Container(
      width: widgetDiameter,
      height: widgetDiameter,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. The Custom Painter for the Ring
          CustomPaint(
            size: Size(widgetDiameter, widgetDiameter),
            painter: RingProgressPainter(
              segments: segments,
              totalValue: totalValue,
              strokeWidth: ringStrokeWidth,
            ),
          ),

          // 2. The central white circle (or slightly off-white)
          Container(
            width: innerCircleRadius * 2,
            height: innerCircleRadius * 2,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.bgColor, width: 15),
            ),
          ),

          // 3. The Central Content (Icon and Text)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with gold background
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor, // Gold-like color
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 10),
              // The main text
              Text(
                centerText,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
