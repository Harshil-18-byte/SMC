import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Painter for the subtle pattern background on unlocked achievements
class PatternPainter extends CustomPainter {
  final Color color;

  PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const spacing = 20.0;
    for (var i = -size.height; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, size.height),
        Offset(i + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(PatternPainter oldDelegate) => oldDelegate.color != color;
}

/// Painter for the particle explosion effect
class ParticleExplosionPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  final List<ExplosionParticle> _particles;

  ParticleExplosionPainter({
    required this.animation,
    required this.color,
  })  : _particles = List.generate(50, (index) => ExplosionParticle()),
        super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in _particles) {
      final progress = animation.value;
      if (progress < particle.delay) continue;

      final particleProgress =
          (progress - particle.delay) / (1.0 - particle.delay);
      if (particleProgress > 1.0) continue;

      final distance = particle.speed * particleProgress * size.width;
      final alpha = (1.0 - particleProgress).clamp(0.0, 1.0);

      final x = center.dx + math.cos(particle.angle) * distance;
      final y = center.dy + math.sin(particle.angle) * distance;

      paint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(
          Offset(x, y), particle.size * (1 - particleProgress), paint);
    }
  }

  @override
  bool shouldRepaint(ParticleExplosionPainter oldDelegate) => true;
}

class ExplosionParticle {
  final double angle = math.Random().nextDouble() * 2 * math.pi;
  final double speed = math.Random().nextDouble() * 0.5 + 0.2;
  final double size = math.Random().nextDouble() * 6 + 2;
  final double delay = math.Random().nextDouble() * 0.2;
}


