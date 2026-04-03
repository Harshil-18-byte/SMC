import 'package:flutter/material.dart';
import 'package:smc/config/routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/core/services/user_service.dart';
import 'package:smc/data/models/user_model.dart';
import 'package:smc/data/models/auth_models.dart';
import 'package:smc/core/localization/app_localizations.dart';
import 'package:smc/core/visuals/infra_visuals.dart';
import 'dart:math' as math;

/// Secure Login Screen — Professional Engineering & Infrastructure Design
/// Features: blueprint scanning animation on login, grid/blueprint background,
/// and a high-density, technical command center aesthetic.
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

  // ── Dark, solid, matte palette ──
  static const Color _bgDarkCharcoal = Color(0xFF141618);
  static const Color _bgLightWarm = Color(0xFFF5F0EB);
  static const Color _cardDark = Color(0xFF1C1F22);
  static const Color _cardLight = Color(0xFFFFFFFF);
  static const Color _borderDark = Color(0xFF2A2D31);
  static const Color _borderLight = Color(0xFFD6CFC7);
  static const Color _textDark = Color(0xFFE8E4DF);
  static const Color _textLight = Color(0xFF2C2825);
  static const Color _subtleDark = Color(0xFF6B6560);
  static const Color _subtleLight = Color(0xFF9A938C);

  static const _roleConfig = <UserRole, _RoleUIConfig>{
    UserRole.superAdmin: _RoleUIConfig(
      icon: Icons.account_balance_rounded,
      color: Color(0xFF1A237E),
      darkColor: Color(0xFF3F51B5),
      label: 'National',
    ),
    UserRole.stateAdmin: _RoleUIConfig(
      icon: Icons.gavel_rounded,
      color: Color(0xFF2E7D32),
      darkColor: Color(0xFF4CAF50),
      label: 'State',
    ),
    UserRole.cityAdmin: _RoleUIConfig(
      icon: Icons.location_city_rounded,
      color: Color(0xFFC62828),
      darkColor: Color(0xFFE57373),
      label: 'City',
    ),
    UserRole.fieldInspector: _RoleUIConfig(
      icon: Icons.engineering_rounded,
      color: Color(0xFFEF6C00),
      darkColor: Color(0xFFFFB74D),
      label: 'Inspector',
    ),
    UserRole.viewer: _RoleUIConfig(
      icon: Icons.person_pin_circle_rounded,
      color: Colors.blueGrey,
      darkColor: Colors.blueGrey,
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
    final bgColor = isDark ? _bgDarkCharcoal : _bgLightWarm;
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
                    gridColor: (isDark ? Colors.blue : Colors.blueGrey),
                    opacity: isDark ? 0.08 : 0.04,
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
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const ThemeSwitcher(),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    children: [
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        child: _buildPulseLogo(isDark, accentColor),
                      ),
                      const SizedBox(height: 8),
                      FadeIn(
                        delay: const Duration(milliseconds: 300),
                        child: _InfraPulseLine(color: accentColor),
                      ),
                      const SizedBox(height: 20),
                      FadeInDown(
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 600),
                        child: _buildTitle(isDark, textColor),
                      ),
                      const SizedBox(height: 28),
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
                      FadeInUp(
                        delay: const Duration(milliseconds: 650),
                        child: _buildDemoCredentials(isDark, accentColor),
                      ),
                      const SizedBox(height: 24),
                      FadeInUp(
                        delay: const Duration(milliseconds: 700),
                        child: _buildCitizenRegistration(isDark, accentColor),
                      ),
                      const SizedBox(height: 36),
                      FadeInUp(
                        delay: const Duration(milliseconds: 800),
                        child: Text(
                          AppLocalizations.of(context).translate('login_footer_text'),
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? _subtleDark : _subtleLight,
                            letterSpacing: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
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
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accentColor,
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.15),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(_roleConfig[_selectedRole]!.icon, key: ValueKey(_selectedRole), size: 34, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTitle(bool isDark, Color textColor) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Text(
          l10n.translate('login_title'),
          style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: textColor),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.translate('login_subtitle'),
          style: GoogleFonts.outfit(fontSize: 14, color: isDark ? _subtleDark : _subtleLight, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleSelector(bool isDark, Color accentColor, Color textColor) {
    final l10n = AppLocalizations.of(context);
    final roles = [
      (UserRole.superAdmin, 'National', Icons.account_balance_rounded),
      (UserRole.stateAdmin, 'State', Icons.gavel_rounded),
      (UserRole.cityAdmin, 'City', Icons.location_city_rounded),
      (UserRole.fieldInspector, 'Inspector', Icons.engineering_rounded),
      (UserRole.viewer, 'Citizen', Icons.person_pin_circle_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            l10n.translate('login_as').toUpperCase(),
            style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: isDark ? _subtleDark : _subtleLight, letterSpacing: 1.5),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? _cardDark : _cardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? _borderDark : _borderLight, width: 1.5),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: roles.map((r) {
              final isSelected = _selectedRole == r.$1;
              final color = isDark ? _roleConfig[r.$1]!.darkColor : _roleConfig[r.$1]!.color;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedRole = r.$1;
                    _authController.reset();
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(r.$3, size: 18, color: isSelected ? color : (isDark ? _subtleDark : _subtleLight)),
                        const SizedBox(height: 4),
                        Text(
                          r.$2,
                          style: GoogleFonts.outfit(fontSize: 10, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? color : (isDark ? _subtleDark : _subtleLight)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(bool isDark, Color accentColor, _RoleUIConfig config, Color textColor) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? _cardDark : _cardLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? _borderDark : _borderLight, width: 1.5),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _usernameController,
              label: l10n.translate('login_username_label'),
              hint: l10n.translate('login_username_hint'),
              icon: Icons.badge_outlined,
              isDark: isDark,
              accentColor: accentColor,
              validator: (v) => (v == null || v.isEmpty) ? l10n.translate('login_username_required') : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _passwordController,
              label: l10n.translate('login_password_label'),
              hint: l10n.translate('login_password_hint'),
              icon: Icons.lock_outline_rounded,
              isDark: isDark,
              accentColor: accentColor,
              isPassword: true,
              validator: (v) => (v == null || v.isEmpty) ? l10n.translate('login_password_required') : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Stack(
                  children: [
                    if (_isLoading)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: AuthProgressPainter(progress: _authController.value, color: Colors.white.withValues(alpha: 0.3)),
                        ),
                      ),
                    Center(
                      child: Text(
                        _isLoading ? 'AUTHENTICATING...' : l10n.translate('login_sign_in'),
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w700, letterSpacing: 1),
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
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      validator: validator,
      style: GoogleFonts.outfit(fontSize: 15, color: isDark ? _textDark : _textLight),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: accentColor.withValues(alpha: 0.6)),
        suffixIcon: isPassword ? IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, size: 20), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildDemoCredentials(bool isDark, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.blue.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.key_rounded, size: 16, color: accentColor),
              const SizedBox(width: 8),
              Text('DEMO LOGIN VAULT', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: accentColor)),
            ],
          ),
          const SizedBox(height: 12),
          _buildCredRow('NATIONAL', 'admin_nat', 'pass123', isDark),
          _buildCredRow('STATE', 'admin_state', 'pass123', isDark),
          _buildCredRow('CITY', 'admin_city', 'pass123', isDark),
          _buildCredRow('INSPECTOR', 'ins_001', 'pass123', isDark),
          _buildCredRow('CITIZEN', 'citizen_77', 'pass123', isDark),
        ],
      ),
    );
  }

  Widget _buildCredRow(String role, String user, String pass, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(role, style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: isDark ? Colors.white54 : Colors.black54)),
          Text('$user / $pass', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildCitizenRegistration(bool isDark, Color accentColor) {
    return Column(
      children: [
        Text(
          "OR",
          style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            side: BorderSide(color: accentColor, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            "NEW CITIZEN REGISTRATION",
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: accentColor, fontSize: 13),
          ),
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
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(size: const Size(200, 30), painter: _InfraPulsePainter(progress: _controller.value, color: widget.color.withValues(alpha: 0.5))),
    );
  }
}

class _InfraPulsePainter extends CustomPainter {
  final double progress;
  final Color color;
  _InfraPulsePainter({required this.progress, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1.5..style = PaintingStyle.stroke;
    final w = size.width; final h = size.height; final midY = h / 2;
    final path = Path(); path.moveTo(0, midY);
    for (double x = 0; x < w; x += 10) {
      final yOffset = (x > w * 0.4 && x < w * 0.6) ? (math.sin(x * 0.5) * 10) : (math.sin(x * 0.1) * 2);
      path.lineTo(x, midY + yOffset);
    }
    path.lineTo(w, midY); canvas.drawPath(path, paint);
    final packetX = w * progress;
    canvas.drawRect(Rect.fromCenter(center: Offset(packetX, midY), width: 6, height: 6), Paint()..color = color);
  }
  @override
  bool shouldRepaint(covariant _InfraPulsePainter old) => old.progress != progress;
}
