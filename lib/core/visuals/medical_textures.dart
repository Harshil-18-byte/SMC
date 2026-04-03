import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A subtle noise/grain texture overlay to make digital screens feel like
/// physical paper, cardboard, or matte medical folders.
class PaperGrainPainter extends CustomPainter {
  final double opacity;
  final Color color;

  PaperGrainPainter({this.opacity = 0.04, this.color = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    // Use a fixed seed for consistent noise pattern, avoids flickering
    final rng = math.Random(12345);
    final width = size.width.toInt();
    final height = size.height.toInt();

    // To prevent severe performance issues, we draw noise in a grid
    // rather than pixel-by-pixel for the entire screen.
    const int step = 3;
    for (int y = 0; y < height; y += step) {
      for (int x = 0; x < width; x += step) {
        if (rng.nextDouble() > 0.5) {
          canvas.drawRect(
              Rect.fromLTWH(x.toDouble(), y.toDouble(), 1.5, 1.5), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant PaperGrainPainter old) =>
      old.opacity != opacity || old.color != color;
}

/// A widget that wraps its child with a subtle paper texture overlay.
/// Best used as the root background of a Scaffold.
class PaperTextureBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const PaperTextureBackground(
      {super.key, required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: PaperGrainPainter(
                opacity: isDark ? 0.05 : 0.03,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A decorative clipboard clip that can be placed at the top of a card or drawer
class ClipboardClipDecoration extends StatelessWidget {
  final bool isDark;

  const ClipboardClipDecoration({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final metalColor =
        isDark ? const Color(0xFF6B6560) : const Color(0xFF9A938C);
    final highlight = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.5);

    return Container(
      width: 120,
      height: 24,
      decoration: BoxDecoration(
        color: metalColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 3),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Metal highlight
          Positioned(
            top: 2,
            left: 2,
            right: 2,
            height: 4,
            child: Container(
              decoration: BoxDecoration(
                color: highlight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Clip hinge details
          Positioned(
            top: 10,
            left: 20,
            child: _buildRivet(isDark),
          ),
          Positioned(
            top: 10,
            right: 20,
            child: _buildRivet(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildRivet(bool isDark) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF4A4440) : const Color(0xFF6B6560),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 2,
          ),
        ],
      ),
    );
  }
}
