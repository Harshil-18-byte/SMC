import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A hand-drawn, sketchy alternative to perfect vector icons.
/// Looks like it was scribbled onto the medical chart by a human.
class SketchyIcon extends StatelessWidget {
  final SketchyIconType type;
  final double size;
  final Color color;

  const SketchyIcon(
    this.type, {
    super.key,
    this.size = 24.0,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SketchyIconPainter(type, color),
      ),
    );
  }
}

enum SketchyIconType {
  home,
  profile,
  settings,
  search,
  medicalBag,
  heartbeat,
  document,
  alert,
  cross,
}

class _SketchyIconPainter extends CustomPainter {
  final SketchyIconType type;
  final Color color;

  _SketchyIconPainter(this.type, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.08
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Fixed seeded RNG so the "sketchiness" stays consistent
    // and doesn't jitter on every frame
    final rng = math.Random(type.index);

    double j() => (rng.nextDouble() - 0.5) * (w * 0.06);

    switch (type) {
      case SketchyIconType.home:
        final path = Path();
        // Roof
        path.moveTo(w * 0.1 + j(), h * 0.5 + j());
        path.lineTo(w * 0.5 + j(), h * 0.1 + j());
        path.lineTo(w * 0.9 + j(), h * 0.5 + j());
        // Walls
        path.moveTo(w * 0.2 + j(), h * 0.4 + j());
        path.lineTo(w * 0.2 + j(), h * 0.9 + j());
        path.lineTo(w * 0.8 + j(), h * 0.9 + j());
        path.lineTo(w * 0.8 + j(), h * 0.4 + j());
        canvas.drawPath(path, paint);
        break;

      case SketchyIconType.profile:
        final path = Path();
        // Head
        path.addOval(Rect.fromCircle(
            center: Offset(w * 0.5 + j(), h * 0.3 + j()), radius: w * 0.2));
        // Shoulders
        path.moveTo(w * 0.2 + j(), h * 0.9 + j());
        path.quadraticBezierTo(
            w * 0.2 + j(), h * 0.6 + j(), w * 0.5 + j(), h * 0.6 + j());
        path.quadraticBezierTo(
            w * 0.8 + j(), h * 0.6 + j(), w * 0.8 + j(), h * 0.9 + j());
        canvas.drawPath(path, paint);
        break;

      case SketchyIconType.settings:
        // A sketchy gear: circle with rough spokes
        canvas.drawCircle(Offset(w * 0.5 + j(), h * 0.5 + j()), w * 0.2, paint);
        for (int i = 0; i < 6; i++) {
          final angle = (i * math.pi / 3) + j();
          final start = Offset(w * 0.5 + math.cos(angle) * (w * 0.2),
              h * 0.5 + math.sin(angle) * (w * 0.2));
          final end = Offset(w * 0.5 + math.cos(angle) * (w * 0.4) + j(),
              h * 0.5 + math.sin(angle) * (w * 0.4) + j());
          canvas.drawLine(start, end, paint);
        }
        break;

      case SketchyIconType.search:
        // Magnifying glass
        canvas.drawCircle(
            Offset(w * 0.4 + j(), h * 0.4 + j()), w * 0.25, paint);
        canvas.drawLine(Offset(w * 0.6 + j(), h * 0.6 + j()),
            Offset(w * 0.9 + j(), h * 0.9 + j()), paint);
        break;

      case SketchyIconType.medicalBag:
        final path = Path();
        // Box
        path.addRect(
            Rect.fromLTWH(w * 0.15 + j(), h * 0.3 + j(), w * 0.7, h * 0.55));
        // Handle
        path.moveTo(w * 0.3 + j(), h * 0.3 + j());
        path.quadraticBezierTo(
            w * 0.5 + j(), h * 0.0 + j(), w * 0.7 + j(), h * 0.3 + j());
        canvas.drawPath(path, paint);
        // Cross inside
        canvas.drawLine(Offset(w * 0.5 + j(), h * 0.45 + j()),
            Offset(w * 0.5 + j(), h * 0.7 + j()), paint);
        canvas.drawLine(Offset(w * 0.35 + j(), h * 0.57 + j()),
            Offset(w * 0.65 + j(), h * 0.57 + j()), paint);
        break;

      case SketchyIconType.heartbeat:
        final path = Path();
        path.moveTo(w * 0.1 + j(), h * 0.5 + j());
        path.lineTo(w * 0.3 + j(), h * 0.5 + j());
        path.lineTo(w * 0.4 + j(), h * 0.2 + j());
        path.lineTo(w * 0.6 + j(), h * 0.8 + j());
        path.lineTo(w * 0.7 + j(), h * 0.5 + j());
        path.lineTo(w * 0.9 + j(), h * 0.5 + j());
        canvas.drawPath(path, paint);
        break;

      case SketchyIconType.document:
        final path = Path();
        // Page bounds
        path.moveTo(w * 0.2 + j(), h * 0.1 + j());
        path.lineTo(w * 0.6 + j(), h * 0.1 + j());
        path.lineTo(w * 0.8 + j(), h * 0.3 + j());
        path.lineTo(w * 0.8 + j(), h * 0.9 + j());
        path.lineTo(w * 0.2 + j(), h * 0.9 + j());
        path.close();
        canvas.drawPath(path, paint);
        // Fold
        canvas.drawLine(Offset(w * 0.6 + j(), h * 0.1 + j()),
            Offset(w * 0.6 + j(), h * 0.3 + j()), paint);
        canvas.drawLine(Offset(w * 0.6 + j(), h * 0.3 + j()),
            Offset(w * 0.8 + j(), h * 0.3 + j()), paint);
        // Text lines
        canvas.drawLine(Offset(w * 0.3 + j(), h * 0.4 + j()),
            Offset(w * 0.7 + j(), h * 0.4 + j()), paint);
        canvas.drawLine(Offset(w * 0.3 + j(), h * 0.6 + j()),
            Offset(w * 0.7 + j(), h * 0.6 + j()), paint);
        break;

      case SketchyIconType.alert:
        final path = Path();
        // Triangle
        path.moveTo(w * 0.5 + j(), h * 0.1 + j());
        path.lineTo(w * 0.1 + j(), h * 0.8 + j());
        path.lineTo(w * 0.9 + j(), h * 0.8 + j());
        path.close();
        canvas.drawPath(path, paint);
        // Exclamation point
        canvas.drawLine(Offset(w * 0.5 + j(), h * 0.3 + j()),
            Offset(w * 0.5 + j(), h * 0.6 + j()), paint);
        canvas.drawCircle(Offset(w * 0.5 + j(), h * 0.7 + j()), w * 0.05,
            paint..style = PaintingStyle.fill);
        break;

      case SketchyIconType.cross:
        canvas.drawLine(Offset(w * 0.2 + j(), h * 0.2 + j()),
            Offset(w * 0.8 + j(), h * 0.8 + j()), paint);
        canvas.drawLine(Offset(w * 0.8 + j(), h * 0.2 + j()),
            Offset(w * 0.2 + j(), h * 0.8 + j()), paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _SketchyIconPainter old) =>
      old.type != type || old.color != color;
}
