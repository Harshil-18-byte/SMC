import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smc/core/providers/notification_provider.dart';

class NotificationBadge extends StatelessWidget {
  final VoidCallback? onTap;

  const NotificationBadge({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                provider.unreadCount > 0
                    ? Icons.notifications_active
                    : Icons.notifications_outlined,
              ),
              onPressed: onTap ??
                  () {
                    Navigator.pushNamed(context, '/notifications');
                  },
            ),
            if (provider.unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    provider.unreadCount > 99
                        ? '99+'
                        : '${provider.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}


