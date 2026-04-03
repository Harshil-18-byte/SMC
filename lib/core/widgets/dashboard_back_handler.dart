import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smc/core/localization/app_localizations.dart';

/// Wrapper widget to handle back button behavior for main dashboard screens
/// Prevents accidental app closure by showing a confirmation dialog
class DashboardBackHandler extends StatelessWidget {
  final Widget child;
  final String? dashboardName;

  const DashboardBackHandler({
    super.key,
    required this.child,
    this.dashboardName,
  });

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              AppLocalizations.of(context).exitAppTitle,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            content: Text(
              AppLocalizations.of(context).exitAppMessage,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  AppLocalizations.of(context).cancel,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context).exit,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Intercept to show confirmation or handle internal pop
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final navigator = Navigator.of(context);

        // If we can pop internally (sub-pages), do it.
        if (navigator.canPop()) {
          navigator.pop();
        } else {
          // At root dashboard, show exit confirmation
          final shouldExit = await _showExitDialog(context);
          if (shouldExit && context.mounted) {
            SystemNavigator.pop();
          }
        }
      },
      child: child,
    );
  }
}


