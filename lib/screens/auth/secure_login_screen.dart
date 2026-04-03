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
import 'package:smc/core/visuals/medical_doodle_painters.dart';

/// Secure Login Screen — Hand-crafted Medical Professional Design
/// Features: syringe injection animation on login, sketchy doodle background,
/// dark solid colours, rough "human" imperfections, and a clinical clipboard feel.
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

  UserRole _selectedRole = UserRole.admin;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  late AnimationController _doodleController;
  late AnimationController _syringeController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // ── Dark, solid, matte palette ──
  // No gloss, no glass — just honest, grounded medical colours
  static const Color _bgDarkCharcoal = Color(0xFF141618);
  static const Color _bgLightWarm = Color(0xFFF5F0EB); // warm cream
  static const Color _cardDark = Color(0xFF1C1F22);
  static const Color _cardLight = Color(0xFFFFFFFF);
  static const Color _borderDark = Color(0xFF2A2D31);
  static const Color _borderLight = Color(0xFFD6CFC7);
  static const Color _textDark = Color(0xFFE8E4DF);
  static const Color _textLight = Color(0xFF2C2825);
  static const Color _subtleDark = Color(0xFF6B6560);
  static const Color _subtleLight = Color(0xFF9A938C);

  static const _roleConfig = <UserRole, _RoleUIConfig>{
    UserRole.admin: _RoleUIConfig(
      icon: Icons.admin_panel_settings_rounded,
      color: Color(0xFF5C6BC0), // muted indigo
      darkColor: Color(0xFF7986CB),
      label: 'Admin',
    ),
    UserRole.fieldWorker: _RoleUIConfig(
      icon: Icons.medical_services_rounded,
      color: Color(0xFF2E7D6F), // deep teal
      darkColor: Color(0xFF4DB6A0),
      label: 'Field Worker',
    ),
    UserRole.doctor: _RoleUIConfig(
      icon: Icons.local_hospital_rounded,
      color: Color(0xFF388E3C), // solid green
      darkColor: Color(0xFF66BB6A),
      label: 'Hospital',
    ),
    UserRole.citizen: _RoleUIConfig(
      icon: Icons.person_pin_rounded,
      color: Color(0xFF7B5EA7), // muted purple
      darkColor: Color(0xFF9E86C8),
      label: 'Citizen',
    ),
  };

  @override
  void initState() {
    super.initState();
    _doodleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _syringeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
    _doodleController.dispose();
    _syringeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Play syringe injection animation
    await _syringeController.forward();
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    final userProvider = context.read<UserProvider>();
    switch (_selectedRole) {
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
        userProvider.setUser(User.mockCitizen());
        break;
      default:
        userProvider.setUser(User.mockCitizen());
    }

    final route = _getRouteForRole(_selectedRole);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
  }

  String _getRouteForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppRoutes.adminDashboard;
      case UserRole.fieldWorker:
        return AppRoutes.fieldWorkerHome;
      case UserRole.doctor:
        return AppRoutes.hospitalDashboard;
      case UserRole.citizen:
        return AppRoutes.citizenHome;
      default:
        return AppRoutes.citizenHome;
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
          // ── Background: notebook lines + hand-drawn doodles ──
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _doodleController,
              builder: (context, _) {
                return CustomPaint(
                  painter: NotebookBackgroundPainter(
                    lineColor: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.04),
                    animationValue: _doodleController.value,
                  ),
                  foregroundPainter: MedicalDoodlePainter(
                    color: accentColor.withValues(alpha: isDark ? 0.07 : 0.05),
                    animationValue: _doodleController.value,
                  ),
                );
              },
            ),
          ),

          // ── Theme toggle ──
          Positioned(
            top: 10,
            right: 10,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const ThemeSwitcher(),
              ),
            ),
          ),

          // ── Main content ──
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // ── Pulse Logo with sketchy ring ──
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: _buildPulseLogo(isDark, accentColor),
                    ),

                    const SizedBox(height: 8),

                    // ── Heartbeat line ──
                    FadeIn(
                      delay: const Duration(milliseconds: 300),
                      child: _HeartbeatLine(color: accentColor),
                    ),

                    const SizedBox(height: 20),

                    // ── Title with handwritten touch ──
                    FadeInDown(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 600),
                      child: _buildTitle(isDark, textColor),
                    ),

                    const SizedBox(height: 28),

                    // ── Role Selector (clipboard tabs) ──
                    FadeInDown(
                      delay: const Duration(milliseconds: 350),
                      duration: const Duration(milliseconds: 600),
                      child: _buildRoleSelector(isDark, accentColor, textColor),
                    ),

                    const SizedBox(height: 24),

                    // ── Login form card (clipboard) ──
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      duration: const Duration(milliseconds: 600),
                      child: _buildLoginCard(
                          isDark, accentColor, config, textColor),
                    ),

                    const SizedBox(height: 36),

                    // ── Footer ──
                    FadeInUp(
                      delay: const Duration(milliseconds: 800),
                      child: Text(
                        AppLocalizations.of(context)
                            .translate('login_footer_text'),
                        style: GoogleFonts.caveat(
                          fontSize: 13,
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
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Pulse Logo — solid circle, sketchy border, no gloss
  // ────────────────────────────────────────────────────────────
  Widget _buildPulseLogo(bool isDark, Color accentColor) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnim.value,
          child: child,
        );
      },
      child: CustomPaint(
        foregroundPainter: SketchyBorderPainter(
          color: accentColor.withValues(alpha: 0.4),
          strokeWidth: 1.8,
        ),
        child: Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accentColor, // Solid — no gradient
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
            child: Icon(
              _roleConfig[_selectedRole]!.icon,
              key: ValueKey(_selectedRole),
              size: 34,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Title — use Caveat (handwritten) for subtitle to feel human
  // ────────────────────────────────────────────────────────────
  Widget _buildTitle(bool isDark, Color textColor) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Text(
          l10n.translate('login_title'),
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.translate('login_subtitle'),
          style: GoogleFonts.caveat(
            fontSize: 16,
            color: isDark ? _subtleDark : _subtleLight,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────
  // Role Selector — clipboard tab style, solid matte
  // ────────────────────────────────────────────────────────────
  Widget _buildRoleSelector(bool isDark, Color accentColor, Color textColor) {
    final l10n = AppLocalizations.of(context);

    final roles = [
      (UserRole.admin, l10n.admin, Icons.admin_panel_settings_rounded),
      (UserRole.fieldWorker, l10n.fieldWorker, Icons.medical_services_rounded),
      (UserRole.doctor, l10n.hospitalPortal, Icons.local_hospital_rounded),
      (UserRole.citizen, l10n.translate('citizen'), Icons.person_pin_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              // Small clipboard clip icon
              Icon(Icons.push_pin_outlined,
                  size: 14, color: isDark ? _subtleDark : _subtleLight),
              const SizedBox(width: 6),
              Text(
                l10n.translate('login_as').toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDark ? _subtleDark : _subtleLight,
                  letterSpacing: 1.8,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? _cardDark : _cardLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? _borderDark : _borderLight,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(5),
          child: Row(
            children: roles.map((r) {
              final isSelected = _selectedRole == r.$1;
              final roleConfig = _roleConfig[r.$1]!;
              final color = isDark ? roleConfig.darkColor : roleConfig.color;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedRole = r.$1;
                    // Reset syringe for new role
                    _syringeController.reset();
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: isDark ? 0.15 : 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? Border.all(
                              color: color.withValues(alpha: 0.35),
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          r.$3,
                          size: 20,
                          color: isSelected
                              ? color
                              : (isDark ? _subtleDark : _subtleLight),
                        ),
                        const SizedBox(height: 5),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Text(
                              r.$2,
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? color
                                    : (isDark ? _subtleDark : _subtleLight),
                              ),
                              maxLines: 1,
                            ),
                          ),
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

  // ────────────────────────────────────────────────────────────
  // Login Card — clipboard-style, solid matte, sketchy border overlay
  // ────────────────────────────────────────────────────────────
  Widget _buildLoginCard(
      bool isDark, Color accentColor, _RoleUIConfig config, Color textColor) {
    final l10n = AppLocalizations.of(context);

    return CustomPaint(
      foregroundPainter: SketchyBorderPainter(
        color: accentColor.withValues(alpha: 0.12),
        strokeWidth: 1.2,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? _cardDark : _cardLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? _borderDark : _borderLight,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -6,
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ── Clipboard clip at top ──
              Transform.translate(
                offset: const Offset(0, -8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    'PATIENT FILE',
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: accentColor.withValues(alpha: 0.7),
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Username / ID
              _buildTextField(
                controller: _usernameController,
                label: l10n.translate('login_username_label'),
                hint: l10n.translate('login_username_hint'),
                icon: Icons.badge_outlined,
                isDark: isDark,
                accentColor: accentColor,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.translate('login_username_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password
              _buildTextField(
                controller: _passwordController,
                label: l10n.translate('login_password_label'),
                hint: l10n.translate('login_password_hint'),
                icon: Icons.lock_outline_rounded,
                isDark: isDark,
                accentColor: accentColor,
                isPassword: true,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.translate('login_password_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Remember + Forgot
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color:
                                _rememberMe ? accentColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _rememberMe
                                  ? accentColor
                                  : (isDark ? _borderDark : _borderLight),
                              width: 1.5,
                            ),
                          ),
                          child: _rememberMe
                              ? const Icon(Icons.check,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.translate('login_remember_me'),
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: isDark ? _subtleDark : _subtleLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.translate('login_forgot_demo')),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      );
                    },
                    child: Text(
                      l10n.translate('login_forgot_password'),
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Syringe Injection Login Button ──
              _buildSyringeButton(isDark, accentColor, l10n, textColor),
              const SizedBox(height: 16),

              // Dev hint
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.06 : 0.04),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.science_outlined,
                        size: 16, color: accentColor.withValues(alpha: 0.5)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.translate('login_dev_hint'),
                        style: GoogleFonts.caveat(
                          fontSize: 13,
                          color: isDark ? _subtleDark : _subtleLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Syringe Login Button — the hero interaction!
  // ────────────────────────────────────────────────────────────
  Widget _buildSyringeButton(
      bool isDark, Color accentColor, AppLocalizations l10n, Color textColor) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: GestureDetector(
        onTap: _isLoading ? null : _handleLogin,
        child: AnimatedBuilder(
          animation: _syringeController,
          builder: (context, _) {
            final progress = _syringeController.value;
            // Button "presses down" slightly as syringe injects
            final pressScale = 1.0 - (progress * 0.03);

            return Transform.scale(
              scale: pressScale,
              child: Container(
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          accentColor.withValues(alpha: 0.2 * (1.0 - progress)),
                      blurRadius: 12,
                      offset: Offset(0, 4 * (1.0 - progress)),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Syringe icon/animation
                    SizedBox(
                      width: 40,
                      height: 50,
                      child: CustomPaint(
                        painter: SyringeInjectionPainter(
                          progress: progress,
                          liquidColor: accentColor.withValues(alpha: 0.6),
                          barrelColor: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Text changes during injection
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isLoading
                          ? Text(
                              progress < 0.5
                                  ? 'Injecting...'
                                  : 'Authenticating...',
                              key: ValueKey('loading_$progress'),
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            )
                          : Text(
                              l10n.translate('login_sign_in'),
                              key: const ValueKey('idle'),
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Text Field — solid matte, no gloss
  // ────────────────────────────────────────────────────────────
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
      style: GoogleFonts.outfit(
        fontSize: 15,
        color: isDark ? _textDark : _textLight,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: isDark ? _subtleDark : _subtleLight,
        ),
        hintStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.15),
        ),
        prefixIcon:
            Icon(icon, size: 20, color: accentColor.withValues(alpha: 0.6)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: isDark ? _subtleDark : _subtleLight,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? _borderDark : _borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? _borderDark : _borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFC62828), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFC62828), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

// ─── Role UI Config ────────────────────────────────────────
class _RoleUIConfig {
  final IconData icon;
  final Color color;
  final Color darkColor;
  final String label;

  const _RoleUIConfig({
    required this.icon,
    required this.color,
    required this.darkColor,
    required this.label,
  });
}

// ─── Heartbeat Line Widget ─────────────────────────────────
class _HeartbeatLine extends StatefulWidget {
  final Color color;
  const _HeartbeatLine({required this.color});

  @override
  State<_HeartbeatLine> createState() => _HeartbeatLineState();
}

class _HeartbeatLineState extends State<_HeartbeatLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(200, 30),
          painter: _HeartbeatPainter(
            progress: _controller.value,
            color: widget.color.withValues(alpha: 0.5),
          ),
        );
      },
    );
  }
}

// ─── ECG Heartbeat Painter ─────────────────────────────────
class _HeartbeatPainter extends CustomPainter {
  final double progress;
  final Color color;

  _HeartbeatPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final midY = size.height / 2;
    final w = size.width;

    // ECG-style heartbeat waveform
    path.moveTo(0, midY);
    path.lineTo(w * 0.25, midY);
    path.lineTo(w * 0.32, midY - 3);
    path.lineTo(w * 0.36, midY + 2);
    path.lineTo(w * 0.40, midY);
    path.lineTo(w * 0.44, midY);
    path.lineTo(w * 0.47, midY - size.height * 0.4);
    path.lineTo(w * 0.50, midY + size.height * 0.35);
    path.lineTo(w * 0.53, midY - size.height * 0.15);
    path.lineTo(w * 0.56, midY);
    path.lineTo(w * 0.60, midY);
    path.lineTo(w * 0.63, midY - 3);
    path.lineTo(w * 0.67, midY + 2);
    path.lineTo(w * 0.70, midY);
    path.lineTo(w, midY);

    canvas.drawPath(path, paint);

    // Glowing dot that travels along
    final glowX = w * progress;
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(glowX, midY), 3, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _HeartbeatPainter old) =>
      old.progress != progress || old.color != color;
}
