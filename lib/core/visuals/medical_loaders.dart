import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

/// A custom loader that draws an animated ECG heartbeat line instead
/// of a standard circular progress indicator.
class ECGLoader extends StatefulWidget {
  final Color? color;
  final double width;
  final double height;
  final String? message;

  const ECGLoader({
    super.key,
    this.color,
    this.width = 120,
    this.height = 40,
    this.message,
  });

  @override
  State<ECGLoader> createState() => _ECGLoaderState();
}

class _ECGLoaderState extends State<ECGLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.color ?? Theme.of(context).primaryColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: Size(widget.width, widget.height),
              painter: _ECGLoaderPainter(
                progress: _controller.value,
                color: themeColor,
              ),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 12),
          FadeIn(
            duration: const Duration(milliseconds: 800),
            child: Text(
              widget.message!,
              style: TextStyle(
                color: themeColor.withValues(alpha: 0.8),
                fontSize: 13,
                fontFamily: 'Caveat',
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ]
      ],
    );
  }
}

class _ECGLoaderPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ECGLoaderPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // We draw a fixed faint ECG line, and a bright "pulse" traveling over it
    final paintBase = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final paintGlow = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final midY = size.height / 2;
    final w = size.width;
    final h = size.height;

    path.moveTo(0, midY);
    path.lineTo(w * 0.2, midY);
    path.lineTo(w * 0.25, midY - h * 0.15);
    path.lineTo(w * 0.3, midY + h * 0.1);
    path.lineTo(w * 0.35, midY);
    path.lineTo(w * 0.45, midY);

    // Main spike
    path.lineTo(w * 0.48, midY - h * 0.4);
    path.lineTo(w * 0.52, midY + h * 0.35);
    path.lineTo(w * 0.55, midY - h * 0.1);
    path.lineTo(w * 0.58, midY);

    path.lineTo(w * 0.7, midY);

    // Small T wave
    path.quadraticBezierTo(w * 0.75, midY - h * 0.15, w * 0.8, midY);

    path.lineTo(w, midY);

    // Draw faint base path
    canvas.drawPath(path, paintBase);

    // Calculate path metrics to draw only a segment of the path based on progress

    // We want the pulse to be a fraction of the total length
    try {
      final metrics = path.computeMetrics().toList();
      if (metrics.isEmpty) return;

      final metric = metrics.first;
      final totalLength = metric.length;
      final pulseLength = totalLength * 0.25;

      // Progress from 0 to 1, but we want the pulse to travel entirely through
      // so we map progress to start point from -pulseLength to totalLength
      final start = -pulseLength + (totalLength + pulseLength * 2) * progress;
      final end = start + pulseLength;

      // Clamp values
      final extractStart = start.clamp(0.0, totalLength);
      final extractEnd = end.clamp(0.0, totalLength);

      if (extractEnd > extractStart) {
        final extractPath = metric.extractPath(extractStart, extractEnd);
        canvas.drawPath(extractPath, paintGlow);

        // Draw a glowing dot at the head of the pulse
        final headPos = metric.getTangentForOffset(extractEnd)?.position;
        if (headPos != null) {
          canvas.drawCircle(
              headPos,
              3.5,
              Paint()
                ..color = color
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
          canvas.drawCircle(headPos, 1.5, Paint()..color = Colors.white);
        }
      }
    } catch (_) {
      // Fallback
    }
  }

  @override
  bool shouldRepaint(covariant _ECGLoaderPainter old) =>
      old.progress != progress || old.color != color;
}
