import 'package:flutter/material.dart';
import 'package:smc/core/visuals/medical_doodle_painters.dart';
import 'dart:math' as math;

/// A card that responds to hover and tap with grounded, solid interactions.
/// No glassmorphism! Uses solid colors, sketchy borders, and crisp shadows.
class MagicCard extends StatefulWidget {
  final Widget child;
  final Color color;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  const MagicCard({
    super.key,
    required this.child,
    required this.color,
    this.onTap,
    this.padding,
  });

  @override
  State<MagicCard> createState() => _MagicCardState();
}

class _MagicCardState extends State<MagicCard> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _tapController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: GestureDetector(
        onTapDown: (_) => _tapController.forward(),
        onTapUp: (_) {
          _tapController.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () => _tapController.reverse(),
        child: AnimatedBuilder(
          animation: Listenable.merge([_hoverController, _tapController]),
          builder: (context, child) {
            // Very subtle organic push down, not wild 3D
            final scale = 1.0 -
                (0.02 * _tapController.value) +
                (0.01 * _hoverController.value);
            // Crisp, solid shadow
            final shadowOffset = 4.0 +
                (4.0 * _hoverController.value) -
                (4.0 * _tapController.value);

            return Transform.scale(
              scale: scale,
              child: CustomPaint(
                foregroundPainter: SketchyBorderPainter(
                  color: widget.color.withValues(alpha: 0.3),
                  strokeWidth: 1.5 + _hoverController.value * 0.5,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                        BorderRadius.circular(10), // Sharp, clean corners
                    border: Border.all(
                      // Solid border instead of glass gradient
                      color: widget.color.withValues(
                          alpha: 0.2 + (0.3 * _hoverController.value)),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.15),
                        blurRadius: shadowOffset,
                        offset: Offset(0, shadowOffset),
                        spreadRadius: 0, // No spread for a crisp drop shadow
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: widget.padding ?? const EdgeInsets.all(24),
                      // Slight tint overlay on hover
                      color: widget.color
                          .withValues(alpha: 0.05 * _hoverController.value),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A field of slow, organic floating particles (dust motes) rather than magical stars
class ParticleField extends StatefulWidget {
  final Color color;
  const ParticleField({super.key, required this.color});

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = List.generate(15, (_) => _Particle());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter:
              _ParticlePainter(_particles, _controller.value, widget.color),
        );
      },
    );
  }
}

class _Particle {
  double x = math.Random().nextDouble();
  double y = math.Random().nextDouble();
  double size = math.Random().nextDouble() * 3 + 1;
  double speedY = math.Random().nextDouble() * 0.05 + 0.02;
  double speedX = (math.Random().nextDouble() - 0.5) * 0.02;
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;

  _ParticlePainter(this.particles, this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    // Very subtle, muted particles like dust motes
    final paint = Paint()..color = color.withValues(alpha: 0.1);
    for (var p in particles) {
      final y = (p.y + progress * p.speedY) % 1.0;
      final x = (p.x + progress * p.speedX) % 1.0;
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}
