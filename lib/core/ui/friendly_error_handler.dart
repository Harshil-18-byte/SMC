import 'package:flutter/material.dart';
import 'package:smc/core/ui/hand_drawn_illustration.dart';

// Friendly Error Handler
class FriendlyErrorHandler extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const FriendlyErrorHandler(
      {super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    String title;
    String message;

    // Simple error matching
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Network')) {
      title = "Can't reach the server";
      message = "Looks like your internet is playing hide and seek 🙈\n\n"
          "Things to try:\n"
          "• Check your Wi-Fi/mobile data\n"
          "• Move to an area with better signal\n"
          "• Try again in a minute";
    } else if (error.toString().contains('Auth')) {
      title = "Hmm, that didn't work";
      message = "Your session might have expired.\n"
          "Let's log you in again to keep things secure 🔐";
    } else {
      title = "Oops! Something went wrong";
      message = "This is on us, not you.\n\n"
          "We've been notified and are looking into it.\n"
          "Reference ID: ${_generateRefID()}";
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomIllustration(type: 'error', size: 180),
            const SizedBox(height: 32),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.6,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _generateRefID() {
    return DateTime.now().millisecondsSinceEpoch.toString().substring(8);
  }
}


