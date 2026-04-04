import 'package:flutter/material.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/config/routes.dart';
import 'package:smc/core/visuals/industrial_visuals.dart';
import 'package:google_fonts/google_fonts.dart';

/// Site Operational Profile Screen
/// Displays professional credentials, assignment zones, and system settings for site-level personnel.
class SiteProfileScreen extends StatelessWidget {
  const SiteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Text('OPERATIONAL PROFILE', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.2)),
        actions: const [ThemeSwitcher(), SizedBox(width: 8)],
      ),
      body: IndustrialVisuals.blueprintBackground(
        isDark: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildProfileHeader(context),
              const SizedBox(height: 40),
              _buildStatsRow(),
              const SizedBox(height: 40),
              _buildSettingsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Theme.of(context).primaryColor, width: 2)),
          child: const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF1E293B),
            child: Icon(Icons.engineering_rounded, size: 50, color: Theme.of(context).primaryColor),
          ),
        ),
        const SizedBox(height: 20),
        Text('INGR. ARNAV DESAI', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
        Text('LEAD FIELD ENGINEER • SECTOR-04', style: GoogleFonts.outfit(color: Theme.of(context).primaryColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statItem('AUDITS', '142'),
        _statItem('REPORTS', '89'),
        _statItem('CRITICAL', '12'),
      ],
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SYSTEM CONFIGURATION', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
          child: Column(
            children: [
              _buildSettingTile(Icons.security_rounded, 'Security Protocol'),
              _buildSettingTile(Icons.notifications_active_rounded, 'Alert Thresholds'),
              _buildSettingTile(Icons.logout_rounded, 'Terminate Session', isDestructive: true, onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(IconData icon, String title, {bool isDestructive = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Theme.of(context).primaryColor, size: 20),
      title: Text(title, style: TextStyle(color: isDestructive ? Colors.red : Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
      onTap: onTap ?? () {},
    );
  }
}
