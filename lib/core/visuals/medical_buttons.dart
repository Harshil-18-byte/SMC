import 'package:flutter/material.dart';

/// A button that acts like a solid medical rubber stamp hitting paper.
/// When pressed, it shrinks slightly and shows a "stamped" shadow.
class RubberStampButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color color;
  final bool isDestructive;
  final double width;
  final double height;
  final EdgeInsets padding;

  const RubberStampButton({
    super.key,
    required this.child,
    required this.onTap,
    required this.color,
    this.isDestructive = false,
    this.width = double.infinity,
    this.height = 56.0,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
  });

  @override
  State<RubberStampButton> createState() => _RubberStampButtonState();
}

class _RubberStampButtonState extends State<RubberStampButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    // Shrinks down to mimic pressing into paper
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Very subtle rotation to mimic an imperfect hand stamp
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.015).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final isPressed = _controller.value > 0;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(
                _scaleAnimation.value, _scaleAnimation.value, 1.0)
              ..rotateZ(_rotationAnimation.value),
            child: Container(
              width: widget.width,
              height: widget.height,
              padding: widget.padding,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: isPressed ? 0.9 : 1.0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.5),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        widget.color.withValues(alpha: isPressed ? 0.4 : 0.15),
                    blurRadius: isPressed ? 4 : 8,
                    offset: Offset(0, isPressed ? 2 : 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
