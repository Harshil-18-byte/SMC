import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/core/widgets/smc_back_button.dart';
import 'package:google_fonts/google_fonts.dart';

/// Audit History & Asset Technical Logs
/// Replaces HealthRecordsScreen with Industrial Inspection & Service History.
class AuditHistoryScreen extends StatelessWidget {
  const AuditHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        leading: const SMCBackButton(),
        title: Text('HISTORICAL AUDIT LOGS', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
        actions: const [ThemeSwitcher(), SizedBox(width: 8)],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().streamCollection(
          collection: 'audit_records',
          orderBy: 'date',
          descending: true,
        ),
        builder: (context, snapshot) {
          final rawRecords = snapshot.data ?? [];
          final records = rawRecords.isEmpty
              ? [
                  {
                    'id': 'r1',
                    'title': 'Structural Integrity Audit',
                    'provider': 'National Infra Bureau',
                    'date': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
                    'type': 'structural',
                    'description': 'Annual check of Load-Bearing components (Sector 4). All nodes nominal.',
                    'details': {'Integrity': '94%', 'Stress Ratio': '0.42', 'Result': 'PASSED'}
                  },
                  {
                    'id': 'r2',
                    'title': 'Geo-Technical Analysis',
                    'provider': 'SMC Soil Research',
                    'date': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
                    'type': 'geotech',
                    'description': 'Soil stability analysis for South Drainage Grid project.',
                    'details': {'Saturation': '12%', 'Shift Factor': '0.001', 'Compaction': 'OPTIMAL'}
                  },
                  {
                    'id': 'r3',
                    'title': 'Utility Grid Overhaul',
                    'provider': 'Universal Power Corp',
                    'date': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
                    'type': 'utility',
                    'description': 'Substation transformer replacement and circuit diagnostic.',
                    'details': {'Efficiency': '+15%', 'Output': '4.2 GW', 'Downtime': '0s'}
                  },
                ]
              : rawRecords;

          if (records.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) => _buildRecordCard(context, records[index], isDark),
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, Map<String, dynamic> record, bool isDark) {
    final date = record['date'] != null ? DateTime.parse(record['date']) : DateTime.now();
    final type = record['type'] ?? 'document';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: _getRecordColor(type).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(_getRecordIcon(type), color: _getRecordColor(type), size: 20),
        ),
        title: Text(record['title']?.toUpperCase() ?? 'TECHNICAL RECORD', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white)),
        subtitle: Text('${record['provider']} • ${DateFormat('MMM dd, yyyy').format(date)}', style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        childrenPadding: const EdgeInsets.all(16),
        collapsedIconColor: Colors.white,
        iconColor: Theme.of(context).primaryColor,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record['description'] ?? 'No data provided.', style: const TextStyle(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 16),
                if (record['details'] != null) ...[
                  Text('DIAGNOSTIC METRICS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  ...(record['details'] as Map<String, dynamic>).entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text('${e.key}: ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        Text('${e.value}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  )),
                ],
                const SizedBox(height: 24),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text('GENERATE TECHNICAL PDF', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                    style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).primaryColor, side: BorderSide(color: Theme.of(context).primaryColor)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRecordColor(String type) {
    switch (type) {
      case 'structural': return Colors.orange;
      case 'geotech': return Colors.brown;
      case 'utility': return Colors.yellow;
      case 'overhaul': return Theme.of(context).primaryColor;
      default: return Colors.grey;
    }
  }

  IconData _getRecordIcon(String type) {
    switch (type) {
      case 'structural': return Icons.hub_rounded;
      case 'geotech': return Icons.landscape_rounded;
      case 'utility': return Icons.electrical_services_rounded;
      case 'overhaul': return Icons.build_rounded;
      default: return Icons.description_rounded;
    }
  }
}
