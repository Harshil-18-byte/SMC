import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smc/core/theme/universal_theme.dart';
import 'package:smc/data/models/asset_medication.dart';
import 'package:smc/data/services/firestore_service.dart';

/// Maintenance Reminders & Tactical Scheduling
/// Replaces MedicationRemindersScreen with Industrial Field Task Tracking.
class MaintenanceRemindersScreen extends StatefulWidget {
  const MaintenanceRemindersScreen({super.key});

  @override
  State<MaintenanceRemindersScreen> createState() =>
      _MaintenanceRemindersScreenState();
}

class _MaintenanceRemindersScreenState extends State<MaintenanceRemindersScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String _engineerId = 'engineer_01'; // Demo ID

  List<AssetMedication> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    try {
      final data = await _firestoreService.getCollection(
        collection: 'engineers/$_engineerId/reminders',
      );

      if (mounted) {
        setState(() {
          _reminders = data
              .map((m) => AssetMedication.fromMap(m, m['id'] as String))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading reminders: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          'MAINTENANCE TIMELINE',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded),
            onPressed: () {}, // Planned for Phase 3
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(UniversalTheme.getSpacing(context, SpacingSize.md)),
              children: [
                if (_reminders.isNotEmpty) ...[
                  _buildSectionHeader('UPCOMING SHIFTS / TASKS', isDark),
                  const SizedBox(height: 12),
                  ..._reminders
                      .where((m) => m.frequency == MedicationFrequency.daily)
                      .expand((m) => m.reminderTimes.map((t) => _buildTaskItem(m, t, isDark))),
                  const SizedBox(height: 24),
                ],
                _buildSectionHeader('ASSET CONSUMABLES / REAGENTS', isDark),
                const SizedBox(height: 12),
                if (_reminders.isEmpty)
                  const Center(child: Text('No active maintenance cycles deployment.', style: TextStyle(color: Colors.grey)))
                else
                  ..._reminders.map((r) => _buildResourceCard(r, isDark)),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: Theme.of(context).primaryColor[400],
      ),
    );
  }

  Widget _buildTaskItem(AssetMedication task, TimeOfDay time, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _formatTime(time),
              style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor, fontSize: 12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                Text(task.instructions, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildResourceCard(AssetMedication resource, bool isDark) {
    final progress = resource.progress;
    final color = resource.isLow ? Colors.red : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(resource.name.toUpperCase(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              Icon(Icons.inventory_2_rounded, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white10,
            color: color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(progress * 100).toInt()}% Remaining', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
              Text('RESERVE: ${resource.dosesLeft} UNITS', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute $period";
  }
}
