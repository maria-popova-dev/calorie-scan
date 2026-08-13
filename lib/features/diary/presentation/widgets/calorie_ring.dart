import 'dart:math' as math;
import 'package:flutter/material.dart';

class CalorieRing extends StatelessWidget {
  final double consumed;
  final double goal;

  const CalorieRing({
    super.key,
    required this.consumed,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final isOverGoal = consumed > goal;
    final progress = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    final remaining = (goal - consumed).clamp(0, double.infinity);
    final ringColor = isOverGoal ? const Color(0xFFFF3B30) : const Color(0xFF34C759);

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(220, 220),
            painter: _RingPainter(progress: progress, color: ringColor),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                consumed.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'of ${goal.toStringAsFixed(0)} kcal',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isOverGoal
                    ? '${(consumed - goal).toStringAsFixed(0)} over'
                    : '${remaining.toStringAsFixed(0)} left',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: ringColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 20) / 2;

    final backgroundPaint = Paint()
      ..color = const Color(0xFFEDEDE8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}