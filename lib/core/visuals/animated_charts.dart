import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBarChart extends StatefulWidget {
  final List<double> data;
  final List<String> labels;
  final Color barColor;
  final double height;

  const AnimatedBarChart({
    super.key,
    required this.data,
    required this.labels,
    this.barColor = Colors.blueAccent,
    this.height = 200,
  });

  @override
  State<AnimatedBarChart> createState() => _AnimatedBarChartState();
}

class _AnimatedBarChartState extends State<AnimatedBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: BarChartPainter(
              data: widget.data,
              labels: widget.labels,
              progress: _animation.value,
              color: widget.barColor,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class BarChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final double progress;
  final Color color;

  BarChartPainter({
    required this.data,
    required this.labels,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final textStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.7),
      fontSize: 10,
    );

    final barWidth = size.width / (data.length * 2);
    final spacing = size.width / data.length;
    final maxData = data.reduce(math.max);

    for (int i = 0; i < data.length; i++) {
      final value = data[i];
      final barHeight = (value / maxData) * size.height * 0.8 * progress;
      final x = i * spacing + spacing / 2 - barWidth / 2;
      final y = size.height - 20; // Reserve space for labels

      // Draw Bar with Gradient
      final rect = Rect.fromLTWH(x, y - barHeight, barWidth, barHeight);
      final gradient = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          color.withValues(alpha: 0.5),
          color,
        ],
      );
      paint.shader = gradient.createShader(rect);

      // Rounded top corners
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        paint,
      );

      // Draw Label
      if (progress > 0.8) {
        final textSpan = TextSpan(text: labels[i], style: textStyle);
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        textPainter.layout(minWidth: barWidth);
        textPainter.paint(
          canvas,
          Offset(x, size.height - 15),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant BarChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.data != data;
  }
}

class AnimatedLineChart extends StatefulWidget {
  final List<double> data;
  final Color lineColor;
  final double height;

  const AnimatedLineChart({
    super.key,
    required this.data,
    this.lineColor = Colors.greenAccent,
    this.height = 150,
  });

  @override
  State<AnimatedLineChart> createState() => _AnimatedLineChartState();
}

class _AnimatedLineChartState extends State<AnimatedLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutQuart,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: LineChartPainter(
              data: widget.data,
              progress: _animation.value,
              color: widget.lineColor,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> data;
  final double progress;
  final Color color;

  LineChartPainter({
    required this.data,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final spacing = size.width / (data.length - 1);
    final maxData = data.reduce(math.max);
    final minData = data.reduce(math.min);
    final range = maxData - minData;

    // Build the full path first
    final fullPath = Path();
    for (int i = 0; i < data.length; i++) {
      final value = data[i];
      final normalizedValue = range == 0 ? 0.5 : (value - minData) / range;
      final x = i * spacing;
      final y = size.height - (normalizedValue * size.height * 0.8) - 10;

      if (i == 0) {
        fullPath.moveTo(x, y);
      } else {
        // Cubic bezier for smoothness
        final prevValue = data[i - 1];
        final prevNormalized = range == 0 ? 0.5 : (prevValue - minData) / range;
        final prevX = (i - 1) * spacing;
        final prevY = size.height - (prevNormalized * size.height * 0.8) - 10;

        final controlPoint1 = Offset(prevX + spacing / 2, prevY);
        final controlPoint2 = Offset(prevX + spacing / 2, y);

        fullPath.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx,
            controlPoint2.dy, x, y);
      }
    }

    // Extract sub-path based on progress
    // Since PathMetrics can be expensive, for simple usage we can just clip or use metrics
    final pathMetrics = fullPath.computeMetrics();
    for (final metric in pathMetrics) {
      final extractPath = metric.extractPath(0.0, metric.length * progress);
      canvas.drawPath(extractPath, paint);

      // Draw gradient under the line
      if (progress > 0.1) {
        final fillPath = Path.from(extractPath);
        fillPath.lineTo(
            metric
                .extractPath(0.0, metric.length * progress)
                .getBounds()
                .centerRight
                .dx,
            size.height);
        fillPath.lineTo(0, size.height);
        fillPath.close();

        final fillPaint = Paint()
          ..style = PaintingStyle.fill
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.3),
              color.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

        canvas.drawPath(fillPath, fillPaint);
      }
    }

    // Draw dots at points
    if (progress > 0.9) {
      final dotPaint = Paint()..color = Colors.white;
      for (int i = 0; i < data.length; i++) {
        final value = data[i];
        final normalizedValue = range == 0 ? 0.5 : (value - minData) / range;
        final x = i * spacing;
        final y = size.height - (normalizedValue * size.height * 0.8) - 10;

        canvas.drawCircle(Offset(x, y), 4, dotPaint);

        // Create border paint
        final borderPaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        canvas.drawCircle(Offset(x, y), 4, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.data != data;
  }
}


