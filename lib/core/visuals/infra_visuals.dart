import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

/// Draws scattered technical blueprint doodles across the background.
/// Engineering symbols, structural beams, bolts, and cranes.
class InfraBlueprintPainter extends CustomPainter {
  final Color color;
  final double animationValue;

  InfraBlueprintPainter({required this.color, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(88); // Deterministic seed

    final technicalPaint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    for (int i = 0; i < 15; i++) {
      final cx = rng.nextDouble() * size.width;
      final cy = rng.nextDouble() * size.height;
      final floatY = math.sin(animationValue * 2 * math.pi + i * 0.5) * 5;

      canvas.save();
      canvas.translate(cx, cy + floatY);
      canvas.rotate((i % 4) * (math.pi / 2)); // Orthogonal rotations

      final type = i % 5;
      switch (type) {
        case 0:
          _drawIBeam(canvas, technicalPaint);
          break;
        case 1:
          _drawBolt(canvas, technicalPaint);
          break;
        case 2:
          _drawCraneSimple(canvas, technicalPaint);
          break;
        case 3:
          _drawCompass(canvas, technicalPaint);
          break;
        case 4:
          _drawGridMark(canvas, technicalPaint);
          break;
      }
      canvas.restore();
    }
  }

  void _drawIBeam(Canvas canvas, Paint paint) {
    const w = 30.0;
    const h = 10.0;
    canvas.drawRect(const Rect.fromLTWH(-w / 2, -h / 2, w, 2), paint);
    canvas.drawRect(const Rect.fromLTWH(-w / 2, h / 2 - 2, w, 2), paint);
    canvas.drawLine(const Offset(0, -h / 2), const Offset(0, h / 2), paint);
  }

  void _drawBolt(Canvas canvas, Paint paint) {
    canvas.drawCircle(Offset.zero, 6, paint);
    canvas.drawLine(const Offset(-4, -4), const Offset(4, 4), paint);
  }

  void _drawCraneSimple(Canvas canvas, Paint paint) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, -20);
    path.lineTo(15, -20);
    path.moveTo(0, -15);
    path.lineTo(-10, 0);
    canvas.drawPath(path, paint);
  }

  void _drawCompass(Canvas canvas, Paint paint) {
    canvas.drawCircle(Offset.zero, 8, paint);
    canvas.drawLine(const Offset(0, -12), const Offset(0, 12), paint);
    canvas.drawLine(const Offset(-12, 0), const Offset(12, 0), paint);
  }

  void _drawGridMark(Canvas canvas, Paint paint) {
    const s = 10.0;
    canvas.drawLine(const Offset(-s, 0), const Offset(s, 0), paint);
    canvas.drawLine(const Offset(0, -s), const Offset(0, s), paint);
  }

  @override
  bool shouldRepaint(covariant InfraBlueprintPainter old) =>
      old.animationValue != animationValue || old.color != color;
}

/// Tech-focused progress painter for the login button.
/// Shows a "Blueprint Scan" line or structural build-up.
class AuthProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  AuthProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Build-up rectangle
    final rect = Rect.fromLTWH(0, h * (1 - progress), w, h * progress);
    canvas.drawRect(rect, fillPaint);
    
    // Scanning line
    final scanY = h * (1 - progress);
    canvas.drawLine(Offset(0, scanY), Offset(w, scanY), paint);

    // Structural "corner" marks
    const cs = 5.0;
    canvas.drawLine(Offset.zero, const Offset(cs, 0), paint);
    canvas.drawLine(Offset.zero, const Offset(0, cs), paint);
    canvas.drawLine(Offset(w, 0), Offset(w - cs, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, cs), paint);
  }

  @override
  bool shouldRepaint(covariant AuthProgressPainter old) => old.progress != progress;
}

/// Engineering Grid Background Painter.
class GridBackgroundPainter extends CustomPainter {
  final Color gridColor;
  final double opacity;

  GridBackgroundPainter({required this.gridColor, this.opacity = 0.05});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor.withValues(alpha: opacity)
      ..strokeWidth = 0.5;

    const step = 25.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Secondary coarser grid
    final coarsePaint = Paint()
      ..color = gridColor.withValues(alpha: opacity * 2)
      ..strokeWidth = 1.0;
    const coarseStep = step * 5;
    for (double x = 0; x < size.width; x += coarseStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), coarsePaint);
    }
    for (double y = 0; y < size.height; y += coarseStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), coarsePaint);
    }
  }

  @override
  bool shouldRepaint(covariant GridBackgroundPainter old) => old.gridColor != gridColor;
}

/// A technical background widget with grain and grid lines.
class InfraGridBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const InfraGridBackground({super.key, required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: GridBackgroundPainter(
              gridColor: isDark ? Colors.blue : Colors.blueGrey,
              opacity: isDark ? 0.05 : 0.02,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// A heavy-duty industrial action button.
/// Replaces the medical "RubberStampButton".
class IndustrialActionButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color color;
  final double width;
  final double height;

  const IndustrialActionButton({
    super.key,
    required this.child,
    required this.onTap,
    this.color = Colors.blue,
    this.width = 160,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Center(
          child: DefaultTextStyle(
            style: GoogleFonts.outfit(
              color: color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
