import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Painter for the animated background in the parallax dashboard
class AnimatedBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  AnimatedBackgroundPainter({required this.animation})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    final t = animation.value;

    // Draw some organic moving blobs
    for (var i = 0; i < 3; i++) {
      final x = size.width * (0.5 + 0.3 * math.sin(t * 2 * math.pi + i));
      final y = size.height * (0.5 + 0.2 * math.cos(t * 1.5 * math.pi + i));
      final radius = size.width * (0.3 + 0.1 * math.sin(t * math.pi * 0.5 + i));

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(AnimatedBackgroundPainter oldDelegate) => true;
}

/// Painter for the glowing health score circle
class GlowingCirclePainter extends CustomPainter {
  final double progress;
  final Color color;

  GlowingCirclePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 6.0;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    // Glow effect
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      glowPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(GlowingCirclePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}


