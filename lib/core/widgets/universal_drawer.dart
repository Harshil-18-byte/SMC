import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smc/core/theme/theme_service.dart';
import 'package:smc/core/localization/widgets/language_selector.dart';
import 'package:smc/config/routes.dart';
import 'package:smc/core/services/user_service.dart';
import 'package:smc/data/models/user_model.dart';
import 'package:smc/data/models/auth_models.dart';
import 'package:smc/core/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';

/// Universal Tactical Navigation Drawer
/// Multi-role navigation hub for administrative, field-engineer, and public user contexts.
class UniversalDrawer extends StatelessWidget {
  final bool isPermanent;

  const UniversalDrawer({
    super.key,
    this.isPermanent = false,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    final role = user?.role ?? UserRole.viewer;

    return Drawer(
      elevation: isPermanent ? 0 : 16,
      backgroundColor: const Color(0xFF0F172A), // Tactical Dark Blue
      child: Column(
        children: [
          _buildHeader(context, user),
          const Divider(height: 1, color: Colors.white10),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildSectionHeader(context, "MAIN COMMAND"),
                _buildNavItem(
                  context,
                  Icons.dashboard_rounded,
                  "OVERVIEW",
                  role == UserRole.superAdmin ? AppRoutes.nationalDashboard :
                  role == UserRole.stateAdmin ? AppRoutes.stateDashboard :
                  role == UserRole.cityAdmin ? AppRoutes.cityDashboard :
                  role == UserRole.fieldInspector ? AppRoutes.inspectorHome :
                  AppRoutes.viewerHome,
                ),

                // Role-Specific Domains
                if (role == UserRole.superAdmin || role == UserRole.stateAdmin || role == UserRole.cityAdmin) ...[
                  const Divider(color: Colors.white10),
                  _buildSectionHeader(context, "ADMINISTRATIVE CONTROL"),
                  _buildNavItem(context, Icons.policy_rounded, "Tactical Surveillance", AppRoutes.adminSurveillance),
                  _buildNavItem(context, Icons.analytics_rounded, "Strategic Command", AppRoutes.adminCommandCenter),
                  _buildNavItem(context, Icons.hub_rounded, "System Infrastructure", AppRoutes.adminInfrastructureStatus),
                  _buildNavItem(context, Icons.map_rounded, "Risk Heatmap", AppRoutes.riskHeatmap),
                ],

                if (role == UserRole.fieldInspector) ...[
                  const Divider(color: Colors.white10),
                  _buildSectionHeader(context, "FIELD OPERATIONS"),
                  _buildNavItem(context, Icons.add_task_rounded, "New Audit Cycle", AppRoutes.newInspection),
                  _buildNavItem(context, Icons.history_rounded, "Audit Trail", AppRoutes.inspectorTasks),
                  _buildNavItem(context, Icons.engineering_rounded, "Diagnostic Analysis", AppRoutes.inspectorSchedule),
                ],

                if (role == UserRole.viewer) ...[
                  const Divider(color: Colors.white10),
                  _buildSectionHeader(context, "REGIONAL ACCESS"),
                  _buildNavItem(context, Icons.report_gmailerrorred_rounded, "Submit Incident", AppRoutes.viewerHome),
                  _buildNavItem(context, Icons.search_rounded, "Asset Directory", AppRoutes.assetSearch),
                  _buildNavItem(context, Icons.warning_amber_rounded, "Emergency Override", AppRoutes.publicSOS),
                ],

                const Divider(color: Colors.white10),
                _buildSectionHeader(context, "OPERATIONAL TERMINAL"),
                _buildNavItem(
                  context,
                  Icons.person_pin_rounded,
                  "Operational Profile",
                  AppRoutes.profile,
                ),
                _buildNavItem(
                  context,
                  Icons.sensors_rounded,
                  "IoT Telemetry",
                  AppRoutes.iotDashboard,
                ),
                _buildNavItem(
                  context,
                  Icons.settings_suggest_rounded,
                  "System Settings",
                  AppRoutes.settings,
                ),
                
                const Divider(color: Colors.white10),
                _buildThemeToggle(context),
                _buildLanguageItem(context),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          _buildLogout(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User? user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.blue,
            child: Text(
              user?.name.substring(0, 1).toUpperCase() ?? 'O',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(user?.name.toUpperCase() ?? "FIELD OPERATOR", 
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
          Text(user?.role.displayName.toUpperCase() ?? "AUTHORIZED USER", 
              style: GoogleFonts.outfit(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: Colors.grey,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String title, String route) {
    final bool isSelected = ModalRoute.of(context)?.settings.name == route;

    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.grey[400], size: 20),
      title: Text(title, style: GoogleFonts.outfit(
        fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
        fontSize: 13,
        color: isSelected ? Colors.blue : Colors.white70,
      )),
      selected: isSelected,
      onTap: () {
        if (!isPermanent) Navigator.pop(context);
        if (!isSelected) {
          if (route.contains('dashboard')) {
            Navigator.pushReplacementNamed(context, route);
          } else {
            Navigator.pushNamed(context, route);
          }
        }
      },
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    return ListTile(
      leading: Icon(themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode, color: Colors.grey[400], size: 20),
      title: Text("DARK MODE", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
      trailing: Switch.adaptive(
        value: themeService.isDarkMode,
        activeTrackColor: Colors.blue,
        onChanged: (value) => themeService.toggleTheme(),
      ),
    );
  }

  Widget _buildLanguageItem(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.language_rounded, color: Colors.grey[400], size: 20),
      title: Text("LANGUAGE", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
      onTap: () => LanguageSelectorDialog.show(context),
    );
  }

  Widget _buildLogout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            context.read<AuthProvider>().logout();
            context.read<UserProvider>().logout();
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
          },
          icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 18),
          label: Text("TERMINATE SESSION", style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 12)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }
}
