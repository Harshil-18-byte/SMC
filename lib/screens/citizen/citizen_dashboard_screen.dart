import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smc/core/visuals/infra_visuals.dart';
import 'package:smc/core/layout/adaptive_layout.dart';
import 'package:smc/core/widgets/universal_drawer.dart';
import 'package:smc/config/routes.dart';

class CitizenDashboardScreen extends StatefulWidget {
  const CitizenDashboardScreen({super.key});

  @override
  State<CitizenDashboardScreen> createState() => _CitizenDashboardScreenState();
}

class _CitizenDashboardScreenState extends State<CitizenDashboardScreen> {
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
        compactBody: _buildBody(context, isDark),
        mediumBody: _buildBody(context, isDark),
        expandedBody: _buildBody(context, isDark),
        largeBody: _buildBody(context, isDark),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Exit Portal?", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to exit the Citizen Portal?", style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false), 
            child: const Text("EXIT", style: TextStyle(color: Colors.red))),
        ],
      ),
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
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
          ),
          const CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=Citizen'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.newInspection, arguments: {'inspectorId': 'CITIZEN-01'}),
        label: Text("REPORT ISSUE", style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        icon: const Icon(Icons.add_a_photo_rounded),
      ),
      body: InfraGridBackground(
        isDark: isDark,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModernGreeting(isDark),
              const SizedBox(height: 24),
              _buildImpactStats(isDark),
              const SizedBox(height: 24),
              _buildRewardCenter(isDark),
              const SizedBox(height: 32),
              _buildSectionHeader("PROJECTS NEAR ME", Icons.location_on_rounded, Colors.teal),
              const SizedBox(height: 12),
              _buildNearbyProjects(isDark),
              const SizedBox(height: 32),
              _buildSectionHeader("SERVICE HUB", Icons.category_rounded, Colors.purpleAccent),
              const SizedBox(height: 12),
              _buildServiceHub(isDark),
              const SizedBox(height: 32),
              _buildSectionHeader("QUICK HAZARD", Icons.bolt_rounded, Colors.orange),
              const SizedBox(height: 12),
              _buildHazardGrid(isDark),
              const SizedBox(height: 32),
              _buildSectionHeader("MY RECENT GRIEVANCES", Icons.history_rounded, Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              _buildReportTimeline(isDark),
              const SizedBox(height: 120),
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
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Text(
          "Contributing to Bharat's Infrastructure",
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildImpactStats(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("04", "REPORTS", isDark),
          _buildStatItem("75%", "FIX RATE", isDark),
          _buildStatItem("842", "SCCUs", isDark),
        ],
      ),
    );
  }

  Widget _buildStatItem(String val, String label, bool isDark) {
    return Column(
      children: [
        Text(val, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary)),
        Text(label, style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: isDark ? Colors.white70 : Colors.black54)),
      ],
    );
  }

  Widget _buildRewardCenter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? [Color(0xFF1E293B), Colors.black] : [Theme.of(context).primaryColor.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text("SCCU REWARDS PROGRAM", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Your reports have improved 3 neighborhoods this month. Earn 158 more points for Priority Fix access.",
            style: GoogleFonts.outfit(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700, foregroundColor: Colors.white),
              child: Text("REDEEM UTILITY PERK", style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyProjects(bool isDark) {
    final projects = [
      {'name': 'Coastal Road Link', 'dist': '1.2 km', 'progress': 0.92},
      {'name': 'Smart Pole Grid', 'dist': '0.5 km', 'progress': 0.40},
    ];

    return Column(
      children: projects.map((p) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.engineering_rounded, color: Colors.teal, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text("Distance: ${p['dist']}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: p['progress'] as double,
                    backgroundColor: Colors.teal.withValues(alpha: 0.1),
                    color: Colors.teal,
                    minHeight: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text("${((p['progress'] as double) * 100).toInt()}%", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.teal, fontSize: 12)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildServiceHub(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _serviceCard("Paving", Icons.rounded_corner_rounded, Colors.purpleAccent, isDark),
          _serviceCard("Lights", Icons.lightbulb_outline_rounded, Theme.of(context).primaryColor, isDark),
          _serviceCard("Drainage", Icons.waves_rounded, Colors.tealAccent, isDark),
          _serviceCard("Greens", Icons.park_outlined, Colors.greenAccent, isDark),
        ],
      ),
    );
  }

  Widget _serviceCard(String label, IconData icon, Color color, bool isDark) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildHazardGrid(bool isDark) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _hazardItem("Live Wire", Icons.electric_bolt_rounded, isDark),
        _hazardItem("Gas Leak", Icons.gas_meter_rounded, isDark),
        _hazardItem("Water Burst", Icons.water_drop_rounded, isDark),
      ],
    );
  }

  Widget _hazardItem(String label, IconData icon, bool isDark) {
    final width = (MediaQuery.of(context).size.width - 52) / 2;
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildReportTimeline(bool isDark) {
    final reports = [
      {'t': 'Pothole @ MG Road', 's': 'Resolved', 'c': Colors.green},
      {'t': 'Light Out @ Sector 4', 's': 'Verified', 'c': Colors.orange},
    ];

    return Column(
      children: reports.map((r) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(child: Text(r['t'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: (r['c'] as Color).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(r['s'] as String, style: TextStyle(color: r['c'] as Color, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2, color: color)),
      ],
    );
  }
}
