import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smc/data/services/auth_service.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/core/ui/imperfect_shapes.dart';
import 'package:smc/core/ui/hand_drawn_illustration.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/core/localization/app_localizations.dart';
import 'package:smc/core/widgets/smc_back_button.dart';

class CitizenSOSScreen extends StatefulWidget {
  const CitizenSOSScreen({super.key});

  @override
  State<CitizenSOSScreen> createState() => _CitizenSOSScreenState();
}

class _CitizenSOSScreenState extends State<CitizenSOSScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  bool _isSOSActive = false;
  bool _isTransmitting = false;
  String _statusMessage = ''; // Initialize in didChangeDependencies
  Timer? _holdTimer;
  int _holdDuration = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_statusMessage.isEmpty) {
      _statusMessage = AppLocalizations.of(context).translate('hold_sos');
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  void _onSOSPressDown() {
    if (_isSOSActive) return;

    _holdDuration = 0;
    _holdTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _holdDuration += 100;
        double progress = _holdDuration / 3000;
        if (progress > 1.0) progress = 1.0;
      });

      if (_holdDuration >= 3000) {
        timer.cancel();
        _triggerSOS();
      }
    });
  }

  void _onSOSPressUp() {
    if (_isSOSActive) return;
    _holdTimer?.cancel();
    setState(() {
      _holdDuration = 0;
    });
  }

  Future<void> _triggerSOS() async {
    setState(() {
      _isSOSActive = true;
      _isTransmitting = true;
      _statusMessage = 'Acquiring GPS Location...';
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() => _statusMessage = 'Transmitting Alert...');

      final user = _authService.currentUser;
      final sosData = {
        'citizenId': user?.uid ?? 'anonymous',
        'citizenName': user?.displayName ?? 'Guest User',
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
        'type': 'medical_emergency',
        'batteryLevel': 85, // Mock
      };

      await _firestoreService.createDocument(
        collection: 'emergency_alerts',
        data: sosData,
      );

      setState(() {
        _isTransmitting = false;
        _statusMessage = AppLocalizations.of(context).translate('sos_sent');
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSOSActive = false;
          _isTransmitting = false;
          _statusMessage = 'Failed to send SOS. Try again.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _cancelSOS() {
    // In a real app, this would update the backend to cancel the alert
    setState(() {
      _isSOSActive = false;
      _statusMessage = AppLocalizations.of(context).translate('hold_sos');
      _holdDuration = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_holdDuration / 3000).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: _isSOSActive
          ? const Color(0xFFfee2e2)
          : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const SMCBackButton(iconColor: Colors.red),
        title: Text(
          AppLocalizations.of(context).translate('emergency_sos_title'),
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.red),
        backgroundColor: Colors.transparent,
        actions: const [ThemeSwitcher()],
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Ripple/Progress Effect
                if (!_isSOSActive)
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.red),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),

                // SOS Button
                GestureDetector(
                  onTapDown: (_) => _onSOSPressDown(),
                  onTapUp: (_) => _onSOSPressUp(),
                  onTapCancel: _onSOSPressUp,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _isSOSActive
                            ? [Colors.red.shade700, Colors.red.shade900]
                            : [Colors.red.shade500, Colors.red.shade700],
                      ),
                      shape: ImperfectCircleBorder(
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 4,
                        ),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.5),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sos_rounded,
                            size: 80, color: Colors.white),
                        if (_isSOSActive && _isTransmitting)
                          const SizedBox(height: 16)
                        else if (!_isSOSActive)
                          Text(
                            'HOLD 3S',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        if (_isTransmitting)
                          const CustomIllustration(
                            type: 'loading',
                            size: 40,
                            color: Colors.white,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isSOSActive ? Colors.red[900] : Colors.grey[600],
              ),
            ),
            if (_isSOSActive && !_isTransmitting) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: 200,
                height: 56,
                child: ElevatedButton(
                  onPressed: _cancelSOS,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).translate('cancel_alert'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 100), // Spacing
          ],
        ),
      ),
    );
  }
}
