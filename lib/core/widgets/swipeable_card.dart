import 'package:flutter/material.dart';

enum SwipeDirection { left, right, up, down }

class SwipeableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;

  const SwipeableCard({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _rotationAnimation;

  Offset _dragOffset = Offset.zero;
  double _dragRotation = 0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_controller);

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(_controller);

    _controller.addListener(() {
      setState(() {
        if (_isAnimating) {
          _dragOffset = _offsetAnimation.value;
          _dragRotation = _rotationAnimation.value;
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine overlay content based on drag position
    Widget? overlay;
    if (_dragOffset.dx > 50) {
      overlay = _buildOverlay(
          'ACCEPT', Colors.green.withValues(alpha: 0.9), Icons.check_circle);
    } else if (_dragOffset.dx < -50) {
      overlay = _buildOverlay(
          'REJECT', Colors.red.withValues(alpha: 0.9), Icons.cancel);
    } else if (_dragOffset.dy < -50) {
      overlay = _buildOverlay('PRIORITY', Colors.orange.withValues(alpha: 0.9),
          Icons.priority_high);
    }

    return GestureDetector(
      onPanStart: (details) {
        if (_isAnimating) return;
        _controller.stop();
      },
      onPanUpdate: (details) {
        if (_isAnimating) return;
        setState(() {
          _dragOffset += details.delta;
          _dragRotation = _dragOffset.dx / 1000; // Subtle rotation
        });
      },
      onPanEnd: (details) {
        if (_isAnimating) return;
        _handleSwipeEnd(details.velocity);
      },
      child: Transform.translate(
        offset: _dragOffset,
        child: Transform.rotate(
          angle: _dragRotation,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: widget.child,
                ),
              ),
              if (overlay != null) Positioned.fill(child: overlay),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(String label, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSwipeEnd(Velocity velocity) {
    final double velocityX = velocity.pixelsPerSecond.dx;
    final double velocityY = velocity.pixelsPerSecond.dy;
    const double swipeThreshold = 100.0;
    const double velocityThreshold = 500.0;

    SwipeDirection? direction;

    // Determine direction based on drag distance and velocity
    if (_dragOffset.dx > swipeThreshold || velocityX > velocityThreshold) {
      direction = SwipeDirection.right;
    } else if (_dragOffset.dx < -swipeThreshold ||
        velocityX < -velocityThreshold) {
      direction = SwipeDirection.left;
    } else if (_dragOffset.dy < -swipeThreshold ||
        velocityY < -velocityThreshold) {
      direction = SwipeDirection.up;
    }

    if (direction != null) {
      _animateSwipeOut(direction);
    } else {
      _resetPosition();
    }
  }

  void _animateSwipeOut(SwipeDirection direction) {
    _isAnimating = true;
    Offset targetOffset;
    double targetRotation = _dragRotation;

    final Size screenSize = MediaQuery.of(context).size;

    switch (direction) {
      case SwipeDirection.left:
        targetOffset = Offset(-screenSize.width * 1.5, _dragOffset.dy);
        targetRotation = -0.5;
        break;
      case SwipeDirection.right:
        targetOffset = Offset(screenSize.width * 1.5, _dragOffset.dy);
        targetRotation = 0.5;
        break;
      case SwipeDirection.up:
        targetOffset = Offset(_dragOffset.dx, -screenSize.height * 1.5);
        break;
      default:
        targetOffset = Offset.zero;
    }

    _offsetAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: targetOffset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _rotationAnimation = Tween<double>(
      begin: _dragRotation,
      end: targetRotation,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward(from: 0).then((_) {
      _isAnimating = false;
      // Trigger callback
      switch (direction) {
        case SwipeDirection.left:
          widget.onSwipeLeft?.call();
          break;
        case SwipeDirection.right:
          widget.onSwipeRight?.call();
          break;
        case SwipeDirection.up:
          widget.onSwipeUp?.call();
          break;
        default:
          break;
      }
      // Reset position immediately after callback so the card comes back
      // In a real app, the parent would likely remove this card from the tree
      // But for reuse, we reset.
      setState(() {
        _dragOffset = Offset.zero;
        _dragRotation = 0;
      });
    });
  }

  void _resetPosition() {
    _isAnimating = true;
    _offsetAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: _dragRotation,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward(from: 0).then((_) {
      _isAnimating = false;
    });
  }
}


