import 'package:flutter/material.dart';
import 'package:smc/config/routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/core/services/user_service.dart';
import 'package:smc/data/models/user_model.dart';
import 'package:smc/data/models/auth_models.dart';
import 'dart:math' as math;

/// Secure Login Screen — Professional Engineering & Infrastructure Design
/// Restored to absolute original layout/features with professional Slate/Amber palette.
class SecureLoginScreen extends StatefulWidget {
  const SecureLoginScreen({super.key});

  @override
  State<SecureLoginScreen> createState() => _SecureLoginScreenState();
}

class _SecureLoginScreenState extends State<SecureLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.superAdmin;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  late AnimationController _gridController;
  late AnimationController _authController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // ── Industrial Matte Palette ──
  static const Color _bgDarkSlate = Color(0xFF0F172A);
  static const Color _bgLightWarm = Color(0xFFFAFAFA);
  static const Color _cardDark = Color(0xFF1E293B);
  static const Color _cardLight = Color(0xFFFFFFFF);
  static const Color _borderDark = Color(0xFF334155);
  static const Color _borderLight = Color(0xFFE2E8F0);
  static const Color _textDark = Color(0xFFF8FAFC);
  static const Color _textLight = Color(0xFF1E293B);
  static const Color _subtleDark = Color(0xFF94A3B8);
  static const Color _subtleLight = Color(0xFF64748B);

  static const _roleConfig = <UserRole, _RoleUIConfig>{
    UserRole.superAdmin: _RoleUIConfig(
      icon: Icons.account_balance_rounded,
      color: Color(0xFF334155),
      darkColor: Color(0xFF94A3B8),
      label: 'National',
    ),
    UserRole.stateAdmin: _RoleUIConfig(
      icon: Icons.gavel_rounded,
      color: Color(0xFF0F766E),
      darkColor: Color(0xFF2DD4BF),
      label: 'State',
    ),
    UserRole.cityAdmin: _RoleUIConfig(
      icon: Icons.location_city_rounded,
      color: Color(0xFFB45309),
      darkColor: Color(0xFFFBBF24),
      label: 'City',
    ),
    UserRole.fieldInspector: _RoleUIConfig(
      icon: Icons.engineering_rounded,
      color: Color(0xFF1D4ED8), 
      darkColor: Color(0xFFF59E0B), 
      label: 'Inspector',
    ),
    UserRole.viewer: _RoleUIConfig(
      icon: Icons.person_pin_circle_rounded,
      color: Color(0xFF64748B),
      darkColor: Color(0xFFCBD5E1),
      label: 'Citizen',
    ),
  };

  @override
  void initState() {
    super.initState();
    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _authController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _gridController.dispose();
    _authController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await _authController.forward();
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final userProvider = context.read<UserProvider>();
    switch (_selectedRole) {
      case UserRole.superAdmin:
        userProvider.setUser(User.mockNationalAdmin());
        break;
      case UserRole.stateAdmin:
        userProvider.setUser(User.mockCityAdmin());
        break;
      case UserRole.cityAdmin:
        userProvider.setUser(User.mockCityAdmin());
        break;
      case UserRole.fieldInspector:
        userProvider.setUser(User.mockFieldInspector());
        break;
      default:
        userProvider.setUser(User.mockViewer());
    }

    final route = _getRouteForRole(_selectedRole);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
  }

  String _getRouteForRole(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return AppRoutes.nationalDashboard;
      case UserRole.stateAdmin:
        return AppRoutes.stateDashboard;
      case UserRole.cityAdmin:
        return AppRoutes.cityDashboard;
      case UserRole.fieldInspector:
        return AppRoutes.inspectorHome;
      default:
        return AppRoutes.viewerHome;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = _roleConfig[_selectedRole]!;
    final accentColor = isDark ? config.darkColor : config.color;
    final bgColor = isDark ? _bgDarkSlate : _bgLightWarm;
    final textColor = isDark ? _textDark : _textLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _gridController,
              builder: (context, _) {
                return CustomPaint(
                  painter: GridBackgroundPainter(
                    gridColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                    opacity: isDark ? 0.2 : 0.1,
                  ),
                  foregroundPainter: InfraBlueprintPainter(
                    color: accentColor.withValues(alpha: isDark ? 0.08 : 0.06),
                    animationValue: _gridController.value,
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: SafeArea(
              child: const ThemeSwitcher(),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    children: [
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        child: _buildPulseLogo(isDark, accentColor),
                      ),
                      const SizedBox(height: 12),
                      FadeIn(
                        delay: const Duration(milliseconds: 300),
                        child: _InfraPulseLine(color: accentColor),
                      ),
                      const SizedBox(height: 24),
                      FadeInDown(
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 600),
                        child: _buildTitle(isDark, textColor),
                      ),
                      const SizedBox(height: 32),
                      FadeInDown(
                        delay: const Duration(milliseconds: 350),
                        duration: const Duration(milliseconds: 600),
                        child: _buildRoleSelector(isDark, accentColor, textColor),
                      ),
                      const SizedBox(height: 24),
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        duration: const Duration(milliseconds: 600),
                        child: _buildLoginCard(isDark, accentColor, config, textColor),
                      ),
                      const SizedBox(height: 16),
                      FadeInUp(
                        delay: const Duration(milliseconds: 650),
                        duration: const Duration(milliseconds: 600),
                        child: _buildDemoCredentials(isDark, accentColor),
                      ),
                      const SizedBox(height: 24),
                      FadeInUp(
                        delay: const Duration(milliseconds: 700),
                        child: _buildCitizenRegistration(isDark, accentColor),
                      ),
                      const SizedBox(height: 40),
                      FadeInUp(
                        delay: const Duration(milliseconds: 800),
                        child: Text(
                          "SMART MANAGEMENT CENTER • INDUSTRIAL GRADE TERMINAL",
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark ? _subtleDark : _subtleLight,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseLogo(bool isDark, Color accentColor) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) => Transform.scale(scale: _pulseAnim.value, child: child),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? _cardDark : _cardLight,
          border: Border.all(color: accentColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Icon(_roleConfig[_selectedRole]!.icon, size: 36, color: accentColor),
        ),
      ),
    );
  }

  Widget _buildTitle(bool isDark, Color textColor) {
    return Column(
      children: [
        Text(
          "SECURE DATA TERMINAL",
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            color: isDark ? _roleConfig[_selectedRole]!.darkColor : _roleConfig[_selectedRole]!.color,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "SMC PLATFORM LOGIN",
          style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800, color: textColor),
        ),
      ],
    );
  }

  Widget _buildRoleSelector(bool isDark, Color accentColor, Color textColor) {
    final roles = UserRole.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "SELECT OPERATIONAL DOMAIN",
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isDark ? _subtleDark : _subtleLight,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDark ? _cardDark : _cardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? _borderDark : _borderLight, width: 1.5),
          ),
          child: Row(
            children: roles.map((r) {
              final isSelected = _selectedRole == r;
              final color = isDark ? _roleConfig[r]!.darkColor : _roleConfig[r]!.color;
              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedRole = r),
                  borderRadius: BorderRadius.circular(11),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        _roleConfig[r]!.icon,
                        size: 22,
                        color: isSelected
                            ? (isDark ? Colors.black : Colors.white)
                            : (isDark ? _subtleDark : _subtleLight),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            _roleConfig[_selectedRole]!.label.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: accentColor,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(bool isDark, Color accentColor, _RoleUIConfig config, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? _cardDark : _cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? _borderDark : _borderLight, width: 1.5),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 30, offset: const Offset(0, 15)),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _usernameController,
              label: "OPERATOR IDENTIFIER",
              hint: "System ID",
              icon: Icons.badge_outlined,
              isDark: isDark,
              accentColor: accentColor,
              validator: (v) => (v == null || v.isEmpty) ? "ID Required" : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _passwordController,
              label: "SECURITY CLEARANCE CODE",
              hint: "Passcode",
              icon: Icons.lock_outline_rounded,
              isDark: isDark,
              accentColor: accentColor,
              isPassword: true,
              validator: (v) => (v == null || v.isEmpty) ? "Code Required" : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Stack(
                  children: [
                    if (_isLoading)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: AuthProgressPainter(progress: _authController.value, color: Colors.white.withValues(alpha: 0.4)),
                        ),
                      ),
                    Center(
                      child: Text(
                        "AUTHORIZE SESSION",
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w800, letterSpacing: 2, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    required Color accentColor,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: isDark ? _subtleDark : _subtleLight, letterSpacing: 1.5),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          validator: validator,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? _textDark : _textLight),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(color: isDark ? _subtleDark.withValues(alpha: 0.4) : _subtleLight.withValues(alpha: 0.4)),
            prefixIcon: Icon(icon, size: 20, color: accentColor),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, size: 20),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    color: isDark ? _subtleDark : _subtleLight)
                : null,
            filled: true,
            fillColor: isDark ? _bgDarkSlate.withValues(alpha: 0.5) : _bgLightWarm,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? _borderDark : _borderLight)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? _borderDark : _borderLight)),
          ),
        ),
      ],
    );
  }

  Widget _buildDemoCredentials(bool isDark, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? _cardDark.withValues(alpha: 0.6) : _cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.vpn_key_outlined, size: 18, color: accentColor),
              const SizedBox(width: 10),
              Text('DEMO ACCESS VAULT', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: accentColor)),
            ],
          ),
          const SizedBox(height: 16),
          _buildCredRow('NATIONAL ADMIN', 'admin_nat', 'pass123', isDark),
          _buildCredRow('STATE MANAGER', 'admin_state', 'pass123', isDark),
          _buildCredRow('CITY OPERATOR', 'admin_city', 'pass123', isDark),
          _buildCredRow('FIELD ENGINEER', 'ins_001', 'pass123', isDark),
          _buildCredRow('CITIZEN ACCESS', 'citizen_77', 'pass123', isDark),
        ],
      ),
    );
  }

  Widget _buildCredRow(String role, String user, String pass, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          _usernameController.text = user;
          _passwordController.text = pass;
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(role, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: isDark ? _subtleDark : _subtleLight)),
            Text('$user / $pass', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? _textDark : _textLight)),
          ],
        ),
      ),
    );
  }

  Widget _buildCitizenRegistration(bool isDark, Color accentColor) {
    return Column(
      children: [
        Text("OR", style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: isDark ? _subtleDark : _subtleLight)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.viewerHome),
              child: Text(
                "GUEST ACCESS",
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: accentColor, fontSize: 13, decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(width: 8),
            Text("|", style: TextStyle(color: isDark ? _subtleDark : _subtleLight)),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {},
              child: Text(
                "NEW REGISTRATION",
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: accentColor, fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleUIConfig {
  final IconData icon;
  final Color color;
  final Color darkColor;
  final String label;
  const _RoleUIConfig({required this.icon, required this.color, required this.darkColor, required this.label});
}

class _InfraPulseLine extends StatefulWidget {
  final Color color;
  const _InfraPulseLine({required this.color});
  @override
  State<_InfraPulseLine> createState() => _InfraPulseLineState();
}

class _InfraPulseLineState extends State<_InfraPulseLine> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(size: const Size(220, 20), painter: _PulsePainter(_controller.value, widget.color.withValues(alpha: 0.4))),
    );
  }
}

class _PulsePainter extends CustomPainter {
  final double progress; final Color color;
  _PulsePainter(this.progress, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1.5..style = PaintingStyle.stroke;
    final path = Path(); final midY = size.height / 2;
    path.moveTo(0, midY);
    for (double i = 0; i < size.width; i += 1) {
      double y = midY + math.sin((i / size.width * 4 * math.pi) + (progress * 2 * math.pi)) * 5;
      path.lineTo(i, y);
    }
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GridBackgroundPainter extends CustomPainter {
  final Color gridColor; final double opacity;
  GridBackgroundPainter({required this.gridColor, required this.opacity});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = gridColor.withValues(alpha: opacity)..strokeWidth = 0.5;
    for (double i = 0; i <= size.width; i += 30) { canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint); }
    for (double i = 0; i <= size.height; i += 30) { canvas.drawLine(Offset(0, i), Offset(size.width, i), paint); }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class InfraBlueprintPainter extends CustomPainter {
  final Color color; final double animationValue;
  InfraBlueprintPainter({required this.color, required this.animationValue});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1.0..style = PaintingStyle.stroke;
    final scanY = size.height * (math.sin(animationValue * 2 * math.pi) + 1) / 2;
    canvas.drawLine(Offset(0, scanY), Offset(size.width, scanY), paint..strokeWidth = 2.0);
    for (int i = 0; i < 4; i++) {
      double radius = (size.width * 0.4) * ((animationValue + i * 0.25) % 1.0);
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), radius, paint..color = color.withValues(alpha: (1.0 - (radius / (size.width * 0.4))) * 0.1));
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AuthProgressPainter extends CustomPainter {
  final double progress; final Color color;
  AuthProgressPainter({required this.progress, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * progress, size.height), paint);
  }
  @override bool shouldRepaint(covariant AuthProgressPainter oldDelegate) => true;
}
