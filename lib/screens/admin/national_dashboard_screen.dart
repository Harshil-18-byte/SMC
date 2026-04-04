import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smc/core/visuals/infra_visuals.dart';
import 'package:smc/core/layout/adaptive_layout.dart';
import 'package:smc/core/widgets/universal_drawer.dart';
import 'package:smc/widgets/smc_map.dart';
import 'package:smc/config/routes.dart';

class NationalDashboardScreen extends StatefulWidget {
  const NationalDashboardScreen({super.key});

  @override
  State<NationalDashboardScreen> createState() => _NationalDashboardScreenState();
}

class _NationalDashboardScreenState extends State<NationalDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitConfirmation(context);
      },
      child: AdaptiveLayout(
        compactBody: _buildDashboardBody(context, isDark),
        mediumBody: _buildDashboardBody(context, isDark),
        expandedBody: _buildDashboardBody(context, isDark),
        largeBody: _buildDashboardBody(context, isDark),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Exit Command?", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to exit the National Command Center?", style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("RESUME")),
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false), 
            child: const Text("EXIT", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildDashboardBody(BuildContext context, bool isDark) {
    return Scaffold(
      drawer: const UniversalDrawer(),
      appBar: AppBar(
        title: Text(
          "NATIONAL INFRASTRUCTURE COMMAND",
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_open_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: InfraGridBackground(
        isDark: isDark,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMacroStats(isDark),
              const SizedBox(height: 24),
              _buildComplianceHub(isDark),
              const SizedBox(height: 24),
              _buildNationalMap(isDark),
              const SizedBox(height: 32),
              _buildEmergencyVerificationHub(isDark),
              const SizedBox(height: 32),
              _buildStateLeaderboard(isDark),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplianceHub(bool isDark) {
    final amber = const Color(0xFFF59E0B);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("SMART COMPLIANCE MONITORING", Icons.verified_user_rounded),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: amber.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Column(
            children: [
              _complianceRow("Critical Node Audit", "98.2%", true, amber),
              const Divider(color: Colors.white10, height: 24),
              _complianceRow("Industrial OSHA Compliance", "94.5%", true, amber),
              const Divider(color: Colors.white10, height: 24),
              _complianceRow("Environmental Risk Factor", "Low", false, Colors.green),
            ],
          ),
        ),
      ],
    );
  }

  Widget _complianceRow(String label, String value, bool isPositive, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70)),
        Row(
          children: [
            Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(width: 8),
            Icon(isPositive ? Icons.arrow_upward_rounded : Icons.check_circle_outline, size: 14, color: color),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroStats(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Row(
              children: [
                _buildMetricTile("NIRI Index", "88.4", Icons.insights_rounded, Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                _buildMetricTile("Governance", "28/28", Icons.account_tree_rounded, Colors.teal),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMetricTile("Capital Capex", "₹4.2T", Icons.account_balance_rounded, Colors.orange),
                const SizedBox(width: 12),
                _buildMetricTile("Compliance", "92%", Icons.verified_user_rounded, Colors.green),
              ],
            ),
          ],
        );
      }
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        height: 90,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 18, color: color),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: color),
              ),
            ),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNationalMap(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("INTER-STATE INFRASTRUCTURE STATUS", Icons.public_rounded),
        const SizedBox(height: 16),
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: const SMCMap(showMarkers: true),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            fontSize: 10,
            letterSpacing: 1.2,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStateLeaderboard(bool isDark) {
    final states = [
      {'name': 'Maharashtra', 'score': '94.2', 'trend': '+1.2%'},
      {'name': 'Karnataka', 'score': '91.8', 'trend': '+0.5%'},
      {'name': 'Delhi', 'score': '89.5', 'trend': '-0.2%'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("STATE COMPLIANCE LEADERBOARD", Icons.leaderboard_rounded),
        const SizedBox(height: 16),
        ...states.map((state) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1), radius: 16, child: Text(state['name']![0], style: TextStyle(fontSize: 12))),
              const SizedBox(width: 12),
              Expanded(child: Text(state['name']!, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13))),
              Text(state['score']!, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 13)),
              const SizedBox(width: 8),
              Text(state['trend']!, style: GoogleFonts.outfit(fontSize: 11, color: Colors.green)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildEmergencyVerificationHub(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("EMERGENCY COORDINATION CENTER (ECC)", Icons.security_rounded),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withValues(alpha: 0.2), width: 1.5),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.emergency_rounded, color: Colors.red, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("AUTOMATED ALERT: SENSOR C-104", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.red, fontSize: 12)),
                        Text("Grid Thermal Variance Detected", style: GoogleFonts.outfit(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ALERT DISMISSED BY NATIONAL COMMAND"), backgroundColor: Colors.orange));
                      },
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: EdgeInsets.zero),
                      child: Text("DISMISS", style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.red, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ALERT VERIFIED: FIELD AGENTS DISPATCHED"), backgroundColor: Colors.green));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: EdgeInsets.zero),
                      child: Text("VERIFY", style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
