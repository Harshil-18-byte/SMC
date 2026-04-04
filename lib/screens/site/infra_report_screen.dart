import 'package:flutter/material.dart';
import 'package:smc/core/widgets/smc_back_button.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/core/localization/app_localizations.dart';

/// Infrastructure Report Screen
/// Provides detailed infra reports: maintenance logs, audit results, compliance
class InfraReportScreen extends StatelessWidget {
  const InfraReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: SMCAppBar(
        title: AppLocalizations.of(context).translate('infra_report'),
        actions: const [ThemeSwitcher(), SizedBox(width: 8)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compliance Score
            _buildComplianceCard(context, isDark),
            const SizedBox(height: 20),

            _buildSectionTitle(context, 'RECENT AUDITS'),
            const SizedBox(height: 12),
            ..._buildAuditList(context, isDark),

            const SizedBox(height: 20),
            _buildSectionTitle(context, 'MAINTENANCE LOGS'),
            const SizedBox(height: 12),
            ..._buildMaintenanceLogs(context, isDark),

            const SizedBox(height: 20),
            _buildSectionTitle(context, 'INFRASTRUCTURE ALERTS'),
            const SizedBox(height: 12),
            ..._buildAlerts(context, isDark),

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

  Widget _buildComplianceCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF137fec),
            const Color(0xFF137fec).withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF137fec).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
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
                child: const Icon(Icons.verified_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Infrastructure Compliance',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('87',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w800)),
              Text('/100',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Last Audit',
                      style: TextStyle(color: Colors.white54, fontSize: 11)),
                  Text('Feb 12, 2026',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.87,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAuditList(BuildContext context, bool isDark) {
    final audits = [
      {
        'title': 'Fire Safety Audit',
        'date': 'Feb 12, 2026',
        'status': 'Passed',
        'icon': Icons.local_fire_department_rounded,
        'color': Colors.green
      },
      {
        'title': 'Biomedical Waste Audit',
        'date': 'Jan 28, 2026',
        'status': 'Passed',
        'icon': Icons.recycling_rounded,
        'color': Colors.green
      },
      {
        'title': 'NABH Accreditation Review',
        'date': 'Jan 15, 2026',
        'status': 'In Progress',
        'icon': Icons.workspace_premium_rounded,
        'color': Colors.orange
      },
      {
        'title': 'Electrical Safety Check',
        'date': 'Jan 05, 2026',
        'status': 'Passed',
        'icon': Icons.electric_bolt_rounded,
        'color': Colors.green
      },
      {
        'title': 'Water Quality Testing',
        'date': 'Dec 20, 2025',
        'status': 'Minor Issue',
        'icon': Icons.water_drop_rounded,
        'color': Colors.orange
      },
    ];

    return audits.map((audit) {
      final statusColor = audit['color'] as Color;
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(audit['icon'] as IconData, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(audit['title'] as String,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(audit['date'] as String,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                audit['status'] as String,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildMaintenanceLogs(BuildContext context, bool isDark) {
    final logs = [
      {
        'task': 'OT Sterilization System Serviced',
        'date': 'Feb 15',
        'by': 'BioMed Team',
        'icon': Icons.cleaning_services_rounded
      },
      {
        'task': 'DG Set #2 Oil Change',
        'date': 'Feb 10',
        'by': 'Electrical Team',
        'icon': Icons.settings_rounded
      },
      {
        'task': 'HVAC Filter Replacement',
        'date': 'Feb 08',
        'by': 'Maintenance',
        'icon': Icons.air_rounded
      },
      {
        'task': 'MRI Calibration',
        'date': 'Feb 05',
        'by': 'Vendor (Siemens)',
        'icon': Icons.tune_rounded
      },
      {
        'task': 'UPS Battery Check',
        'date': 'Feb 01',
        'by': 'Electrical Team',
        'icon': Icons.battery_charging_full_rounded
      },
    ];

    return logs.map((log) {
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
            Icon(log['icon'] as IconData, size: 18, color: Theme.of(context).primaryColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log['task'] as String,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('${log['date']} • ${log['by']}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildAlerts(BuildContext context, bool isDark) {
    final alerts = [
      {
        'title': 'MRI Under Maintenance',
        'desc': 'Expected back online by Feb 20',
        'severity': 'warning'
      },
      {
        'title': 'Elevator #3 Repair',
        'desc': 'Scheduled for Feb 22',
        'severity': 'info'
      },
    ];

    return alerts.map((alert) {
      final isWarning = alert['severity'] == 'warning';
      final color = isWarning ? Colors.orange : Theme.of(context).primaryColor;
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(
                isWarning
                    ? Icons.warning_amber_rounded
                    : Icons.info_outline_rounded,
                color: color,
                size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert['title']!,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: color)),
                  Text(alert['desc']!,
                      style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
