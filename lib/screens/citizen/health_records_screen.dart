import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smc/core/services/user_service.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:smc/core/services/pdf_service.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/core/localization/app_localizations.dart';
import 'package:smc/core/widgets/smc_back_button.dart';

class HealthRecordsScreen extends StatelessWidget {
  const HealthRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Current user context
    final userProvider = Provider.of<UserProvider>(context);
    final uid = userProvider.currentUser?.id ?? 'cit_001';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const SMCBackButton(),
        title: Text(AppLocalizations.of(context).translate('health_records')),
        actions: const [ThemeSwitcher(), SizedBox(width: 8)],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().streamCollection(
          collection: 'health_records',
          orderBy: 'date',
          descending: true,
        ),
        builder: (context, snapshot) {
          // DETECT EMPTY STATE AND APPLY FALLBACK
          final rawRecords = snapshot.data ?? [];
          final records = rawRecords.isEmpty
              ? [
                  {
                    'id': 'r1',
                    'title': 'General Wellness Checkup',
                    'provider': 'City General Hospital',
                    'date': DateTime.now()
                        .subtract(const Duration(days: 30))
                        .toIso8601String(),
                    'type': 'visit',
                    'description':
                        'Regular quarterly checkup. All vital signs normal.',
                    'details': {
                      'Weight': '72kg',
                      'BP': '120/80',
                      'Heart Rate': '72 bpm'
                    }
                  },
                  {
                    'id': 'r2',
                    'title': 'Lipid Profile Report',
                    'provider': 'SMC Diagnostics',
                    'date': DateTime.now()
                        .subtract(const Duration(days: 15))
                        .toIso8601String(),
                    'type': 'lab_report',
                    'description':
                        'Blood analysis results for cholesterol levels.',
                    'details': {
                      'Total Cholesterol': '180 mg/dL',
                      'HDL': '50 mg/dL',
                      'LDL': '110 mg/dL'
                    }
                  },
                  {
                    'id': 'r3',
                    'title': 'Vitamin D Supplement',
                    'provider': 'Dr. Sarah Wilson',
                    'date': DateTime.now()
                        .subtract(const Duration(days: 10))
                        .toIso8601String(),
                    'type': 'prescription',
                    'description': 'Prescribed 2000 IU daily for 3 months.',
                    'details': {'Dosage': '1 tablet/day', 'Duration': '90 Days'}
                  },
                ]
              : rawRecords
                  .where((r) => r['citizenId'] == uid || r['citizenId'] == null)
                  .toList();

          if (records.isEmpty &&
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (records.isEmpty) {
            return Center(
                child: Text(AppLocalizations.of(context).noDataAvailable));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return _buildRecordCard(context, record, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(
      BuildContext context, Map<String, dynamic> record, bool isDark) {
    final date = record['date'] != null
        ? DateTime.parse(record['date'])
        : DateTime.now();
    final type = record['type'] ?? 'document';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getTypeColor(type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_getTypeIcon(type), color: _getTypeColor(type)),
        ),
        title: Text(
          record['title'] ?? 'Medical Record',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '${record['provider'] ?? 'Unknown'} • ${DateFormat('MMM dd, yyyy').format(date)}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record['description'] ?? 'No description provided.',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                if (record['details'] != null) ...[
                  const Text('DETAILS',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  const SizedBox(height: 4),
                  ...(record['details'] as Map<String, dynamic>)
                      .entries
                      .map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Text('${e.key}: ',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                                Text('${e.value}',
                                    style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          )),
                ],
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Generating PDF Report...')),
                      );
                      await PdfService.generateMedicalRecordPdf(
                        citizenName:
                            'Mahesh Shinde', // Hardcoded for demo/user context
                        title: record['title'] ?? 'Health Report',
                        provider: record['provider'] ?? 'SMC Health Network',
                        date: DateFormat('MMM dd, yyyy').format(date),
                        type: type,
                        description: record['description'] ?? '',
                        details: record['details'] ?? {},
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: Text(
                        AppLocalizations.of(context).translate('download_pdf')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _getTypeColor(type).withValues(alpha: 0.1),
                      foregroundColor: _getTypeColor(type),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'vaccination':
        return Colors.purple;
      case 'prescription':
        return Colors.green;
      case 'lab_report':
        return Colors.blue;
      case 'visit':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'vaccination':
        return Icons.vaccines_rounded;
      case 'prescription':
        return Icons.medication_rounded;
      case 'lab_report':
        return Icons.analytics_rounded;
      case 'visit':
        return Icons.local_hospital_rounded;
      default:
        return Icons.description_rounded;
    }
  }
}
