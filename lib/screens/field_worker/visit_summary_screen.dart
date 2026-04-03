import 'package:flutter/material.dart';
import 'package:smc/core/widgets/smc_back_button.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/core/localization/app_localizations.dart';

/// Visit Summary Screen
/// Shows a detailed summary of a specific field worker visit
class VisitSummaryScreen extends StatelessWidget {
  final String? visitId;
  final Map<String, dynamic>? visitData;

  const VisitSummaryScreen({super.key, this.visitId, this.visitData});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: SMCAppBar(
        title: AppLocalizations.of(context).translate('visit_summary'),
        actions: const [ThemeSwitcher(), SizedBox(width: 8)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visit Header with status
            _buildVisitHeader(context, isDark),
            const SizedBox(height: 20),

            // Location Details
            _buildSectionTitle(context, 'LOCATION'),
            const SizedBox(height: 12),
            _buildLocationCard(context, isDark),
            const SizedBox(height: 20),

            // Members Screened
            _buildSectionTitle(context, 'MEMBERS SCREENED'),
            const SizedBox(height: 12),
            ..._buildMembersScreened(context, isDark),
            const SizedBox(height: 20),

            // Symptoms Observed
            _buildSectionTitle(context, 'SYMPTOMS OBSERVED'),
            const SizedBox(height: 12),
            _buildSymptomChips(context, isDark),
            const SizedBox(height: 20),

            // Vitals Recorded
            _buildSectionTitle(context, 'VITALS RECORDED'),
            const SizedBox(height: 12),
            _buildVitalsTable(context, isDark),
            const SizedBox(height: 20),

            // Actions Taken
            _buildSectionTitle(context, 'ACTIONS TAKEN'),
            const SizedBox(height: 12),
            _buildActionsList(context, isDark),
            const SizedBox(height: 20),

            // Notes
            _buildSectionTitle(context, 'FIELD NOTES'),
            const SizedBox(height: 12),
            _buildNotesCard(context, isDark),

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

  Widget _buildVisitHeader(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF137fec), Color(0xFF0057B8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.assignment_turned_in_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Household Visit #VR-2026-0145',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    Text('Feb 14, 2026 • 10:30 AM',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('COMPLETED',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
              const SizedBox(width: 10),
              const Text('Type: Routine Check',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              const Spacer(),
              const Text('Duration: 25 min',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: Colors.blue, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                  child: Text('Ward 24, Mangalwar Peth, Bharat',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.home_rounded, color: Colors.grey[500], size: 18),
              const SizedBox(width: 10),
              const Expanded(
                  child: Text('Household: Patil Family (HH-1024)',
                      style: TextStyle(fontSize: 12))),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.pin_drop_rounded, color: Colors.grey[500], size: 18),
              const SizedBox(width: 10),
              Text('Lat: 17.6599° N, Lon: 75.9064° E',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMembersScreened(BuildContext context, bool isDark) {
    final members = [
      {
        'name': 'Suresh Patil',
        'age': '40',
        'gender': 'Male',
        'status': 'Healthy'
      },
      {
        'name': 'Sunita Patil',
        'age': '36',
        'gender': 'Female',
        'status': 'Anemia'
      },
      {
        'name': 'Rahul Patil',
        'age': '12',
        'gender': 'Male',
        'status': 'Healthy'
      },
      {
        'name': 'Sita Patil',
        'age': '70',
        'gender': 'Female',
        'status': 'Hypertension'
      },
    ];

    return members.map((m) {
      final hasIssue = m['status'] != 'Healthy';
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: hasIssue
                  ? Colors.orange.withValues(alpha: 0.1)
                  : Colors.green.withValues(alpha: 0.1),
              child: Text(m['name']![0],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: hasIssue ? Colors.orange : Colors.green,
                  )),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m['name']!,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('${m['age']}y • ${m['gender']}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: hasIssue
                    ? Colors.orange.withValues(alpha: 0.1)
                    : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(m['status']!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: hasIssue ? Colors.orange : Colors.green,
                  )),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildSymptomChips(BuildContext context, bool isDark) {
    final symptoms = ['Fatigue', 'Dizziness', 'Joint Pain', 'Low Appetite'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: symptoms.map((s) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
          ),
          child: Text(s,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange)),
        );
      }).toList(),
    );
  }

  Widget _buildVitalsTable(BuildContext context, bool isDark) {
    final vitals = [
      {
        'member': 'Suresh Patil',
        'bp': '128/82',
        'hr': '76',
        'temp': '98.4',
        'spo2': '97'
      },
      {
        'member': 'Sunita Patil',
        'bp': '110/70',
        'hr': '82',
        'temp': '98.6',
        'spo2': '96'
      },
      {
        'member': 'Sita Patil',
        'bp': '148/92',
        'hr': '70',
        'temp': '98.2',
        'spo2': '95'
      },
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1.2),
            2: FlexColumnWidth(0.8),
            3: FlexColumnWidth(0.8),
            4: FlexColumnWidth(0.8),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFF1F5F9),
              ),
              children: const [
                Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Name',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11))),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('BP',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11))),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('HR',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11))),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Temp',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11))),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('SpO2',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11))),
              ],
            ),
            ...vitals.map((v) => TableRow(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.02)
                        : Colors.white,
                  ),
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(v['member']!,
                            style: const TextStyle(fontSize: 11))),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(v['bp']!,
                            style: const TextStyle(fontSize: 11))),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(v['hr']!,
                            style: const TextStyle(fontSize: 11))),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(v['temp']!,
                            style: const TextStyle(fontSize: 11))),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(v['spo2']!,
                            style: const TextStyle(fontSize: 11))),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsList(BuildContext context, bool isDark) {
    final actions = [
      {
        'action': 'Iron tablets distributed to Sunita Patil',
        'icon': Icons.medication_rounded
      },
      {
        'action': 'BP medication review recommended for Sita Patil',
        'icon': Icons.medical_services_rounded
      },
      {
        'action': 'Nutritional counseling provided',
        'icon': Icons.restaurant_rounded
      },
      {
        'action': 'Follow-up visit scheduled for Feb 28',
        'icon': Icons.event_rounded
      },
    ];

    return Column(
      children: actions.map((a) {
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
              Icon(a['icon'] as IconData, size: 18, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(a['action'] as String,
                      style: const TextStyle(fontSize: 13))),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFE2D9A8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_alt_rounded, size: 16, color: Colors.amber[700]),
              const SizedBox(width: 6),
              Text('Field Worker Notes',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.amber[800])),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Visited Patil household for routine NCD screening. Sita Patil\'s BP continues to be elevated - recommended physician consultation at Civil Hospital. '
            'Sunita Patil shows signs of iron deficiency anemia, distributed 30-day supply of iron tablets. '
            'Overall family hygiene maintained. Drinking water source: borewell (tested OK).',
            style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark ? Colors.grey[300] : Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}
