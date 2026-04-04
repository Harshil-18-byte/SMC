import 'package:flutter/material.dart';
import 'package:smc/core/widgets/smc_back_button.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/core/visuals/industrial_visuals.dart';
import 'package:google_fonts/google_fonts.dart';

/// Site Infrastructure Screen
/// High-density oversight of regional physical infrastructure systems, diagnostics, and utility status.
class SiteInfraScreen extends StatelessWidget {
  const SiteInfraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        leading: const SMCBackButton(),
        title: Text('SITE INFRASTRUCTURE', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
        actions: const [ThemeSwitcher(), SizedBox(width: 8)],
      ),
      body: IndustrialVisuals.blueprintBackground(
        isDark: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, 'SYSTEM OVERVIEW'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatTile('STRUCTURAL NODES', '1,240', Icons.hub_rounded, Theme.of(context).primaryColor)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatTile('TELEMETRY STATUS', 'ACTIVE', Icons.sensors_rounded, Colors.green)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatTile('LATENCY (MS)', '14', Icons.speed_rounded, Colors.purple)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatTile('UPLINK HEALTH', '99.8%', Icons.wifi_protected_setup_rounded, Colors.teal)),
                ],
              ),
              const SizedBox(height: 32),

              _buildSectionTitle(context, 'ASSET SYSTEMS'),
              const SizedBox(height: 16),
              ..._buildSystemCards(context),

              const SizedBox(height: 32),

              _buildSectionTitle(context, 'DIAGNOSTIC ARRAY STATUS'),
              const SizedBox(height: 16),
              _buildDiagnosticList(context),

              const SizedBox(height: 32),

              _buildSectionTitle(context, 'REGIONAL UTILITIES'),
              const SizedBox(height: 16),
              _buildUtilityCard('Primary Power Grid', 'Main + Backup Genset', Icons.bolt_rounded, Colors.amber, 0.98),
              _buildUtilityCard('Data Network', 'Fiber + Satellite Uplink', Icons.language_rounded, Theme.of(context).primaryColor, 0.99),
              _buildUtilityCard('Hydrology Control', 'Pumping Station 04', Icons.water_drop_rounded, Colors.cyan, 0.82),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor, letterSpacing: 1.5));
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
          Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
        ],
      ),
    );
  }

  List<Widget> _buildSystemCards(BuildContext context) {
    final systems = [
      {'name': 'Foundation Integrity', 'nodes': '480', 'health': '99%', 'color': Theme.of(context).primaryColor, 'icon': Icons.architecture_rounded},
      {'name': 'Electrical Infrastructure', 'nodes': '210', 'health': '85%', 'color': Colors.orange, 'icon': Icons.bolt_rounded},
      {'name': 'Sanitation Systems', 'nodes': '150', 'health': '92%', 'color': Colors.green, 'icon': Icons.water_damage_rounded},
    ];

    return systems.map((sys) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(sys['icon'] as IconData, color: sys['color'] as Color, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sys['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Text('${sys['nodes']} nodes monitored • ${sys['health']} operational', style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 18),
        ],
      ),
    )).toList();
  }

  Widget _buildDiagnosticList(BuildContext context) {
    final tools = [
      {'name': 'Seismic Sensor Array', 'status': 'Stable', 'ok': true},
      {'name': 'UAV Thermal Sweeper', 'status': 'Deployment Ready', 'ok': true},
      {'name': 'Subsurface Scanner', 'status': 'Calibrating', 'ok': false},
    ];

    return Column(
      children: tools.map((t) => Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(Icons.biotech_rounded, size: 18, color: (t['ok'] as bool) ? Theme.of(context).primaryColor : Colors.orange),
            const SizedBox(width: 12),
            Expanded(child: Text(t['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
            Text(t['status'] as String, style: TextStyle(color: (t['ok'] as bool) ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildUtilityCard(String name, String detail, IconData icon, Color color, double level) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(detail, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ),
              Text('${(level * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: level, minHeight: 2, backgroundColor: Colors.white10, color: color),
        ],
      ),
    );
  }
}
