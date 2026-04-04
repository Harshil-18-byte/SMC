import 'package:flutter/material.dart';
import 'package:smc/core/widgets/smc_back_button.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/core/localization/app_localizations.dart';

/// Asset Summary Screen
/// Compact asset inspection summary visible from both Citizen and Field Worker sides
class AssetSummaryScreen extends StatelessWidget {
  final String? assetId;
  final String? assetName;

  const AssetSummaryScreen({super.key, this.assetId, this.assetName});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = assetName ?? 'Suresh Patil';

    return Scaffold(
      appBar: SMCAppBar(
        title: AppLocalizations.of(context).translate('asset_summary'),
        actions: const [ThemeSwitcher(), SizedBox(width: 8)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asset Identity Card
            _buildAssetCard(context, isDark, name),
            const SizedBox(height: 20),

            // Vitals Snapshot
            _buildSectionTitle(context, 'LATEST VITALS'),
            const SizedBox(height: 12),
            _buildVitalsGrid(context, isDark),
            const SizedBox(height: 20),

            // Active Conditions
            _buildSectionTitle(context, 'ACTIVE CONDITIONS'),
            const SizedBox(height: 12),
            _buildConditionsList(context, isDark),
            const SizedBox(height: 20),

            // Recent Visits
            _buildSectionTitle(context, 'RECENT VISITS'),
            const SizedBox(height: 12),
            _buildRecentVisits(context, isDark),
            const SizedBox(height: 20),

            // Medications
            _buildSectionTitle(context, 'CURRENT MEDICATIONS'),
            const SizedBox(height: 12),
            _buildMedications(context, isDark),
            const SizedBox(height: 20),

            // Allergies
            _buildSectionTitle(context, 'ALLERGIES'),
            const SizedBox(height: 12),
            _buildAllergies(context, isDark),

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
                const Text('Inspection ID: SOL-4522-8901',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 2),
                const Text('Age: 40  •  Blood Group: O+  •  Male',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsGrid(BuildContext context, bool isDark) {
    final vitals = [
      {
        'label': 'Blood Pressure',
        'value': '128/82',
        'unit': 'mmHg',
        'icon': Icons.favorite_rounded,
        'color': Colors.red
      },
      {
        'label': 'Heart Rate',
        'value': '76',
        'unit': 'bpm',
        'icon': Icons.monitor_heart_rounded,
        'color': Colors.pink
      },
      {
        'label': 'SpO2',
        'value': '97',
        'unit': '%',
        'icon': Icons.air_rounded,
        'color': Colors.blue
      },
      {
        'label': 'Temperature',
        'value': '98.4',
        'unit': '°F',
        'icon': Icons.thermostat_rounded,
        'color': Colors.orange
      },
      {
        'label': 'Blood Sugar',
        'value': '112',
        'unit': 'mg/dL',
        'icon': Icons.water_drop_rounded,
        'color': Colors.purple
      },
      {
        'label': 'Weight',
        'value': '72',
        'unit': 'kg',
        'icon': Icons.monitor_weight_rounded,
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
      children: vitals.map((v) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(v['icon'] as IconData, color: v['color'] as Color, size: 20),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('${v['value']}',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color:
                            isDark ? Colors.white : const Color(0xFF111418))),
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

  Widget _buildConditionsList(BuildContext context, bool isDark) {
    final conditions = [
      {'name': 'Type 2 Diabetes', 'since': 'Since 2019', 'status': 'Managed'},
      {
        'name': 'Hypertension (Stage 1)',
        'since': 'Since 2021',
        'status': 'Monitoring'
      },
    ];

    return Column(
      children: conditions.map((c) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.medical_information_rounded,
                    color: Colors.orange, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c['name']!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
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

  Widget _buildRecentVisits(BuildContext context, bool isDark) {
    final visits = [
      {
        'date': 'Feb 14, 2026',
        'type': 'Field Visit',
        'by': 'ANM Priya Sharma',
        'notes': 'BP check, medication review'
      },
      {
        'date': 'Jan 28, 2026',
        'type': 'Site Visit',
        'by': 'Dr. James Chen',
        'notes': 'Quarterly diabetes checkup'
      },
      {
        'date': 'Jan 10, 2026',
        'type': 'Lab',
        'by': 'SMC Diagnostics',
        'notes': 'HbA1c test, lipid profile'
      },
    ];

    return Column(
      children: visits.map((v) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.event_rounded,
                    color: Colors.blue, size: 18),
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
                                fontWeight: FontWeight.bold, fontSize: 13)),
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

  Widget _buildMedications(BuildContext context, bool isDark) {
    final meds = [
      {
        'name': 'Metformin 500mg',
        'dosage': '1 tab twice daily',
        'color': Colors.blue
      },
      {
        'name': 'Amlodipine 5mg',
        'dosage': '1 tab once daily (morning)',
        'color': Colors.red
      },
      {
        'name': 'Vitamin D3 2000IU',
        'dosage': '1 tab daily',
        'color': Colors.orange
      },
    ];

    return Column(
      children: meds.map((m) {
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(Icons.medication_rounded,
                  size: 18, color: m['color'] as Color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m['name'] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(m['dosage'] as String,
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAllergies(BuildContext context, bool isDark) {
    final allergies = ['Penicillin', 'Sulfa Drugs'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allergies.map((a) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.red, size: 14),
              const SizedBox(width: 4),
              Text(a,
                  style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 12)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
