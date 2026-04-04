import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smc/core/widgets/smc_back_button.dart';
import 'package:smc/core/theme/theme_switcher.dart';

/// Infrastructure Integrity Summary Screen
/// Operational status and telemetry overview for regional infrastructure assets.
class AssetSummaryScreen extends StatelessWidget {
  final String? assetId;
  final String? assetName;

  const AssetSummaryScreen({super.key, this.assetId, this.assetName});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = assetName ?? 'Western Bridge Link - 04';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        leading: const SMCBackButton(),
        title: Text('INTEGRITY SUMMARY', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
        actions: const [ThemeSwitcher(), SizedBox(width: 8)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asset Identity Card
            _buildAssetCard(context, isDark, name),
            const SizedBox(height: 24),

            // Telemetry Snapshot
            _buildSectionTitle(context, 'LIVE TELEMETRY'),
            const SizedBox(height: 12),
            _buildTelemetryGrid(context, isDark),
            const SizedBox(height: 24),

            // Critical Defects
            _buildSectionTitle(context, 'STRUCTURAL DEFECT HISTORY'),
            const SizedBox(height: 12),
            _buildDefectsList(context, isDark),
            const SizedBox(height: 24),

            // Maintenance Schedule
            _buildSectionTitle(context, 'PLANNED MAINTENANCE'),
            const SizedBox(height: 12),
            _buildMaintenanceSchedule(context, isDark),
            const SizedBox(height: 24),

            // Material Analysis
            _buildSectionTitle(context, 'MATERIAL COMPOSITION'),
            const SizedBox(height: 12),
            _buildMaterialAnalysis(context, isDark),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildAssetCard(BuildContext context, bool isDark, String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('ASSET ID: BR-LINK-04-SEC4',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                const Text('Built: 2018  •  Material: Concrete/Steel  •  Load Class: A',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryGrid(BuildContext context, bool isDark) {
    final metrics = [
      {
        'label': 'Stress Load',
        'value': '42.5',
        'unit': 'kN/m²',
        'icon': Icons.fitness_center_rounded,
        'color': Colors.red
      },
      {
        'label': 'Vibration',
        'value': '0.14',
        'unit': 'Hz',
        'icon': Icons.vibration_rounded,
        'color': Colors.pink
      },
      {
        'label': 'Integrity',
        'value': '99.2',
        'unit': '%',
        'icon': Icons.shield_rounded,
        'color': Theme.of(context).primaryColor
      },
      {
        'label': 'Ambient Temp',
        'value': '32.4',
        'unit': '°C',
        'icon': Icons.thermostat_rounded,
        'color': Colors.orange
      },
      {
        'label': 'Deformation',
        'value': '0.02',
        'unit': 'mm',
        'icon': Icons.straighten_rounded,
        'color': Colors.purple
      },
      {
        'label': 'Node Status',
        'value': '124',
        'unit': 'ACTIVE',
        'icon': Icons.hub_rounded,
        'color': Colors.teal
      },
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.9,
      children: metrics.map((v) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(v['icon'] as IconData, color: v['color'] as Color, size: 20),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('${v['value']}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ),
              Text('${v['unit']}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              const SizedBox(height: 2),
              Text('${v['label']}',
                  style: TextStyle(fontSize: 9, color: Colors.grey[400]),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDefectsList(BuildContext context, bool isDark) {
    final defects = [
      {'name': 'Structural Hairline Crack', 'since': 'Detected May 2024', 'status': 'Stable'},
      {'name': 'Joint Corrosion - Pylon 4', 'since': 'Detected Feb 2026', 'status': 'Monitoring'},
    ];

    return Column(
      children: defects.map((c) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.report_problem_rounded,
                    color: Colors.orange, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c['name']!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                    Text(c['since']!,
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(c['status']!,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMaintenanceSchedule(BuildContext context, bool isDark) {
    final events = [
      {
        'date': 'Feb 14, 2026',
        'type': 'Sensor Calibration',
        'by': 'Engr. Arnav Desai',
        'notes': 'Vibration node resynchronization'
      },
      {
        'date': 'Jan 28, 2026',
        'type': 'Structural Wash',
        'by': 'Fleet Unit 09',
        'notes': 'Chemical cleaning of support pylons'
      },
    ];

    return Column(
      children: events.map((v) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.event_rounded,
                    color: Theme.of(context).primaryColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(v['type']!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                        const SizedBox(width: 6),
                        Text(v['date']!,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500])),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(v['by']!,
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600])),
                    Text(v['notes']!,
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[400])),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMaterialAnalysis(BuildContext context, bool isDark) {
    final components = [
      {'name': 'Structural Steel Grade 4', 'level': 0.94, 'color': Colors.blue},
      {'name': 'RCC Concrete - Mixed', 'level': 0.88, 'color': Colors.teal},
    ];

    return Column(
      children: components.map((m) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(m['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('${((m['level'] as double)*100).toInt()}% INTEGRITY', style: TextStyle(color: m['color'] as Color, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: m['level'] as double, color: m['color'] as Color, backgroundColor: Colors.white10, minHeight: 4),
            ],
          ),
        );
      }).toList(),
    );
  }
}
