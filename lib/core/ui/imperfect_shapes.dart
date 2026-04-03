import 'package:flutter/material.dart';
import 'dart:math';

// Use custom shape with slight irregularity
class ImperfectCircleBorder extends ShapeBorder {
  final BorderSide side;

  const ImperfectCircleBorder({this.side = BorderSide.none});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect.deflate(side.width), textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();
    final center = rect.center;
    final radius = rect.width / 2;

    // Create circle with slight wobble
    final random = Random(rect.hashCode); // Consistent random based on rect
    for (var i = 0; i < 360; i += 10) {
      final angle = i * pi / 180;
      // Multi-frequency wobble for organic feel
      final wobble = sin(angle * 3) * 1.5 +
          cos(angle * 7) * 0.8 +
          (random.nextDouble() - 0.5);
      final r = radius + wobble;

      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;

    final paint = side.toPaint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = getOuterPath(rect, textDirection: textDirection);
    canvas.drawPath(path, paint);

    // Artistic "Sketch" touch: draw a second, slightly offset faint line
    final sketchPaint = side.toPaint()
      ..color = side.color.withValues(alpha: 0.2)
      ..strokeWidth = side.width * 0.6
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(1.2, 0.8);
    canvas.drawPath(path, sketchPaint);
    canvas.restore();
  }

  @override
  ShapeBorder scale(double t) {
    return ImperfectCircleBorder(side: side.scale(t));
  }
}


