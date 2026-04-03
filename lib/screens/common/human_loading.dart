import 'package:flutter/material.dart';
import 'dart:async';
import 'package:smc/core/ui/hand_drawn_illustration.dart';

/// Human Loading
/// A loading indicator that communicates progress with friendly messages
class HumanLoading extends StatefulWidget {
  final List<String>? messages;
  final Duration interval;

  const HumanLoading({
    super.key,
    this.messages,
    this.interval = const Duration(seconds: 2),
  });

  @override
  State<HumanLoading> createState() => _HumanLoadingState();
}

class _HumanLoadingState extends State<HumanLoading>
    with SingleTickerProviderStateMixin {
  late List<String> _messages;
  String _currentMessage = '';
  int _messageIndex = 0;
  Timer? _timer;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _messages = widget.messages ??
        [
          "Connecting to server...",
          "Fetching your updates...",
          "Almost there...",
          "Just a moment...",
        ];
    _currentMessage = _messages[0];
    _startMessageCycle();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  void _startMessageCycle() {
    _timer = Timer.periodic(widget.interval, (timer) {
      if (!mounted) return;
      if (_messageIndex < _messages.length - 1) {
        setState(() {
          _messageIndex++;
          _currentMessage = _messages[_messageIndex];
        });
      } else {
        setState(() {
          _messageIndex = 1;
          _currentMessage = _messages[_messageIndex];
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hand-drawn sketchy loader with rotation
          RotationTransition(
            turns: _rotationController,
            child: const CustomIllustration(
              type: 'loading',
              size: 80,
            ),
          ),
          const SizedBox(height: 32),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _currentMessage,
                key: ValueKey<String>(_currentMessage),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


