import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Draws scattered hand-drawn medical doodles across the background.
/// Each doodle is intentionally "sketchy" — slightly irregular strokes,
/// small imperfections, and rough edges to look human-made.
class MedicalDoodlePainter extends CustomPainter {
  final Color color;
  final double animationValue;

  MedicalDoodlePainter({required this.color, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42); // Deterministic seed for stable layout

    final sketchPaint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw various doodles scattered around
    for (int i = 0; i < 12; i++) {
      final cx = rng.nextDouble() * size.width;
      final cy = rng.nextDouble() * size.height;
      // Subtle float offset from animation
      final floatY = math.sin(animationValue * 2 * math.pi + i * 0.8) * 3;
      final floatX = math.cos(animationValue * 2 * math.pi + i * 1.2) * 2;

      canvas.save();
      canvas.translate(cx + floatX, cy + floatY);
      // Slight rotation for "casually placed" feel
      canvas.rotate((rng.nextDouble() - 0.5) * 0.4);

      final doodleType = i % 6;
      switch (doodleType) {
        case 0:
          _drawSketchyPill(canvas, sketchPaint, rng);
          break;
        case 1:
          _drawSketchyCross(canvas, sketchPaint, rng);
          break;
        case 2:
          _drawSketchyHeart(canvas, sketchPaint, rng);
          break;
        case 3:
          _drawSketchySyringe(canvas, sketchPaint, rng);
          break;
        case 4:
          _drawSketchyBandaid(canvas, sketchPaint, rng);
          break;
        case 5:
          _drawSketchyStethoscope(canvas, sketchPaint, rng);
          break;
      }

      canvas.restore();
    }
  }

  /// Draws a sketchy pill capsule with imperfect lines
  void _drawSketchyPill(Canvas canvas, Paint paint, math.Random rng) {
    final path = Path();
    final w = 22.0;
    final h = 10.0;
    // Left rounded end — slightly wobbly
    path.moveTo(-w / 2, -h / 2 + _jitter(rng));
    path.quadraticBezierTo(-w / 2 - 5 + _jitter(rng), 0 + _jitter(rng), -w / 2,
        h / 2 + _jitter(rng));
    // Bottom line
    path.lineTo(w / 2 + _jitter(rng), h / 2 + _jitter(rng));
    // Right rounded end
    path.quadraticBezierTo(w / 2 + 5 + _jitter(rng), 0 + _jitter(rng), w / 2,
        -h / 2 + _jitter(rng));
    // Top line
    path.lineTo(-w / 2 + _jitter(rng), -h / 2 + _jitter(rng));
    canvas.drawPath(path, paint);
    // Dividing line in the middle
    canvas.drawLine(Offset(0 + _jitter(rng), -h / 2 + _jitter(rng)),
        Offset(0 + _jitter(rng), h / 2 + _jitter(rng)), paint);
  }

  /// Draws a sketchy medical cross
  void _drawSketchyCross(Canvas canvas, Paint paint, math.Random rng) {
    final s = 8.0;
    // Vertical bar
    canvas.drawLine(Offset(0 + _jitter(rng), -s + _jitter(rng)),
        Offset(0 + _jitter(rng), s + _jitter(rng)), paint);
    // Horizontal bar
    canvas.drawLine(Offset(-s + _jitter(rng), 0 + _jitter(rng)),
        Offset(s + _jitter(rng), 0 + _jitter(rng)), paint);
  }

  /// Draws a sketchy heart shape
  void _drawSketchyHeart(Canvas canvas, Paint paint, math.Random rng) {
    final path = Path();
    path.moveTo(0, 4 + _jitter(rng));
    path.cubicTo(-8 + _jitter(rng), -2 + _jitter(rng), -8 + _jitter(rng),
        -8 + _jitter(rng), 0, -4 + _jitter(rng));
    path.cubicTo(8 + _jitter(rng), -8 + _jitter(rng), 8 + _jitter(rng),
        -2 + _jitter(rng), 0, 4 + _jitter(rng));
    canvas.drawPath(path, paint);
  }

  /// Draws a sketchy syringe
  void _drawSketchySyringe(Canvas canvas, Paint paint, math.Random rng) {
    // Barrel
    canvas.drawRect(
        Rect.fromLTWH(-3 + _jitter(rng), -12 + _jitter(rng), 6, 18), paint);
    // Plunger handle
    canvas.drawLine(Offset(-4 + _jitter(rng), -12 + _jitter(rng)),
        Offset(4 + _jitter(rng), -12 + _jitter(rng)), paint);
    canvas.drawLine(Offset(0 + _jitter(rng), -12 + _jitter(rng)),
        Offset(0 + _jitter(rng), -16 + _jitter(rng)), paint);
    // Needle
    canvas.drawLine(Offset(0 + _jitter(rng), 6 + _jitter(rng)),
        Offset(0 + _jitter(rng), 14 + _jitter(rng)), paint);
  }

  /// Draws a sketchy bandaid
  void _drawSketchyBandaid(Canvas canvas, Paint paint, math.Random rng) {
    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(_jitter(rng), _jitter(rng)), width: 24, height: 10),
        const Radius.circular(5)));
    canvas.drawPath(path, paint);
    // Center dots
    canvas.drawCircle(Offset(-3 + _jitter(rng), _jitter(rng)), 1.2, paint);
    canvas.drawCircle(Offset(3 + _jitter(rng), _jitter(rng)), 1.2, paint);
  }

  /// Draws a sketchy stethoscope
  void _drawSketchyStethoscope(Canvas canvas, Paint paint, math.Random rng) {
    final path = Path();
    // Ear tubes
    path.moveTo(-5 + _jitter(rng), -10 + _jitter(rng));
    path.quadraticBezierTo(-6 + _jitter(rng), 0 + _jitter(rng),
        0 + _jitter(rng), 5 + _jitter(rng));
    path.moveTo(5 + _jitter(rng), -10 + _jitter(rng));
    path.quadraticBezierTo(
        6 + _jitter(rng), 0 + _jitter(rng), 0 + _jitter(rng), 5 + _jitter(rng));
    // Tube down
    path.moveTo(0 + _jitter(rng), 5 + _jitter(rng));
    path.lineTo(0 + _jitter(rng), 12 + _jitter(rng));
    canvas.drawPath(path, paint);
    // Chest piece (circle at bottom)
    canvas.drawCircle(Offset(0 + _jitter(rng), 14 + _jitter(rng)), 4, paint);
  }

  double _jitter(math.Random rng) => (rng.nextDouble() - 0.5) * 2.5;

  @override
  bool shouldRepaint(covariant MedicalDoodlePainter old) =>
      old.animationValue != animationValue || old.color != color;
}

/// Painter for the syringe injection animation on the login button.
/// Shows a syringe that "injects" as the user presses login.
class SyringeInjectionPainter extends CustomPainter {
  final double progress; // 0.0 = plunger up, 1.0 = fully pressed
  final Color liquidColor;
  final Color barrelColor;

  SyringeInjectionPainter({
    required this.progress,
    required this.liquidColor,
    required this.barrelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final barrelPaint = Paint()
      ..color = barrelColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final liquidPaint = Paint()
      ..color = liquidColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final needlePaint = Paint()
      ..color = barrelColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Syringe barrel dimensions
    final barrelW = 28.0;
    final barrelH = size.height * 0.55;
    final barrelTop = cy - barrelH / 2;
    final barrelLeft = cx - barrelW / 2;

    // Draw barrel outline
    final barrelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(barrelLeft, barrelTop, barrelW, barrelH),
      const Radius.circular(4),
    );
    canvas.drawRRect(barrelRect, barrelPaint);

    // Liquid fill (fills from bottom, empties as progress increases)
    final liquidHeight = barrelH * (1.0 - progress) * 0.85;
    if (liquidHeight > 0) {
      final liquidRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          barrelLeft + 2,
          barrelTop + barrelH - liquidHeight - 2,
          barrelW - 4,
          liquidHeight,
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(liquidRect, liquidPaint);
    }

    // Plunger (moves down with progress)
    final plungerY = barrelTop + (barrelH * 0.85 * progress);
    // Plunger rod
    canvas.drawLine(
      Offset(cx, barrelTop - 12),
      Offset(cx, plungerY),
      barrelPaint,
    );
    // Plunger handle (T-bar at top)
    canvas.drawLine(
      Offset(cx - 12, barrelTop - 12),
      Offset(cx + 12, barrelTop - 12),
      Paint()
        ..color = barrelColor
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round,
    );
    // Plunger disc
    canvas.drawLine(
      Offset(barrelLeft + 3, plungerY),
      Offset(barrelLeft + barrelW - 3, plungerY),
      Paint()
        ..color = barrelColor
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Needle
    final needleTop = barrelTop + barrelH;
    final needleBottom = needleTop + 16;
    canvas.drawLine(
      Offset(cx, needleTop),
      Offset(cx, needleBottom),
      needlePaint,
    );

    // Tick marks on barrel
    for (int i = 1; i <= 4; i++) {
      final y = barrelTop + (barrelH / 5) * i;
      canvas.drawLine(
        Offset(barrelLeft, y),
        Offset(barrelLeft + 5, y),
        Paint()
          ..color = barrelColor.withValues(alpha: 0.4)
          ..strokeWidth = 0.8,
      );
    }

    // Drip from needle (appears when progress > 0.8)
    if (progress > 0.8) {
      final dripProgress = (progress - 0.8) / 0.2;
      final dripY = needleBottom + 4 + (dripProgress * 10);
      canvas.drawCircle(
        Offset(cx, dripY),
        2.0 * dripProgress,
        Paint()
          ..color = liquidColor.withValues(alpha: 0.6 * (1.0 - dripProgress)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant SyringeInjectionPainter old) =>
      old.progress != progress ||
      old.liquidColor != liquidColor ||
      old.barrelColor != barrelColor;
}

/// Draws a rough, hand-sketched border around a widget area.
/// Intentionally wobbly to look human-drawn.
class SketchyBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  SketchyBorderPainter({required this.color, this.strokeWidth = 1.5});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(17);
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final jitterAmt = 2.0;

    double j() => (rng.nextDouble() - 0.5) * jitterAmt;

    // Top edge
    path.moveTo(j(), j());
    for (double x = 0; x < w; x += w / 8) {
      path.lineTo(x + j(), j());
    }
    path.lineTo(w + j(), j());

    // Right edge
    for (double y = 0; y < h; y += h / 6) {
      path.lineTo(w + j(), y + j());
    }
    path.lineTo(w + j(), h + j());

    // Bottom edge
    for (double x = w; x > 0; x -= w / 8) {
      path.lineTo(x + j(), h + j());
    }
    path.lineTo(j(), h + j());

    // Left edge
    for (double y = h; y > 0; y -= h / 6) {
      path.lineTo(j(), y + j());
    }
    path.lineTo(j(), j());

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SketchyBorderPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

/// Background painter: dark with subtle "notebook" ruled lines and
/// scattered small doodle marks for a human, hand-notated feel.
class NotebookBackgroundPainter extends CustomPainter {
  final Color lineColor;
  final double animationValue;

  NotebookBackgroundPainter(
      {required this.lineColor, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.4;

    // Horizontal ruled lines
    const spacing = 32.0;
    for (double y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Left margin line
    final marginPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.3)
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(40, 0), Offset(40, size.height), marginPaint);
  }

  @override
  bool shouldRepaint(covariant NotebookBackgroundPainter old) =>
      old.lineColor != lineColor || old.animationValue != animationValue;
}
