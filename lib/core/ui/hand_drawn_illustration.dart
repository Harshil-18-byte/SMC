import 'package:flutter/material.dart';
import 'dart:math';

// Use custom illustrations for empty states
class CustomIllustration extends StatelessWidget {
  final String type; // 'no_visits', 'all_done', 'error'
  final Color? color;
  final double size;

  const CustomIllustration({
    super.key,
    required this.type,
    this.color,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HandDrawnPainter(
        type: type,
        color: color ?? Theme.of(context).primaryColor,
      ),
      size: Size(size, size),
    );
  }
}

class HandDrawnPainter extends CustomPainter {
  final String type;
  final Color color;
  final Random _random = Random();

  HandDrawnPainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Sketch style paint
    final mainPaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final shadowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (type == 'no_visits') {
      _drawRelaxedScene(canvas, size, mainPaint, shadowPaint);
    } else if (type == 'all_done') {
      _drawSuccessScene(canvas, size, mainPaint, shadowPaint);
    } else if (type == 'error') {
      _drawConfusionScene(canvas, size, mainPaint, shadowPaint);
    } else if (type == 'loading') {
      _drawLoadingCircle(canvas, size, mainPaint);
    }
  }

  // A more complex scene: A clipboard resting on a chair/box
  void _drawRelaxedScene(
      Canvas canvas, Size size, Paint mainPaint, Paint shadowPaint) {
    final center = size.center(Offset.zero);
    final w = size.width;
    final h = size.height;

    // Draw Clipboard rectangle
    final clipRect =
        Rect.fromCenter(center: center, width: w * 0.4, height: h * 0.5);
    _drawSketchRect(canvas, clipRect, mainPaint, shadowPaint);

    // Clip at top
    final clipTop = Rect.fromCenter(
        center: center.translate(0, -h * 0.25),
        width: w * 0.2,
        height: h * 0.05);
    _drawSketchRect(canvas, clipTop, mainPaint, shadowPaint);

    // "Zzz" floating to imply rest
    _drawTextSketch(
        canvas, "Zzz", center.translate(w * 0.3, -h * 0.3), mainPaint);

    // Checkmark on clipboard
    _drawSketchLine(canvas, center.translate(-w * 0.1, 0),
        center.translate(-w * 0.02, h * 0.1), mainPaint, shadowPaint);
    _drawSketchLine(canvas, center.translate(-w * 0.02, h * 0.1),
        center.translate(w * 0.15, -h * 0.15), mainPaint, shadowPaint);
  }

  void _drawSuccessScene(
      Canvas canvas, Size size, Paint mainPaint, Paint shadowPaint) {
    final center = size.center(Offset.zero);
    final w = size.width;

    // Big Star
    final points = 5;
    final radius = w * 0.3;
    final innerRadius = w * 0.12;

    final path = Path();
    double angle = -pi / 2;
    final angleStep = pi / points;

    for (int i = 0; i < points * 2; i++) {
      final r = (i % 2 == 0) ? radius : innerRadius;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
      angle += angleStep;
    }
    path.close();

    // Draw star with wobble by tracing edges manually or just simple path
    // For sketch look, let's trace the path edges using sketchLine logic would be complex
    // So we apply mainPaint to path and add some random strokes around
    canvas.drawPath(path, mainPaint);

    // Add sparkles
    _drawSparkle(canvas, center.translate(-w * 0.35, -w * 0.2), mainPaint);
    _drawSparkle(canvas, center.translate(w * 0.35, -w * 0.1), mainPaint);
    _drawSparkle(canvas, center.translate(0, -w * 0.4), mainPaint);
  }

  void _drawConfusionScene(
      Canvas canvas, Size size, Paint mainPaint, Paint shadowPaint) {
    final center = size.center(Offset.zero);
    final w = size.width;

    // Draw a tangled knot style
    final path = Path();
    path.moveTo(center.dx - w * 0.2, center.dy);
    for (int i = 0; i < 10; i++) {
      path.quadraticBezierTo(
          center.dx +
              (i % 2 == 0 ? w * 0.3 : -w * 0.3) +
              _random.nextDouble() * 20,
          center.dy + (i * 10.0) - 50 + _random.nextDouble() * 20,
          center.dx + (i % 2 == 0 ? -w * 0.2 : w * 0.2),
          center.dy + (i * 10.0) - 40);
    }
    canvas.drawPath(path, mainPaint);

    // Question marks
    _drawQuestionMark(canvas, center.translate(0, -w * 0.3), mainPaint,
        scale: 1.5);
  }

  void _drawLoadingCircle(Canvas canvas, Size size, Paint paint) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.3;
    _drawImperfectCircle(canvas, center, radius, paint);
    // Add an arrow tip to suggest rotation
    _drawSketchLine(canvas, center.translate(radius, 0),
        center.translate(radius + 10, 10), paint, paint);
    _drawSketchLine(canvas, center.translate(radius, 0),
        center.translate(radius - 5, 12), paint, paint);
  }

  void _drawSketchLine(
      Canvas canvas, Offset p1, Offset p2, Paint mainPaint, Paint shadowPaint) {
    // Draw the main line with wobble
    _drawWobblyLine(canvas, p1, p2, mainPaint);

    // Draw a second faint line slightly offset for "sketch" look
    if (_random.nextBool()) {
      final offset =
          Offset(_random.nextDouble() * 4 - 2, _random.nextDouble() * 4 - 2);
      _drawWobblyLine(canvas, p1 + offset, p2 + offset, shadowPaint);
    }
  }

  void _drawSketchRect(
      Canvas canvas, Rect rect, Paint mainPaint, Paint shadowPaint) {
    _drawSketchLine(
        canvas, rect.topLeft, rect.topRight, mainPaint, shadowPaint);
    _drawSketchLine(
        canvas, rect.topRight, rect.bottomRight, mainPaint, shadowPaint);
    _drawSketchLine(
        canvas, rect.bottomRight, rect.bottomLeft, mainPaint, shadowPaint);
    _drawSketchLine(
        canvas, rect.bottomLeft, rect.topLeft, mainPaint, shadowPaint);
  }

  void _drawTextSketch(Canvas canvas, String text, Offset pos, Paint paint) {
    final tp = TextPainter(
        text: TextSpan(
            text: text,
            style: TextStyle(
                color: paint.color,
                fontSize: 24,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, pos);
  }

  void _drawWobblyLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final path = Path();
    path.moveTo(p1.dx, p1.dy);

    // Add control point for slight curve/wobble
    final midX = (p1.dx + p2.dx) / 2;
    final midY = (p1.dy + p2.dy) / 2;
    // Random offset
    final offset = 5.0;
    final cx = midX + (_random.nextDouble() * offset * 2 - offset);
    final cy = midY + (_random.nextDouble() * offset * 2 - offset);

    path.quadraticBezierTo(cx, cy, p2.dx, p2.dy);
    canvas.drawPath(path, paint);
  }

  void _drawImperfectCircle(
      Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (var i = 0; i < 360; i += 20) {
      final angle = i * pi / 180;
      final r = radius + (_random.nextDouble() * 4 - 2); // +/- 2px wobble
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawQuestionMark(Canvas canvas, Offset pos, Paint paint,
      {double scale = 1.0}) {
    // Simple logic for ?
    canvas.drawCircle(pos.translate(0, 10 * scale), 2 * scale, paint);
    // Curve
    final path = Path();
    path.moveTo(pos.dx - 5 * scale, pos.dy - 5 * scale);
    path.quadraticBezierTo(
        pos.dx, pos.dy - 15 * scale, pos.dx + 5 * scale, pos.dy - 5 * scale);
    path.quadraticBezierTo(
        pos.dx + 5 * scale, pos.dy, pos.dx, pos.dy + 5 * scale);
    canvas.drawPath(path, paint);
  }

  void _drawSparkle(Canvas canvas, Offset pos, Paint paint) {
    // Cross shape
    canvas.drawLine(pos.translate(0, -5), pos.translate(0, 5), paint);
    canvas.drawLine(pos.translate(-5, 0), pos.translate(5, 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


