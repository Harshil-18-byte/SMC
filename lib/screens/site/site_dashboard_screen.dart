import 'package:flutter/material.dart';
import 'package:smc/config/routes.dart';
import 'package:smc/core/widgets/dashboard_back_handler.dart';
import 'package:smc/core/layout/adaptive_layout.dart';
import 'package:smc/core/widgets/universal_drawer.dart';
import 'package:smc/core/visuals/industrial_visuals.dart';
import 'package:google_fonts/google_fonts.dart';

/// Site-Specific Dashboard
/// Provides localized asset oversight and recent audit telemetry for regional managers.
class SiteDashboardScreen extends StatelessWidget {
  const SiteDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardBackHandler(
      dashboardName: 'Site Dashboard',
      child: AdaptiveLayout(
        compactBody: _buildDashboardBody(context),
        mediumBody: _buildDashboardBody(context),
        expandedBody: _buildDashboardBody(context),
        largeBody: _buildDashboardBody(context),
      ),
    );
  }

  Widget _buildDashboardBody(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      drawer: const UniversalDrawer(),
      body: IndustrialVisuals.blueprintBackground(
        isDark: true,
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 32),
                      _buildQuickActions(context),
                      const SizedBox(height: 32),
                      _buildIntegritySection(),
                      const SizedBox(height: 32),
                      _buildRecentAuditsSection(context),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.9),
        border: const Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              icon: Icon(Icons.menu_open_rounded, color: Theme.of(context).primaryColor),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          const SizedBox(width: 12),
          Text("REGIONAL SITE COMMAND", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("LOCAL JURISDICTION", style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor, letterSpacing: 2)),
        const SizedBox(height: 4),
        Text("Sector-09 Field Operations", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("FAST TRACK OPERATIONS", style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          IndustrialVisuals.largeActionButton(
            label: 'NEW ASSET AUDIT',
            icon: Icons.add_moderator_rounded,
            onTap: () => Navigator.pushNamed(context, '/inspector/audit', arguments: {
              'inspectorId': 'INS-901',
              'assetId': 'BR-01',
              'assetName': 'Western Bridge 04'
            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _actionCard(context, Icons.analytics_rounded, 'TELEMETRY', 'Live sensor feeds', Colors.purple, AppRoutes.iotDashboard),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionCard(context, Icons.history_edu_rounded, 'LOGS', 'Audit trail history', Colors.orange, AppRoutes.adminAuditLogs),
              ),
            ],
          )
        ],
    );
  }

  Widget _actionCard(BuildContext context, IconData icon, String title, String subtitle, Color color, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildIntegritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("INFRASTRUCTURE INTEGRITY", style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        _statItem('CRITICAL DEFECTS', '04', Colors.red, 0.2),
        const SizedBox(height: 12),
        _statItem('STRUCTURAL RISK', 'LOW', Colors.green, 0.85),
      ],
    );
  }

  Widget _statItem(String label, String value, Color color, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress, color: color, backgroundColor: color.withValues(alpha: 0.1), minHeight: 4),
        ],
      ),
    );
  }

  Widget _buildRecentAuditsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RECENT AUDIT REGISTRY", style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, i) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(Icons.description_rounded, color: Theme.of(context).primaryColor),
              title: Text('Audit Report #12${8-i}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text('Status: Verified • 2h ago', style: TextStyle(color: Colors.grey, fontSize: 11)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
              onTap: () => Navigator.pushNamed(context, AppRoutes.adminAuditLogs),
            ),
          ),
        ),
      ],
    );
  }
}
