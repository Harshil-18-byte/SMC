import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smc/core/visuals/infra_visuals.dart';
import 'package:smc/core/layout/adaptive_layout.dart';
import 'package:smc/core/widgets/universal_drawer.dart';
import 'package:flutter/services.dart';

class CitizenDashboardScreen extends StatefulWidget {
  const CitizenDashboardScreen({super.key});

  @override
  State<CitizenDashboardScreen> createState() => _CitizenDashboardScreenState();
}

class _CitizenDashboardScreenState extends State<CitizenDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AdaptiveLayout(
      compactBody: _buildBody(context, isDark),
      mediumBody: _buildBody(context, isDark),
      expandedBody: _buildBody(context, isDark),
      largeBody: _buildBody(context, isDark),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark) {
    return Scaffold(
      drawer: const UniversalDrawer(),
      appBar: AppBar(
        title: Text(
          "CITIZEN PORTAL",
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=Citizen'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToReport(context),
        label: Text("REPORT ISSUE", style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        icon: const Icon(Icons.add_a_photo_rounded),
      ),
      body: InfraGridBackground(
        isDark: isDark,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModernGreeting(isDark),
              const SizedBox(height: 32),
              _buildImpactStats(isDark),
              const SizedBox(height: 32),
              _buildRewardCenter(isDark),
              const SizedBox(height: 32),
              _buildSectionHeader("STATE PROJECTS NEAR ME", Icons.location_on_rounded, Colors.teal),
              const SizedBox(height: 16),
              _buildNearbyProjects(isDark),
              const SizedBox(height: 32),
              _buildSectionHeader("INFRASTRUCTURE SERVICE HUB", Icons.category_rounded, Colors.purpleAccent),
              const SizedBox(height: 16),
              _buildServiceHub(isDark),
              const SizedBox(height: 32),
              _buildSectionHeader("QUICK HAZARD REPORT", Icons.bolt_rounded, Colors.orange),
              const SizedBox(height: 16),
              _buildHazardGrid(isDark),
              const SizedBox(height: 32),
              _buildSectionHeader("MY RECENT GRIEVANCES", Icons.history_rounded, Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              _buildReportTimeline(isDark),
              const SizedBox(height: 32),
              _buildSectionHeader("REGIONAL INFRA ALERTS", Icons.campaign_rounded, Colors.redAccent),
              const SizedBox(height: 16),
              _buildAlertCard("Bridge Maintenance - Mumbai", "Bandra-Worli Sea Link will have restricted lanes on Sunday night.", isDark),
              const SizedBox(height: 12),
              _buildAlertCard("Power Grid Upgrade - Delhi", "Planned maintenance in Rohini Sector 4 from 2PM to 4PM.", isDark),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernGreeting(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Jai Hind, Citizen",
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Text(
          "Contributing to Bharat's World-Class Infrastructure",
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildImpactStats(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("04", "REPORTS FILED", isDark),
          _buildStatItem("75%", "FIX RATE", isDark),
          _buildStatItem("842", "SCCU POINTS", isDark),
        ],
      ),
    );
  }

  Widget _buildRewardCenter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? [Colors.blueGrey.shade900, Colors.black] : [Colors.blue.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: Colors.amber, size: 24),
              const SizedBox(width: 12),
              Text("SCCU REWARDS PROGRAM", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Your reports have improved 3 neighborhoods this month. You've earned 842 Smart City Contribution Units.",
            style: GoogleFonts.outfit(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showRedeemPointsSheet(isDark),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text("REDEEM FOR PUBLIC UTILITY", style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyProjects(bool isDark) {
    final projects = [
      {'name': 'Coastal Road Link', 'dist': '1.2 km', 'progress': 0.92, 'status': 'Active'},
      {'name': 'Smart Pole Grid', 'dist': '0.5 km', 'progress': 0.40, 'status': 'Delayed'},
    ];

    return Column(
      children: projects.map((p) => InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showProjectTimelineSheet(p['name'] as String, isDark);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.engineering_rounded, color: Colors.teal),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['name'] as String, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    Text("Distance: ${p['dist']}", style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: p['progress'] as double,
                      backgroundColor: Colors.teal.withValues(alpha: 0.1),
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text("${((p['progress'] as double) * 100).toInt()}%", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.teal)),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildServiceHub(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildServiceCard("Request Paving", Icons.rounded_corner_rounded, Colors.purpleAccent, isDark),
          _buildServiceCard("New Streetlight", Icons.lightbulb_outline_rounded, Colors.blueAccent, isDark),
          _buildServiceCard("Drainage Link", Icons.waves_rounded, Colors.tealAccent, isDark),
          _buildServiceCard("Tree Plantation", Icons.park_outlined, Colors.greenAccent, isDark),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String label, IconData icon, Color color, bool isDark) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Text("Official Hub", style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String val, String label, bool isDark) {
    return Column(
      children: [
        Text(val, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary)),
        Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: isDark ? Colors.white70 : Colors.black54)),
      ],
    );
  }

  Widget _buildHazardGrid(bool isDark) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildHazardItem("Live Wire", Icons.electric_bolt_rounded, isDark),
        _buildHazardItem("Gas Leak", Icons.gas_meter_rounded, isDark),
        _buildHazardItem("Falling Tree", Icons.park_rounded, isDark),
        _buildHazardItem("Water Burst", Icons.water_drop_rounded, isDark),
      ],
    );
  }

  Widget _buildHazardItem(String label, IconData icon, bool isDark) {
    return InkWell(
      onTap: () {
        HapticFeedback.vibrate();
        _showHazardReportFlow(label, isDark);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: (MediaQuery.of(context).size.width - 60) / 2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.orange),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  void _showRedeemPointsSheet(bool isDark) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141618) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 2),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("SCCU REDEMPTION HUB", style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.amber, letterSpacing: 2)),
            const SizedBox(height: 8),
            Text("Select Utility Perk", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildRedeemOption("Priority Pothole Fix", "500 Units", Icons.construction_rounded, isDark),
            _buildRedeemOption("Green Space Sponsorship", "800 Units", Icons.park_rounded, isDark),
            _buildRedeemOption("Community Wi-Fi Boost", "300 Units", Icons.wifi_rounded, isDark),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text("REDEEM UNITS", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRedeemOption(String title, String cost, IconData icon, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)), Text(cost, style: GoogleFonts.outfit(fontSize: 11, color: Colors.amber))])),
          const Icon(Icons.radio_button_checked_rounded, color: Colors.amber),
        ],
      ),
    );
  }

  void _showProjectTimelineSheet(String name, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 400,
        decoration: BoxDecoration(color: isDark ? const Color(0xFF101922) : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("PROJECT TIMELINE", style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.teal)),
            Text(name, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildTimelineStep("Phase 1: Foundation", "Completed", true),
            _buildTimelineStep("Phase 2: Structural Link", "In Progress", false),
            _buildTimelineStep("Phase 3: Utility Integration", "Scheduled", false),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(String label, String status, bool isDone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(isDone ? Icons.check_circle_rounded : Icons.pending_rounded, color: isDone ? Colors.teal : Colors.grey),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)), Text(status, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey))]),
        ],
      ),
    );
  }

  void _showHazardReportFlow(String type, bool isDark) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("URGENT: Identifying Precision Location for $type Report..."), backgroundColor: Colors.orange));
  }

  Widget _buildReportTimeline(bool isDark) {
    return Column(
      children: [
        _buildTimelineItem("Pothole reported at MG Road", "Yesterday, 10:30 AM", "Work Order Issued", Colors.blue, isDark),
        _buildTimelineItem("Streetlight out in Sector 4", "2 days ago", "Verified", Colors.orange, isDark),
        _buildTimelineItem("Garbage pile near metro", "Last week", "Resolved", Colors.green, isDark),
      ],
    );
  }

  Widget _buildTimelineItem(String title, String time, String status, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700)),
                Text(time, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(status.toUpperCase(), style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(String title, String desc, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.redAccent),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.redAccent)),
            ],
          ),
          const SizedBox(height: 4),
          Text(desc, style: GoogleFonts.outfit(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 1.2,
            color: color,
          ),
        ),
      ],
    );
  }

  void _navigateToReport(BuildContext context) {
    // Navigate to a more specific report screen if needed, or just stay here.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("OPENING HIGH-PRECISION EVIDENCE CAPTURE...")),
    );
  }
}
