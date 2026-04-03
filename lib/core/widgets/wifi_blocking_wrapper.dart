import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:smc/core/services/network_validator_service.dart';

/// A wrapper widget that blocks the UI if WiFi is connected.
/// Forces users to use mobile data.
class WiFiBlockingWrapper extends StatelessWidget {
  final Widget child;

  const WiFiBlockingWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: NetworkValidatorService.connectivityStream,
      initialData: const [], // Default to empty list, matching stream type
      builder: (context, snapshot) {
        // If snapshot has data, use it. Otherwise, we can't be sure yet.
        // But for better UX, we should check the current status once.
        bool isWiFi = false;

        if (snapshot.hasData) {
          isWiFi = snapshot.data!.contains(ConnectivityResult.wifi);
        } else {
          // While waiting for stream, we can't assume.
          // In a real app, we might want to check Connectivity().checkConnectivity()
          // but that's async.
        }

        return Stack(
          children: [
            child,
            if (isWiFi)
              Container(
                color: Colors.black.withValues(alpha: 0.85),
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          color: Colors.orange,
                          size: 80,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'WiFi Connection Restricted',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'For security and accurate tracking, this app requires mobile data. Please disable WiFi in your settings to proceed.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.orange),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Waiting for mobile data...',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          onPressed: () {
                            // In a real app, this could open settings
                            // For now, we just wait for the stream to update
                          },
                          icon: const Icon(Icons.settings),
                          label: const Text('Open Settings'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}


