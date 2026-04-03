import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:smc/data/models/auth_models.dart';
import 'package:smc/config/routes.dart';
import 'package:smc/data/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:smc/core/services/user_service.dart';
import 'package:smc/data/models/user_model.dart';

/// OTP Verification Screen
/// 6-digit numeric input with countdown and attempt tracking
class OTPVerificationScreen extends StatefulWidget {
  final String identifier;
  final UserRole role;

  const OTPVerificationScreen({
    super.key,
    required this.identifier,
    required this.role,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _remainingSeconds = 60;
  int _attemptCount = 0;
  final int _maxAttempts = 3;
  bool _isLocked = false;
  bool _isVerifying = false;
  DateTime? _lockUntil;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _remainingSeconds = 60);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      _showError('Please enter complete 6-digit OTP');
      return;
    }

    if (_isLocked) {
      if (_lockUntil != null && DateTime.now().isAfter(_lockUntil!)) {
        setState(() {
          _isLocked = false;
          _lockUntil = null;
          _attemptCount = 0;
        });
      } else {
        _showError('Account locked. Try again later.');
        return;
      }
    }

    setState(() => _isVerifying = true);

    try {
      final authService = AuthService();
      final isValid = await authService.verifyOTP(widget.identifier, otp);

      if (isValid) {
        if (mounted) {
          // Set user in provider before navigating
          final userProvider = context.read<UserProvider>();
          switch (widget.role) {
            case UserRole.admin:
              userProvider.setUser(User.mockAdmin());
              break;
            case UserRole.fieldWorker:
              userProvider.setUser(User.mockFieldWorker());
              break;
            case UserRole.doctor:
              userProvider.setUser(User.mockDoctor());
              break;
            case UserRole.citizen:
            case UserRole.guest:
              userProvider.setUser(User.mockCitizen());
              break;
          }

          setState(() => _isVerifying = false);
          _navigateToRoleHome();
        }
      } else {
        setState(() {
          _attemptCount++;
          _isVerifying = false;
        });

        if (_attemptCount >= _maxAttempts) {
          setState(() {
            _isLocked = true;
            _lockUntil = DateTime.now().add(const Duration(minutes: 15));
          });
          _showError('Too many attempts. Account locked for 15 minutes.');
        } else {
          _showError(
            'Invalid OTP. ${_maxAttempts - _attemptCount} attempts remaining.',
          );
          _clearOTP();
        }
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      _showError('Verification failed: ${e.toString()}');
    }
  }

  void _navigateToRoleHome() {
    // Navigate based on role
    switch (widget.role) {
      case UserRole.admin:
        // Navigate to Admin Dashboard
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
        break;
      case UserRole.fieldWorker:
        // Navigate to Field Worker Home
        Navigator.pushReplacementNamed(context, AppRoutes.fieldWorkerHome);
        break;
      case UserRole.doctor:
        // Navigate to Hospital Dashboard
        Navigator.pushReplacementNamed(context, AppRoutes.hospitalDashboard);
        break;
      case UserRole.citizen:
        // Navigate to Citizen Home
        Navigator.pushReplacementNamed(context, AppRoutes.citizenHome);
        break;
      case UserRole.guest:
        // Guest also goes to Citizen Home for now
        Navigator.pushReplacementNamed(context, AppRoutes.citizenHome);
        break;
    }
  }

  void _clearOTP() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _resendOTP() async {
    if (_remainingSeconds > 0) {
      _showError('Please wait ${_remainingSeconds}s before resending');
      return;
    }

    try {
      final authService = AuthService();
      await authService.sendOTP(widget.identifier);

      _showSuccess('OTP resent successfully');
      _startTimer();
      _clearOTP();
    } catch (e) {
      _showError('Resend failed: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF4D4D),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 48),
              _buildOTPInput(),
              const SizedBox(height: 32),
              _buildTimer(),
              const SizedBox(height: 24),
              _buildVerifyButton(),
              const SizedBox(height: 16),
              _buildResendButton(),
              if (_isLocked) ...[
                const SizedBox(height: 24),
                _buildLockWarning(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF137fec).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.verified_user,
            size: 40,
            color: Color(0xFF137fec),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Verify OTP',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the 6-digit code sent to',
          style: TextStyle(fontSize: 16, color: Colors.grey[400]),
        ),
        const SizedBox(height: 4),
        Text(
          widget.identifier,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF137fec),
          ),
        ),
      ],
    );
  }

  Widget _buildOTPInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) => _buildOTPBox(index)),
    );
  }

  Widget _buildOTPBox(int index) {
    return SizedBox(
      width: 50,
      height: 60,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        enabled: !_isLocked,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.headlineSmall?.color,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: _isLocked
              ? Theme.of(context).cardColor.withValues(alpha: 0.5)
              : Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF137fec), width: 2),
          ),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }

          // Auto-verify when all 6 digits entered
          if (index == 5 && value.isNotEmpty) {
            _verifyOTP();
          }
        },
      ),
    );
  }

  Widget _buildTimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2733),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2D3748)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer,
            color: _remainingSeconds > 0
                ? const Color(0xFF137fec)
                : Colors.grey[600],
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            _remainingSeconds > 0
                ? 'Code expires in ${_remainingSeconds}s'
                : 'Code expired',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _remainingSeconds > 0
                  ? const Color(0xFF137fec)
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLocked || _isVerifying ? null : _verifyOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF137fec),
          disabledBackgroundColor: Colors.grey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isVerifying
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Verify & Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildResendButton() {
    final canResend = _remainingSeconds == 0 && !_isLocked;

    return TextButton(
      onPressed: canResend ? _resendOTP : null,
      child: Text(
        "Didn't receive code? Resend",
        style: TextStyle(
          fontSize: 14,
          color: canResend ? const Color(0xFF137fec) : Colors.grey[600],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLockWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4D4D).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF4D4D)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock, color: Color(0xFFFF4D4D), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Locked',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF4D4D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Too many failed attempts. Try again after 15 minutes.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


