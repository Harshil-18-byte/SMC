import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class MilestoneTracker {
  static void showCelebration(
    BuildContext context, {
    required String title,
    required String message,
    String emoji = '🎉',
  }) {
    // specialized dialog or snackbar
    showDialog(
      context: context,
      builder: (context) => _CelebrationDialog(
        title: title,
        message: message,
        emoji: emoji,
      ),
    );
  }

  static void checkAndCelebrate(BuildContext context, int count) {
    if (count > 0 && count % 5 == 0) {
      showCelebration(
        context,
        title: "Milestone Reached!",
        message: "You have completed $count visits!",
        emoji: "🏆",
      );
    }
  }
}

class _CelebrationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String emoji;

  const _CelebrationDialog({
    required this.title,
    required this.message,
    required this.emoji,
  });

  @override
  State<_CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<_CelebrationDialog> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 3));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.all(32),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.emoji,
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Awesome!'),
              ),
            ],
          ),
        ),
        ConfettiWidget(
          confettiController: _controller,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple
          ],
        ),
      ],
    );
  }
}


