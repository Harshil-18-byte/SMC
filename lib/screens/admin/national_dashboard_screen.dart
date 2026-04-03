import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smc/core/visuals/infra_visuals.dart';
import 'package:smc/core/layout/adaptive_layout.dart';
import 'package:smc/core/widgets/universal_drawer.dart';
import 'package:smc/core/widgets/compact_widgets.dart';
import 'package:smc/widgets/smc_map.dart';
import 'package:flutter/services.dart';

class NationalDashboardScreen extends StatefulWidget {
  const NationalDashboardScreen({super.key});

  @override
  State<NationalDashboardScreen> createState() => _NationalDashboardScreenState();
}

class _NationalDashboardScreenState extends State<NationalDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AdaptiveLayout(
      compactBody: _buildDashboardBody(context, isDark),
      mediumBody: _buildDashboardBody(context, isDark),
      expandedBody: _buildDashboardBody(context, isDark),
      largeBody: _buildDashboardBody(context, isDark),
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
              _buildNationalMap(isDark),
              const SizedBox(height: 32),
              _buildEmergencyVerificationHub(isDark),
              const SizedBox(height: 32),
              _buildStateLeaderboard(isDark),
              const SizedBox(height: 32),
              _buildStrategicFeatures(isDark),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroStats(bool isDark) {
    return AdaptiveGrid(
      childAspectRatio: 1.5,
      children: [
        _buildMetricTile("NIRI Index", "88.4", Icons.insights_rounded, Colors.blue),
        _buildMetricTile("Governance", "28/28", Icons.account_tree_rounded, Colors.teal),
        _buildMetricTile("Capital Capex", "₹4.2T", Icons.account_balance_rounded, Colors.orange),
        _buildMetricTile("Compliance", "92%", Icons.verified_user_rounded, Colors.green),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 20, color: color),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
          ),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey),
          ),
        ],
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
          height: 350,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: Colors.blue.withValues(alpha: 0.1), child: Text(state['name']![0])),
              const SizedBox(width: 16),
              Expanded(child: Text(state['name']!, style: GoogleFonts.outfit(fontWeight: FontWeight.bold))),
              Text(state['score']!, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(width: 8),
              Text(state['trend']!, style: GoogleFonts.outfit(fontSize: 12, color: Colors.green)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildStrategicFeatures(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("NATIONAL POLICY & STRATEGY", Icons.security_rounded),
        const SizedBox(height: 16),
        AdaptiveGrid(
          childAspectRatio: 1.2,
          children: [
            _buildFeatureStub("Policy Hub", "Push National SOPs to all states.", Icons.gavel_rounded),
            _buildFeatureStub("Budget Control", "Global grant management tool.", Icons.monetization_on_rounded),
            _buildFeatureStub("Vendor Registry", "National blacklisting database.", Icons.business_rounded),
            _buildFeatureStub("Safety Audits", "Schedule cross-state audits.", Icons.fact_check_rounded),
            _buildFeatureStub("Disaster Planning", "Resilience scoring engine.", Icons.storm_rounded),
            _buildFeatureStub("Citizen Grievance", "Aggregate national analytics.", Icons.people_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureStub(String title, String desc, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        if (title == "Policy Hub") _showPolicyHub(isDark);
        if (title == "Budget Control") _showBudgetControl(isDark);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: Colors.blue),
            const SizedBox(height: 8),
            Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(desc, style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  void _showPolicyHub(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 500,
        decoration: BoxDecoration(color: isDark ? const Color(0xFF141618) : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("NATIONAL POLICY REGISTRY", style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blue)),
            Text("Push Strategic Directives", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildPolicyItem("Zero-Emission Paving Standard", "Draft"),
            _buildPolicyItem("Smart Grid Interoperability v2", "Active"),
            _buildPolicyItem("National Land Acquisition SOP", "Under Review"),
            const Spacer(),
            IndustrialActionButton(height: 50, color: Colors.blue, onTap: () => Navigator.pop(context), child: const Text("CLOSE HUB")),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyItem(String title, String status) {
    return ListTile(
      leading: const Icon(Icons.description_rounded, color: Colors.blue),
      title: Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
      trailing: Text(status.toUpperCase(), style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey)),
    );
  }

  void _showBudgetControl(bool isDark) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Accessing National Capex Disbursement Matrix..."), backgroundColor: Colors.blue));
  }

  Widget _buildEmergencyVerificationHub(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("EMERGENCY COORDINATION CENTER (ECC)", Icons.security_rounded),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withValues(alpha: 0.2), width: 2),
            image: DecorationImage(
              image: const NetworkImage('https://www.transparenttextures.com/patterns/carbon-fibre.png'),
              opacity: isDark ? 0.05 : 0.02,
              repeat: ImageRepeat.repeat,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.emergency_rounded, color: Colors.red, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("AUTOMATED ALERT: SENSOR C-104", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.red, fontSize: 13)),
                        Text("Mithand Power Grid - Thermal Variance Detected", style: GoogleFonts.outfit(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Emergency Incident Logged for Audit Review."), backgroundColor: Colors.grey));
                      },
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                      child: Text("DISMISS", style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.red)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        HapticFeedback.heavyImpact();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Initiating National Alert Sequence..."), backgroundColor: Colors.red));
                        await Future.delayed(const Duration(seconds: 2));
                        if (mounted) {
                          HapticFeedback.vibrate();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("URGENT BROADCAST COMPLETED. Sensors Reset."), backgroundColor: Colors.green));
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text("VERIFY & BROADCAST", style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "NOTICE: PROFESSIONAL PROTOCOL REQUIRES HUMAN VERIFICATION BEFORE NATIONAL ALERT BROADCAST.",
                style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.red.withValues(alpha: 0.7)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            fontSize: 11,
            letterSpacing: 1.2,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}
