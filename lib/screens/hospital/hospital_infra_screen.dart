import 'package:flutter/material.dart';
import 'package:smc/core/widgets/smc_back_button.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/core/localization/app_localizations.dart';

/// Hospital Infrastructure Screen
/// Shows infrastructure overview: equipment, departments, ICU, OT status
class HospitalInfraScreen extends StatelessWidget {
  const HospitalInfraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: SMCAppBar(
        title: AppLocalizations.of(context).translate('hospital_infra'),
        actions: const [ThemeSwitcher(), SizedBox(width: 8)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Stats Row
            _buildSectionTitle(context, 'INFRASTRUCTURE OVERVIEW'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildStatTile(context, isDark, 'Total Beds', '320',
                        Icons.bed_rounded, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildStatTile(context, isDark, 'ICU Units', '24',
                        Icons.monitor_heart_rounded, Colors.red)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildStatTile(context, isDark, 'OT Rooms', '8',
                        Icons.medical_services_rounded, Colors.orange)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildStatTile(context, isDark, 'Ventilators', '18',
                        Icons.air_rounded, Colors.teal)),
              ],
            ),
            const SizedBox(height: 24),

            // Departments
            _buildSectionTitle(context, 'DEPARTMENTS'),
            const SizedBox(height: 12),
            ..._buildDepartmentCards(context, isDark),

            const SizedBox(height: 24),

            // Equipment Status
            _buildSectionTitle(context, 'CRITICAL EQUIPMENT STATUS'),
            const SizedBox(height: 12),
            _buildEquipmentList(context, isDark),

            const SizedBox(height: 24),

            // Utility Status
            _buildSectionTitle(context, 'UTILITIES'),
            const SizedBox(height: 12),
            _buildUtilityCard(
                context,
                isDark,
                'Power Supply',
                'Grid + 2 DG Sets',
                Icons.electric_bolt_rounded,
                Colors.amber,
                0.98),
            const SizedBox(height: 8),
            _buildUtilityCard(
                context,
                isDark,
                'Water Supply',
                'Municipal + Borewell',
                Icons.water_drop_rounded,
                Colors.blue,
                0.85),
            const SizedBox(height: 8),
            _buildUtilityCard(context, isDark, 'Oxygen Pipeline',
                'Central Supply Active', Icons.air_rounded, Colors.cyan, 0.92),
            const SizedBox(height: 8),
            _buildUtilityCard(
                context,
                isDark,
                'Waste Management',
                'Biomedical + General',
                Icons.delete_sweep_rounded,
                Colors.green,
                0.78),

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

  Widget _buildStatTile(BuildContext context, bool isDark, String label,
      String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF111418),
              )),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              )),
        ],
      ),
    );
  }

  List<Widget> _buildDepartmentCards(BuildContext context, bool isDark) {
    final departments = [
      {
        'name': 'General Medicine',
        'beds': '80',
        'staff': '24',
        'color': Colors.blue
      },
      {'name': 'Surgery', 'beds': '40', 'staff': '16', 'color': Colors.red},
      {
        'name': 'Pediatrics',
        'beds': '30',
        'staff': '12',
        'color': Colors.green
      },
      {
        'name': 'Orthopedics',
        'beds': '25',
        'staff': '10',
        'color': Colors.orange
      },
      {'name': 'Gynecology', 'beds': '35', 'staff': '14', 'color': Colors.pink},
      {
        'name': 'Ophthalmology',
        'beds': '15',
        'staff': '8',
        'color': Colors.purple
      },
    ];

    return departments.map((dept) {
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (dept['color'] as Color).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.local_hospital_rounded,
                  color: dept['color'] as Color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dept['name'] as String,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('${dept['beds']} beds • ${dept['staff']} staff',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey[400], size: 20),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildEquipmentList(BuildContext context, bool isDark) {
    final equipment = [
      {
        'name': 'X-Ray Machine',
        'status': 'Operational',
        'icon': Icons.image_rounded,
        'ok': true
      },
      {
        'name': 'CT Scanner',
        'status': 'Operational',
        'icon': Icons.scanner_rounded,
        'ok': true
      },
      {
        'name': 'MRI Machine',
        'status': 'Under Maintenance',
        'icon': Icons.biotech_rounded,
        'ok': false
      },
      {
        'name': 'Ultrasonography',
        'status': 'Operational',
        'icon': Icons.monitor_rounded,
        'ok': true
      },
      {
        'name': 'ECG Machine',
        'status': 'Operational',
        'icon': Icons.monitor_heart_rounded,
        'ok': true
      },
      {
        'name': 'Dialysis Unit (4)',
        'status': '3 Operational',
        'icon': Icons.bloodtype_rounded,
        'ok': true
      },
    ];

    return Column(
      children: equipment.map((eq) {
        final isOk = eq['ok'] as bool;
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
              Icon(eq['icon'] as IconData,
                  size: 20, color: isOk ? Colors.blue : Colors.orange),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(eq['name'] as String,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isOk
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  eq['status'] as String,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isOk ? Colors.green : Colors.orange),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUtilityCard(BuildContext context, bool isDark, String name,
      String detail, IconData icon, Color color, double level) {
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
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(detail,
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ),
              Text('${(level * 100).toInt()}%',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: color, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: level,
              minHeight: 6,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
